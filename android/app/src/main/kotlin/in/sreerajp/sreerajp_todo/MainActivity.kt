package `in`.sreerajp.sreerajp_todo

import android.app.Activity
import android.app.KeyguardManager
import android.content.Context
import android.content.Intent
import android.Manifest
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import android.speech.RecognitionListener
import android.speech.RecognizerIntent
import android.speech.SpeechRecognizer
import android.util.Base64
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.security.KeyStore
import java.security.SecureRandom
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import javax.crypto.spec.GCMParameterSpec

class MainActivity : FlutterActivity() {
    private val CHANNEL = "in.sreerajp.todo/database_key"
    private val SCREEN_WAKE_CHANNEL = "in.sreerajp.todo/screen_wake"
    private val APP_LOCK_CHANNEL = "in.sreerajp.todo/app_lock"
    private val SPEECH_CHANNEL = "in.sreerajp.todo/speech"
    private val SPEECH_EVENT_CHANNEL = "in.sreerajp.todo/speech_events"
    private val KEY_ALIAS = "SreerajpTodoMasterKey"
    private val PREFS_NAME = "sreerajp_todo_secure_prefs"
    private val PREF_KEY_DATA = "encrypted_db_key"
    private val PREF_KEY_IV = "encrypted_db_key_iv"
    private val DEVICE_CREDENTIAL_REQUEST = 4711
    private val MICROPHONE_REQUEST = 4712

    // Held while the device unlock screen is in front of us, so its result can
    // be handed back to the Dart side that asked for it.
    private var pendingUnlockResult: MethodChannel.Result? = null

    // Held while the microphone permission dialog is up.
    private var pendingMicrophoneResult: MethodChannel.Result? = null

    // The on-device recogniser, alive only while the voice sheet is listening.
    private var speechRecognizer: SpeechRecognizer? = null

    // Where heard words are pushed back to Dart.
    private var speechEvents: EventChannel.EventSink? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getOrCreateDatabaseKey" -> {
                    try {
                        val hexKey = getOrCreateDatabaseKey()
                        result.success(hexKey)
                    } catch (e: Exception) {
                        result.error("KEYSTORE_ERROR", e.message, null)
                    }
                }
                // Replaces the stored key after the database has been
                // rekeyed. Returns false rather than throwing, so the caller
                // can put the database back on its old key.
                "storeDatabaseKey" -> {
                    try {
                        val keyHex = call.argument<String>("keyHex")
                        if (keyHex == null || keyHex.length != 64) {
                            result.error("BAD_ARGUMENT", "keyHex must be 64 characters", null)
                        } else {
                            storeDatabaseKey(keyHex)
                            result.success(true)
                        }
                    } catch (e: Exception) {
                        result.success(false)
                    }
                }
                // Wraps a short secret with the same Keystore master key the
                // database key uses, so the backup passphrase can be kept
                // without ever writing it in plain text.
                "encryptSecret" -> {
                    try {
                        val plainText = call.argument<String>("plainText")
                        if (plainText == null) {
                            result.error("BAD_ARGUMENT", "plainText is required", null)
                        } else {
                            result.success(encryptSecret(plainText))
                        }
                    } catch (e: Exception) {
                        result.error("KEYSTORE_ERROR", e.message, null)
                    }
                }
                "decryptSecret" -> {
                    try {
                        val cipherText = call.argument<String>("cipherText")
                        if (cipherText == null) {
                            result.error("BAD_ARGUMENT", "cipherText is required", null)
                        } else {
                            result.success(decryptSecret(cipherText))
                        }
                    } catch (e: Exception) {
                        result.error("KEYSTORE_ERROR", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }

        // Keeps the screen on while a time segment is running, when the user
        // has turned that setting on. A small channel is used instead of a
        // package so the audited dependency list stays unchanged.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SCREEN_WAKE_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "setKeepAwake") {
                val enabled = call.argument<Boolean>("enabled") ?: false
                runOnUiThread {
                    if (enabled) {
                        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                    } else {
                        window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                    }
                }
                result.success(null)
            } else {
                result.notImplemented()
            }
        }

        // App lock helpers. The device unlock screen is used instead of a
        // biometric library, so no new dependency is added.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, APP_LOCK_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                // Keeps the recent-apps preview and screenshots blank while the
                // app holds private notes.
                "setSecureFlag" -> {
                    val enabled = call.argument<Boolean>("enabled") ?: false
                    runOnUiThread {
                        if (enabled) {
                            window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
                        } else {
                            window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                        }
                    }
                    result.success(null)
                }
                "isDeviceCredentialAvailable" -> {
                    result.success(isDeviceCredentialAvailable())
                }
                "authenticateWithDeviceCredential" -> {
                    if (pendingUnlockResult != null) {
                        result.error("IN_PROGRESS", "An unlock is already running", null)
                    } else if (!isDeviceCredentialAvailable()) {
                        result.error("UNAVAILABLE", "No device lock is set up", null)
                    } else {
                        val title = call.argument<String>("title") ?: ""
                        val description = call.argument<String>("description") ?: ""
                        val keyguardManager =
                            getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager
                        @Suppress("DEPRECATION")
                        val intent =
                            keyguardManager.createConfirmDeviceCredentialIntent(title, description)
                        if (intent == null) {
                            result.error("UNAVAILABLE", "No device lock is set up", null)
                        } else {
                            pendingUnlockResult = result
                            @Suppress("DEPRECATION")
                            startActivityForResult(intent, DEVICE_CREDENTIAL_REQUEST)
                        }
                    }
                }
                else -> result.notImplemented()
            }
        }

        // On-device speech recognition for the voice task sheet.
        //
        // The recogniser is a separate app on the device, so the offline
        // promise is kept in two ways at once. This app declares no INTERNET
        // permission, so nothing here can reach the network. And the recogniser
        // is always asked for its on-device engine: from API 33 through
        // createOnDeviceSpeechRecognizer, and below that through
        // EXTRA_PREFER_OFFLINE. A device that cannot promise that is reported
        // back as "no_offline", and the Dart side falls back to typing rather
        // than letting anything go online behind the back of the user.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SPEECH_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "check" -> result.success(checkSpeechReadiness())
                "requestPermission" -> {
                    if (pendingMicrophoneResult != null) {
                        result.error("IN_PROGRESS", "A permission request is already running", null)
                    } else if (hasMicrophonePermission()) {
                        result.success(true)
                    } else {
                        pendingMicrophoneResult = result
                        requestPermissions(
                            arrayOf(Manifest.permission.RECORD_AUDIO),
                            MICROPHONE_REQUEST
                        )
                    }
                }
                "start" -> {
                    val locale = call.argument<String>("locale") ?: "en-IN"
                    runOnUiThread { startListening(locale) }
                    result.success(null)
                }
                "stop" -> {
                    runOnUiThread { speechRecognizer?.stopListening() }
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, SPEECH_EVENT_CHANNEL)
            .setStreamHandler(
                object : EventChannel.StreamHandler {
                    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                        speechEvents = events
                    }

                    override fun onCancel(arguments: Any?) {
                        speechEvents = null
                    }
                }
            )
    }

    private fun hasMicrophonePermission(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) return true
        return checkSelfPermission(Manifest.permission.RECORD_AUDIO) ==
            PackageManager.PERMISSION_GRANTED
    }

    // Reports whether the voice sheet can listen, and why not when it cannot.
    private fun checkSpeechReadiness(): String {
        if (!SpeechRecognizer.isRecognitionAvailable(this)) return "no_recogniser"
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
            // EXTRA_PREFER_OFFLINE does not exist here, so staying offline
            // cannot be promised. Better to say so than to risk it.
            return "no_offline"
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
            !SpeechRecognizer.isOnDeviceRecognitionAvailable(this)
        ) {
            return "no_offline"
        }
        if (!hasMicrophonePermission()) return "no_permission"
        return "ready"
    }

    private fun startListening(localeTag: String) {
        if (!hasMicrophonePermission()) {
            sendSpeechError("permission")
            return
        }
        destroyRecognizer()

        val recognizer = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
            SpeechRecognizer.isOnDeviceRecognitionAvailable(this)
        ) {
            SpeechRecognizer.createOnDeviceSpeechRecognizer(this)
        } else {
            SpeechRecognizer.createSpeechRecognizer(this)
        }
        speechRecognizer = recognizer

        val intent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH).apply {
            putExtra(
                RecognizerIntent.EXTRA_LANGUAGE_MODEL,
                RecognizerIntent.LANGUAGE_MODEL_FREE_FORM
            )
            putExtra(RecognizerIntent.EXTRA_LANGUAGE, localeTag)
            putExtra(RecognizerIntent.EXTRA_PARTIAL_RESULTS, true)
            putExtra(RecognizerIntent.EXTRA_MAX_RESULTS, 1)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                putExtra(RecognizerIntent.EXTRA_PREFER_OFFLINE, true)
            }
        }

        recognizer.setRecognitionListener(object : RecognitionListener {
            override fun onReadyForSpeech(params: Bundle?) {}

            override fun onBeginningOfSpeech() {}

            override fun onRmsChanged(rmsdB: Float) {}

            override fun onBufferReceived(buffer: ByteArray?) {}

            override fun onEndOfSpeech() {}

            override fun onPartialResults(partialResults: Bundle?) {
                val text = firstMatch(partialResults) ?: return
                sendSpeechEvent("partial", text)
            }

            override fun onResults(results: Bundle?) {
                val text = firstMatch(results)
                if (text.isNullOrBlank()) {
                    sendSpeechError("no_match")
                } else {
                    sendSpeechEvent("result", text)
                }
                destroyRecognizer()
            }

            override fun onError(error: Int) {
                sendSpeechError(speechErrorCode(error))
                destroyRecognizer()
            }

            override fun onEvent(eventType: Int, params: Bundle?) {}
        })

        try {
            recognizer.startListening(intent)
        } catch (e: Exception) {
            sendSpeechError("unknown")
            destroyRecognizer()
        }
    }

    private fun firstMatch(bundle: Bundle?): String? =
        bundle?.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)?.firstOrNull()

    // Turns a recogniser error number into the short code Dart understands.
    //
    // A network error is deliberately reported as a missing offline language.
    // We asked for the on-device engine, so a recogniser reaching for the
    // network means it had no offline pack for that language. Telling the user
    // to install one is far more useful than "network error" in an app that
    // holds no network permission at all.
    private fun speechErrorCode(error: Int): String = when (error) {
        SpeechRecognizer.ERROR_INSUFFICIENT_PERMISSIONS -> "permission"
        SpeechRecognizer.ERROR_NO_MATCH,
        SpeechRecognizer.ERROR_SPEECH_TIMEOUT -> "no_match"
        SpeechRecognizer.ERROR_NETWORK,
        SpeechRecognizer.ERROR_NETWORK_TIMEOUT,
        SpeechRecognizer.ERROR_SERVER -> "no_offline_language"
        SpeechRecognizer.ERROR_RECOGNIZER_BUSY -> "busy"
        // ERROR_LANGUAGE_NOT_SUPPORTED (11) and ERROR_LANGUAGE_UNAVAILABLE (12)
        // arrived in API 33. Their numbers are used directly so this file still
        // compiles against an older compile SDK.
        11, 12 -> "no_offline_language"
        else -> "unknown"
    }

    private fun sendSpeechEvent(type: String, text: String) {
        runOnUiThread {
            speechEvents?.success(mapOf("type" to type, "text" to text))
        }
    }

    private fun sendSpeechError(code: String) {
        runOnUiThread {
            speechEvents?.success(mapOf("type" to "error", "code" to code))
        }
    }

    private fun destroyRecognizer() {
        speechRecognizer?.let {
            it.setRecognitionListener(null)
            it.destroy()
        }
        speechRecognizer = null
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == MICROPHONE_REQUEST) {
            val pending = pendingMicrophoneResult
            pendingMicrophoneResult = null
            val granted = grantResults.isNotEmpty() &&
                grantResults[0] == PackageManager.PERMISSION_GRANTED
            pending?.success(granted)
        }
    }

    @Deprecated("startActivityForResult is the only API available down to minSdk 21")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        @Suppress("DEPRECATION")
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == DEVICE_CREDENTIAL_REQUEST) {
            val pending = pendingUnlockResult
            pendingUnlockResult = null
            pending?.success(resultCode == Activity.RESULT_OK)
        }
    }

    private fun isDeviceCredentialAvailable(): Boolean {
        val keyguardManager =
            getSystemService(Context.KEYGUARD_SERVICE) as? KeyguardManager ?: return false
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            keyguardManager.isDeviceSecure
        } else {
            @Suppress("DEPRECATION")
            keyguardManager.isKeyguardSecure
        }
    }

    private fun encryptSecret(plainText: String): String {
        val masterKey = getOrCreateMasterKey()
        val cipher = Cipher.getInstance("AES/GCM/NoPadding")
        cipher.init(Cipher.ENCRYPT_MODE, masterKey)
        val iv = cipher.iv
        val encryptedBytes = cipher.doFinal(plainText.toByteArray(Charsets.UTF_8))
        // The IV is not secret, so it travels with the payload rather than
        // needing a second slot in preferences.
        return Base64.encodeToString(iv, Base64.NO_WRAP) + ":" +
            Base64.encodeToString(encryptedBytes, Base64.NO_WRAP)
    }

    private fun decryptSecret(cipherText: String): String? {
        val parts = cipherText.split(":")
        if (parts.size != 2) return null
        val iv = Base64.decode(parts[0], Base64.NO_WRAP)
        val encryptedBytes = Base64.decode(parts[1], Base64.NO_WRAP)
        val masterKey = getOrCreateMasterKey()
        val cipher = Cipher.getInstance("AES/GCM/NoPadding")
        cipher.init(Cipher.DECRYPT_MODE, masterKey, GCMParameterSpec(128, iv))
        return String(cipher.doFinal(encryptedBytes), Charsets.UTF_8)
    }

    override fun onDestroy() {
        // Never leave the flag set behind us, or the screen would stay on for
        // whatever the user opens next.
        window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        // The recogniser holds the microphone open, so it must never outlive
        // the screen that asked for it.
        destroyRecognizer()
        speechEvents = null
        super.onDestroy()
    }

    private fun getOrCreateDatabaseKey(): String {
        val prefs = applicationContext.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val storedData = prefs.getString(PREF_KEY_DATA, null)
        val storedIv = prefs.getString(PREF_KEY_IV, null)

        val masterKey = getOrCreateMasterKey()

        if (storedData != null && storedIv != null) {
            val encryptedBytes = Base64.decode(storedData, Base64.DEFAULT)
            val iv = Base64.decode(storedIv, Base64.DEFAULT)
            val cipher = Cipher.getInstance("AES/GCM/NoPadding")
            val spec = GCMParameterSpec(128, iv)
            cipher.init(Cipher.DECRYPT_MODE, masterKey, spec)
            val rawKeyBytes = cipher.doFinal(encryptedBytes)
            return bytesToHex(rawKeyBytes)
        } else {
            val rawKeyBytes = ByteArray(32)
            SecureRandom().nextBytes(rawKeyBytes)

            val cipher = Cipher.getInstance("AES/GCM/NoPadding")
            cipher.init(Cipher.ENCRYPT_MODE, masterKey)
            val iv = cipher.iv
            val encryptedBytes = cipher.doFinal(rawKeyBytes)

            prefs.edit()
                .putString(PREF_KEY_DATA, Base64.encodeToString(encryptedBytes, Base64.NO_WRAP))
                .putString(PREF_KEY_IV, Base64.encodeToString(iv, Base64.NO_WRAP))
                .apply()

            return bytesToHex(rawKeyBytes)
        }
    }

    private fun storeDatabaseKey(keyHex: String) {
        val rawKeyBytes = hexToBytes(keyHex)
        val masterKey = getOrCreateMasterKey()
        val cipher = Cipher.getInstance("AES/GCM/NoPadding")
        cipher.init(Cipher.ENCRYPT_MODE, masterKey)
        val iv = cipher.iv
        val encryptedBytes = cipher.doFinal(rawKeyBytes)

        val prefs = applicationContext.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        prefs.edit()
            .putString(PREF_KEY_DATA, Base64.encodeToString(encryptedBytes, Base64.NO_WRAP))
            .putString(PREF_KEY_IV, Base64.encodeToString(iv, Base64.NO_WRAP))
            .commit()
    }

    private fun hexToBytes(hex: String): ByteArray {
        val bytes = ByteArray(hex.length / 2)
        for (i in bytes.indices) {
            bytes[i] = hex.substring(i * 2, i * 2 + 2).toInt(16).toByte()
        }
        return bytes
    }

    private fun getOrCreateMasterKey(): SecretKey {
        val keyStore = KeyStore.getInstance("AndroidKeyStore")
        keyStore.load(null)
        if (!keyStore.containsAlias(KEY_ALIAS)) {
            val keyGenerator = KeyGenerator.getInstance(
                KeyProperties.KEY_ALGORITHM_AES,
                "AndroidKeyStore"
            )
            val builder = KeyGenParameterSpec.Builder(
                KEY_ALIAS,
                KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT
            )
                .setBlockModes(KeyProperties.BLOCK_MODE_GCM)
                .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE)
                .setKeySize(256)
            keyGenerator.init(builder.build())
            keyGenerator.generateKey()
        }
        val entry = keyStore.getEntry(KEY_ALIAS, null) as KeyStore.SecretKeyEntry
        return entry.secretKey
    }

    private fun bytesToHex(bytes: ByteArray): String {
        val sb = StringBuilder(bytes.size * 2)
        for (b in bytes) {
            sb.append(String.format("%02x", b.toInt() and 0xFF))
        }
        return sb.toString()
    }
}


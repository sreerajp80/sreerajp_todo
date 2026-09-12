package `in`.sreerajp.sreerajp_todo

import android.app.Activity
import android.app.KeyguardManager
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.Manifest
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.ColorMatrix
import android.graphics.ColorMatrixColorFilter
import android.graphics.Paint
import android.os.Build
import android.os.Bundle
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import android.speech.RecognitionListener
import android.speech.RecognizerIntent
import android.speech.SpeechRecognizer
import android.util.Base64
import android.view.WindowManager
import androidx.core.app.NotificationCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import com.googlecode.tesseract.android.TessBaseAPI
import java.io.File
import java.io.FileOutputStream
import java.security.KeyStore
import java.security.SecureRandom
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import javax.crypto.spec.GCMParameterSpec
import java.util.concurrent.Executors

class MainActivity : FlutterActivity() {
    private val CHANNEL = "in.sreerajp.todo/database_key"
    private val SCREEN_WAKE_CHANNEL = "in.sreerajp.todo/screen_wake"
    private val APP_LOCK_CHANNEL = "in.sreerajp.todo/app_lock"
    private val SPEECH_CHANNEL = "in.sreerajp.todo/speech"
    private val SPEECH_EVENT_CHANNEL = "in.sreerajp.todo/speech_events"
    private val RUNNING_NOTIFICATION_CHANNEL = "in.sreerajp.todo/running_notification"
    private val RUNNING_CHANNEL_ID = "running_todo_timer_channel"
    private val RUNNING_NOTIFICATION_ID = 1001
    private val PENDING_NOTIFICATION_CHANNEL = "in.sreerajp.todo/pending_notification"
    private val PENDING_CHANNEL_ID = "pending_todo_reminder_channel"
    private val PENDING_NOTIFICATION_ID = 1002
    private val OCR_CHANNEL = "in.sreerajp.todo/ocr"
    private val KEY_ALIAS = "SreerajpTodoMasterKey"
    private val PREFS_NAME = "sreerajp_todo_secure_prefs"
    private val PREF_KEY_DATA = "encrypted_db_key"
    private val PREF_KEY_IV = "encrypted_db_key_iv"
    private val DEVICE_CREDENTIAL_REQUEST = 4711
    private val MICROPHONE_REQUEST = 4712
    private val NOTIFICATION_PERMISSION_REQUEST = 4713

    // Held while the notification permission dialog is up.
    private var pendingNotificationPermissionResult: MethodChannel.Result? = null

    // Held while the device unlock screen is in front of us, so its result can
    // be handed back to the Dart side that asked for it.
    private var pendingUnlockResult: MethodChannel.Result? = null

    // Held while the microphone permission dialog is up.
    private var pendingMicrophoneResult: MethodChannel.Result? = null

    // The on-device recogniser, alive only while the voice sheet is listening.
    private var speechRecognizer: SpeechRecognizer? = null

    // Where heard words are pushed back to Dart.
    private var speechEvents: EventChannel.EventSink? = null

    // Recognition runs one job at a time. Tesseract holds a lot of native
    // memory, and two scans at once on a phone is a crash waiting to happen.
    private val ocrExecutor = Executors.newSingleThreadExecutor()

    /** Ids of recognition requests whose caller has gone away. */
    private val cancelledOcrRequests = mutableSetOf<Int>()
    private var activeTessApi: TessBaseAPI? = null
    private var activeTessLang: String? = null

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

        // On-device Tesseract OCR. Runs entirely offline against language models
        // copied out of the app's own assets.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, OCR_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "extractText" -> {
                    val imagePath = call.argument<String>("imagePath")
                    val language = call.argument<String>("language") ?: "eng+mal"
                    val requestId = call.argument<Int>("requestId") ?: 0
                    if (imagePath.isNullOrBlank()) {
                        result.error("invalid_args", "imagePath is required", null)
                        return@setMethodCallHandler
                    }
                    val imageFile = File(imagePath)
                    if (!imageFile.exists()) {
                        result.error("file_not_found", "Image file does not exist", null)
                        return@setMethodCallHandler
                    }

                    ocrExecutor.execute {
                        // Recognition runs one job at a time, so a job can sit in the
                        // queue long after the screen that asked for it has gone. Drop
                        // it instead of spending the CPU on an answer nobody wants.
                        if (isOcrRequestCancelled(requestId)) {
                            runOnUiThread { result.success("") }
                            return@execute
                        }
                        try {
                            ensureTessData(applicationContext)
                            val text = performTesseractOcr(applicationContext, imageFile, language)
                            runOnUiThread { result.success(text) }
                        } catch (e: Exception) {
                            runOnUiThread { result.error("ocr_failure", e.message, null) }
                        } finally {
                            clearCancelledOcrRequest(requestId)
                        }
                    }
                }
                "cancelOcr" -> {
                    val requestIds = call.argument<List<Int>>("requestIds")
                    if (requestIds == null) {
                        result.error("invalid_args", "requestIds is required", null)
                        return@setMethodCallHandler
                    }
                    synchronized(cancelledOcrRequests) {
                        cancelledOcrRequests.addAll(requestIds)
                    }
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }

        // Ongoing notification with live chronometer for active running tasks.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, RUNNING_NOTIFICATION_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "show" -> {
                    val title = call.argument<String>("title") ?: "Task"
                    val startTimeMillis = call.argument<Number>("startTimeMillis")?.toLong() ?: System.currentTimeMillis()
                    runOnUiThread {
                        showRunningNotification(title, startTimeMillis)
                    }
                    result.success(true)
                }
                "hide" -> {
                    runOnUiThread {
                        hideRunningNotification()
                    }
                    result.success(true)
                }
                "hasPermission" -> {
                    result.success(hasNotificationPermission())
                }
                "requestPermission" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                        if (hasNotificationPermission()) {
                            result.success(true)
                        } else if (pendingNotificationPermissionResult != null) {
                            result.error("IN_PROGRESS", "A notification permission request is already running", null)
                        } else {
                            pendingNotificationPermissionResult = result
                            requestPermissions(
                                arrayOf(Manifest.permission.POST_NOTIFICATIONS),
                                NOTIFICATION_PERMISSION_REQUEST
                            )
                        }
                    } else {
                        result.success(true)
                    }
                }
                else -> result.notImplemented()
            }
        }

        // Pending todo reminders status-bar notification and background alarm scheduling.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, PENDING_NOTIFICATION_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "show" -> {
                    val title = call.argument<String>("title") ?: "Pending Tasks Reminder"
                    val body = call.argument<String>("body") ?: "You have pending tasks remaining"
                    val count = call.argument<Int>("count") ?: 1
                    runOnUiThread {
                        showPendingNotification(title, body, count)
                    }
                    result.success(true)
                }
                "cancel" -> {
                    runOnUiThread {
                        cancelPendingNotification()
                    }
                    result.success(true)
                }
                "scheduleAlerts" -> {
                    val enabled = call.argument<Boolean>("enabled") ?: false
                    val dayStartEnabled = call.argument<Boolean>("dayStartEnabled") ?: true
                    val dayStartHour = call.argument<Int>("dayStartHour") ?: 9
                    val dayStartMinute = call.argument<Int>("dayStartMinute") ?: 0
                    val intervalMinutes = call.argument<Int>("intervalMinutes") ?: 120
                    val count = call.argument<Int>("count") ?: 1
                    AlarmReceiver.saveAndSchedule(
                        this,
                        enabled,
                        dayStartEnabled,
                        dayStartHour,
                        dayStartMinute,
                        intervalMinutes,
                        count
                    )
                    result.success(true)
                }
                "cancelScheduledAlerts" -> {
                    AlarmReceiver.cancelAlarm(this)
                    result.success(true)
                }
                "hasPermission" -> {
                    result.success(hasNotificationPermission())
                }
                "requestPermission" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                        if (hasNotificationPermission()) {
                            result.success(true)
                        } else if (pendingNotificationPermissionResult != null) {
                            result.error("IN_PROGRESS", "A notification permission request is already running", null)
                        } else {
                            pendingNotificationPermissionResult = result
                            requestPermissions(
                                arrayOf(Manifest.permission.POST_NOTIFICATIONS),
                                NOTIFICATION_PERMISSION_REQUEST
                            )
                        }
                    } else {
                        result.success(true)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun hasMicrophonePermission(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) return true
        return checkSelfPermission(Manifest.permission.RECORD_AUDIO) ==
            PackageManager.PERMISSION_GRANTED
    }

    // Reports whether the voice sheet can listen, and why not when it cannot.
    private fun checkSpeechReadiness(): String {
        if (!SpeechRecognizer.isRecognitionAvailable(this)) return "no_recogniser"
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
            // Below Android 13 there is no way to pin an on-device recogniser.
            // EXTRA_PREFER_OFFLINE is only a hint, so a system speech service
            // with no offline model but a working connection can still send the
            // audio to a server and return a normal result. Refuse instead of
            // risking that: the app promises to stay offline.
            return "no_offline"
        }
        if (!SpeechRecognizer.isOnDeviceRecognitionAvailable(this)) {
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
        } else if (requestCode == NOTIFICATION_PERMISSION_REQUEST) {
            val pending = pendingNotificationPermissionResult
            pendingNotificationPermissionResult = null
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
        // Tesseract holds native memory the garbage collector cannot see,
        // so it must be handed back explicitly.
        activeTessApi?.recycle()
        activeTessApi = null
        ocrExecutor.shutdown()
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

    private fun ensureNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                RUNNING_CHANNEL_ID,
                "Active Task Timer",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Shows live ongoing timer for currently active task"
                setShowBadge(false)
                enableVibration(false)
                setSound(null, null)
            }
            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager
            notificationManager?.createNotificationChannel(channel)
        }
    }

    private fun showRunningNotification(title: String, startTimeMillis: Long) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            if (checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED) {
                return
            }
        }
        ensureNotificationChannel()

        val launchIntent = packageManager.getLaunchIntentForPackage(packageName) ?: Intent(this, MainActivity::class.java)
        launchIntent.flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP

        val pendingIntentFlags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }

        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            launchIntent,
            pendingIntentFlags
        )

        val builder = NotificationCompat.Builder(this, RUNNING_CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle(title)
            .setContentText("Time tracking in progress")
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setShowWhen(true)
            .setWhen(startTimeMillis)
            .setUsesChronometer(true)
            .setContentIntent(pendingIntent)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setCategory(NotificationCompat.CATEGORY_PROGRESS)

        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager
        notificationManager?.notify(RUNNING_NOTIFICATION_ID, builder.build())
    }

    private fun hideRunningNotification() {
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager
        notificationManager?.cancel(RUNNING_NOTIFICATION_ID)
    }

    private fun ensurePendingNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                PENDING_CHANNEL_ID,
                "Pending Task Reminders",
                NotificationManager.IMPORTANCE_DEFAULT
            ).apply {
                description = "Alerts and reminders for pending tasks"
                setShowBadge(true)
                enableVibration(true)
            }
            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager
            notificationManager?.createNotificationChannel(channel)
        }
    }

    private fun showPendingNotification(title: String, body: String, count: Int) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            if (checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED) {
                return
            }
        }
        ensurePendingNotificationChannel()

        val launchIntent = packageManager.getLaunchIntentForPackage(packageName) ?: Intent(this, MainActivity::class.java)
        launchIntent.flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP

        val pendingIntentFlags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }

        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            launchIntent,
            pendingIntentFlags
        )

        val builder = NotificationCompat.Builder(this, PENDING_CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle(title)
            .setContentText(body)
            .setStyle(NotificationCompat.BigTextStyle().bigText(body))
            .setNumber(count)
            .setAutoCancel(true)
            .setShowWhen(true)
            .setContentIntent(pendingIntent)
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)
            .setCategory(NotificationCompat.CATEGORY_REMINDER)

        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager
        notificationManager?.notify(PENDING_NOTIFICATION_ID, builder.build())
    }

    private fun cancelPendingNotification() {
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager
        notificationManager?.cancel(PENDING_NOTIFICATION_ID)
    }

    private fun hasNotificationPermission(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) return true
        return checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) == PackageManager.PERMISSION_GRANTED
    }

    /**
     * Adds a clean white quiet-zone border around [src] so that dark edges or characters
     * touching the crop boundary do not confuse Tesseract's Leptonica binarizer.
     */
    private fun addQuietZonePadding(src: Bitmap, paddingPx: Int = 32): Bitmap {
        val paddedWidth = src.width + paddingPx * 2
        val paddedHeight = src.height + paddingPx * 2
        val output = Bitmap.createBitmap(paddedWidth, paddedHeight, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(output)
        canvas.drawColor(Color.WHITE)
        canvas.drawBitmap(src, paddingPx.toFloat(), paddingPx.toFloat(), null)
        return output
    }

    /**
     * Returns a colour-inverted copy of [src].
     *
     * Tesseract and its Leptonica binarizer assume dark ink on light paper. Light
     * lettering on a dark band — a newspaper masthead, a titled banner, a slide —
     * is treated as background and dropped entirely. Recognising the inverted copy
     * as well is the only way that text is ever seen.
     */
    private fun invertBitmap(src: Bitmap): Bitmap {
        val output = Bitmap.createBitmap(src.width, src.height, Bitmap.Config.ARGB_8888)
        val matrix = ColorMatrix(
            floatArrayOf(
                -1f, 0f, 0f, 0f, 255f,
                0f, -1f, 0f, 0f, 255f,
                0f, 0f, -1f, 0f, 255f,
                0f, 0f, 0f, 1f, 0f,
            ),
        )
        val paint = Paint().apply { colorFilter = ColorMatrixColorFilter(matrix) }
        Canvas(output).drawBitmap(src, 0f, 0f, paint)
        return output
    }

    /**
     * Mean luminance of [src] on a 0..255 scale, measured on a small sampled copy
     * so a full-resolution photo is not walked pixel by pixel.
     */
    private fun meanLuminance(src: Bitmap): Int {
        val sample = Bitmap.createScaledBitmap(src, SAMPLE_EDGE, SAMPLE_EDGE, true)
        return try {
            val pixels = IntArray(SAMPLE_EDGE * SAMPLE_EDGE)
            sample.getPixels(pixels, 0, SAMPLE_EDGE, 0, 0, SAMPLE_EDGE, SAMPLE_EDGE)
            var total = 0L
            for (pixel in pixels) {
                val r = (pixel shr 16) and 0xFF
                val g = (pixel shr 8) and 0xFF
                val b = pixel and 0xFF
                total += (r * 299 + g * 587 + b * 114) / 1000
            }
            (total / pixels.size).toInt()
        } finally {
            if (sample !== src) sample.recycle()
        }
    }

    /** One recognised word, with what we need to keep it and place it. */
    private data class RecognisedWord(
        val text: String,
        val confidence: Float,
        val hasMalayalam: Boolean,
        val endsLine: Boolean,
        val lineLeft: Int,
        val lineTop: Int,
        val lineRight: Int,
        val lineBottom: Int,
    )

    /** True when [text] contains at least one letter from the Malayalam block. */
    private fun hasMalayalamLetter(text: String): Boolean {
        return text.any { it in MALAYALAM_BLOCK_START..MALAYALAM_BLOCK_END }
    }

    /**
     * Rebuilds the recognised text, dropping only words the recognizer was unsure
     * about *and* that are the wrong script for the page, then putting the
     * surviving lines into reading order.
     *
     * Running two languages at once means that when Tesseract meets a shape that
     * is not a letter at all — a printed ornament, a rule, a logo mark — it still
     * tries to name it, and a Latin letter is the easiest fit. Those are the words
     * worth dropping.
     *
     * A single confidence floor cannot express that. Real Malayalam photographed
     * off newsprint scores low too, and deleting a correct word is worse than
     * keeping a slightly wrong one: a reader can mend a wrong letter, but cannot
     * recover a word that is not there. So Malayalam words face a low floor and
     * keep almost everything, while a non-Malayalam word on a Malayalam page —
     * the ornament case, and only that — faces a high one.
     *
     * Returns `null` when there is nothing to walk, so the caller can fall back.
     */
    private fun collectConfidentText(tess: TessBaseAPI): String? {
        val iterator = tess.resultIterator ?: return null
        val words = mutableListOf<RecognisedWord>()
        try {
            iterator.begin()
            do {
                val word = iterator
                    .getUTF8Text(TessBaseAPI.PageIteratorLevel.RIL_WORD)
                    ?.trim()
                    .orEmpty()
                val endsLine = iterator.isAtFinalElement(
                    TessBaseAPI.PageIteratorLevel.RIL_TEXTLINE,
                    TessBaseAPI.PageIteratorLevel.RIL_WORD,
                )
                if (word.isNotEmpty()) {
                    // Left, top, right, bottom of the line this word sits on.
                    val box = iterator.getBoundingBox(
                        TessBaseAPI.PageIteratorLevel.RIL_TEXTLINE,
                    )
                    words.add(
                        RecognisedWord(
                            text = word,
                            confidence = iterator.confidence(
                                TessBaseAPI.PageIteratorLevel.RIL_WORD,
                            ),
                            hasMalayalam = hasMalayalamLetter(word),
                            endsLine = endsLine,
                            lineLeft = box[0],
                            lineTop = box[1],
                            lineRight = box[2],
                            lineBottom = box[3],
                        ),
                    )
                } else if (endsLine && words.isNotEmpty()) {
                    words[words.size - 1] = words.last().copy(endsLine = true)
                }
            } while (iterator.next(TessBaseAPI.PageIteratorLevel.RIL_WORD))
        } finally {
            iterator.delete()
        }

        if (words.isEmpty()) return ""

        // Decide what kind of page this is, counting only words that clear the low
        // floor so that junk cannot vote. An English page must behave exactly as it
        // did before this filter existed, so the high floor applies to Malayalam
        // pages only.
        val readable = words.filter { it.confidence >= MALAYALAM_CONFIDENCE_FLOOR }
        val malayalamCount = readable.count { it.hasMalayalam }
        val pageIsMalayalam = malayalamCount > (readable.size - malayalamCount)

        val lines = mutableListOf<TextLineBox>()
        val lineText = StringBuilder()
        var left = 0
        var top = 0
        var right = 0
        var bottom = 0
        var started = false

        fun flushLine() {
            if (lineText.isEmpty()) return
            lines.add(TextLineBox(left, top, right, bottom, lineText.toString()))
            lineText.clear()
            started = false
        }

        for (word in words) {
            val floor = if (word.hasMalayalam || !pageIsMalayalam) {
                MALAYALAM_CONFIDENCE_FLOOR
            } else {
                FOREIGN_CONFIDENCE_FLOOR
            }
            if (word.confidence >= floor) {
                if (lineText.isNotEmpty()) lineText.append(' ')
                lineText.append(word.text)
                if (started) {
                    left = minOf(left, word.lineLeft)
                    top = minOf(top, word.lineTop)
                    right = maxOf(right, word.lineRight)
                    bottom = maxOf(bottom, word.lineBottom)
                } else {
                    left = word.lineLeft
                    top = word.lineTop
                    right = word.lineRight
                    bottom = word.lineBottom
                    started = true
                }
            }
            if (word.endsLine) flushLine()
        }
        flushLine()

        return orderLinesForReading(lines).joinToString("\n") { it.text }.trim()
    }

    /**
     * Scores one recognition result. A pass is better when it is both confident and
     * finds more words, so a stray high-confidence fragment cannot beat a full line
     * of slightly less certain text.
     */
    private fun scoreRecognition(text: String, confidence: Int): Int {
        if (text.isBlank()) return 0
        val words = text.split(Regex("\\s+")).count { it.isNotBlank() }
        return confidence * words
    }

    private fun isOcrRequestCancelled(requestId: Int): Boolean =
        synchronized(cancelledOcrRequests) { cancelledOcrRequests.contains(requestId) }

    private fun clearCancelledOcrRequest(requestId: Int) {
        synchronized(cancelledOcrRequests) { cancelledOcrRequests.remove(requestId) }
    }

    /** One recognition attempt: a page segmentation mode against a given bitmap. */
    private data class OcrPass(val bitmap: Bitmap, val pageSegMode: Int)

    @Synchronized
    private fun performTesseractOcr(
        context: Context,
        imageFile: File,
        language: String,
    ): String {
        val datapath = context.filesDir.absolutePath
        val tess = activeTessApi ?: TessBaseAPI().also {
            activeTessApi = it
        }

        if (activeTessLang != language) {
            val success = tess.init(datapath, language)
            if (!success) {
                val fallbackLang = if (language.contains("eng")) "eng" else "mal"
                val fallbackSuccess = tess.init(datapath, fallbackLang)
                if (!fallbackSuccess) {
                    throw IllegalStateException("Failed to initialize Tesseract with language: $language")
                }
                activeTessLang = fallbackLang
            } else {
                activeTessLang = language
            }
        }

        // Our images are resized PNGs with no DPI metadata, so Tesseract's own
        // resolution guess is wrong and the LSTM line model loses accuracy on
        // vowel signs and ligatures. Telling it the effective DPI fixes that.
        tess.setVariable("user_defined_dpi", "300")
        tess.setVariable("preserve_interword_spaces", "1")

        val rawBitmap = BitmapFactory.decodeFile(imageFile.absolutePath)
            ?: throw IllegalArgumentException("Could not decode image file: ${imageFile.name}")

        // Add a clean white quiet-zone padding around the image. Tight crops often have
        // dark borders or character strokes that touch the edge, causing Leptonica to treat
        // them as page frames/borders and discard all text lines.
        val bitmap = addQuietZonePadding(rawBitmap, paddingPx = 32)
        if (bitmap !== rawBitmap) {
            rawBitmap.recycle()
        }

        // A dark-dominant image is very likely light text on a dark ground. Recognise
        // the inverted copy too and let the scoring below decide which reading wins.
        // A normal light page skips this entirely and stays as fast as before.
        val inverted = if (meanLuminance(bitmap) < DARK_IMAGE_LUMINANCE) {
            invertBitmap(bitmap)
        } else {
            null
        }

        return try {
            val passes = mutableListOf<OcrPass>()
            for (mode in PAGE_SEG_MODES) {
                passes.add(OcrPass(bitmap, mode))
            }
            if (inverted != null) {
                for (mode in PAGE_SEG_MODES) {
                    passes.add(OcrPass(inverted, mode))
                }
            }

            var bestText = ""
            var bestScore = 0
            for (pass in passes) {
                tess.pageSegMode = pass.pageSegMode
                tess.setImage(pass.bitmap)
                val rawText = tess.utF8Text?.trim() ?: ""
                // Prefer the confidence-filtered reading. If the floor stripped
                // everything but the recognizer did find words, keep the unfiltered
                // text — a tuning value must never turn a working scan blank.
                val filtered = collectConfidentText(tess)
                val text = if (filtered.isNullOrEmpty()) rawText else filtered
                if (text.isNotEmpty()) {
                    val score = scoreRecognition(text, tess.meanConfidence())
                    if (score > bestScore) {
                        bestScore = score
                        bestText = text
                    }
                    // A clean page is read well on its first pass. Stop there rather
                    // than spending three more passes to confirm it.
                    if (score >= CONFIDENT_SCORE) break
                }
            }

            tess.clear()
            bestText
        } finally {
            inverted?.recycle()
            bitmap.recycle()
        }
    }
}

/**
 * Identifies the set of language models currently shipped in assets.
 *
 * `ensureTessData` copies the models to internal storage once and then leaves
 * them alone, so an app update carrying a new model would never replace the old
 * copy. Bumping this string forces one re-copy. Change it whenever any file in
 * `assets/tessdata/` changes.
 */
private const val TESSDATA_VERSION = "2026-09-12-mal-best"

/** Name of the marker file recording which model set is on disk. */
private const val TESSDATA_VERSION_FILE = ".model_version"

/** First character of the Unicode Malayalam block. */
private const val MALAYALAM_BLOCK_START = '\u0D00'

/** Last character of the Unicode Malayalam block. */
private const val MALAYALAM_BLOCK_END = '\u0D7F'

/**
 * Word confidence (0..100) below which a word in the page's own script is
 * discarded.
 *
 * Deliberately low. Malayalam photographed off newsprint often scores in the
 * forties, and losing a correct word costs the reader more than keeping a
 * slightly wrong one.
 */
private const val MALAYALAM_CONFIDENCE_FLOOR = 30f

/**
 * Word confidence (0..100) below which a word that is *not* in the page's script
 * is discarded — a Latin word on a Malayalam page.
 *
 * Ornaments, rules and logo marks are reported this way and score well under 40.
 * Raise this, never the floor above, if such junk starts appearing again.
 */
private const val FOREIGN_CONFIDENCE_FLOOR = 60f

/** Edge length of the downscaled copy used to measure average brightness. */
private const val SAMPLE_EDGE = 32

/**
 * Mean luminance (0..255) below which an image counts as dark-dominant and is
 * also recognised inverted.
 */
private const val DARK_IMAGE_LUMINANCE = 110

/**
 * Score (mean confidence x word count) above which a pass is considered good
 * enough to stop trying the remaining page segmentation modes.
 */
private const val CONFIDENT_SCORE = 1600

/**
 * Page segmentation modes tried in order: a full page first, then a single
 * uniform block for crops and columns, then sparse text for banners, headers
 * and scattered words. Every mode is scored and the best reading wins — an
 * earlier mode returning *some* text no longer blocks the later ones.
 */
private val PAGE_SEG_MODES = listOf(
    TessBaseAPI.PageSegMode.PSM_AUTO,
    TessBaseAPI.PageSegMode.PSM_SINGLE_BLOCK,
    TessBaseAPI.PageSegMode.PSM_SPARSE_TEXT,
)

/**
 * Copies the bundled language models out of assets into app-internal storage,
 * where Tesseract can open them as ordinary files.
 *
 * The models are only replaced when the shipped set changes. Without that check
 * an app update carrying a new model would keep using the old copy for everyone
 * who already had the app installed.
 */
private fun ensureTessData(context: Context) {
    val tessDataDir = File(context.filesDir, "tessdata")
    if (!tessDataDir.exists()) {
        tessDataDir.mkdirs()
    }

    val versionFile = File(tessDataDir, TESSDATA_VERSION_FILE)
    val installedVersion = try {
        if (versionFile.exists()) versionFile.readText().trim() else null
    } catch (_: Exception) {
        null
    }
    val needsRefresh = installedVersion != TESSDATA_VERSION

    for (lang in listOf("eng", "mal")) {
        val targetFile = File(tessDataDir, "$lang.traineddata")
        val possibleAssetPaths = listOf(
            "flutter_assets/assets/tessdata/$lang.traineddata",
            "assets/tessdata/$lang.traineddata",
        )
        if (needsRefresh || !targetFile.exists() || targetFile.length() == 0L) {
            for (assetPath in possibleAssetPaths) {
                try {
                    context.assets.open(assetPath).use { input ->
                        FileOutputStream(targetFile).use { output ->
                            input.copyTo(output)
                        }
                    }
                    if (targetFile.exists() && targetFile.length() > 0L) {
                        break
                    }
                } catch (_: Exception) {
                    // Try next path
                }
            }
        }
    }

    // Record the version only once every model is actually on disk, so a copy that
    // failed part way is retried on the next run instead of being marked done.
    if (needsRefresh) {
        val allPresent = listOf("eng", "mal").all { lang ->
            File(tessDataDir, "$lang.traineddata").let { it.exists() && it.length() > 0L }
        }
        if (allPresent) {
            try {
                versionFile.writeText(TESSDATA_VERSION)
            } catch (_: Exception) {
                // Losing the marker only costs one extra copy on the next launch.
            }
        }
    }
}

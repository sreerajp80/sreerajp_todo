package `in`.sreerajp.sreerajp_todo

import android.content.Context
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import android.util.Base64
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.security.KeyStore
import java.security.SecureRandom
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import javax.crypto.spec.GCMParameterSpec

class MainActivity : FlutterActivity() {
    private val CHANNEL = "in.sreerajp.todo/database_key"
    private val KEY_ALIAS = "SreerajpTodoMasterKey"
    private val PREFS_NAME = "sreerajp_todo_secure_prefs"
    private val PREF_KEY_DATA = "encrypted_db_key"
    private val PREF_KEY_IV = "encrypted_db_key_iv"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getOrCreateDatabaseKey") {
                try {
                    val hexKey = getOrCreateDatabaseKey()
                    result.success(hexKey)
                } catch (e: Exception) {
                    result.error("KEYSTORE_ERROR", e.message, null)
                }
            } else {
                result.notImplemented()
            }
        }
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


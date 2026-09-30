package `in`.sreerajp.sreerajp_todo

import com.google.zxing.BarcodeFormat
import com.google.zxing.BinaryBitmap
import com.google.zxing.DecodeHintType
import com.google.zxing.LuminanceSource
import com.google.zxing.NotFoundException
import com.google.zxing.PlanarYUVLuminanceSource
import com.google.zxing.ReaderException
import com.google.zxing.common.HybridBinarizer
import com.google.zxing.qrcode.QRCodeReader

/**
 * Reads a QR code from one camera frame, fully on the device.
 *
 * Uses the ZXing core library: plain Java maths (finder patterns, grid
 * sampling, Reed-Solomon error correction). No network, no Play Services.
 *
 * The input is the brightness ("Y") plane of a YUV camera frame. [rowStride]
 * is the number of bytes per row, which can be larger than [width] because of
 * padding at the end of each row.
 */
object QrFrameDecoder {
    private val hints: Map<DecodeHintType, Any> = mapOf(
        DecodeHintType.POSSIBLE_FORMATS to listOf(BarcodeFormat.QR_CODE),
        DecodeHintType.CHARACTER_SET to "UTF-8",
    )

    /** Returns the QR text, or null when no QR code is found in the frame. */
    fun decode(bytes: ByteArray, width: Int, height: Int, rowStride: Int): String? {
        require(width > 0 && height > 0) { "width and height must be positive" }
        require(rowStride >= width) { "rowStride must be at least width" }
        require(bytes.size >= rowStride * (height - 1) + width) { "frame is too small" }

        val source = PlanarYUVLuminanceSource(
            bytes, rowStride, height, 0, 0, width, height, false,
        )
        // Try the normal image first, then the inverted one, so light codes
        // on a dark background are read too.
        return decodeSource(source) ?: decodeSource(source.invert())
    }

    private fun decodeSource(source: LuminanceSource): String? {
        val reader = QRCodeReader()
        return try {
            reader.decode(BinaryBitmap(HybridBinarizer(source)), hints).text
        } catch (e: NotFoundException) {
            null
        } catch (e: ReaderException) {
            // Checksum or format errors: a blurred or partial code. The next
            // frame usually reads cleanly.
            null
        } finally {
            reader.reset()
        }
    }
}

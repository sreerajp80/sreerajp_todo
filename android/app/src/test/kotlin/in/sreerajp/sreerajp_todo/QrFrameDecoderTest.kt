package `in`.sreerajp.sreerajp_todo

import com.google.zxing.BarcodeFormat
import com.google.zxing.EncodeHintType
import com.google.zxing.qrcode.QRCodeWriter
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

/**
 * Covers [QrFrameDecoder]. Codes are drawn with ZXing's own writer and turned
 * into a brightness plane, so no device, camera or emulator is involved.
 */
class QrFrameDecoderTest {

    /**
     * Draws [text] as a QR code of [size] x [size] pixels. Each row is
     * [rowStride] bytes long; bytes past the image width are padding.
     * Black modules are 0 and white is 255, or the reverse when [inverted].
     */
    private fun frame(
        text: String,
        size: Int = 300,
        rowStride: Int = size,
        inverted: Boolean = false,
    ): ByteArray {
        val matrix = QRCodeWriter().encode(
            text,
            BarcodeFormat.QR_CODE,
            size,
            size,
            mapOf(EncodeHintType.CHARACTER_SET to "UTF-8"),
        )
        val dark: Byte = if (inverted) 255.toByte() else 0
        val light: Byte = if (inverted) 0 else 255.toByte()
        val bytes = ByteArray(rowStride * size) { 127 }
        for (y in 0 until size) {
            for (x in 0 until size) {
                bytes[y * rowStride + x] = if (matrix.get(x, y)) dark else light
            }
        }
        return bytes
    }

    @Test
    fun decodesPlainText() {
        val bytes = frame("AIRQR|1|3|hello")
        assertEquals("AIRQR|1|3|hello", QrFrameDecoder.decode(bytes, 300, 300, 300))
    }

    @Test
    fun decodesUnicodeText() {
        val text = "മലയാളം संस्कृतम् ✓"
        val bytes = frame(text)
        assertEquals(text, QrFrameDecoder.decode(bytes, 300, 300, 300))
    }

    @Test
    fun handlesRowPadding() {
        val bytes = frame("padded rows", size = 300, rowStride = 320)
        assertEquals("padded rows", QrFrameDecoder.decode(bytes, 300, 300, 320))
    }

    @Test
    fun decodesLightCodeOnDarkBackground() {
        val bytes = frame("inverted", inverted = true)
        assertEquals("inverted", QrFrameDecoder.decode(bytes, 300, 300, 300))
    }

    @Test
    fun returnsNullForBlankFrame() {
        val bytes = ByteArray(300 * 300) { 200.toByte() }
        assertNull(QrFrameDecoder.decode(bytes, 300, 300, 300))
    }

    @Test(expected = IllegalArgumentException::class)
    fun rejectsFrameThatIsTooSmall() {
        QrFrameDecoder.decode(ByteArray(10), 300, 300, 300)
    }
}

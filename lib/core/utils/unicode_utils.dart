import 'package:unorm_dart/unorm_dart.dart' as unorm;

String nfcNormalize(String s) => unorm.nfc(s);

/// Detects whether [text] is predominantly RTL.
///
/// Uses the first strong directional character (Unicode Bidi classes R, AL, AN
/// for RTL; L, EN for LTR). Returns null if no strong character is found,
/// letting Flutter fall back to the ambient directionality.
TextDirection? detectTextDirection(String text) {
  for (final codeUnit in text.runes) {
    if (_isRtlChar(codeUnit)) return TextDirection.rtl;
    if (_isLtrChar(codeUnit)) return TextDirection.ltr;
  }
  return null;
}

bool _isRtlChar(int code) {
  // Arabic block: U+0600–U+06FF
  if (code >= 0x0600 && code <= 0x06FF) return true;
  // Arabic Supplement: U+0750–U+077F
  if (code >= 0x0750 && code <= 0x077F) return true;
  // Arabic Extended-A: U+08A0–U+08FF
  if (code >= 0x08A0 && code <= 0x08FF) return true;
  // Hebrew block: U+0590–U+05FF
  if (code >= 0x0590 && code <= 0x05FF) return true;
  // Thaana: U+0780–U+07BF
  if (code >= 0x0780 && code <= 0x07BF) return true;
  // Syriac: U+0700–U+074F
  if (code >= 0x0700 && code <= 0x074F) return true;
  return false;
}

bool _isLtrChar(int code) {
  // Latin: U+0041–U+005A, U+0061–U+007A
  if (code >= 0x0041 && code <= 0x005A) return true;
  if (code >= 0x0061 && code <= 0x007A) return true;
  // Latin Extended-A / B / Additional
  if (code >= 0x00C0 && code <= 0x024F) return true;
  // CJK Unified Ideographs (treated as LTR)
  if (code >= 0x4E00 && code <= 0x9FFF) return true;
  // Devanagari
  if (code >= 0x0900 && code <= 0x097F) return true;
  return false;
}

/// Dart-only enum mirroring dart:ui TextDirection to keep core/ free of Flutter.
enum TextDirection { ltr, rtl }

import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

base class DataBlob extends Struct {
  @Uint32()
  external int cbData;

  external Pointer<Uint8> pbData;
}

typedef NativeCryptProtectData =
    Int32 Function(
      Pointer<DataBlob> pDataIn,
      Pointer<Void> szDataDescr,
      Pointer<DataBlob> pOptionalEntropy,
      Pointer<Void> pvReserved,
      Pointer<Void> pPromptStruct,
      Uint32 dwFlags,
      Pointer<DataBlob> pDataOut,
    );

typedef DartCryptProtectData =
    int Function(
      Pointer<DataBlob> pDataIn,
      Pointer<Void> szDataDescr,
      Pointer<DataBlob> pOptionalEntropy,
      Pointer<Void> pvReserved,
      Pointer<Void> pPromptStruct,
      int dwFlags,
      Pointer<DataBlob> pDataOut,
    );

typedef NativeCryptUnprotectData =
    Int32 Function(
      Pointer<DataBlob> pDataIn,
      Pointer<Void> ppszDataDescr,
      Pointer<DataBlob> pOptionalEntropy,
      Pointer<Void> pvReserved,
      Pointer<Void> pPromptStruct,
      Uint32 dwFlags,
      Pointer<DataBlob> pDataOut,
    );

typedef DartCryptUnprotectData =
    int Function(
      Pointer<DataBlob> pDataIn,
      Pointer<Void> ppszDataDescr,
      Pointer<DataBlob> pOptionalEntropy,
      Pointer<Void> pvReserved,
      Pointer<Void> pPromptStruct,
      int dwFlags,
      Pointer<DataBlob> pDataOut,
    );

typedef NativeLocalAlloc =
    Pointer<Void> Function(Uint32 uFlags, IntPtr dwBytes);
typedef DartLocalAlloc = Pointer<Void> Function(int uFlags, int dwBytes);

typedef NativeLocalFree = Pointer<Void> Function(Pointer<Void> hMem);
typedef DartLocalFree = Pointer<Void> Function(Pointer<Void> hMem);

class Win32Dpapi {
  Win32Dpapi() {
    if (!Platform.isWindows) {
      throw UnsupportedError('Win32Dpapi is only supported on Windows.');
    }
    _crypt32 = DynamicLibrary.open('crypt32.dll');
    _kernel32 = DynamicLibrary.open('kernel32.dll');

    _cryptProtectData = _crypt32
        .lookupFunction<NativeCryptProtectData, DartCryptProtectData>(
          'CryptProtectData',
        );
    _cryptUnprotectData = _crypt32
        .lookupFunction<NativeCryptUnprotectData, DartCryptUnprotectData>(
          'CryptUnprotectData',
        );
    _localAlloc = _kernel32.lookupFunction<NativeLocalAlloc, DartLocalAlloc>(
      'LocalAlloc',
    );
    _localFree = _kernel32.lookupFunction<NativeLocalFree, DartLocalFree>(
      'LocalFree',
    );
  }

  late final DynamicLibrary _crypt32;
  late final DynamicLibrary _kernel32;
  late final DartCryptProtectData _cryptProtectData;
  late final DartCryptUnprotectData _cryptUnprotectData;
  late final DartLocalAlloc _localAlloc;
  late final DartLocalFree _localFree;

  Uint8List protect(Uint8List plainData) {
    final pDataIn = _localAlloc(0, sizeOf<DataBlob>()).cast<DataBlob>();
    final pbDataIn = _localAlloc(0, plainData.length).cast<Uint8>();

    try {
      final inputBytes = pbDataIn.asTypedList(plainData.length);
      inputBytes.setAll(0, plainData);

      pDataIn.ref.cbData = plainData.length;
      pDataIn.ref.pbData = pbDataIn;

      final pDataOut = _localAlloc(0, sizeOf<DataBlob>()).cast<DataBlob>();

      try {
        final result = _cryptProtectData(
          pDataIn,
          nullptr,
          nullptr,
          nullptr,
          nullptr,
          0,
          pDataOut,
        );

        if (result == 0) {
          throw StateError(
            'CryptProtectData failed to encrypt data with Windows DPAPI.',
          );
        }

        final outLength = pDataOut.ref.cbData;
        final outBytes = pDataOut.ref.pbData.asTypedList(outLength);
        final protectedData = Uint8List.fromList(outBytes);

        _localFree(pDataOut.ref.pbData.cast<Void>());
        return protectedData;
      } finally {
        _localFree(pDataOut.cast<Void>());
      }
    } finally {
      _localFree(pbDataIn.cast<Void>());
      _localFree(pDataIn.cast<Void>());
    }
  }

  Uint8List unprotect(Uint8List protectedData) {
    final pDataIn = _localAlloc(0, sizeOf<DataBlob>()).cast<DataBlob>();
    final pbDataIn = _localAlloc(0, protectedData.length).cast<Uint8>();

    try {
      final inputBytes = pbDataIn.asTypedList(protectedData.length);
      inputBytes.setAll(0, protectedData);

      pDataIn.ref.cbData = protectedData.length;
      pDataIn.ref.pbData = pbDataIn;

      final pDataOut = _localAlloc(0, sizeOf<DataBlob>()).cast<DataBlob>();

      try {
        final result = _cryptUnprotectData(
          pDataIn,
          nullptr,
          nullptr,
          nullptr,
          nullptr,
          0,
          pDataOut,
        );

        if (result == 0) {
          throw StateError(
            'CryptUnprotectData failed to decrypt data with Windows DPAPI.',
          );
        }

        final outLength = pDataOut.ref.cbData;
        final outBytes = pDataOut.ref.pbData.asTypedList(outLength);
        final unprotectedData = Uint8List.fromList(outBytes);

        _localFree(pDataOut.ref.pbData.cast<Void>());
        return unprotectedData;
      } finally {
        _localFree(pDataOut.cast<Void>());
      }
    } finally {
      _localFree(pbDataIn.cast<Void>());
      _localFree(pDataIn.cast<Void>());
    }
  }
}

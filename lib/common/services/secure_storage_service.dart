import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Distinguishes storage outcomes for AI key read/write operations.
/// Error messages are human-readable Chinese strings.
sealed class SecureStorageResult<T> {
  const SecureStorageResult(this.errorMessage);
  final String? errorMessage;
  bool get isOk => errorMessage == null;
  bool get isError => errorMessage != null;
}

/// Read succeeded — value may be null if the key was never set.
class SecureReadOk<T> extends SecureStorageResult<T> {
  const SecureReadOk(this.value) : super(null);
  final T value;
}

/// Write succeeded.
class SecureWriteOk extends SecureStorageResult<void> {
  const SecureWriteOk() : super(null);
}

/// Storage read/write failed.
class SecureStorageError extends SecureStorageResult<Never> {
  const SecureStorageError(this.message) : super(null);
  final String message;
}

/// Abstraction over platform-native credential storage.
/// iOS: Keychain  |  Android: EncryptedSharedPreferences  |  Web: SharedPreferences (documented risk)
class SecureStorageService {
  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
              iOptions: IOSOptions(
                accessibility:
                    KeychainAccessibility.first_unlock_this_device,
              ),
            );

  final FlutterSecureStorage _storage;

  Future<SecureStorageResult<String?>> read(String key) async {
    try {
      final value = await _storage.read(key: key);
      return SecureReadOk<String?>(value);
    } catch (e) {
      return SecureStorageError('安全存储读取失败: $e');
    }
  }

  Future<SecureStorageResult<void>> write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
      return const SecureWriteOk();
    } catch (e) {
      return SecureStorageError('安全存储写入失败: $e');
    }
  }

  Future<SecureStorageResult<void>> delete(String key) async {
    try {
      await _storage.delete(key: key);
      return const SecureWriteOk();
    } catch (e) {
      return SecureStorageError('安全存储删除失败: $e');
    }
  }
}

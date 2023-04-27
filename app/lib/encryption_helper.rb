# This is a light encryption tool.
# The salt being constant it should not be used to encrypt or store sensitive data.
class EncryptionHelper
  class << self
    def encrypt(value)
      encryptor.encrypt_and_sign(value)
    end

    def decrypt(value)
      encryptor.decrypt_and_verify(value)
    end

    private

    def encryptor
      ActiveSupport::MessageEncryptor.new(key)
    end

    def key
      ActiveSupport::KeyGenerator.new(ENV["ENCRYPTION_KEY"]).generate_key(
        ENV["ENCRYPTION_SALT"], ActiveSupport::MessageEncryptor.key_len
      )
    end
  end
end

class AddEncryptionToUsers < ActiveRecord::Migration[7.1]
  def up
    User.find_each(&:encrypt)
  end

  def down
    User.find_each(&:decrypt)
  end
end

class AddEncryptionToUsers < ActiveRecord::Migration[7.1]
  def up
    User.where.not(nir: nil).find_each(&:encrypt)
  end

  def down
    User.where.not(nir: nil).find_each(&:decrypt)
  end
end

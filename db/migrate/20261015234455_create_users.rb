class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      # Nullable for guest users, who have no email address; the model requires one for everyone else.
      t.string :email_address
      t.string :password_digest, null: false
      t.boolean :guest, null: false, default: false

      t.timestamps
    end
    add_index :users, :email_address, unique: true
  end
end

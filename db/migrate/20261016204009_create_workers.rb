class CreateWorkers < ActiveRecord::Migration[8.1]
  def change
    create_table :workers do |t|
      t.references :user, null: false, foreign_key: true, index: false
      t.string :name, null: false
      t.integer :position, null: false

      t.timestamps

      # Covers lookups by user too, and returns each user's rows already in order.
      t.index [ :user_id, :position ]
    end
  end
end

class CreateTasks < ActiveRecord::Migration[8.1]
  def change
    create_table :tasks do |t|
      t.references :user, null: false, foreign_key: true, index: false
      t.references :worker, foreign_key: true
      t.string :name, null: false
      t.integer :position, null: false
      t.integer :percent_complete, null: false, default: 0

      t.timestamps

      # Covers lookups by user too, and returns each user's rows already in order.
      t.index [ :user_id, :position ]
    end
  end
end

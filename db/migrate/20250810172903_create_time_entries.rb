class CreateTimeEntries < ActiveRecord::Migration[7.1]
  def change
    create_table :time_entries do |t|
      t.references :user, null: false, foreign_key: true
      t.date :date
      t.float :distance
      t.integer :time_in_seconds

      t.timestamps
    end
  end
end

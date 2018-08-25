class CreateActiveStorageData < ActiveRecord::Migration[5.2]
  def change
    create_table :active_storage_data do |t|
      t.string :key, null: false
      t.binary :io, null: false

      t.timestamps
    end
    add_index :active_storage_data, :key
  end
end

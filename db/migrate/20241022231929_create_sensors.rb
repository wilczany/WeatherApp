class CreateSensors < ActiveRecord::Migration[7.2]
  def change
    create_table :sensors do |t|
      t.string :name
      t.integer :location
      t.integer :state
      t.timestamps
    end
  end
end

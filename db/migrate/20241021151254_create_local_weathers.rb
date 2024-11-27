class CreateLocalWeathers < ActiveRecord::Migration[7.2]
  def change
    create_enum :location, %w[inside outside]
    create_enum :state, %w[on off]
    
    create_table :local_weathers do |t|
      t.float :temperature
      t.float :humidity
      t.integer :pressure

      t.timestamps
    end
  end
end

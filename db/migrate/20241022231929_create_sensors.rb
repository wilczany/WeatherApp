class CreateSensors < ActiveRecord::Migration[7.2]
  def change
    create_enum :location, %w[inside outside]
    create_enum :state, %w[on off]

    create_table :sensors do |t|
      t.string :name
      t.enum "location", enum_type: :location
      t.enum "state", enum_type: :state, default: "off"

      t.timestamps
    end
  end
end

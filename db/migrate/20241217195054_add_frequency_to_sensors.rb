class AddFrequencyToSensors < ActiveRecord::Migration[7.2]
  def change
    add_column :sensors, :frequency, :integer
  end
end

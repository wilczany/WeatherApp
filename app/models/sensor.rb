class Sensor < ApplicationRecord
  enum location: [ :inside, :outside ]
  enum state: [ :on, :off ]
  has_many :local_weathers

  def latest_weather
    local_weathers.order(created_at: :desc).first
  end
end

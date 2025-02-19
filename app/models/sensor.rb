class Sensor < ApplicationRecord
  enum :location, { inside: 0, outside: 1 }
  enum :state, { on: 0, off: 1 }
  has_many :local_weathers

  def latest_weather
    local_weathers.order(created_at: :desc).first
  end

  def translated_location
    I18n.t("enums.sensor.location.#{location}")
  end

  def translated_state
    I18n.t("enums.sensor.state.#{state == 'on' ? true : false}")
  end
end

class Sensor < ApplicationRecord
  enum :location, {
    inside: "inside",
    outside: "outside"
  }
  enum :state, {
    on: "on",
    off: "off"
}
  has_many :local_weathers

  def latest_weather
    local_weathers.order(created_at: :desc).first
  end
end

require "rufus-scheduler"

s = Rufus::Scheduler.singleton
interval_time = 5
s.every "#{interval_time}m" do
  latest_records = LocalWeather
  .select("DISTINCT ON (sensor_id) *")
  .order("sensor_id, created_at DESC")


  latest_records.each do |record|
    time = record.created_at
    if time < interval_time.minutes.ago
      Sensor.find(record.sensor_id).update(state: :off)
    end
  end
end

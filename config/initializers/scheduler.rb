require "rufus-scheduler"


s = Rufus::Scheduler.singleton


s.every "5m" do
  latest_records = LocalWeather
  .select("DISTINCT ON (sensor_id) *")
  .order("sensor_id, created_at DESC")


  latest_records.each do |record|
    time = record.created_at
    if time < 5.minutes.ago
      Sensor.find(record.sensor_id).update(state: :off)
    end
  end
  puts "########\n#UPDATED SENSORS\n########"
end

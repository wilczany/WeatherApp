
require "rufus-scheduler"


scheduler = Rufus::Scheduler.singleton

scheduler.every "1m" do
    # Rails.logger.info "Scheduler is alive: #{Time.now}"
    LocalWeatherService.get_weather
end

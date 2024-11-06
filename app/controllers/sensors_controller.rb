class SensorsController < ApplicationController
    def index
        @sensors = Sensor.all.sort
    end

    def show
        @sensor = Sensor.find(params[:id])
        @weathers = @sensor.local_weathers.order(created_at: :desc).limit(10)
        @latest = @weathers.last

        @temperature_data = @weathers.map { |reading|
            [ reading.created_at, reading.temperature ]
        }
        @humidity_data = @weathers.map { |reading|
            [ reading.created_at, reading.humidity ]
        }
        @pressure_data = @weathers.map { |reading|
            [ reading.created_at, reading.pressure ]
        }
    end
end

class SensorsController < ApplicationController
    def index
        @sensors = Sensor.all.sort
    end

    def show
        @sensor = Sensor.find(params[:id])
        puts params[:minutes_ago]
        puts "#######################"
        time_param = params[:minutes_ago]
        time = time_param.to_i&.nonzero? || 20
        @weathers = @sensor.local_weathers.where("created_at >= ?", time.minutes.ago).order(created_at: :asc)
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

    def frequency
        data = Sensor.all.map do |sensor|
          {sensor.id => sensor.frequency}
        end
        data = data.to_json

        # ale nabroiłeś saku

        response.headers.clear

        render json: data
    end

    def edit
        @sensor = Sensor.find(params[:id])
    end

    def update
        @sensor = Sensor.find(params[:id])
        if @sensor.update(sensor_params)
            redirect_to @sensor, notice: 'Sensor was successfully updated.'
        else
            render :edit
        end
    end

    private

    def sensor_params
        params.require(:sensor).permit(:name, :location, :frequency)
    end
end

class SensorsController < ApplicationController
    def index
        @sensors = Sensor.all.sort
    end

    def show
        @sensor = Sensor.find(params[:id])
        @latest = @sensor.latest_weather

        if params[:start_time].present? && params[:end_time].present?
            start_time = Time.zone.parse(params[:start_time])
            end_time = Time.zone.parse(params[:end_time])
            @data = LocalWeather.charts_data(params[:id], start_time, end_time)
        else
            @data = LocalWeather.charts_data(params[:id], @latest.created_at - 30.minutes, @latest.created_at)
        end
    end

    def frequency
        data = Sensor.all.map do |sensor|
          { "S#{sensor.id}" => sensor.frequency }
        end
        data = data.to_json

        # zmniejszone zostały nagłówki odpowiedzi ze względu na ograniczenia sprzętowe związane z odczytem

        response.headers.clear

        render json: data
    end

    def edit
        @sensor = Sensor.find(params[:id])
    end

    def update
        @sensor = Sensor.find(params[:id])
        if @sensor.update(sensor_params)
            redirect_to @sensor
        else
            render :edit
        end
    end

    private

    def sensor_params
        params.require(:sensor).permit(:name, :location, :frequency)
    end
end

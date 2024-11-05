class SensorsController < ApplicationController
    def index
        @sensors = Sensor.all.sort
    end

    def show
        @sensor = Sensor.find(params[:id])
    end
end

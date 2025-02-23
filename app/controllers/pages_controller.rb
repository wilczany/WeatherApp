class PagesController < ApplicationController
  def forecast
    city = params[:city]
    forecast_data = ForecastService.fetch(city)
    if forecast_data.nil?
      flash.now[:notice] = "City not found"
      return
    elsif forecast_data[:error]
      flash.now[:alert] = forecast_data[:error]
      return
    end

    @location = forecast_data[:location]
    @today = forecast_data[:today]
    @current_weather = forecast_data[:current_weather]
    @forecasts = forecast_data[:forecasts]
  end
end

class Forecast
  attr_reader :temperature, :condition
  def initialize(time, temperature, condition)
    @time = time
    @temperature = temperature
    @condition = condition
  end

  def time
    @time.strftime("%H:%M")
  end
end

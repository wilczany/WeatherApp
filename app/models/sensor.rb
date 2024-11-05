class Sensor < ApplicationRecord
  enum location: [ :inside, :outside ]
  enum state: [ :on, :off ]
  has_many :local_weathers
end

class Sensor < ApplicationRecord
  enum location: [ :inside, :outside ]
  has_many :local_weathers
end

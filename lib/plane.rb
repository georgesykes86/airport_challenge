require_relative './exceptions'

class Plane

  def initialize
    @flying = false
  end

  def land
    raise PlaneError, "Plane already on the ground" unless @flying
    @flying = false
  end

  def take_off(airport)
    raise PlaneError, "Plane already in-flight" if flying?
    airport.release_plane(self)
    @flying = true
  end

  def flying?
    @flying
  end

end

module DeviceHelper

  DEVICETYPE = ["PROJECTOR","PHONE","TV"]

  def get_devices(room)
    devices = Array.new

    flags = room.devices

    if (flags & 1) == 1
      devices << DEVICETYPE[0]
    end

    flags >> 1
    if (flags & 1) == 1
      devices << DEVICETYPE[1]
    end

    flags >> 1
    if (flags & 1) == 1
      devices << DEVICETYPE[2]
    end

  end

end

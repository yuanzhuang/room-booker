module DeviceHelper

  DEVICETYPE = ["PROJECTOR","PHONE"]

  def get_devices(room)
    devices = Array.new

    flags = room.devices

    if (flags & 1) == 1
      devices << DEVICETYPE[0]
    end

    flag >> 1
    if (flag & 1) == 1
      devices << DEVICETYPE[1]
    end

  end

end

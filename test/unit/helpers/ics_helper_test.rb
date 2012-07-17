require 'test_helper'

class IcsHelperTest < ActionView::TestCase

  include IcsHelper

  def test_generate_ics

    booking = Booking.find(980190963)

    ics = generate_ics(booking)

    puts ics.to_s

    assert true

  end

end

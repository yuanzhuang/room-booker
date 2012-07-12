require 'test_helper'


class BookingsHelperTest < ActionView::TestCase

  include BookingsHelper

  def test_split_boooking

    date = Date.new

    days_1 = []
    days_2 = [0,1,2]
    days_3 = [0,2,4]
    days_4 = [0]

    assert_equal [date], split_booking(date,days_1)
    assert_equal [date], split_booking(date,days_4)
    assert_equal [date,date.tomorrow,date.tomorrow.tomorrow], split_booking(date,days_2)
    assert_equal [date,date.tomorrow.tomorrow,date.tomorrow.tomorrow.tomorrow.tomorrow], split_booking(date,days_3)

  end

  def test_select_risk_bookings_pre
    booking = Booking.find 39
    bookings = select_risk_bookings_pre(booking)
    bookings.inspect
    assert true
  end



  def test_select_risk_bookings

  end

  def test_build_day_bits2

  end

  def test_build_day_bits

  end

  def test_build_hour_bits
    booking = Booking.new
    booking.starttime = Time.now
    booking.endtime =Time.now + 60*60*3

    booking2 = Booking.new
    booking2.starttime = Time.now
    booking2.endtime = Time.now

    booking3 = Booking.new
    booking3.starttime = Time.now
    booking3.endtime = Time.now + 60*30

    booking4 = Booking.new
    booking4.starttime = Time.now
    booking4.endtime = Time.now + 60*60

    assert_equal 1<<16 | 1<<15 | 1<<14 | 1<<13 | 1<<12 | 1<<11 , build_hour_bits(booking)
    assert_equal 1<<16,build_hour_bits(booking2)
    assert_equal 1<<16 , build_hour_bits(booking3)
    assert_equal 1<<16 | 1<<15 , build_hour_bits(booking4)

  end

  def test_select_risk_times

  end

  def test_compare_date

    date1 = Date.current
    date2 = Date.tomorrow
    date3 = Date.yesterday

    assert_equal 0,compare_date(date1,date1)
    assert_equal 0,compare_date(date2,date2)
    assert_equal 0,compare_date(date3,date3)
    assert_equal -1,compare_date(date1,date2)
    assert_equal -1,compare_date(date3,date1)
  end

end

class Notifier < ActionMailer::Base

  include IcsHelper
  include BookingsHelper

  default from: "room_booker@rbcon.com"

  # send a notification mail to the organizer and all invitees if one booking done
  def notification_mail(booking)

    @booking_organizer = User.find(booking.user_id).username
    @booking = booking

    filename = "tmpfile/"+booking.guid
    ics_content = generate_ics(booking)

    mail_addr = User.find(booking.user_id).username
    mails_addr = split_invitees(booking.invitees)
    mails_addr << mail_addr

    attachments['invite.ics'] = {:content => ics_content.to_s, :mime_type => "text/calendar"}

    mail(:to => mails_addr, :subject => booking.summary, :template_path => "notifier", :template_name => "content" )

  end

end

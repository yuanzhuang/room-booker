class Notifier < ActionMailer::Base

  include IcsHelper

  default from: "room_booker@rbcon.com"

  # send a notification mail to the organizer and all invitees if one booking done
  def notification_mail(booking)



    filename = "tmpfile/"+booking.guid
    ics_content = generate_ics(booking)
    ics_file = File.new( filename, "w")
    ics_file.write(ics_content.to_s)
    ics_file.close

    attachments['invite.ics'] = File.read(filename)

    mail(:to => "whywhy36@sina.com", :subject => "Test SendGrid Service", :template_path => "notifier", :template_name => "another" )

  end

end

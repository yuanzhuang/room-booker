# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
RoomBooker::Application.initialize!

ActionMailer::Base.smtp_settings = {
    :user_name => "cftester",
    :password => "cloudf1",
    :domain => 'gmail.com',
    :address => "smtp.sendgrid.net",
    :port => 587,
    :authentication => :plain,
    :enable_starttls_auto => true
}

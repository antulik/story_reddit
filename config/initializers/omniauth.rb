require 'omniauth'

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :story, ENV['DOORKEEPER_APP_ID'], ENV['DOORKEEPER_APP_SECRET'], :client_options => {:site => ENV['DOORKEEPER_APP_URL']}
end

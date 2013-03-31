StoryGem.configure do |config|
  config.consumer_key    = ENV['DOORKEEPER_APP_ID']
  config.consumer_secret = ENV['DOORKEEPER_APP_SECRET']
  config.endpoint        = ENV['DOORKEEPER_APP_URL']
end

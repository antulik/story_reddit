module ApplicationHelper
  def addons_url
    "#{ENV['DOORKEEPER_APP_URL']}/addons"
  end
end

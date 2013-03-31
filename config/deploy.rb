require "bundler/setup"
require "bundler/capistrano"

set :application, "story_reddit"
set :server_name, 'story-reddit.antonkatunin.com'
set :repository, 'git@github.com:antulik/story_reddit.git'

require 'antulik/server1/config'

require 'whenever/capistrano'

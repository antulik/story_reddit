namespace :sync do

  task :fetch => :environment do
    User.all.each do |user|
      puts "synchronising user #{user.id}"
      sync = RedditSynchronizer.new(user)
      sync.sync_popular_subreddits
    end
  end

end

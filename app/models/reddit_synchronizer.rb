class RedditSynchronizer

  attr_accessor :user

  def initialize user
    self.user = user
  end

  def story_client
    @story_client ||= StoryGem::Client.new(:oauth_token => user.story_token)
  end


  def story_calendars
    @story_calendars ||= story_client.calendars
  end

  def story_calendar_get_or_create external_id
    calendar = story_calendars.detect { |c| c.external_id == external_id }

    if calendar.nil?
      subreddit = reddit_client.subreddit_info(external_id)
      subreddit = get_object subreddit

      random_color = "%06x" % (rand * 0xffffff)
      story_client.calendar_create({
          summary:       subreddit['display_name'],
          description:   subreddit['public_description'],
          external_type: '',
          external_id:   external_id,
          color:         "##{random_color}",
          event_type:    'link'

      })
    else
      calendar
    end
  end

  def sync_popular_subreddits
    subreddits = reddit_client.get_reddits(:condition => 'popular', :limit => 5)
    subreddits = get_collection subreddits

    subreddits.each do |subreddit|
      subreddit = subreddit['data']

      sync_subreddit subreddit['display_name']
    end
  end

  def sync_subreddit subreddit

    listings = reddit_client.get_listing(:subreddit => subreddit, :page => 'top', :limit => 100)
    listings = get_collection listings

    import_data = listings.map do |listing|
      listing = listing['data']
      {
          :external_id        => listing['id'],
          :description        => listing['title'],
          :permalink          => "http://reddit.com#{listing['permalink']}",
          :posted_by_username => listing['author'],
          :content_thumbnail  => listing['thumbnail'],
          :content_url        => listing['url'],
          :size               => listing['score'],
          :start              => Time.at(listing['created_utc']).to_s,
          :raw_data           => listing
      }
    end

    calendar = story_calendar_get_or_create subreddit
    story_client.events_import(calendar.id, import_data)
  end

  def reddit_client
    @reddit_client ||= Snoo::Client.new
  end

  # SUBREDDIT
  #{"kind"    => "t5",
  #    "data" =>
  #        {"header_img"            => "http://c.thumbs.redditmedia.com/cqqKDqD3imcNj2iV.png",
  #            "header_title"       => "2 Million! Logo by corvuskorax",
  #            "description"        => "blah",
  #            "description_html"   => "blah",
  #            "title"              => "/r/Pics",
  #            "url"                => "/r/pics/",
  #            "created"            => 1201224669.0,
  #            "created_utc"        => 1201221069.0,
  #            "public_description" => "A place to share interesting photographs and pictures.",
  #            "accounts_active"    => 16690,
  #            "over18"             => false,
  #            "header_size"        => [150, 56],
  #            "subscribers"        => 2984862,
  #            "display_name"       => "pics",
  #            "id"                 => "2qh0u",
  #            "name"               => "t5_2qh0u"}}


  # LISTING
  #{"kind"    => "t3",
  #    "data" =>
  #        {"domain"                    => "imgur.com",
  #            "banned_by"              => nil,
  #            "media_embed"            => {},
  #            "subreddit"              => "pics",
  #            "selftext_html"          => nil,
  #            "selftext"               => "",
  #            "likes"                  => nil,
  #            "link_flair_text"        => nil,
  #            "id"                     => "16f69v",
  #            "clicked"                => false,
  #            "title"                  => "I see your photogenic Iguana and raise you my smiling iguana",
  #            "num_comments"           => 0,
  #            "score"                  => 2,
  #            "approved_by"            => nil,
  #            "over_18"                => false,
  #            "hidden"                 => false,
  #            "thumbnail"              => "http://f.thumbs.redditmedia.com/IlvipKbyqrKzy_RM.jpg",
  #            "subreddit_id"           => "t5_2qh0u",
  #            "edited"                 => false,
  #            "link_flair_css_class"   => nil,
  #            "author_flair_css_class" => nil,
  #            "downs"                  => 1,
  #            "saved"                  => false,
  #            "is_self"                => false,
  #            "permalink"              =>
  #                "/r/pics/comments/16f69v/i_see_your_photogenic_iguana_and_raise_you_my/",
  #            "name"                   => "t3_16f69v",
  #            "created"                => 1357992758.0,
  #            "url"                    => "http://imgur.com/Yivdo",
  #            "author_flair_text"      => nil,
  #            "author"                 => "ThatBillKid",
  #            "created_utc"            => 1357963958.0,
  #            "media"                  => nil,
  #            "num_reports"            => nil,
  #            "ups"                    => 3}}


  def get_object response
    response.parsed_response['data']
  end

  def get_collection response
    response.parsed_response['data']['children']
  end

end
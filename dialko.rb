# -*- coding: utf-8 -*-

require 'yaml'

require 'rubygems'
require 'twitter'

require_relative 'getjson'

class Array
  def choice
    self[rand(self.size)]
  end
end

puts 'start'

dir = File.dirname(File.expand_path(__FILE__))
account = YAML.load_file(dir + '/account.yaml')
dialko = (proc {
  begin
    YAML.load_file(dir + '/dialko.yaml')
  rescue => e
    p e
    {}
  end
}).call

Twitter.configure do |config|
  config.consumer_key = account['consumer_key']
  config.consumer_secret = account['consumer_secret']
  config.oauth_token = account['oauth_token']
  config.oauth_token_secret = account['oauth_token_secret']
end

# 過去Tweets
#
now = DateTime.now
yearago = now << 12
puts yearago

last_watched_datetime_for_retro = DateTime.parse(dialko['last_watched_datetime_for_retro'] ||  yearago.to_s)

json = getJson(yearago)
json.reverse!

target = nil
json.each do |tweet|
  next if ['@', '#'].any? {|e| tweet['text'].include?(e)}
  created_at = DateTime.parse(tweet['created_at'])
  if (created_at > last_watched_datetime_for_retro and created_at <= yearago)
    target = tweet
    last_watched_datetime_for_retro = created_at
    break
  end
end

if target
  puts target
  Twitter.update(target['text'])
end

dialko['last_watched_datetime_for_retro'] = last_watched_datetime_for_retro.to_s

# Tweetへの反応
#
Twitter.home_timeline.each do |tweet|
  break if !dialko['last_watched_id'] or tweet.id <= dialko['last_watched_id']
  next if tweet.user.screen_name == 'dialko'
  puts "processing: #{tweet.id}, #{tweet.text}, #{tweet.user.screen_name}"
  case tweet.text
  when /^@dialko repeat (.+)$/
    Twitter.update($1)
  when /寝る前の薬飲んだ/
    Twitter.update("@#{tweet.user.screen_name} かしこまりました、おやすみなさいませ。")
  when /薬飲んだ/
    Twitter.update("@#{tweet.user.screen_name} かしこまりました。#{Time.now.strftime('%T')}に承りました。")
  when /(dialko|ディアル子)/
    Twitter.update(['はい。', 'はい…。', 'えっ？', 'そんな…。'].choice)
  end
end

dialko['last_watched_id'] = Twitter.home_timeline.first.id

# 終了処理
#
YAML.dump(dialko, File.open(dir + '/dialko.yaml', 'w'))
puts 'finish'

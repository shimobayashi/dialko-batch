# -*- coding: utf-8 -*-

require 'yaml'

require 'rubygems'
require 'twitter'

class Array
  def choice
    self[rand(self.size)]
  end
end

puts 'start'

dir = File.dirname(File.expand_path(__FILE__))
account = YAML.load_file(dir + '/account.yaml')
dialko = YAML.load_file(dir + '/dialko.yaml')

Twitter.configure do |config|
  config.consumer_key = account['consumer_key']
  config.consumer_secret = account['consumer_secret']
  config.oauth_token = account['oauth_token']
  config.oauth_token_secret = account['oauth_token_secret']
end

Twitter.home_timeline.each do |tweet|
  break if tweet.id <= dialko['last_watched_id']
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
YAML.dump(dialko, File.open(dir + '/dialko.yaml', 'w'))

puts 'finish'

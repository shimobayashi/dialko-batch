require 'yaml'

require 'rubygems'
require 'twitter'

dir = File.dirname(File.expand_path(__FILE__))
account = YAML.load_file(dir + '/account.yaml')
dialko = YAML.load_file(dir + '/dialko.yaml')

Twitter.configure do |config|
  config.consumer_key = account.consumer_key
  config.consumer_secret = account.consumer_secret
  config.oauth_token = account.oauth_token
  config.oauth_token_sercret = account.oauth_token_sercret
end

c = 0
Twitter.home_timeline.each do |tweet|
  p tweet
  c += 1
  exit if c > 20
end

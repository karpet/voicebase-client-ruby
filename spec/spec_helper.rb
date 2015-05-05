# use local 'lib' dir in include path
$:.unshift File.dirname(__FILE__)+'/../lib'
require 'voicebase'
require 'json'
require 'pp'
require 'dotenv'

Dotenv.load

RSpec.configure do |config|
  #config.run_all_when_everything_filtered = true
  #config.filter_run :focus
  config.color = true

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'
end

# assumes ID and SECRET set in env vars
AUTH_ID     = ENV['VB_ID']
AUTH_SECRET = ENV['VB_SECRET']
if !AUTH_ID or !AUTH_SECRET
  abort("Must set VB_ID and VB_SECRET env vars -- did you create a .env file?")
end

def get_vb_client
  VoiceBase::Client.new(
  :id => AUTH_ID,
  :secret => AUTH_SECRET,
  # must duplicate env var because we modify it with gsub
  :host   => (ENV['VB_HOST'] || 'https://apis.voicebase.com').dup.to_s,
  :debug  => ENV['VB_DEBUG'],
  #:croak_on_404 => true
  )
end

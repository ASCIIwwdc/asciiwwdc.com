require 'bundler'
Bundler.require

DB = Sequel.connect(ENV['DATABASE_URL'])

Rack::Mime::MIME_TYPES.merge!({
  ".srt" => "text/plain",
  ".vtt" => "text/vtt",
})

use Rack::Static, urls: ["/css", "/images", "/js", "favicon.ico"], root: "public"
use Rack::Gauges, tracker: ENV['GAUGES_TRACKER_ID'] if ENV['GAUGES_TRACKER_ID']

require './web'

run Web

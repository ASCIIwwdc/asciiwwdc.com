require 'bundler'
Bundler.require

DB = Sequel.connect(ENV['DATABASE_URL'])

Rack::Mime::MIME_TYPES.merge!({
  ".srt" => "text/plain",
  ".vtt" => "text/vtt",
})

use Rack::Static, urls: ["/css", "/images", "/js", "favicon.ico"], root: "public"
use Rack::GoogleAnalytics, tracker: ENV['GOOGLE_ANALYTICS_TRACKER'] if ENV['GOOGLE_ANALYTICS_TRACKER']

require './web'

use Rack::Deflater
run Web

require 'bundler'
Bundler.require

Sequel.extension :core_extensions, :migration
DB = Sequel.connect(ENV['DATABASE_URL'])
DB.extension :pg_array

Rack::Mime::MIME_TYPES.merge!({
  ".srt" => "text/plain",
  ".vtt" => "text/vtt",
})

use Rack::Static, urls: ["/css", "/images", "/js", "favicon.ico"], root: "public"

require './web'

use Rack::Deflater
run Web

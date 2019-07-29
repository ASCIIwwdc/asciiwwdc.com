# frozen_string_literal: true

require 'bundler'
Bundler.require

Sequel.extension :core_extensions, :migration
DB = Sequel.connect(ENV['DATABASE_URL'])
DB.extension :pg_array

Rack::Mime::MIME_TYPES.merge!(
  '.srt' => 'text/plain',
  '.vtt' => 'text/vtt'
)

use Rack::SslEnforcer if ENV['RACK_ENV'] == 'production'
use Rack::HeadersFilter
use Rack::Deflater
use Rack::Static, urls: ['/css', '/images', '/js', 'favicon.ico'],
                  root: 'public'

if ENV['REDIS']
  use Rack::Cache, metastore: "#{ENV['REDIS']}/0/metastore",
                   entitystore: "#{ENV['REDIS']}/0/entitystore"
end

require './web'

run Web

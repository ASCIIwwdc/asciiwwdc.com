# frozen_string_literal: true

require './lib/models/session'

class Web < Sinatra::Base
  register Sinatra::Contrib
  helpers Sinatra::Param

  set :raise_sinatra_param_exceptions, true
  set :show_exceptions, !settings.production?
  set :raise_errors, true
  set :supported_mime_types, lambda {
    [
      'text/html',
      'application/json',
      'text/vtt',
      'text/plain',
      'application/rss+xml'
    ].flat_map { |content_type| MIME::Types[content_type] }
  }.call

  helpers do
    def title(*args)
      [*args].compact.join(' - ')
    end

    def url(session)
      request.base_url + "/#{session.year}/sessions/#{session.number}"
    end

    def image_url(session)
      request.base_url + case Integer(session.year)
                         when 2010, 2011
                           "/images/wwdc-#{session.year}.jpg"
                         else
                           "/images/wwdc-#{session.year}.png"
                         end
    end

    def video_url(session)
      "https://developer.apple.com/videos/wwdc/#{session.year}/?id=#{session.number}"
    end
  end

  before do
    @query = params[:q]

    cache_control :public, max_age: 86_400

    settings.supported_mime_types.each do |mimetype|
      extension = '.' + mimetype.preferred_extension
      next unless request.path.end_with?(extension)

      request.accept.unshift(mimetype)
      request.path_info = request.path_info.chomp(extension)
      break
    end

    unless settings.development?
      headers 'Content-Security-Policy' => %(
                  default-src 'self' *.asciiwwdc.com;
                  form-action 'self';
                  frame-ancestors 'none';
                  object-src 'none';
                  base-uri 'none';
              ).gsub("\n", ' ').squeeze(' ').strip,
              'Link' => %(
                  </css/screen.css>; rel=preload; as=style
              ).gsub("\n", ' ').squeeze(' ').strip,
              'Referrer-Policy' => 'same-origin',
              'Server' => '',
              'Strict-Transport-Security' => 'max-age=63072000; includeSubDomains; preload',
              'X-Content-Type-Options' => 'nosniff',
              'X-Frame-Options' => 'DENY',
              'X-XSS-Protection' => '1; mode=block'
    end
  end

  error Sinatra::Param::InvalidParameterError do
    haml :error, locals: { message: env['sinatra.error'], code: 400 }
  end

  error 404 do
    haml :error, locals: { message: 'Not found', code: 404 }
  end

  get '/' do
    @sessions = Session.select(:title, :year, :number, :track)
                       .order(:year, :number)
                       .all
                       .group_by(&:year)
    haml :index
  end

  get '/contribute' do
    haml :contribute
  end

  get '/:year/sessions/:number.?:format?', provides: %i[html json vtt txt] do
    param :year, Integer, required: true
    param :number, Integer, required: true

    unless @session = Session.first(year: params[:year], number: params[:number])
      halt 404
    end

    link video_url(@session), rel: :alternate

    respond_to do |f|
      f.html { haml :session }
      f.json { @session.to_json }
      f.vtt  { send_file "data/#{params[:year]}/#{params[:number]}.vtt", type: :vtt }
      f.txt  { @session.transcript }
    end
  end

  get '/search.?:format?', provides: %i[html json rss] do
    param :q, String, blank: false
    param :year, Integer, in: 2010..2019

    @sessions = Session.search(@query, params[:year])

    respond_to do |f|
      f.html { haml :search }
      f.json do
        headers['Content-Type'] = 'application/json'

        {
          query: @query,
          results: @sessions.collect(&:to_h)
        }.to_json
      end
      f.rss {
          headers['Content-Type'] = 'application/rss+xml'

          builder :'search.rss'
      }
    end
  end

  get '/sitemap.xml' do
    headers['Content-Type'] = 'application/xml'

    @sessions ||= Session.select(:title, :year, :number, :track)
                         .order(:year, :number)
                         .all

    builder :'sitemap.xml'
  end

  get '/open-search.xml' do
    headers['Content-Type'] = 'text/xml'

    builder :'open-search.xml'
  end

  get %r{/(?<year>\d{4})/} do
    param :year, Integer

    case params[:year]
    when 2010..2019
      redirect "/#wwdc-#{params[:year]}"
    else
      pass
    end
  end
end

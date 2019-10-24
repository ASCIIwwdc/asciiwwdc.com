require './lib/models/session'

class Web < Sinatra::Base
  register Sinatra::Contrib
  helpers Sinatra::Param

  set :raise_sinatra_param_exceptions, true
  set :show_exceptions, !settings.production?
  set :raise_errors, true

  helpers do
    def title(*args)
      [*args].compact.join(" - ")
    end

    def url(session)
      "/#{session.year}/sessions/#{session.number}"
    end

    def image_url(session)
      case Integer(session.year)
      when 2010, 2011
        "/images/wwdc-#{session.year}.jpg"
      when 2012..2018
        "/images/wwdc-#{session.year}.png"
      else
        nil
      end
    end

    def video_url(session)
      "https://developer.apple.com/videos/wwdc/#{session.year}/?id=#{session.number}"
    end
  end

  before do
    @query = params[:q]

    cache_control :public, max_age: 3600

    headers "Content-Security-Policy" => %(
                default-src 'self' *.asciiwwdc.com;
                form-action 'self';
                frame-ancestors 'none';
                object-src 'none';
                base-uri 'none';
            ).gsub("\n", ' ').squeeze(' ').strip,
            "Link" => %(
                </css/screen.css>; rel=preload; as=style
            ).gsub("\n", ' ').squeeze(' ').strip,
            "Referrer-Policy" => "same-origin",
            "Server" => '',
            "Strict-Transport-Security" => "max-age=63072000; includeSubDomains; preload",
            "X-Content-Type-Options" => "nosniff",
            "X-Frame-Options" => "DENY",
            "X-XSS-Protection" => "1; mode=block" unless settings.development?
  end

  error Sinatra::Param::InvalidParameterError do
    haml :error, :locals => { :msg => env['sinatra.error'] }
  end

  error 404 do
    haml :error, :locals => { :msg => "404 Not found"}
  end

  not_found do
    haml :error, :locals => { :msg => "404 Not found"}
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

  get '/:year/sessions/:number', provides: [:html, :json, :vtt, :txt] do
    param :year, Integer, required: true
    param :number, Integer, required: true

    halt 404 unless @session = Session.first(year: params[:year], number: params[:number])

    link video_url(@session), :rel => :alternate

    respond_to do |f|
      f.html {haml :session}
      f.json {@session.to_json}
      f.vtt  {send_file "data/#{params[:year]}/#{params[:number]}.vtt", type: :vtt}
      f.txt  {@session.transcript}
    end
  end

  get '/search', provides: [:html, :json] do
    param :q, String, blank: false
    param :year, Integer, in: 2010..2018

    @sessions = Session.search(@query, params[:year])

    respond_to do |f|
      f.html {haml :search}
      f.json do
        {
          query: @query,
          results: @sessions.collect(&:to_h)
        }.to_json
      end
    end
  end

  get '/sitemap.xml' do
    @sessions = Session.order(:year, :number).all

    respond_to do |f|
      f.xml { builder :sitemap }
    end
  end

  get '/:year' do
    param :year, Integer

    case params[:year]
    when 2010..2018
      redirect "/#wwdc-#{params[:year]}"
    else
      pass
    end
  end

end

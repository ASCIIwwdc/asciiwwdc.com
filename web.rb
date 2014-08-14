require './lib/models/session'

class Web < Sinatra::Base
  register Sinatra::Contrib
  helpers Sinatra::Param

  helpers do
    def title(*args)
      [*args].compact.join(" - ")
    end

    def url(session)
      "/#{session.year}/sessions/#{session.number}"
    end

    def image_url(session)
      case Integer(session.year)
      when 2010, 2012..2014
        "/images/wwdc-#{session.year}.png"
      when 2011
        "/images/wwdc-#{session.year}.jpg"
      else
        nil
      end
    end

    def video_url(session)
      "https://developer.apple.com/videos/wwdc/#{session.year}/?id=#{session.number}"
    end
  end

  before do
    @query = Rack::Utils.escape_html(params[:q]) if params[:q]

    cache_control :public, max_age: 36000 unless @query
  end

  get '/' do
    @sessions = Session.order(:year, :number).all.group_by(&:year)

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
      f.vtt  {send_file "data/#{params[:year]}/#{params[:number]}.srt", type: :vtt}
      f.txt  {@session.transcript}
    end
  end

  get '/search', provides: [:html, :json] do
    param :q, String, blank: false
    param :year, Integer, in: 2010..2014

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
    when 2010..2014
      redirect "/#wwdc-#{params[:year]}"
    else
      pass
    end
  end
end

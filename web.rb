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
      when 2013
        "/images/wwdc-2013.png"
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

  get '/2013' do
    redirect '/'
  end

  get '/2012' do
    redirect '/'
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

    @sessions = Session.search(@query)

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
end

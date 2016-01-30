require 'csv'
require 'active_support/all'
require 'sinatra/base'
require 'json'
require 'net/http'
require 'logger'

require './WLDataLoader.rb'
require './Haltestelle.rb'
require './Linie.rb'
require './Steig.rb'



class WLData
  attr_accessor :haltestellen, :linien, :steige, :types

  def initialize
    @haltestellen = Hash.new
    @linien = Hash.new
    @steige = Hash.new
    @types = Hash.new
  end
end

class App < Sinatra::Base
  attr_reader :logger

  def self.data
    @@data
  end

  configure do
    enable :logging

    logger = Logger.new STDOUT
    @logger = logger
    logger.level = Logger::INFO
    logger.datetime_format = '%a %d-%m-%Y %H:%M:%S '
    set :logger, logger
    set :logging, logger

    # Load credentials
    begin
      filepath = ENV["CRED_FILE"]
      filepath ||= "creds.json"
      logger.debug "Reading api keys from creds.json"
      cred_file = File.open(filepath).read
      creds = JSON.parse(cred_file)['CONFIG']['CONFIG_VARS']
      logger.debug "Successfully parsed creds.json"
    rescue
      logger.error "Could not open or parse the creds.json file"
      creds = JSON.generate Hash.new
    end

    set :google_maps_api_key, creds["GOOGLE_MAPS_API_KEY"]
    set :wlsender, creds["WLSENDER"]

    WLDataLoader.update_csv_files
  end

  @logger.info "Lese Haltestellen..."

  @@data = WLData.new

  CSV.foreach("./wl-data/haltestellen.csv", col_sep: ';', headers: true) do |row|
    h = Haltestelle.new row
    @@data.haltestellen[h.id] = h
  end
  @logger.info "Fertig, insgesamt #{@@data.haltestellen.size} Haltestellen gelesen."

  @logger.info "Lese Linien..."

  CSV.foreach("./wl-data/linien.csv", col_sep: ';', headers: true) do |row|
    l = Linie.new row
    @@data.linien[l.id] = l
  end

  linien_types = @@data.linien.map {|id, l| l.verkehrsmittel }.uniq

  linien_types.each do |t|
    @@data.types[t] = @@data.linien.select do |id,l|
      l.is_a? Linie and l.verkehrsmittel == t
    end
  end

  @logger.info "Fertig, insgesamt #{@@data.linien.size} Linien gelesen."

  @logger.info "Lese Steige..."

  CSV.foreach("./wl-data/steige.csv", col_sep: ';', headers: true) do |row|
    s = Steig.new row

    h = @@data.haltestellen[s.haltestelle]
    @@data.linien[s.linie].haltestellen[s.reihenfolge.to_i] = h.id

    @@data.steige[s.id] = s
    h.steige << s.id
  end

  @logger.info "Fertig, insgesamt #{@@data.steige.size} Steige gelesen."



  def json_ids(objects)
    content_type :json
    id_hash = { anzahl: objects.size,
      ids: [] }

    objects.each_key do |id|
      id_hash[:ids].push id
    end

    id_hash.to_json
  end


  get '/' do
    erb :index, :layout => :application
  end

  get '/linien/?' do
    @linien = @@data.linien
    @types = @@data.types
    erb :linien, :layout => :application
  end

  get '/linien/:id' do
    @haltestellen = @@data.haltestellen
    
    @l = @@data.linien[params[:id].to_i]

    if @l
      erb :linie, :layout => :application
    else
      "Keine Linie gefunden"
    end
  end

  get '/haltestellen/?' do
    @haltestellen = @@data.haltestellen
    erb :haltestellen, :layout => :application
  end

  get '/haltestellen.json' do
    json_ids @@data.haltestellen
  end

  get '/linien.json' do
    json_ids @@data.linien
  end

  get '/steige.json' do
    json_ids @@data.steige
  end

  get '/haltestellen/:id.json' do
    content_type :json
    @h = @@data.haltestellen[params[:id].to_i]
    if @h
      @h.to_json
    else
      status 404
    end
  end

  get '/linien/:id.json' do
    content_type :json
    @linie = @@data.linien[params[:id].to_i]
    if @linie
      @linie.to_json
    else
      status 404
    end
  end

  get '/steige/:id.json' do
    content_type :json
    @steig = @@data.steige[params[:id].to_i]
    if @steig
      @steig.to_json
    else
      status 404
    end
  end

  get '/haltestellen/:id' do
    @h = @@data.haltestellen[params[:id].to_i]
    @steige = @@data.steige
    @linien = @@data.linien
    if @h
      @h.refresh_monitors
      erb :haltestelle, :layout => :application
    else
      "Keine Haltestelle gefunden"
    end
  end

  get '/karte/?' do
    @map = Hash.new
    erb :karte, :layout => :application
  end

  run! if app_file == $0
end

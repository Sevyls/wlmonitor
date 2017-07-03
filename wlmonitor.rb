require 'csv'
require 'active_support/all'
require 'sinatra/base'
require 'json'
require 'net/http'
require 'logger'
require "rack/cache"
require 'digest/sha1'

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

  use Rack::Cache

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
      creds['GOOGLE_MAPS_API_KEY'] = ENV['GOOGLE_MAPS_API_KEY']
      creds['WLSENDER'] = ENV['WLSENDER']
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
    h.linien << s.linie
  end

  @logger.info "Fertig, insgesamt #{@@data.steige.size} Steige gelesen."

  def not_found
    send_file 'public/404.html', status: 404
  end

  def json_ids(objects)
    content_type :json
    id_hash = { anzahl: objects.size,
      ids: [] }

    objects.each_key do |id|
      id_hash[:ids].push id
    end

    id_hash.to_json
  end

  before do
    expires 500, :public, :must_revalidate
  end


  get '/' do
    erb :index, :layout => :application
  end

  get '/linien/?' do
    @linien = @@data.linien
    @types = @@data.types
    erb :linien, :layout => :application
  end

  get '/haltestellen/?' do
    @haltestellen = @@data.haltestellen
    erb :haltestellen, :layout => :application
  end

  get '/haltestellen.json' do
    content_type :json
    json = @@data.haltestellen.to_json
    etag Digest::SHA1.base64digest json
    json
  end

  get '/linien.json' do
    content_type :json
    json = @@data.linien.to_json
    etag Digest::SHA1.base64digest json
    json
  end

  get '/steige.json' do
    content_type :json
    json = @@data.steige.to_json
    etag Digest::SHA1.base64digest json
    json
  end

  get '/haltestellen/:id.json' do
    @h = @@data.haltestellen[params[:id].to_i]
    if @h
      content_type :json
      json = @h.to_json
      etag Digest::SHA1.base64digest json
      json
    else
      not_found
    end
  end

  get '/linien/:id.json' do
    @linie = @@data.linien[params[:id].to_i]
    if @linie
      content_type :json
      json = @linie.to_json
      etag Digest::SHA1.base64digest json
      json
    else
      not_found
    end
  end

  get '/linien/:id' do
    @haltestellen = @@data.haltestellen

    @l = @@data.linien[params[:id].to_i]

    if @l

      etag Digest::SHA1.base64digest @l.to_s
      erb :linie, :layout => :application
    else
      not_found
    end
  end

  get '/steige/:id.json' do
    @steig = @@data.steige[params[:id].to_i]
    if @steig
      content_type :json
      json = @steig.to_json
      etag Digest::SHA1.base64digest json
      json
    else
      not_found
    end
  end

  get '/haltestellen/:id' do
    @h = @@data.haltestellen[params[:id].to_i]
    @steige = @@data.steige
    @linien = @@data.linien
    if @h
      @h.refresh_monitors
      expires 5
      erb :haltestelle, :layout => :application
    else
      not_found
    end
  end

  get '/karte/?' do
    @map = Hash.new
    erb :karte, :layout => :application
  end

  run! if app_file == $0
end

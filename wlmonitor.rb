require 'csv'
require 'active_support/all'
require 'sinatra'
require 'json'
require 'net/http'
require 'logger'
   

# Load credentials
begin
  filepath = ENV["CRED_FILE"]
  filepath ||= "creds.json"
  cred_file = File.open(filepath).read
  creds = JSON.parse(cred_file)['CONFIG']['CONFIG_VARS']
rescue
  puts "Could not open the creds.json file"
  creds = JSON.generate Hash.new
end

config = {
  :google_maps_api_key => creds["GOOGLE_MAPS_API_KEY"] || nil,
  :wlsender => creds["WLSENDER"] || nil,
}

configure do
  enable :logging
  set :logging, nil
    logger = Logger.new STDOUT
    logger.level = Logger::INFO
    logger.datetime_format = '%a %d-%m-%Y %H%M '
    set :logger, logger
  set :google_maps_api_key, config[:google_maps_api_key]
  set :wlsender, config[:wlsender]
end
logger = Logger.new STDOUT

class Haltestelle
  attr_accessor :id, :lat, :lon, :typ, :diva, :name, :gemeinde, :gemeinde_id, :steige, :json, :url

  # csv format: "HALTESTELLEN_ID";"TYP";"DIVA";"NAME";"GEMEINDE";"GEMEINDE_ID";"WGS84_LAT";"WGS84_LON"
  def initialize(csv_row)
    @id   = csv_row.field("HALTESTELLEN_ID")
    @lat  = csv_row.field("WGS84_LAT")
    @lon  = csv_row.field("WGS84_LON")
    @typ  = csv_row.field("TYP")
    @diva = csv_row.field("DIVA") # Haltestellennummer in der elektonischen Fahrplanauskunft
    @name = csv_row.field("NAME")
    @gemeinde = csv_row.field("GEMEINDE")
    @gemeinde_id = csv_row.field("GEMEINDE_ID")
    @steige = []
  end
  
  def refresh_monitors
    unless @steige.empty?
      rbl_nrs = @steige.map { |s| 
        # manche Steige haben keine RBL_NR im CSV...
        unless s.rbl_nr.empty?
          "rbl=#{s.rbl_nr}"
        else
          nil
        end  }.join('&')
      @url = "http://www.wienerlinien.at/ogd_realtime/monitor?#{rbl_nrs}&sender=#{Sinatra::Application.settings.wlsender}"
      
      resp = Net::HTTP.get_response(URI.parse(@url))
      unless resp.code == '500'
        data = resp.body
        @json = JSON.parse(data)
        monitors = @json["data"]["monitors"]
        @steige.each do |s|
          s.monitor = monitors.select do |monitor| 
            monitor['locationStop']['properties']['attributes']['rbl'] == s.rbl_nr.to_i and
            not (monitor['lines'].select {|line| line['direction'] == s.richtung }).empty? 
          end
        end
      end
    else
      nil
    end
  end
end

class Linie
  # "LINIEN_ID";"BEZEICHNUNG";"REIHENFOLGE";"ECHTZEIT";"VERKEHRSMITTEL";"STAND"

  attr_accessor :id, :bezeichnung, :reihenfolge, :echtzeit, :verkehrsmittel

  def initialize(csv_row)
    @id = csv_row.field("LINIEN_ID")
    @bezeichnung = csv_row.field("BEZEICHNUNG")
    @reihenfolge = csv_row.field("REIHENFOLGE")
    @echzeit = csv_row.field("ECHTZEIT")
    @verkehrsmittel = csv_row.field("VERKEHRSMITTEL")
  end
end

class Steig
  # "STEIG_ID";"FK_LINIEN_ID";"FK_HALTESTELLEN_ID";"RICHTUNG";"REIHENFOLGE";"RBL_NUMMER";"BEREICH";"STEIG";"STEIG_WGS84_LAT";"STEIG_WGS84_LON";"STAND"

  attr_accessor :id, :linie, :haltestelle, :richtung, :reihenfolge, :rbl_nr, :bereich, :steig, :lat, :lon, :monitor

  def initialize(csv_row)
    @id   = csv_row.field("STEIG_ID")
    @richtung = csv_row.field("RICHTUNG")
    @reihenfolge = csv_row.field("REIHENFOLGE")
    @rbl_nr = csv_row.field("RBL_NUMMER")
    @bereich = csv_row.field("BEREICH")
    @steig = csv_row.field("STEIG")
    @lat  = csv_row.field("STEIG_WGS84_LAT")
    @lon  = csv_row.field("STEIG_WGS84_LON")
  end
end

puts "Lese Haltestellen..."
haltestellen = Hash.new
CSV.foreach("./wl-data/wienerlinien-ogd-haltestellen.csv", col_sep: ';', headers: true) do |row|
  h = Haltestelle.new row
  haltestellen[h.id] = h
end
puts "Fertig, insgesamt #{haltestellen.size} Haltestellen gelesen."

linien = Hash.new

puts "Lese Linien..."

CSV.foreach("./wl-data/wienerlinien-ogd-linien.csv", col_sep: ';', headers: true) do |row|
  l = Linie.new row
  linien[l.id] = l
end
puts "Fertig, insgesamt #{linien.size} Linien gelesen."

steige = Hash.new

puts "Lese Steige..."

CSV.foreach("./wl-data/wienerlinien-ogd-steige.csv", col_sep: ';', headers: true) do |row|
  s = Steig.new row

  h = haltestellen[row.field("FK_HALTESTELLEN_ID")]
  s.haltestelle = h

  l = linien[row.field("FK_LINIEN_ID")]
  s.linie = l

  h.steige << s
  steige[s.id] = s
end

puts "Fertig, insgesamt #{steige.size} Steige gelesen."


get '/' do
  erb :index, :layout => :application
end

get '/linien' do
  @linien = linien
  erb :linien, :layout => :application
end

get '/linien/:id' do
  @l = linien[params[:id]]

  if @l
    erb :linie, :layout => :application
  else
    "Keine Linie gefunden"
  end
end

get '/haltestellen' do
  @haltestellen = haltestellen
  erb :haltestellen, :layout => :application
end

get '/haltestellen/:id' do
  @h = haltestellen[params[:id]]

  if @h
    @h.refresh_monitors
    erb :haltestelle, :layout => :application
  else
    "Keine Haltestelle gefunden"
  end
end

require 'csv'
require 'active_support/all'
require 'sinatra'
require 'json'

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
}

configure do
  set :google_maps_api_key, config[:google_maps_api_key]
end

class Haltestelle
  attr_accessor :id, :lat, :lon, :typ, :diva, :name, :gemeinde, :gemeinde_id, :steige

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

  attr_accessor :id, :linie, :haltestelle, :richtung, :reihenfolge, :rbl_nr, :bereich, :steig, :lat, :lon

  def initialize(csv_row)
    @id   = csv_row.field("STEIG_ID")
    @richtung = csv_row.field("RICHTUNG")
    @reihenfolge = csv_row.field("REIHENFOLGE")
    @rbl_nr = csv_row.field("RBL_NUMMER")
    @bereich = csv_row.field("BEREICH")
    @steig = csv_row.field("STEIG")
    @lat  = csv_row.field("WGS84_LAT")
    @lon  = csv_row.field("WGS84_LON")

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

get '/haltestellen' do
  @haltestellen = haltestellen
  erb :haltestellen, :layout => :application
end

get '/haltestellen/:id' do
  @h = haltestellen[params[:id]]

  if @h
    erb :haltestelle, :layout => :application
  else
    "Keine Haltestelle gefunden"
  end
end

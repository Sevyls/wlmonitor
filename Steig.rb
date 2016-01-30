class Steig
  # "STEIG_ID";"FK_LINIEN_ID";"FK_HALTESTELLEN_ID";"RICHTUNG";"REIHENFOLGE";"RBL_NUMMER";"BEREICH";"STEIG";"STEIG_WGS84_LAT";"STEIG_WGS84_LON";"STAND"

  attr_accessor :id, :linie, :haltestelle, :richtung, :reihenfolge, :rbl_nr, :bereich, :steig, :lat, :lon, :monitor

  def initialize(csv_row)
    @id          = csv_row.field("STEIG_ID").to_i
    @richtung    = csv_row.field("RICHTUNG")
    @reihenfolge = csv_row.field("REIHENFOLGE")
    @rbl_nr      = csv_row.field("RBL_NUMMER")
    @bereich     = csv_row.field("BEREICH")
    @steig       = csv_row.field("STEIG")
    @lat         = csv_row.field("STEIG_WGS84_LAT")
    @lon         = csv_row.field("STEIG_WGS84_LON")
    @haltestelle = csv_row.field("FK_HALTESTELLEN_ID").to_i
    @linie       = csv_row.field("FK_LINIEN_ID").to_i
  end

  def to_json
    { 'id' => @id,
      'richtung' => @richtung,
      'rbl_nr' => @rbl_nr,
      'lat' => @lat,
      'lon' => @lon
    }.to_json
  end
end

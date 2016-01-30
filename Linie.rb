class Linie
  # "LINIEN_ID";"BEZEICHNUNG";"REIHENFOLGE";"ECHTZEIT";"VERKEHRSMITTEL";"STAND"

  attr_accessor :id, :bezeichnung, :reihenfolge, :echtzeit, :verkehrsmittel, :haltestellen

  def initialize(csv_row)
    @id = csv_row.field("LINIEN_ID").to_i
    @bezeichnung = csv_row.field("BEZEICHNUNG")
    @reihenfolge = csv_row.field("REIHENFOLGE")
    @echtzeit = csv_row.field("ECHTZEIT")
    @verkehrsmittel = csv_row.field("VERKEHRSMITTEL")
    @haltestellen = Hash.new
  end

  def to_json
    { 'id' => @id,
      'bezeichnung' => @bezeichnung,
      'verkehrsmittel' => @verkehrsmittel
    }.to_json
  end
end

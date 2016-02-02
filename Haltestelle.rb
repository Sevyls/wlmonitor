class Haltestelle
  attr_accessor :id, :lat, :lon, :typ, :diva, :name, :gemeinde, :gemeinde_id, :steige, :json, :url

  # csv format: "HALTESTELLEN_ID";"TYP";"DIVA";"NAME";"GEMEINDE";"GEMEINDE_ID";"WGS84_LAT";"WGS84_LON"
  def initialize(csv_row)
    @id   = csv_row.field("HALTESTELLEN_ID").to_i
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
      rbl_nrs = []

      @steige.each do |steig_id|
        s = App.data.steige[steig_id]

        # manche Steige haben keine RBL_NR im CSV...
        unless s.rbl_nr.empty?
          rbl_nrs << "rbl=#{s.rbl_nr}"
        else
          nil
        end
      end
      rbl_nrs = rbl_nrs.join '&'
      App.logger.debug "haltestelle id: #{@id}, rbl_nrs: '#{rbl_nrs}'"
      url = "http://www.wienerlinien.at/ogd_realtime/monitor?#{rbl_nrs}&sender=#{App.settings.wlsender}"
      App.logger.debug "rbl_nrs: #{rbl_nrs}"

      unless rbl_nrs.empty?
        App.logger.debug "Sending GET request to #{url}"
        resp = Net::HTTP.get_response(URI.parse(url))
        if resp.code.eql? '200'
          App.logger.debug "HTTP 200 received"
          data = resp.body
          App.logger.debug "Parse json monitor data"
          @json = JSON.parse(data)
          monitors = @json["data"]["monitors"]
          @steige.each do |steig_id|
            s = App.data.steige[steig_id]
            s.monitor = monitors.select do |monitor|
              monitor['locationStop']['properties']['attributes']['rbl'] == s.rbl_nr.to_i and
              not (monitor['lines'].select {|line| line['direction'] == s.richtung }).empty?
            end
          end
        else
          App.logger.error resp.code
        end
      end
    else
      nil
    end
  end

  def to_json
    { 'id' => @id,
      'name' => @name,
      'lat' => @lat,
      'lon' => @lon
    }.to_json
  end
end

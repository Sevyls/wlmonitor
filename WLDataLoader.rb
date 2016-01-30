class WLDataLoader
  def self.update_csv_files
    # Load wl-data
    uris = {
      haltestellen: URI('http://data.wien.gv.at/csv/wienerlinien-ogd-haltestellen.csv'),
      linien:       URI('http://data.wien.gv.at/csv/wienerlinien-ogd-linien.csv'),
      steige:       URI('http://data.wien.gv.at/csv/wienerlinien-ogd-steige.csv'),
      version:      URI('http://data.wien.gv.at/csv/wienerlinien-ogd-version.csv')
    }

    uris.each do |name, uri|
      response = nil
      Net::HTTP.start(uri.host, uri.port) do |http|
        response = http.head(uri)

        if response.code_type.eql? Net::HTTPOK
          modified = response['Last-Modified']
          remoteModifiedDateTime = DateTime.httpdate modified

          filename = "wl-data/#{name}.csv"
          if not File.exist? filename or remoteModifiedDateTime > File.mtime(filename)
            # Download file
            response = http.get(uri)
            # Save file
            open(filename, "wb") do |file|
              file.write(response.body)
            end
            time = Time.parse(remoteModifiedDateTime.to_s)
            File.utime(time, time, filename)

            App.logger.info "Downloaded updated wldata file #{name}: #{modified}"
          else
            App.logger.debug "Did not download wldata file #{name}"
          end
        end
      end
    end
  end
end

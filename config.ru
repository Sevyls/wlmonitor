use Rack::Cors do
  allow do
    origins '*'
    resource '/haltestellen/*.json', :headers => :any, :methods => :get
  end
end

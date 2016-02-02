# wlmonitor
Wiener Linien Monitor Web App

## Dependencies
* Ruby 2.3.x
* Sinatra
* ActiveSupport

## API usage

* Google Maps JavaScript API
* Wien.gv.at OpenData APIs
** "Wiener Linien - Echtzeitdaten" (Vienna’s public transport Real time data) 

https://open.wien.at/site/datensatz/?id=add66f20-d033-4eee-b9a0-47019828e698
(CC BY 3.0 AT) Wiener Linien GmbH & Co KG

## Requirements
### Credentials file 
Define location via `ENV["CRED_FILE"]` or use `./creds.json`
Note: Compatible with cloudcontrol.com Config Plugin!

```json 
{"CONFIG":
  {"CONFIG_VARS":
    {"GOOGLE_MAPS_API_KEY":"<ENTER YOUR KEY HERE>",
     "WLSENDER":"<WIEN.GV.AT OPENDATA DEVELOPER API KEY HERE>"}
  }
}
```


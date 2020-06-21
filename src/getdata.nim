##
## SOURCE FILE: getdata.nim
##
## MIT License
## Copyright (c) 2019 Simon Rowe
##

# import the required Nim standard library modules
import httpclient, json, strformat, strutils, options, times

# import our own modules from this apps source code repo
import types, dbgUtils

proc returnWebSiteData*(webUrl: string, w: Weather): string =
  ##
  ## PROCEDURE: returnWebSiteData
  ## Input: final URL for DarkSky site to obtain forecast and Weather object
  ## Returns: raw web page body recieved and daily API calls count via w object
  ## Description: open the provided URL returning the web site content received
  ## also extract HTTP header to obtain API calls total. API calls total is
  ## updated directly into the Weather (w) passed to the proc.
  ##
  var client = newHttpClient()
  defer: client.close()
  let response = client.get(webUrl)
  result = response.body

  debug "web site reponse: " & response.status
  # output all recived web site data with below if needed
  #debug "web data receivedL " & result

  if response.code != Http200:
    stderr.writeLine "\nFATAL ERROR: web site returned unexpected status of: ",
        response.status, "\n"
    stderr.writeLine "Data received:\n\n", result, "\n\n"
    quit 1

  if result.len == 0:
    stderr.writeLine "\nFATAL ERROR: no data received from web site"
    quit 2

  if response.headers.hasKey "x-forecast-api-calls":
    w.dsApiCalls = response.headers["x-forecast-api-calls"]

proc returnParsedJson*(rawJsonData: string): JsonNode =
  ##
  ## PROCEDURE: returnParsedJson
  ## Input: raw web page body containing JSON data from DarkSky web site
  ## Returns: populated JsonNode containing weather forecast requested
  ## Description: read raw json data passed to the function and try to convert
  ## it into a JSON node object. If fails then raise an exception.
  ##
  debug "running: 'proc returnParsedJson'"

  try:
    result = parseJson(rawJsonData)
  except JsonParsingError:
    let
      e = getCurrentException()
      msg = getCurrentExceptionMsg()
    echo "Got JSON exception ", repr(e), " with message ", msg
  except:
    echo "Unknown exception error when parsing JSON!"

proc extractWeather*(w: Weather, jsonDataWeather: JsonNode) =
  ##
  ## PROCEDURE: extractWeather
  ## Input: Weather object, JsonNode (from DarkSky site)
  ## Returns: nothing.
  ## Description: use the weather JSON object to extract all the
  ## weather content needed into the local structure 'WeatherForecast'.
  ## The unmarshaled data is then placed in the 'w' object.
  # Structure to hold unmarshaled data created using 'nimjson' tool.
  type
    WeatherForecast = ref object
      latitude: float
      longitude: float
      timezone: string
      currently: Currently
      daily: Daily
      alerts: Option[seq[Alerts]]
    Currently = ref object
      time: int64
      summary: string
      icon: string
      temperature: float
      apparentTemperature: float
      windSpeed: float
      uvIndex: int64
    Daily = ref object
      summary: string
      icon: string
    Alerts = ref object
      title: string
      regions: seq[string]
      severity: string
      time: int64
      expires: int64
      description: string
      uri: string

  debug fmt"unmarshall 'jsonDataWeather' to object structure 'WeatherForecast'"

  # local 'weather' var created from above 'WeatherForcast' object type
  var weather: WeatherForecast

  # unmarshall 'jsonDataWeather' to object structure 'WeatherForecast'
  try:
    weather = to(jsonDataWeather, WeatherForecast)
  except:
    let e = getCurrentException()
    let msg = getCurrentExceptionMsg()
    echo fmt"ERROR: Got JSON unmarshal exception: '{repr(e)}' with message: {msg}"
    discard

  # get values needed from weather forecast JSON data:
  debug fmt"JSON unmarshall process completed"
  # below outputs all data or 'nil' if unmarshall above fails...
  #echo repr weather

  # ensure unmarshall worked and data was extracted ok... otherwise quit()
  if isNil weather:
    echo "FATAL ERROR: unmarshall of JSON weather provided no data"
    quit 3

  # TODO: add check to these to ensure a default value is used if missing?
  w.timezone = weather.timezone
  w.longitude = weather.longitude
  w.latitude = weather.latitude
  w.forecastTime = weather.currently.time
  w.summary = weather.currently.summary
  w.windspeed = weather.currently.windSpeed
  w.temperature = weather.currently.temperature
  w.feelsLikeTemp = weather.currently.apparentTemperature
  w.uvIndex = weather.currently.uvIndex
  w.daysOutlook = weather.daily.summary

  debug fmt"starting optional 'Alerts' data extraction..."

  if weather.alerts.isSome():
    debug fmt"optional weather 'Alerts' data available... extracting"
    # now we have some - extract the JSON weather alerts sequence also 
    let newAlertsSeq = weather.alerts.get()
    debug fmt"Alerts Sequenece is: {repr(newAlertsSeq)}"
    # Weather Alerts extraction - only if any exist:
    if newAlertsSeq.len > 0:
      w.alertTotal = newAlertsSeq.len
      debug fmt"found total 'weather Alerts': {w.alertTotal}"
      #var
      # for each weather alert found extract into a formated
      # for displayed as a formated block in the final
      for item in newAlertsSeq:
        # echo repr(item)
        let sdate:string = $fromUnix(item.time).format("ddd dd MMM yyyy HH:mm:ss")
        let edate:string = $fromUnix(item.expires).format("ddd dd MMM yyyy HH:mm:ss")
        var regionAll:string        
        # regions is containedin a seq - so obtian all
        for regionitem in item.regions: 
          regionAll.add fmt" {regionitem}"
        
        w.alertsDump.add fmt"""
 » Weather Alert 
     Alert Title        : {item.title}
     Region(s) Impacted : {strip(regionAll)}
     Weather Severity   : {toUpperAscii(item.severity)}
     Alert Valid From   : {sdate}
     Alert Ending on    : {edate}
     Further Details    : {item.uri}
     Alert Description  : {item.description}"""
    else:
      echo "No alert data found."

  else:
    debug fmt"no weather 'alerts' data identified"

type
  Weather* = ref object
    timezone*: string
    longitude*: float
    lonBearing*: string
    latitude*: float
    latBearing*: string
    forecastTime*: string
    summary*: string
    windspeed*: float
    temperature*: float
    feelsLikeTemp*: float
    uvIndex*: int64
    daysOutlook*: string
    timeFormated*: string #DateTime
    dsAPICalls*: string
    placeName*: string
    placeCountry*: string
    placeUnits*: string
    latConfig*: string
    lonConfig*: string
    darkskyUrl*: string
    darkskyKey*: string
    darkskyExclude*: string
    googleUrl*: string
    googleKey*: string
    alertTotal*: int
    alertsDump*: string
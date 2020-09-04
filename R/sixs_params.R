#' 6S parameters
#' 
#' Retrieves 6S radiative transfer model paremeters from the 6S web interface \url{https://www-loa.univ-lille1.fr/Wsixs/}. The parameters can be used to atmospherically correct VENµS satellite images.
#'
#' @param remote_driver RSelenium driver object, as returned by \code{RSelenium::remoteDriver}
#' @param day The day in which the image was taken [1-31]
#' @param month The month in which the image was taken [1-12]
#' @param SolarZenithalAngle The solar zenith when the image was taken [degrees, between -180 and 180]
#' @param SolarAzimuthalAngle The solar azimuth when the image was taken [degrees, between -180 and 180]
#' @param ViewZenithalAngle The view zenith of the sensor when the image was taken [degrees, between -180 and 180]
#' @param ViewAzimuthalAngle The view azimuth of the sensor when the image was taken [degrees, between -180 and 180]
#' @param Longitude The longitude of the center of the image [degrees, between -180 and 180]
#' @param Latitude The latitude of the center of the image [degrees, between -90 and 90]
#' @param Uw Value of Uw [g/cm^-2]. Can be found in the Aeronet website: https://aeronet.gsfc.nasa.gov/.
#' @param Uo3 Value of Uo3 [cm/atm]. Can be found in the Aeronet website: https://aeronet.gsfc.nasa.gov/.
#' @param opticalDepth Value of Atmospheric Optical Depth (AOD) in 550nm [cm/atm]. Can be found in Aeronet website: https://aeronet.gsfc.nasa.gov/.
#' @param LowerWavelength The lowest wavelength of the spectral band for correction
#' @param UpperWavelength The highest  wavelength of the spectral band for correction
#' @param TargetAltitude The height of the center of the image above sea level [Km]
#' @param GroundCondition The ground condition of the image, one of: \code{"Homogenous Ground"}, \code{"Patchy Ground"}.
#' @param TargetReflectance The target's reflectance type, one of: \code{"Constant"}, \code{"Vegetation"}, \code{"Clear Water"}, \code{"Sand"}, \code{"Lake Water"}.
#' @param EnvironmentReflectance The environment reflectance type of the image, one of: \code{"Constant"}, \code{"Vegetation"}, \code{"Clear Water"}, \code{"Sand"}, \code{"Lake Water"}.
#' @param TargetRadius The area of interest in the image [Km, the default is 0.5]
#' @param .delay Delay between each Selenium server step (for debugging purposes)
#' @param .screenshot Logical, if \code{TRUE} then a screenshot of the Selenium browser, named \code{rselenium_screenshot.png}, is written in the working directory at each step (for debugging purposes)
#'
#' @return Named vector of length three, with the 6S parameters \code{xa}, \code{xb}, and \code{xc}
#' 
#' @details The 6S radiative transfer model relates the top of the atmosphere reflectance or radiance (TOA) with the reflectance at satellite height, and the surface reflectance, using information about the atmospheric conditions, such as aerosol optical depth (AOD) and water vapor (WV) content (Vermote et al. 1997). 
#' The atmospheric correction coefficients (Xa, Xb, Xc) returned by the function can be used to calculate bottom of the atmosphere (BOM) reflectance from top of the atmosphere (TOA) radiance using the following formulas (1) and (2) (Zhao, Tamura, and Takahashi 2001):
#' 
#' (1) y = Xa*TOA-Xb
#' 
#' (2) BOA = y / (1+Xc*y)
#' 
#' where 'y' is an intermediate variable, 'TOA' is the top of the atmosphere radiance, 'BOA' is the bottom of the atmosphere reflectance, and 'Xa', 'Xb', 'Xc' are the correction coefficents returned by the \code{sixs_params} function. 
#' 
#' @references 
#' 
#' Vermote, E. F., Tanre, D., Deuze, J. L., Herman, M., & Morcette, J. J. (1997). Second simulation of the satellite signal in the solar spectrum, 6S: An overview. IEEE transactions on geoscience and remote sensing, 35(3), 675-686.
#' 
#' Zhao, W., Tamura, M., & Takahashi, H. (2001). Atmospheric and spectral corrections for estimating surface albedo from satellite data using 6S code. Remote sensing of Environment, 76(2), 202-212.
#' 
#' @export
#'
#' @examples
#' 
#' \dontrun{
#' 
#' library(RSelenium)
#' 
#' # Connect to Selenium server
#' remote_driver = remoteDriver(remoteServerAddr = "164.90.191.95", port = 4445L)
#' remote_driver$open(silent = TRUE)
#' 
#' # Test '6S'
#' xcoefficients = sixs_params(
#'   remote_driver = remote_driver, 
#'   day = 7,
#'   month = 7, 
#'   SolarZenithalAngle = 30, 
#'   SolarAzimuthalAngle = 117,
#'   ViewZenithalAngle = 25,
#'   ViewAzimuthalAngle = 112, 
#'   Longitude = 31, 
#'   Latitude = 34, 
#'   Uw = 1.52, 
#'   Uo3 = 0.38, 
#'   opticalDepth = 0.5, 
#'   LowerWavelength = 0.4, 
#'   UpperWavelength = 0.44,
#'   TargetAltitude = 0.342,
#'   GroundCondition = "Patchy Ground",
#'   TargetReflectance = "Vegetation",
#'   EnvironmentReflectance = "Vegetation", 
#'   TargetRadius = 0.5,
#'   .screenshot = TRUE
#' )
#' 
#' # Check result
#' xcoefficients == c(0.00627, 0.4462, 0.1665)
#' 
#' # Close connection
#' remote_driver$close()
#' 
#' }

sixs_params = function(
  remote_driver,
  day,
  month, 
  SolarZenithalAngle,
  SolarAzimuthalAngle,
  ViewZenithalAngle, 
  ViewAzimuthalAngle,
  Longitude,
  Latitude,
  Uw,
  Uo3,
  opticalDepth,
  LowerWavelength,
  UpperWavelength,
  TargetAltitude,
  GroundCondition = c("Homogenous Ground", "Patchy Ground"),
  TargetReflectance = c("Constant", "Vegetation", "Clear Water", "Sand", "Lake Water"),
  EnvironmentReflectance = c("Constant", "Vegetation", "Clear Water", "Sand", "Lake Water"),
  TargetRadius = 0.5,
  .delay = 0.5,
  .screenshot = FALSE
  ) {

################################################
# Check input parameters

# day
stopifnot(is.numeric(day))
stopifnot(length(day) == 1)
stopifnot(day %in% 1:31)
day = sprintf("%02d", day)

# month 
stopifnot(is.numeric(month))
stopifnot(length(month) == 1)
stopifnot(month %in% 1:12)
month = sprintf("%02d", month)

# SolarZenithalAngle
stopifnot(is.numeric(SolarZenithalAngle))
stopifnot(length(SolarZenithalAngle) == 1)
stopifnot(SolarZenithalAngle >= -180)
stopifnot(SolarZenithalAngle <= 180)
SolarZenithalAngle = as.character(SolarZenithalAngle)

# SolarAzimuthalAngle
stopifnot(is.numeric(SolarAzimuthalAngle))
stopifnot(length(SolarAzimuthalAngle) == 1)
stopifnot(SolarAzimuthalAngle >= -180)
stopifnot(SolarAzimuthalAngle <= 180)
SolarAzimuthalAngle = as.character(SolarAzimuthalAngle)

# ViewZenithalAngle
stopifnot(is.numeric(ViewZenithalAngle))
stopifnot(length(ViewZenithalAngle) == 1)
stopifnot(ViewZenithalAngle >= -180)
stopifnot(ViewZenithalAngle <= 180)
ViewZenithalAngle = as.character(ViewZenithalAngle)

# ViewAzimuthalAngle
stopifnot(is.numeric(ViewAzimuthalAngle))
stopifnot(length(ViewAzimuthalAngle) == 1)
stopifnot(ViewAzimuthalAngle >= -180)
stopifnot(ViewAzimuthalAngle <= 180)
ViewAzimuthalAngle = as.character(ViewAzimuthalAngle)

# Longitude
stopifnot(is.numeric(Longitude))
stopifnot(length(Longitude) == 1)
stopifnot(Longitude >= -180)
stopifnot(Longitude <= 180)
Longitude = as.character(Longitude)

# Latitude
stopifnot(is.numeric(Latitude))
stopifnot(length(Latitude) == 1)
stopifnot(Latitude >= -180)
stopifnot(Latitude <= 180)
Latitude = as.character(Latitude)

# Uw
stopifnot(is.numeric(Uw))
stopifnot(length(Uw) == 1)
Uw = as.character(Uw)

# Uo3
stopifnot(is.numeric(Uo3))
stopifnot(length(Uo3) == 1)
Uo3 = as.character(Uo3)

# opticalDepth
stopifnot(is.numeric(opticalDepth))
stopifnot(length(opticalDepth) == 1)
opticalDepth = as.character(opticalDepth)

# LowerWavelength
stopifnot(is.numeric(LowerWavelength))
stopifnot(length(LowerWavelength) == 1)
LowerWavelength = as.character(LowerWavelength)

# UpperWavelength
stopifnot(is.numeric(UpperWavelength))
stopifnot(length(UpperWavelength) == 1)
UpperWavelength = as.character(UpperWavelength)

# TargetAltitude
stopifnot(is.numeric(TargetAltitude))
stopifnot(length(TargetAltitude) == 1)
TargetAltitude = as.character(TargetAltitude)

# GroundCondition
stopifnot(length(GroundCondition) == 1)
GroundCondition = match.arg(GroundCondition)

# TargetReflectance
stopifnot(length(TargetReflectance) == 1)
TargetReflectance = match.arg(TargetReflectance)

# EnvironmentReflectance
stopifnot(length(EnvironmentReflectance) == 1)
EnvironmentReflectance = match.arg(EnvironmentReflectance)

# TargetRadius
stopifnot(is.numeric(TargetRadius))
stopifnot(length(TargetRadius) == 1)
TargetRadius = as.character(TargetRadius)

################################################
# Navigate to 6S website

remote_driver$navigate("https://www-loa.univ-lille1.fr/Wsixs/")
remote_driver$setTimeout(type = "implicit", milliseconds = 10000)

################################################
message("Step 1 - Geometrical Conditions")

check(.delay = .delay, .screenshot = .screenshot, remote_driver = remote_driver)

webElem = remote_driver$findElement("partial link text", "Geometrical Condition")
remote_driver$mouseMoveToLocation(webElement = webElem) 
remote_driver$click(1)

check(.delay = .delay, .screenshot = .screenshot, remote_driver = remote_driver)

remote_driver$setTimeout(type = "implicit", milliseconds = 10000)

address_element = remote_driver$findElement("id", "geo_day")
address_element$sendKeysToElement(list(day))

check(.delay = .delay, .screenshot = .screenshot, remote_driver = remote_driver)

address_element = remote_driver$findElement("id", "geo_month")
address_element$sendKeysToElement(list(month))

check(.delay = .delay, .screenshot = .screenshot, remote_driver = remote_driver)

address_element = remote_driver$findElement("id", "geo_opt1")
address_element$sendKeysToElement(list(SolarZenithalAngle))

check(.delay = .delay, .screenshot = .screenshot, remote_driver = remote_driver)

address_element = remote_driver$findElement("id", "geo_opt2")
address_element$sendKeysToElement(list(SolarAzimuthalAngle))

check(.delay = .delay, .screenshot = .screenshot, remote_driver = remote_driver)

address_element = remote_driver$findElement("id", "geo_opt3")
address_element$sendKeysToElement(list(ViewZenithalAngle))

check(.delay = .delay, .screenshot = .screenshot, remote_driver = remote_driver)

address_element = remote_driver$findElement("id", "geo_opt4")
address_element$sendKeysToElement(list(ViewAzimuthalAngle))

check(.delay = .delay, .screenshot = .screenshot, remote_driver = remote_driver)

address_element = remote_driver$findElement("id", "geo_opt5")
address_element$sendKeysToElement(list(Longitude))

check(.delay = .delay, .screenshot = .screenshot, remote_driver = remote_driver)

address_element = remote_driver$findElement("id", "geo_opt6")
address_element$sendKeysToElement(list(Latitude))

check(.delay = .delay, .screenshot = .screenshot, remote_driver = remote_driver)

################################################
message("Step 2 - Atmospheric Model")

webElem = remote_driver$findElement("partial link text", "Atmospheric Model")
webElem$getElementText()
remote_driver$mouseMoveToLocation(webElement = webElem) 
remote_driver$click(1)

check(.delay = .delay, .screenshot = .screenshot, remote_driver = remote_driver)

remote_driver$setTimeout(type = "implicit", milliseconds = 60000)

address_element = remote_driver$findElement("id", "atm_list")
remote_driver$setTimeout(type = "implicit", milliseconds = 10000)
address_element$sendKeysToElement(list("Uw and Uo3", key = "enter"))
remote_driver$setTimeout(type = "implicit", milliseconds = 10000)

check(.delay = .delay, .screenshot = .screenshot, remote_driver = remote_driver)

remote_driver$setTimeout(type = "implicit", milliseconds = 60000)

address_element = remote_driver$findElement("id", "atm_opt1")
address_element$sendKeysToElement(list(Uw))

check(.delay = .delay, .screenshot = .screenshot, remote_driver = remote_driver)

address_element = remote_driver$findElement("id", "atm_opt2")
address_element$sendKeysToElement(list(Uo3))

check(.delay = .delay, .screenshot = .screenshot, remote_driver = remote_driver)

remote_driver$setTimeout(type = "implicit", milliseconds = 60000)

address_element = remote_driver$findElement("id", "aer_list")
choice = address_element$getElementText()
choice = as.data.frame(choice)
b = substr(choice$X.No.Aerosols.nContinental.Model.nMaritime.Model.nUrban.Model.nUser.s.components.nShettle.model.nBiomass.burning.nStratospheric.model.nDistribution...Multimodal., 46,56)
remote_driver$setTimeout(type = "implicit", milliseconds = 60000)
address_element$sendKeysToElement(list(b))

check(.delay = .delay, .screenshot = .screenshot, remote_driver = remote_driver)

remote_driver$setTimeout(type = "implicit", milliseconds = 60000)

address_element = remote_driver$findElement("name", "atm_opt_depth")
address_element$sendKeysToElement(list(opticalDepth))

check(.delay = .delay, .screenshot = .screenshot, remote_driver = remote_driver)

################################################
message("Step 3 - Spectral Conditions")

webElem = remote_driver$findElement("partial link text", "Spectral Conditions")
webElem$getElementText()
remote_driver$mouseMoveToLocation(webElement = webElem) 
remote_driver$click(1)
remote_driver$setTimeout(type = "implicit", milliseconds = 10000)

check(.delay = .delay, .screenshot = .screenshot, remote_driver = remote_driver)

address_element = remote_driver$findElement("id", "choice_spec3")
address_element$getElementText()

check(.delay = .delay, .screenshot = .screenshot, remote_driver = remote_driver)

remote_driver$mouseMoveToLocation(webElement = address_element)
remote_driver$click(1)
address_element = remote_driver$findElement("id", "wave_low")
remote_driver$mouseMoveToLocation(webElement = address_element) 

check(.delay = .delay, .screenshot = .screenshot, remote_driver = remote_driver)

address_element = remote_driver$findElement("id", "wave_low2")
address_element$sendKeysToElement(list(LowerWavelength))

check(.delay = .delay, .screenshot = .screenshot, remote_driver = remote_driver)

address_element = remote_driver$findElement("id", "wave_up2")
address_element$sendKeysToElement(list(UpperWavelength))

check(.delay = .delay, .screenshot = .screenshot, remote_driver = remote_driver)

address_element = remote_driver$findElement("id", "xyform")
address_element$getElementText()

check(.delay = .delay, .screenshot = .screenshot, remote_driver = remote_driver)

remote_driver$mouseMoveToLocation(webElement = address_element)
remote_driver$click(1)

check(.delay = .delay, .screenshot = .screenshot, remote_driver = remote_driver)

################################################
message("Step 4 - Target & Sensor Altitude")

webElem = remote_driver$findElement("partial link text", "Target & Sensor Altitude")
webElem$getElementText()
remote_driver$mouseMoveToLocation(webElement = webElem) 
remote_driver$click(1)
remote_driver$setTimeout(type = "implicit", milliseconds = 10000)

check(.delay = .delay, .screenshot = .screenshot, remote_driver = remote_driver)

address_element = remote_driver$findElement("id", "senstarget")
choice = address_element$getElementText()
choice = as.data.frame(choice)
a = substr(choice$X.Sea.Level.nAltitude..km.., 11,30)
remote_driver$setTimeout(type = "implicit", milliseconds = 10000)
address_element$sendKeysToElement(list(a, key = "enter"))

check(.delay = .delay, .screenshot = .screenshot, remote_driver = remote_driver)

address_element = remote_driver$findElement("id", "senstargetvalue")
remote_driver$setTimeout(type = "implicit", milliseconds = 10000)
address_element$sendKeysToElement(list(TargetAltitude, key = "enter"))

check(.delay = .delay, .screenshot = .screenshot, remote_driver = remote_driver)

################################################
message("Step 5 - Ground Reflectance")

webElem = remote_driver$findElement("partial link text", "Ground Reflectance")
webElem$getElementText()
remote_driver$mouseMoveToLocation(webElement = webElem) 
remote_driver$click(1)

check(.delay = .delay, .screenshot = .screenshot, remote_driver = remote_driver)

remote_driver$setTimeout(type = "implicit", milliseconds = 10000)

address_element = remote_driver$findElement("id", "grd_gr")
remote_driver$setTimeout(type = "implicit", milliseconds = 10000)
address_element$sendKeysToElement(list(GroundCondition, key = "enter"))

check(.delay = .delay, .screenshot = .screenshot, remote_driver = remote_driver)

remote_driver$setTimeout(type = "implicit", milliseconds = 10000)

address_element = remote_driver$findElement("id", "grd_tar")
remote_driver$setTimeout(type = "implicit", milliseconds = 10000)
address_element$sendKeysToElement(list(TargetReflectance, key = "enter"))

check(.delay = .delay, .screenshot = .screenshot, remote_driver = remote_driver)

address_element = remote_driver$findElement("id", "grd_tar2")
remote_driver$setTimeout(type = "implicit", milliseconds = 10000)
address_element$sendKeysToElement(list(EnvironmentReflectance, key = "enter"))

check(.delay = .delay, .screenshot = .screenshot, remote_driver = remote_driver)

address_element = remote_driver$findElement("id", "targ_radius")
address_element$sendKeysToElement(list(TargetRadius, key = "enter"))

check(.delay = .delay, .screenshot = .screenshot, remote_driver = remote_driver)

################################################
message("Step 6 - Signal Source")

webElem = remote_driver$findElement("partial link text", "Signal Source")
remote_driver$mouseMoveToLocation(webElement = webElem) 
remote_driver$click(1)
address_element$setTimeout(type = "implicit", milliseconds = 10000)

check(.delay = .delay, .screenshot = .screenshot, remote_driver = remote_driver)

address_element = remote_driver$findElement("id", "signal_src")
remote_driver$setTimeout(type = "implicit", milliseconds = 10000)
address_element$sendKeysToElement(list("Ground signal retrieval from a measured signal", key = "enter"))

check(.delay = .delay, .screenshot = .screenshot, remote_driver = remote_driver)

address_element = remote_driver$findElement("id", "ground_signal_opt")
remote_driver$setTimeout(type = "implicit", milliseconds = 10000)
address_element$sendKeysToElement(list("Target BRDF proportional to input BRDF", key = "enter"))

check(.delay = .delay, .screenshot = .screenshot, remote_driver = remote_driver)

address_element = remote_driver$findElement("id", "input_value_gr")
address_element$sendKeysToElement(list("0.1"))

check(.delay = .delay, .screenshot = .screenshot, remote_driver = remote_driver)

address_element = remote_driver$findElement("name", "Submit")
remote_driver$mouseMoveToLocation(webElement = address_element)
remote_driver$click(1) 

check(.delay = .delay, .screenshot = .screenshot, remote_driver = remote_driver)

remote_driver$setTimeout(type = "implicit", milliseconds = 10000)

address_element = remote_driver$findElement("class", "frame3")
remote_driver$setTimeout(type = "implicit", milliseconds = 60000)
x = address_element$getElementText()[[1]]
x = as.data.frame(x)

check(.delay = .delay, .screenshot = .screenshot, remote_driver = remote_driver)

# Get coefficients
xcoefficients = substr(x$x, start = 12343, stop = 12408)
xcoefficients = strsplit(xcoefficients, " ")
xcoefficients = xcoefficients[[1]]
xcoefficients = xcoefficients[xcoefficients != ""]
xcoefficients = xcoefficients[(length(xcoefficients)-2):length(xcoefficients)]
xcoefficients = as.numeric(xcoefficients)
names(xcoefficients) = c("xa", "xb", "xc")
return(xcoefficients)

}


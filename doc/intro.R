## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>", 
  fig.align = "center", 
  fig.width = 6, 
  fig.height = 4
)

## ---- eval=FALSE--------------------------------------------------------------
#  install.packages("remotes")
#  remotes::install_github("michaeldorman/sixs")

## ---- eval=FALSE--------------------------------------------------------------
#  library(RSelenium)
#  remote_driver = remoteDriver(remoteServerAddr = "localhost", port = 4445L)
#  remote_driver$open(silent = TRUE)

## -----------------------------------------------------------------------------
library(RSelenium)

# Remote driver
remote_driver = remoteDriver(remoteServerAddr = "164.90.191.95", port = 4445L)

# Open
remote_driver$open(silent = TRUE)

# Browse to google.com & print page title
remote_driver$navigate("https://www.google.com")
remote_driver$getTitle()

# Close
remote_driver$close()

## -----------------------------------------------------------------------------
library(sixs)

## -----------------------------------------------------------------------------
venus1

## -----------------------------------------------------------------------------
plot(venus1)

## ---- eval=FALSE--------------------------------------------------------------
#  library(stars)
#  
#  # Read image
#  r = read_stars("/home/michael/Dropbox/Packages/sixs/other/venus_sample_data/images/VE_VM01_VSC_PDTIMG_L1VALD_ISRAEL03_20190204.DBL.TIF_crop.TIF", proxy = FALSE)
#  
#  # Subset bands
#  r = r[,,,1:12]

## -----------------------------------------------------------------------------
substr(venus1m, 1, 80)

## -----------------------------------------------------------------------------
bands

## -----------------------------------------------------------------------------
library(XML)
l = xmlToList(venus1m)
m = get_venus_metadata(l, band = 1)

## -----------------------------------------------------------------------------
m

## ---- eval=FALSE--------------------------------------------------------------
#  library(XML)
#  x = xmlParse("VE_VM01_VSC_L1VALD_ISRAEL03_20190204.HDR")
#  l = xmlToList(x)
#  m = get_venus_metadata(l, band = 1)

## -----------------------------------------------------------------------------
venus1 = venus1 * 0.001

## -----------------------------------------------------------------------------
venus1 = venus1[,,,3,drop=TRUE]
names(venus1) = "TOA reflectance"

## -----------------------------------------------------------------------------
plot(venus1)

## -----------------------------------------------------------------------------
m = get_venus_metadata(l, band = 3)
venus1_toa_rad = refl_to_rad(
  toa_refl = venus1,
  date = m$date,
  esun = bands$esun[3],
  solar_zenith_angle = m$solar_zenith_angle
)
names(venus1_toa_rad) = "Band 3, TOA radiance"

## -----------------------------------------------------------------------------
plot(venus1_toa_rad)

## ----fig1, echo=FALSE, fig.cap="Example of a list of AERONET stations"--------
knitr::include_graphics("fig1.png")

## ----fig2, echo=FALSE, fig.cap="A window of meteorological data for Sede Boker site in Israel. The links for downloading the relevant data are shown in red squares"----
knitr::include_graphics("fig2.png")

## -----------------------------------------------------------------------------
Uw = 0.665071
Uo3 = 0.2982371
opticalDepth = 0.1105934

## -----------------------------------------------------------------------------
GroundCondition = "Patchy Ground"
TargetReflectance = "Vegetation"
EnvironmentReflectance = "Vegetation" 
TargetRadius = 0.5

## -----------------------------------------------------------------------------
remote_driver$open(silent = TRUE)
xcoefficients = sixs_params(
  remote_driver = remote_driver, 
  day = as.numeric(format(m$date, "%d")),
  month = as.numeric(format(m$date, "%m")), 
  SolarZenithalAngle = m$solar_zenith_angle, 
  SolarAzimuthalAngle = m$solar_azimuth_angle,
  ViewZenithalAngle = m$view_zenith_angle,
  ViewAzimuthalAngle = m$view_azimuth_angle, 
  Longitude = m$longitude, 
  Latitude = m$latitude, 
  Uw = 0.665071, 
  Uo3 = 0.2982371, 
  opticalDepth = 0.1105934, 
  LowerWavelength = bands$lower[3], 
  UpperWavelength = bands$upper[3],
  TargetAltitude = m$elevation,
  GroundCondition = "Patchy Ground",
  TargetReflectance = "Vegetation",
  EnvironmentReflectance = "Vegetation", 
  TargetRadius = 0.5
)
remote_driver$close()

## -----------------------------------------------------------------------------
xcoefficients

## -----------------------------------------------------------------------------
venus1_boa_refl = toa_rad_to_boa_refl(
  toa_rad = venus1_toa_rad, 
  params = xcoefficients
)
names(venus1_boa_refl) = "Band 3, BOA reflectance"

## -----------------------------------------------------------------------------
plot(venus1_boa_refl)

## -----------------------------------------------------------------------------
library(sixs)
library(XML)
library(RSelenium)

# Get image metadata
data(venus1m)
l = xmlToList(venus1m)

# Empty list to keep results
result = list()

for(i in 1:12) {

  # Rescale and select band
  data(venus1)
  venus1 = venus1 * 0.001
  venus1 = venus1[,,,i,drop=TRUE]

  # Get image band metadata
  m = get_venus_metadata(l, band = i)

  # Convert TOA reflectance to TOA radiance
  venus1_toa_rad = refl_to_rad(
    toa_refl = venus1,
    date = m$date,
    esun = bands$esun[i],
    solar_zenith_angle = m$solar_zenith_angle
  )

  # Get 6S parameters
  remote_driver = remoteDriver(remoteServerAddr = "164.90.191.95", port = 4445L)
  remote_driver$open(silent = TRUE)
  xcoefficients = sixs_params(
    remote_driver = remote_driver, 
    day = as.numeric(format(m$date, "%d")),
    month = as.numeric(format(m$date, "%m")), 
    SolarZenithalAngle = m$solar_zenith_angle, 
    SolarAzimuthalAngle = m$solar_azimuth_angle,
    ViewZenithalAngle = m$view_zenith_angle,
    ViewAzimuthalAngle = m$view_azimuth_angle, 
    Longitude = m$longitude, 
    Latitude = m$latitude, 
    Uw = 0.665071, 
    Uo3 = 0.2982371, 
    opticalDepth = 0.1105934, 
    LowerWavelength = bands$lower[i], 
    UpperWavelength = bands$upper[i],
    TargetAltitude = m$elevation,
    GroundCondition = "Patchy Ground",
    TargetReflectance = "Vegetation",
    EnvironmentReflectance = "Vegetation", 
    TargetRadius = 0.5,
    quiet = TRUE
  )
  remote_driver$close()

  # Convert TOA radiance to BOA reflectance
  venus1_boa_refl = toa_rad_to_boa_refl(venus1_toa_rad, xcoefficients)

  # Add result to list
  result[[i]] = venus1_boa_refl

}

# Combine to multi-band raster
result$along = 3
result = do.call(c, result)

## -----------------------------------------------------------------------------
plot(result)

## ---- fig.height=6------------------------------------------------------------
# Extract reflectance profiles for one pixel
data(venus1)
toa_refl1 = venus1[[1]][80,80,] * 0.001
boa_refl1 = result[[1]][80,80,]

# Plot profiles
plot(
  x = rowMeans(bands[c("lower", "upper")]), y = toa_refl1, 
  type = "b", 
  xlab = "Wavelength (micrometers)", 
  ylab = "Reflectance", 
  ylim = range(c(toa_refl1, boa_refl1)),
  col = "red"
)
lines(
  x = rowMeans(bands[c("lower", "upper")]), 
  y = boa_refl1, 
  type = "b", 
  col = "blue"
)
legend(
  "bottomright",
  lty = c(1, 1),
  legend = c("TOA reflectance (original image)", "BOA reflectance (corrected)"), 
  col = c("red", "blue")
)


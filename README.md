
# The `sixs` package

## Purpose

The `sixs` package automates obtaining atmospheric correction parameters
from by programmatically filling up the [web
interface](https://www-loa.univ-lille1.fr/Wsixs/) with user-provided
inputs.

## Setup

### Installing the package

Package `sixs` can be installed from GitHub as follows:

``` r
install.packages("remotes")
remotes::install_github("michaeldorman/sixs")
```

### Setting up a Selenium server

#### Overview

Running the `sixs_params` function, to get the 6S parameters, requires a
Selenium server. The server connection needs to be passed as a parameter
named `remote_driver` to the `sixs_params` function.

The recommended way to run a Selenium server is through docker. Detailed
instructions on how to do that can be found in the [Docker
vignette](https://cran.r-project.org/web/packages/RSelenium/vignettes/docker.html)
of package `RSelenium`.

#### Local server

You can start your own local server, for example using the following
expression on the command line (Ubuntu 18.04):

``` sh
docker run -d -p 4445:4444 selenium/standalone-firefox:2.53.1
```

then connecting to the server from R to create the `remote_driver`
object:

``` r
library(RSelenium)
remote_driver = remoteDriver(remoteServerAddr = "localhost", port = 4445L)
remote_driver$open(silent = TRUE)
```

#### Demo server

Alternatively, you can use the demo server we set up for demontrating
the package. Here is a small example where we browse to google.com and
print the page title:

``` r
library(RSelenium)

# Remote driver
remote_driver = remoteDriver(remoteServerAddr = "164.90.191.95", port = 4445L)

# Open
remote_driver$open(silent = TRUE)

# Browse to google.com & print page title
remote_driver$navigate("https://www.google.com")
remote_driver$getTitle()
```

    ## [[1]]
    ## [1] "Google"

``` r
# Close
remote_driver$close()
```

Note that the connection needs to be closed at the end using:

``` r
remote_driver$close()
```

Keeping the connection open consumes RAM and eventually can make the
server crash\! The demo server is restarted automatically every day at
4AM. If you encounter a problem, please open an
[issue](https://github.com/michaeldorman/sixs/issues).

## Example

### Overview

The following sections demonstrate the entire process of going from a
raw Venus satellite image to an atmospherically-corrected reflectance
image.

### Input data

The input data includes:

1.  The Venus satellite image (`venus1`)
2.  The Venus satellite image metadata (`venus1m`)
3.  Venus bands metadata (`bands`)

The image:

``` r
library(sixs)
```

    ## Loading required package: stars

    ## Loading required package: abind

    ## Loading required package: sf

    ## Linking to GEOS 3.8.0, GDAL 3.0.4, PROJ 7.0.0

``` r
venus1
```

    ## stars object with 3 dimensions and 1 attribute
    ## attribute(s):
    ##      refl       
    ##  Min.   : 31.0  
    ##  1st Qu.:110.0  
    ##  Median :150.0  
    ##  Mean   :174.8  
    ##  3rd Qu.:227.0  
    ##  Max.   :599.0  
    ##  NA's   :2892   
    ## dimension(s):
    ##      from  to  offset delta                refsys point values x/y
    ## x       1 121  736830     5 WGS_1984_UTM_Zone_36N FALSE   NULL [x]
    ## y       1 121 3639028    -5 WGS_1984_UTM_Zone_36N FALSE   NULL [y]
    ## band    1  12      NA    NA                    NA    NA   NULL

``` r
plot(venus1)
```

![](README_files/figure-gfm/unnamed-chunk-6-1.png)<!-- -->

Metadata:

``` r
substr(venus1m, 1, 80)
```

    ## [1] "<?xml version=\"1.0\" encoding=\"UTF-8\"?><?xml-stylesheet type='text/xsl' href='DIS"

Venus bands metadata:

``` r
bands
```

    ##    band   lower   upper     esun
    ## 1     1 0.40399 0.44399 1661.634
    ## 2     2 0.42690 0.46690 1954.005
    ## 3     3 0.47190 0.51190 1990.678
    ## 4     4 0.53500 0.57500 1830.509
    ## 5     5 0.59970 0.63970 1669.217
    ## 6     6 0.59950 0.63950 1670.402
    ## 7     7 0.65120 0.68120 1510.949
    ## 8     8 0.69000 0.71400 1428.368
    ## 9     9 0.73310 0.74910 1290.557
    ## 10   10 0.77420 0.79020 1163.151
    ## 11   11 0.84110 0.88110  965.547
    ## 12   12 0.89870 0.91870  879.865

### Getting image metadata

Metadata from `HDR` file:

``` r
library(XML)
l = xmlToList(venus1m)
m = get_venus_metadata(l, band = 1)
m
```

    ## $date
    ## [1] "2019-02-04"
    ## 
    ## $solar_zenith_angle
    ## [1] 52.45633
    ## 
    ## $solar_azimuth_angle
    ## [1] 156.2326
    ## 
    ## $view_zenith_angle
    ## [1] 12.8512
    ## 
    ## $view_azimuth_angle
    ## [1] 168.3401
    ## 
    ## $longitude
    ## [1] 35.52071
    ## 
    ## $latitude
    ## [1] 32.95559
    ## 
    ## $elevation
    ## [1] 0.325

General metadata on Venus bands.

### Reflectance to radiance

Venus satellite images are provided in TOA reflectance values multiplied
by 1000. However, the 6S algorithm requires the imput to be TOA radiance
values.

Therefore, to proceed the image values need to be divided by 1000:

``` r
venus1 = venus1 * 0.001
```

In the example, we atmospherically correct a specific band (3),
therefore we also subset the third layer from the `venus1` image:

``` r
venus1 = venus1[,,,3,drop=TRUE]
names(venus1) = "TOA reflectance"
```

Here what the TOA reflectance values in band 3 of the `venus1` sample
image look like:

``` r
plot(venus1)
```

![](README_files/figure-gfm/unnamed-chunk-12-1.png)<!-- -->

Then, the resulting TOA reflectance values need to be converted back to
TOA radiance values. This can be done using function `refl_to_rad`.

Here is an example of converting the band 3 of the `venus1` image from
TOA reflectance to TOA radiance:

``` r
m = get_venus_metadata(l, band = 3)
venus1_toa_rad = refl_to_rad(
  toa_refl = venus1,
  date = m$date,
  esun = bands$esun[3],
  solar_zenith_angle = m$solar_zenith_angle
)
names(venus1_toa_rad) = "Band 3, TOA radiance"
```

``` r
plot(venus1_toa_rad)
```

![](README_files/figure-gfm/unnamed-chunk-14-1.png)<!-- -->

When the satellite image is given in radiance units, the inverse
`rad_to_refl` function can be used to convert it to a TOA reflectance
image. The required data includes the `date`, `esun` and
`solar_zenith_angle`, same as in `refl_to_rad`.

### Atmospheric parameters from Aeronet

The 6S algorithm requires obtaining three meteorological parameters from
the AERONET stations data, namely:

  - AOD550nm
  - Uw \[g cm-2\]
  - UO3 \[cm/atm\]

Here is how to obtain these parameters:

  - Navigate to the AERONET [web
    page](https://aeronet.gsfc.nasa.gov/cgi-bin/draw_map_display_aod_v3)
    to open the available data from AERONET stations worldwide.

  - Choose an AEORONET station that is geographically located near your
    site. It is possible to click on the map several times in order to
    zoom in and choose the relevant station easily. For example in
    Figure 1 below is a list of AERONET stations in the western Middle
    East (Israel, Egypt, Cyprus and Greece).

Figure 1: Example of a list of AERONET stations.

  - Click on the relevant station. This will open a window as shown in
    Figure 2.

  - Choose the relevant period (year) on the left panel. In case the
    user does not choose the relevant period, the website will return
    data for the current year as a default. Another option is to choose
    a specific relevant day on the right panel; however, it this is not
    useful for atmospheric correction of satellite imagery since these
    corrections require a daily temporal resolution and not hourly.

  - Click on AOD Level 1.0 to download the data.

Figure 2: A window of meteorological data for Sede Boker site in Israel.
The links for downloading the relevant data are shown in red squares.

  - Accept the data usage agreement in the window shown in Figure 3:

Figure 3: Acceptation of AERONET data usage.

  - Download and unzip the data (a `.lev1` file) and open the data in
    Excel using the option ‘from text’ in the ‘data’ tab.

  - Calculate the AOD in 550 nm: use the AOD in 675 nm (AOD\_675nm
    column) and AOD in 500 nm (AOD\_500nm column) in the formula below
    to calculate AOD in 550 nm:

  - Find the perceptible water value under the column
    ‘Precipitable\_Water(cm)’ that presents the water vapor (Uw) in
    \[g cm-2\].

  - Find the Ozone concentration value under the column ‘Ozone(Dobson)’
    that presents the O3 concentration in Dobson units. Multiply this
    value by 0.001 to obtain the Ozone concentration in \[cm/atm\].

Specifically for `venus1`, the required variables are:

``` r
Uw = 0.665071
Uo3 = 0.2982371
opticalDepth = 0.1105934
```

### Additional parameters

`GroundCondition` is usually `"Patchy Ground"`.

`TargetReflectance` depends on what the project focuses on.

`EnvironmentReflectance` depends on surrounding cover.

`TargetRadius` needs to be smaller than pixel size, in meters (for Venus
\<5.3)

``` r
GroundCondition = "Patchy Ground"
TargetReflectance = "Vegetation"
EnvironmentReflectance = "Vegetation" 
TargetRadius = 0.5
```

### 6S parameters

Once the server is set and the `remote_driver` object exists, you can
execute the `sixs_params` function to get the 6S parameters.

For example, for band 3 from the `venus1` image:

``` r
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
  TargetRadius = 0.5,
)
```

    ## Step 1 - Geometrical Conditions

    ## Step 2 - Atmospheric Model

    ## Step 3 - Spectral Conditions

    ## Step 4 - Target & Sensor Altitude

    ## Step 5 - Ground Reflectance

    ## Step 6 - Signal Source

``` r
remote_driver$close()
```

You can use the `.screenshot=TRUE` parameter in the above function call
for viewing the web interface throughout the process. This will create a
temporary file named `rselenium_screenshot.png` in the current working
directory.

The result is a named numeric vector with the 6S parameter values:

``` r
xcoefficients
```

    ##      xa      xb      xc 
    ## 0.00369 0.11777 0.12263

### TOA to BOA

Finally, using the 6S parameters we can conver the TOA radiance image to
a BOA reflectance image, using function `toa_to_boa`:

``` r
venus1_boa_refl = toa_to_boa(
  toa_rad = venus1_toa_rad, 
  params = xcoefficients
)
names(venus1_boa_refl) = "Band 3, BOA reflectance"
```

Here is the result:

``` r
plot(venus1_boa_refl)
```

![](README_files/figure-gfm/unnamed-chunk-20-1.png)<!-- -->

Done\!

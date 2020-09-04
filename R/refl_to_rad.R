#' Convert a TOA reflectance image to a TOA radiance image
#' 
#' Converts a TOA reflectance image to a TOA radiance image.
#' 
#' @param toa_refl A \code{stars} image with top of atmosphere reflectance values
#' @param date Acquisition date, needs to be \code{Date} of length 1
#' @param esun External solar radiation [W/m^2]. For Venus satellite bands, \code{esun} values are provided in the \code{bands} dataset.
#' @param solar_zenith_angle Solar zenith angle [degrees, between -180 and 180]
#' @return A \code{stars} image with top of atmosphere reflectance values
#' 
#' @details
#' Top of atmosphere radiance can be caulculated using the following formula:
#'  
#' L = TOA * (ESUN * cos(solar_zenith_angle) / (pi * d^2)
#' 
#' where 'L' is the top of atmosphere radiance, 'TOA' is the top of atmosphere reflectance, 'ESUN' is the external solar radiation and 'solar_zenith_angle' is the solar zenith angle.
#' 
#' @export
#' 
#' @examples
#' # Band 3 in sample image 'venus1'
#' library(stars)
#' library(XML)
#' 
#' # Reflectance Venus image, band 3
#' refl = venus1[,,,3,drop=TRUE] / 1000
#' 
#' # Metadata
#' l = xmlToList(venus1m)
#' m = get_venus_metadata(l, band = 1)
#' 
#' # Specific pixel value: reflectance
#' refl[[1]][100,100]  
#' 
#' # Conversion from reflectance to radiance
#' rad = refl_to_rad(
#'     toa_refl = refl,
#'     date = m$date,
#'     esun = bands$esun[3],
#'     solar_zenith_angle = m$solar_zenith
#' )
#' 
#' # Specific pixel value: radiance
#' rad[[1]][100,100]

refl_to_rad = function(toa_refl, date, esun, solar_zenith_angle) {

    # Checks
    stopifnot(length(class(toa_refl)) == 1)
    stopifnot(class(toa_refl) == "stars")
    stopifnot(length(dim(toa_refl[[1]])) == 2)
    stopifnot(inherits(date, "Date"))
    stopifnot(length(date) == 1)
    stopifnot(is.numeric(esun))
    stopifnot(length(esun) == 1)
    stopifnot(esun >= 0)
    stopifnot(is.numeric(solar_zenith_angle))
    stopifnot(length(solar_zenith_angle) == 1)
    stopifnot(solar_zenith_angle >= -180)
    stopifnot(solar_zenith_angle <= 180)

    # Calculate 'd' (earth-sun distance)
    doy = as.character(date, "%j")
    doy = as.numeric(doy)
    d = 1 + 0.033 * cos((2 * pi / 365) * doy)

    # To radians
    solar_zenith_angle = solar_zenith_angle * pi / 180

    # TOA reflectance -> TOA radiance
    toa_rad = toa_refl * (esun * cos(solar_zenith_angle)) / (pi * d^2)

    # Return
    return(toa_rad)

}


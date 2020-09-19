#' Convert a TOA radiance image to a TOA reflectance image
#' 
#' Converts a TOA radiance image to a TOA reflectance image.
#' 
#' @param toa_rad A \code{stars} image with top of atmosphere radiance values
#' @param date Acquisition date, needs to be \code{Date} of length 1
#' @param esun External solar radiation [W/m^2]. For Venus satellite bands, \code{esun} values are provided in the \code{bands} dataset.
#' @param solar_zenith_angle Solar zenith angle [degrees, between -180 and 180]
#' @return A \code{stars} image with top of atmosphere reflectance values
#' 
#' @details
#' Top of atmosphere reflectance can be caulculated using the following formula:
#'  
#' TOA = (pi * L * d^2) / (ESUN * cos(solar_zenith_angle))
#' 
#' where 'TOA' is the top of atmosphere reflectance, 'L' is the top of atmosphere radiance, 'ESUN' is the external solar radiation and 'solar_zenith_angle' is the solar zenith angle.
#' 
#' @export
#' 
#' @examples
#' 
#' library(stars)
#' library(XML)
#' 
#' data(venus1)
#' data(venus1m)
#' 
#' # Get metadata
#' l = xmlToList(venus1m)
#' m = get_venus_metadata(l, band = 1)
#' 
#' # TOA radiance -> TOA reflectance
#' toa_rad =  venus1 * 0.001
#' toa_refl = NULL
#' for(i in 1:dim(venus1)[3]) {
#'     toa_refl[[i]] = rad_to_refl(
#'        toa_rad = toa_rad[,,,i,drop=TRUE],
#'        date = m$date,
#'        esun = bands$esun[i],
#'        solar_zenith_angle = m$solar_zenith_angle
#'     )
#' }
#' toa_refl = do.call(c, toa_refl)
#' toa_refl = st_redimension(toa_refl)
#' 
#' # Plot rasters
#' plot(toa_rad)
#' plot(toa_refl)
#' 
#' # Profile for one pixel
#' toa_rad1 = venus1[[1]][100,100,]
#' toa_refl1 = toa_refl[[1]][100,100,]
#' 
#' # Plot reflectance profile
#' w = rowMeans(bands[c("lower", "upper")])
#' plot(
#'     w, toa_rad1, type = "l", 
#'     xlab = "Wavelength (micrometers)", ylab = "TOA radiance"
#' )
#' plot(
#'     w, toa_refl1, type = "l", 
#'     xlab = "Wavelength (micrometers)", ylab = #' "TOA reflectance"
#' )

rad_to_refl = function(toa_rad, date, esun, solar_zenith_angle) {

    # Checks
    stopifnot(length(class(toa_rad)) == 1)
    stopifnot(class(toa_rad) == "stars")
    stopifnot(length(dim(toa_rad[[1]])) == 2)
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

    # TOA radiance -> TOA reflectance
    toa_refl = (pi * toa_rad * d^2) / (esun * cos(solar_zenith_angle))

    # Return
    return(toa_refl)

}


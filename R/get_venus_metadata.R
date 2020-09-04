#' Extract Venus satellite image metadata
#' 
#' Extracts Venus satellite image metadata, as required for atrmospheric correction using \code{sixs_params}, from a Venus \code{HDR} metadata file.
#' 
#' @param x A \code{list} with the Venus image metadata, as returned by reading the Venus \code{HDR} file with \code{readLines} and parsing to \code{list} with \code{XML::xmlToList}
#' @param band The Venus band for which to return meatadata, \code{numeric} of length 1 between \code{1} and \code{12}
#' 
#' @return \code{list} with the Venus image metadata values
#' elevation in km...
#' 
#' @export
#' 
#' @examples
#' library(XML)
#' data(venus1m)
#' venus1m = xmlToList(venus1m)
#' get_venus_metadata(venus1m, 3)

get_venus_metadata = function(x, band) {

    # Checks
    stopifnot(is.list(x))
    stopifnot(is.numeric(band))
    stopifnot(length(band) == 1)
    stopifnot(band %in% 1:12)
    
    # Acquisition month/day
    date = x$Variable_Header$Specific_Product_Header$Product_Information$Acquisition_Date_Time
    date = substr(date, 5, 14)
    date = as.Date(date)
    # month = as.character(date, "%m")
    # month = as.numeric(month)
    # day = as.character(date, "%d")
    # day = as.numeric(day)

    # esun
    esun = NA

    # Solar zenith angle (theta)
    solar_zenith_angle = x$Variable_Header$Specific_Product_Header$Product_Information$Solar_Angles$Useful_Image$Image_Center$Zenith$text
    solar_zenith_angle = as.numeric(solar_zenith_angle)
    
    # Solar azimuth angle
    solar_azimuth_angle = x$Variable_Header$Specific_Product_Header$Product_Information$Solar_Angles$Useful_Image$Image_Center$Azimuth$text
    solar_azimuth_angle = as.numeric(solar_azimuth_angle)

    # View zenith angle
    if(band %in% c(1,2,5)) view_zenith_angle = x$Variable_Header$Specific_Product_Header$Product_Information$List_of_Viewing_Angles[1]$Viewing_Angles$Useful_Image$Image_Center$Zenith$text
    if(band %in% c(10,11,12)) view_zenith_angle = x$Variable_Header$Specific_Product_Header$Product_Information$List_of_Viewing_Angles[2]$Viewing_Angles$Useful_Image$Image_Center$Zenith$text
    if(band %in% c(7,8,9)) view_zenith_angle = x$Variable_Header$Specific_Product_Header$Product_Information$List_of_Viewing_Angles[3]$Viewing_Angles$Useful_Image$Image_Center$Zenith$text
    if(band %in% c(3,4,6)) view_zenith_angle = x$Variable_Header$Specific_Product_Header$Product_Information$List_of_Viewing_Angles[4]$Viewing_Angles$Useful_Image$Image_Center$Zenith$text
    view_zenith_angle = as.numeric(view_zenith_angle)

    # View azimuth angle
    if(band %in% c(1,2,5)) view_azimuth_angle = x$Variable_Header$Specific_Product_Header$Product_Information$List_of_Viewing_Angles[1]$Viewing_Angles$Useful_Image$Image_Center$Azimuth$text
    if(band %in% c(10,11,12)) view_azimuth_angle = x$Variable_Header$Specific_Product_Header$Product_Information$List_of_Viewing_Angles[2]$Viewing_Angles$Useful_Image$Image_Center$Azimuth$text
    if(band %in% c(7,8,9)) view_azimuth_angle = x$Variable_Header$Specific_Product_Header$Product_Information$List_of_Viewing_Angles[3]$Viewing_Angles$Useful_Image$Image_Center$Azimuth$text
    if(band %in% c(3,4,6)) view_azimuth_angle = x$Variable_Header$Specific_Product_Header$Product_Information$List_of_Viewing_Angles[4]$Viewing_Angles$Useful_Image$Image_Center$Azimuth$text
    view_azimuth_angle = as.numeric(view_azimuth_angle)

    # Longitude
    longitude = x$Variable_Header$Specific_Product_Header$Product_Information$Useful_Image_Geo_Coverage$Center$Long$text
    longitude = as.numeric(longitude)

    # Latitude
    latitude = x$Variable_Header$Specific_Product_Header$Product_Information$Useful_Image_Geo_Coverage$Center$Lat$text
    latitude = as.numeric(latitude)
    
    # Elevation
    elevation = x$Variable_Header$Specific_Product_Header$Product_Information$Used_DEM$Statistics$Average$text
    elevation = as.numeric(elevation)
    elevation = elevation / 1000  ## m -> km

    # Longitude = 31 
    # Latitude = 34 
    # Uw = 1.52 
    # Uo3 = 0.38 
    # opticalDepth = 0.5 
    # LowerWavelength = 0.4 
    # UpperWavelength = 0.44
    # TargetAltitude = 0.342
    # GroundCondition = "Patchy Ground"
    # TargetReflectance = "Vegetation"
    # EnvironmentReflectance = "Vegetation" 

    # Result
    result = list(
        "date" = date,
        # "month" = month,
        "solar_zenith_angle" = solar_zenith_angle,
        "solar_azimuth_angle" = solar_azimuth_angle,
        "view_zenith_angle" = view_zenith_angle,
        "view_azimuth_angle" = view_azimuth_angle,
        "longitude" = longitude,
        "latitude" = latitude,
        "elevation" = elevation
    )
    return(result)

}
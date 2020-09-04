#' Sample Venus image 1: Raster
#'
#' A three-dimensional \code{stars} raster, with 12 layers (spectral bands), as resulting from reading a Venus satellite image \code{TIF} file with:
#' 
#' \code{read_stars("VE_VM01_VSC_PDTIMG_L1VALD_ISRAEL03_20190204.DBL.TIF_crop.TIF")}
#'
#' then cropping a small (600*600 m^2) area and selecting just the first 12 image bands.
#' 
#' @format A \code{stars} raster, where values represent TOA reflectance multiplied by 1000.

"venus1"

#' Sample Venus image 1: BOA reflectance
#'
#' A three-dimensional \code{stars} raster, with 12 layers (spectral bands), after converting \code{venus1} from TOA reflectance to BOA reflectance.
#' 
#' @format A \code{stars} raster

"venus1_boa"

#' Sample Venus image 1: Metadata
#'
#' A \code{character} vector of length 1, with the contents of the XML document with image metadata, as resulting from reading a Venus satellite image metadata \code{HDR} file with:
#' 
#' \code{paste0(readLines("VE_VM01_VSC_L1VALD_ISRAEL03_20190204.HDR"), collapse = "")}
#'
#' @format A \code{character} vector of length 1

"venus1m"

#' Sample Venus image 2: Raster
#'
#' A three-dimensional \code{stars} raster, with 12 layers (spectral bands), as resulting from reading a Venus satellite image \code{TIF} file with:
#' 
#' \code{read_stars("VE_VM01_VSC_PDTIMG_L1VALD_ISRAEL03_20190204.DBL_crop.TIF")}
#'
#' then cropping a small (600*600 m^2) area and selecting just the first 12 image bands.
#' 
#' @format A \code{stars} raster

"venus2"

#' Sample Venus image 2: BOA reflectance
#'
#' A three-dimensional \code{stars} raster, with 12 layers (spectral bands), after converting \code{venus2} from TOA reflectance to BOA reflectance.
#' 
#' @format A \code{stars} raster

"venus2_boa"

#' Sample Venus image 2: Metadata
#'
#' A \code{character} vector of length 1, with the contents of the XML document with image metadata, as resulting from reading a Venus satellite image metadata \code{HDR} file with:
#' 
#' \code{paste0(readLines("VE_VM01_VSC_L1VALD_ISRAW910_20190212.HDR"), collapse = "")}
#'
#' @format A \code{character} vector of length 1

"venus2m"

#' Venus bands
#'
#' A \code{data.frame} with information about Venus satellite bands
#'
#' @format A \code{data.frame} with 15 rows (bands) and fourt columns: \code{band} (band ID, from 1 to 12), \code{lower} (lower wavelength, in micrometers), \code{upper} (lower wavelength, in micrometers), and \code{esun} (solar irradiance, in W/m^2).

"bands"

#' Venus validation
#'
#' A \code{data.frame} with metadata for the two sample Venus satellite images, extracted from (\code{venus1m} and \code{venus2m}). Provided for validation purposes.
#'
#' @format A \code{data.frame}

"venus_validation"


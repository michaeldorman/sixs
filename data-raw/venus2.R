## Code to prepare `venus2` dataset

##################################
# Image

library(stars)

# Read
r = read_stars("/home/michael/Dropbox/Packages/sixs/other/venus_sample_data/images/VE_VM01_VSC_PDTIMG_L1VALD_ISRAEL03_20190204.DBL_crop.TIF", proxy = FALSE)

# Subset bands
r = r[,,,1:12]

# AOI
pnt = c(648272,3458155)
pnt = st_point(pnt)
pnt = st_sfc(pnt)
st_crs(pnt) = st_crs(r)
pol = st_buffer(pnt, 300)
pol = st_bbox(pol)
pol = st_as_sfc(pol)

# Crop
r = r[pol]
r = st_normalize(r)

# Rescale
names(r) = "refl"

# Write
venus2 = r
usethis::use_data(venus2, overwrite = TRUE)

##################################
# Image - BOA reflectance

library(stars)

# Read
r = read_stars("/home/michael/Dropbox/Packages/sixs/other/venus_sample_data/images/VE_VM01_VSC_PDTIMG_L1VALD_ISRAW910_20190204.DBL_surface_reflectance.tif", proxy = FALSE)

# AOI
pnt = c(648272,3458155)
pnt = st_point(pnt)
pnt = st_sfc(pnt)
st_crs(pnt) = st_crs(r)
pol = st_buffer(pnt, 300)
pol = st_bbox(pol)
pol = st_as_sfc(pol)

# Crop
r = r[pol]
r = st_normalize(r)

# Rescale
names(r) = "refl"

# Replace non-ascii characters in CRS
st_crs(r) = st_crs(read_stars("/home/michael/Dropbox/Packages/sixs/other/venus_sample_data/images/VE_VM01_VSC_PDTIMG_L1VALD_ISRAEL03_20190204.DBL.TIF_crop.TIF"))

# Write
venus2_boa = r
usethis::use_data(venus2_boa, overwrite = TRUE)

##################################
# Metadata

# Read
x = readLines("/home/michael/Dropbox/Packages/sixs/other/venus_sample_data/images/VE_VM01_VSC_L1VALD_ISRAW910_20190212.HDR")

# Collapse
x = paste0(x, collapse = "")

# Write
venus2m = x
usethis::use_data(venus2m)


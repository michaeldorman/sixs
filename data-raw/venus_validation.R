## Code to prepare `venus_validation` dataset

# Read
dat = read.csv("/home/michael/Dropbox/Packages/sixs/other/venus_sample_data/images/data_with_6S_parameters_for_michael(1).csv", row.names = 1)

# Fix names
colnames(dat) = gsub("..", ".", colnames(dat), fixed = TRUE)
colnames(dat) = gsub(".", "_", colnames(dat), fixed = TRUE)
colnames(dat) = gsub("_$", "", colnames(dat))

# ESUN error correction
dat$ESUN[dat$Band == 3] = 1990.678

# Write
venus_validation = dat
usethis::use_data(venus_validation, overwrite = TRUE)

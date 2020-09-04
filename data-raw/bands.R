## Code to prepare `bands` dataset

dat = read.csv("/home/michael/Dropbox/Packages/sixs/other/venus_sample_data/bands.csv")

bands = dat
usethis::use_data(bands)

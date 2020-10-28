## Process and upload 5 images for 2nd ("multiple") vignette

setwd("/media/michael/usb32")

# Read
dat = read.csv("data_with_6S_parameters_for_Michael.csv", row.names = 1)

# Clean
colnames(dat) = tolower(colnames(dat))
colnames(dat) = gsub("..", ".", colnames(dat), fixed = TRUE)
colnames(dat) = gsub(".", "_", colnames(dat), fixed = TRUE)
colnames(dat) = gsub("_$", "", colnames(dat))
dat = dat[order(dat$id), ]

# Remove unnecessary columns
vars = c("id", "uo3_cm_atm", "uw_g_cm2", "optical_depth_550nm")
dat = dat[, vars]

# Remove duplicated
dat = unique(dat)

# Write
rownames(dat) = NULL
write.csv(dat, "south/metadata.csv", row.names = FALSE)

# Upload
# rsync -rz --delete --progress /media/michael/usb32/south michael@164.90.191.95:/home/michael/venus/


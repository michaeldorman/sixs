data(venus1m)

# For venus1 & venus2
for(d in c(4, 12)) {
    
    dat = venus_validation[venus_validation$day == d, ]
    if(d == 4) m = XML::xmlToList(venus1m)
    if(d == 12) m = XML::xmlToList(venus2m)
    
    # For each band
    for(i in 1:12) {
    
        m1 = get_venus_metadata(m, i)
        
        expect_equal(as.numeric(as.character(m1$date, "%d")), dat$day[i])
        expect_equal(as.numeric(as.character(m1$date, "%m")), dat$month[i])
        expect_equal(m1$solar_zenith_angle, dat$solar_zenith[i])
        expect_equal(m1$solar_azimuth_angle, dat$solar_azimuth[i])
        expect_equal(m1$view_zenith_angle, dat$view_zenith[i])
        expect_equal(m1$view_azimuth_angle, dat$view_azimuth[i])
        expect_equal(m1$longitude, dat$long[i])
        expect_equal(m1$latitude, dat$lat[i])
        expect_equal(m1$elevation, dat$elevation[i])
    
    }

}


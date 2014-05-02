library(dplyr)
endpoint <- "flights.cwick.co.nz"
user <- "student"
password <- "password"


ontime <- src_postgres("ontime", 
                       host = endpoint,
                       port = 5432,
                       user = user,
                       password = password)
flights <- tbl(ontime, "flights")
head(flights) 
tbl_df(head(flights))

hou <- filter(flights, (year == "2011" & month == 1) &  
                (origin == "HOU" | origin == "IAH"))

explain(hou) 
hou # now it executes
hou_local <- collect(hou)

pdx <- filter(flights, origin == "PDX" & year == "2013")
pdx_by_day <- group_by(pdx, year, month, dayofmonth)
flights_per_day <- summarise(pdx_by_day, n_flights = n())
explain(flights_per_day)

flights_per_day # looks good
flights_per_day$year # but it isn't behaving like a data.frame

fpd <- collect(flights_per_day)

fpd$date <- with(fpd, ISOdate(year, month, dayofmonth))

library(ggplot2)
qplot(date, n_flights, data = fpd, geom = "line")


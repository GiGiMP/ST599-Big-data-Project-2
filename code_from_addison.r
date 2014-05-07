install.packages("RPostgreSQL")
library(dplyr)
library(RPostgreSQL)
library(ggplot2)
big_font <- theme_grey(base_size = 24)

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
str(flights)
#head(select(flights,weatherdelay),100L)
#head(select(filter(flights,!is.na(weatherdelay)),weatherdelay),500L)

#' remove canceled flights

fl <- mutate(flights, difftime = actualelapsedtime - crselapsedtime)

fl_PHLIND <- filter(fl, origin=="PHL", dest=="IND")
fl_PHLIND <- collect(fl_PHLIND)
t<-table(fl_PHLIND$flightnum)
t[order(t)]
fl_1276 <- filter(fl_PHLIND,flightnum==1276)
fl_1276$date<-with(fl_1276, ISOdate(year, month, dayofmonth))
ggplot(aes(x=date,y=actualelapsedtime,color="ACTUAL"),data=fl_1276)+
  geom_smooth()+
  geom_smooth(aes(y=crselapsedtime,color="SCHEDULED")) +
  big_font

# graph of difftime (actual - crs) for PDX to SFO by carrier
fl_PDXSFO<-filter(fl, origin=="PDX", dest=="SFO")
fl_PDXSFO<-collect(fl_PDXSFO)
fl_PDXSFO$date<-with(fl_PDXSFO, ISOdate(year, month, dayofmonth))
ggplot(aes(x=date, y=difftime, color = uniquecarrier), data=fl_PDXSFO) +
  geom_smooth() +
  ggtitle("PDX to SFO Difference by Carrier") +
  big_font
# from this graph, it looks like only United and AS (Alaskan?) are the only 
# carriers with full 25 years of flights from pdx to sfo.

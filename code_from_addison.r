#install.packages("RPostgreSQL")
library(dplyr)
library(RPostgreSQL)
library(ggplot2)

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
  geom_smooth(aes(y=crselapsedtime,color="SCHEDULED"))

ggplot(aes(x=factor(year),y=crselapsedtime),data=fl_1103)+geom_boxplot()

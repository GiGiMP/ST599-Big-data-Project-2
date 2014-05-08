#install.packages("RPostgreSQL")
library(dplyr)
library(RPostgreSQL)
library(ggplot2)
big_font <- theme_grey(base_size = 24)

#change file path as needed"
endpoint <- "flights.cwick.co.nz"
user <- "student"
password <- "password"

ontime <- src_postgres("ontime", 
                       host = endpoint,
                       port = 5432,
                       user = user,
                       password = password)

flights <- tbl(ontime, "flights")
fl <- mutate(flights, difftime = crselapsedtime- actualelapsedtime)
head(flights)
str(flights)
#head(select(flights,weatherdelay),100L)
#head(select(filter(flights,!is.na(weatherdelay)),weatherdelay),500L)

#' remove canceled flights


## graph of flights from Philly to Indianapolis?!?
#fl_PHLIND <- filter(fl, origin=="PHL", dest=="IND")
#fl_PHLIND <- collect(fl_PHLIND)
#t<-table(fl_PHLIND$flightnum)
#t[order(t)]
#fl_1276 <- filter(fl_PHLIND,flightnum==1276)
#fl_1276$date<-with(fl_1276, ISOdate(year, month, dayofmonth))
#ggplot(aes(x=date,y=actualelapsedtime,color="ACTUAL"),data=fl_1276)+
#  geom_smooth()+
#  geom_smooth(aes(y=crselapsedtime,color="SCHEDULED")) +
#  big_font


#fl_PDXSFO_UA <- filter(fl, origin=="PDX", dest=="SFO",uniquecarrier=="UA")
#fl_PDXSFO_UA <- collect(fl_PDXSFO_UA)
#fl_PDXSFO_UA$date<-with(fl_PDXSFO_UA, ISOdate(year, month, dayofmonth))
#ggplot(aes(x=date,y=actualelapsedtime,color="ACTUAL"),data=fl_PDXSFO_UA)+
#  geom_smooth()+
#  geom_smooth(aes(y=crselapsedtime,color="SCHEDULED"))


# graph of difftime (actual - crs) for PDX to SFO by carrier
fl_PDXSFO<-filter(fl, origin=="PDX", dest=="SFO")
fl_PDXSFO<-collect(fl_PDXSFO)
fl_PDXSFO$date<-with(fl_PDXSFO, ISOdate(year, month, dayofmonth))
ggplot(aes(x=date, y=difftime, color = uniquecarrier), data=fl_PDXSFO) +
  geom_smooth() +
  ggtitle("PDX to SFO Difference by Carrier") +
  big_font
# from this graph, it looks like only United and AS (Alaskan?) are the only 
# carriers with full 25 years of flights from pdx to 

carriers<-read.csv("http://stat-computing.org/dataexpo/2009/carriers.csv", header = T, stringsAsFactors = F)
head(carriers)

n<-dim(carriers)[1]

carriers25 <- rep(NA, n)
for(i in 1:n){
  c <- carriers[i,1]
  fc <- filter(fl,uniquecarrier==c)
  fc_by <- group_by(fc, year)
  s <- summarize(fc_by, n())
  sc<-collect(s)
  print(c(i,c,dim(sc)))
  if(dim(sc)[1]==24){
    carriers25[i]=c
    print("accepted")
  }
}

which(!is.na(carriers25))
carriers[378,]
#378 is "CO"

CO <- filter(fl,uniquecarrier=="CO")
CO_by <- group_by(CO, year)
s <- summarize(CO_by, n())
sc<-collect(s)
sc[order(sc$year),]
print(sc)
fl1987<-filter(fl, year==1987)
fl1987_by<-group_by(fl1987,uniquecarrier)
a<-summarize(fl1987_by,n())
b<-collect(a)
b

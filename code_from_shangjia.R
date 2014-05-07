library(dplyr)
library(ggplot2)
library(plyr)
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
tbl_df(head(flights))
# I am blocking out Charlotte's code as it isn't helpful to me.
        #hou <- filter(flights, (year == "2011" & month == 1) &  
                      (origin == "HOU" | origin == "IAH"))
      
        #explain(hou) 
        #hou # now it executes
        #hou_local <- collect(hou)

#subset to get PDX to sfo flights
pdx2sfo.ua <- filter(flights, origin == "PDX" & dest == "SFO" & uniquecarrier == "UA")
# first I group to get the flights by day, get the mean crstime, then I will add a date variable so I can plot.
pdx2sfo.uabyday<-group_by(pdx2sfo.ua, year, month, dayofmonth)
pdx2sfo_ua_byday<-summarize(pdx2sfo.uabyday, mean_crselapsed=mean(crselapsedtime))
pdx2sfo.united<-collect(pdx2sfo_ua_byday)
pdx2sfo.united$date<-with(pdx2sfo.united, ISOdate(year, month, dayofmonth))


library(ggplot2)
qplot(date, mean_crselapsed, data=pdx2sfo.united) + big_font +
  geom_smooth()

ggplot(aes(x=date,y=actualelapsedtime,color="ACTUAL"),data=pdx2sfo.united)+
  geom_smooth()+
  geom_smooth(aes(y=crselapsedtime,color="SCHEDULED")) +
  big_font

#If you want to look at the data with a line geom but I think it isn't very helpful and it takes forever!
qplot(date, mean_crselapsed, data=pdx2sfo.united, geom="line") + big_font +
  geom_smooth()
# there is definitely cyclic patterns. I want to  look at a 2 year spread to see whats going on.
# I will need to look through old notes as I am having trouble remembering how to manipulate
# dates.

#use the library(lubricate), there is a function we used in time series class called
#called parse_date_time, it should help. 

# the flights number increase, it will cause congestion, so it will lead to 
# longer flight time as well. 

# Since the question need us to state the whole picture, I think we can
# look into the general trend (not specify the origin and destination 
# and carrier, see how the trend goes)

fl <- mutate(flights, difftime = actualelapsedtime - crselapsedtime)
fl_all<-collect(fl)
fl$date<-with(fl, ISOdate(year, month, dayofmonth))
ggplot(aes(x=date,y=actualelapsedtime,color="ACTUAL"),data=fl)+
  geom_smooth()+
  geom_smooth(aes(y=crselapsedtime,color="SCHEDULED")) +
  big_font
# It takes forever!!!! The dataset is too large.

# Since I noticed addison said the United and AS have 25 years data, we could
# make the dataset smaller. My friend in other group told me they look into
# fewer years data because after 911, the regulation may be influenced,
# so only take the time period after that also make sense


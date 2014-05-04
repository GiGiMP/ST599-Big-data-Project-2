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
qplot(date, mean_crselapsed, data=pdx2sfo.united) + 
  geom_smooth()

#If you want to look at the data with a line geom but I think it isn't very helpful and it takes forever!
qplot(date, mean_crselapsed, data=pdx2sfo.united, geom="line") +
  geom_smooth()
# there is definitely cyclic patterns. I want to  look at a 2 year spread to see whats going on.
# I will need to look through old notes as I am having trouble remembering how to manipulate
# dates.

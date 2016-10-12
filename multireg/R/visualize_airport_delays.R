

visualize_airports_delay<- function(){
library(dplyr)
library(nycflights13)
library(ggplot2)

data(airports)
data(flights)

# subsetting the important variables for the analysis #
airports_sub<- select(airports, faa, name, lat, lon)
flights_sub<- select(flights, dest, dep_delay, arr_delay)

# Total time of delays #
new_flights<- mutate(flights_sub, total_delay = dep_delay + arr_delay)
new_flights<- filter(new_flights, !is.na(total_delay))

# Merging the two data frames #
airFlight<- inner_join(airports_sub, new_flights, by=c("faa"="dest"))

# Compute total mean delay of flights by airport #
mean_delay<- airFlight %>% group_by(faa) %>% summarise(total_mean = mean(total_delay, na.rm=T))

# Creating new data set for plotting. Total mean delay for every airport #
airFlight_delay<- inner_join(airports_sub, mean_delay, by="faa")

# To get states name we use function latlong2state # 
airFlight_delay$States<- latlong2state(airFlight_delay[,c("lon", "lat")])

airFlight_delay <- airFlight_delay %>% select(States, total_mean) 

# Plotting the data #
states<- map_data("state")

air_mapdata<- inner_join(airFlight_delay, states, by=c("States"="region")) 

map_base<- ggplot(data = states, mapping = aes(x = long, y = lat, group = group)) + 
  geom_polygon(color = "black", fill = "gray")

plot<- map_base + geom_polygon(data = air_mapdata, aes(fill = total_mean), color = "white") +
  geom_polygon(color = "black", fill = NA) +  
  ggtitle("Mean total flight delays for different airports")

noAxes<- theme(
  axis.text = element_blank(),
  axis.line = element_blank(),
  axis.ticks = element_blank(),
  panel.border = element_blank(),
  panel.grid = element_blank(),
  axis.title = element_blank()
)

plot + noAxes

}
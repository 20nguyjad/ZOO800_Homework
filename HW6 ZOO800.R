

###### HW Week 6 ######

# Jaden, Cody, Maddy

# packages
library(ggplot2)
library(tidyverse)


####### Objective 1

#t = year
#r = intrinsic rate of growth
#K = carrying capacity

# define variables in equation
K <- 1000
r <- 0.2
N0 <- 50
years <- 10 # assignment says 10 years in objective 10...

# make (blank) vector to store the population values for each year
N <- numeric(years)
N[1] <- N0 # population values for each year, blank except it starts at defined starting population

# discrete growth population model 
discrete_pop_model <- function(Nt, r, K) {
  return(Nt + r * Nt * (1 - Nt / K))
}

# for loop to run the model over the whole vector 
for (t in 1:(years - 1)) {
  N[t + 1] <- discrete_pop_model(N[t], r, K)
}

# Define years starting from 2025
year <- 2025:(2025 + years - 1)

# Create data frame
pop_data <- data.frame(
  Year = year,
  Population = N
)


ggplot(pop_data, aes(x = Year, y = Population)) +
  geom_point() + geom_line()




####### Objective 2

# this uses function discrete_pop_model so make sure that has been run already

# make new data frame to store data with run number

fiftyrunsResults <- data.frame()
  
# define variables again because I think it makes it funky

K <- 1000
N0 <- 50
years <- 25 # changed years to 25 because assignment wording makes me think we should have 25...
  
# loop for 50 simulations with 50 different normally distributed r values

for (i in 1:50) {
  r <- rnorm(1, mean = 0.2, sd = 0.03)
  N <- numeric(years)
  N[1] <- N0
  
  for (t in 1:(years - 1)) {
    N[t + 1] <-  max(0, discrete_pop_model(N[t], r, K)) } 
    
    fiftyruns <- data.frame(
      Year = 2025:(2025 + years - 1),
      Population = N,
      Sim = i,
      GrowthRate = r
    )
    
    # Combine with all results
    fiftyrunsResults <- rbind(fiftyrunsResults, fiftyruns)
  }

# ggplot with line for each growth curve 
# this will not graph correctly if anything is run out of order LOL

ggplot(fiftyrunsResults, aes(x = Year, y = Population, group = Sim, color = Sim)) +
  geom_line(alpha = 0.4) +
  ggtitle("50 Simulations of Logistic Growth")


####### Objective 3 

# again this is with 25 years instead of 10...
# line indicating target population at 800 (80% of carrying capacity of 1000)

ggplot(fiftyrunsResults, aes(x = Year, y = Population, group = Sim, color = Sim)) +
  geom_line(alpha = 0.4) +
  ggtitle("50 Simulations of Logistic Growth") +
  geom_hline(yintercept= 800 , linetype='dotted', col = 'black')

# from df fiftyrunsResults, want population at year = 2049 for each individual sim number (1-50)
# easiest for me to just subset this

pop_2049 <- fiftyrunsResults %>%
  filter(Year == 2049) %>%
  select(Sim, Year, Population)

# plot histogram with goal at 800 individuals with geom_histogram()
# boy is this ugly but it gets the job done

ggplot(pop_2049, aes(x=Population)) + 
  geom_histogram() +
  geom_vline(xintercept= 800 , linetype='dotted', col = 'black') +
  ggtitle("Simulation Models' Maximum Population")

# find fraction of simulations which meet target population of 800

pop_2049 %>% summarise(percentage = mean(Population >= 800) * 100)
# 74 %

# adding text with annotate() function
# doesn't overlap with any hist bars

ggplot(pop_2049, aes(x=Population)) + 
  geom_histogram() +
  geom_vline(xintercept= 800 , linetype='dotted', col = 'black') +
  annotate("text", x = 720, y = 5, label = "74% of simulations meet target population") +
  ggtitle("Simulation Models' Maximum Population")


    

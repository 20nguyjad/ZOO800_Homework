#Homework 4
#Sept 25, 2025
#Frank, Jaden, Lucas


###########
# Objective 1


install.packages("palmerpenguins")
library(palmerpenguins)

#read in data frame
penguins <- penguins

#find mean value for penguin body mass, this will be cut off value
mean(penguins$body_mass_g, na.rm = TRUE)

#this is how I would do it, but try to make a function that replicates this
#penguins$SizeClass <- factor(ifelse(penguins$body_mass_g < 4201, "Small", "Large"), levels = c("Small", "Large"))

#define break point
Break <- mean(penguins$body_mass_g, na.rm = TRUE)

#create function
SizeSort <- function(df, column1){
  factor(ifelse(column1 <= Break, "Small", "Large"), levels = c("Small", "Large")) 
}

#make sure function actually runs
SizeSort(penguins, penguins$body_mass_g)

#use function to add new column to original data frame
penguins$size_class <- SizeSort(penguins, penguins$body_mass_g)



###########
# Objective 2

#define breakpoints
Break1 <-  
Break2 <- 

#create function

SizeClassV2 <- function(df, column1) 
  {cut(
  df$column1,
  breaks = c(0, 3000, 4000, Inf), # Define the break points
  labels = c("Small", "Medium", "Large"), # Assign labels to the categories
  right = FALSE # Include the lower bound in the interval
)
}


SizeClassV2(penguins, penguins$body_mass_g)

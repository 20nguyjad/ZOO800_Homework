# HW 5
# Jaden Nguyen
# due 10/6/24

# load packages

library(openxlsx)
library(readxl)
library(tidyverse)
library(writexl)

# set working directory to folder (I do this manually)
# also create Output folder now :)

#### Objective 1 #####

#import datasets

FishCSV <- read.csv("fish.csv")
head(FishCSV) # see first five (or six!) rows

FishExcel<- read_excel('fish.xlsx')
head(FishExcel)

FishRDS <- readRDS('fish.rds')
head(FishRDS)


#### Objective 2 #####

write.csv(x = FishCSV, 'Output/FishOutput.csv' )
write_xlsx(FishCSV, 'Output/FishOutput.xlsx')
saveRDS(FishCSV, 'Output/FishOutput.rds')

file.info('Output/FishOutput.csv') #size 13522
file.info('Output/FishOutput.xlsx') #size 13870
file.info('Output/FishOutput.rds') #size 3033

# I prefer to use a .csv file for sharing -- it runs in multiple programs (like Excel) and read.csv runs in base R (I think!)
# long term storage in .rds format will take up less space


#### Objective 3 #####

# use FishCSV data frame (imported from fish.csv)

FishCleaned <- FishCSV %>%
  filter(Species  %in% c("Walleye", "Yellow Perch", "Smallmouth Bass")) %>%
           filter(Lake  %in% c("Erie", "Michigan")) %>%
                    select('Species', 'Lake', 'Year', 'Length_cm', 'Weight_g') %>%
  mutate(Length_mm = Length_cm * 10) %>%
  mutate(Length_group = cut(Length_mm, 
                            breaks = c(0, 200, 400, 600, Inf),
                            labels = c('<200mm', '200-400mm','400-600mm','>600mm'), 
                            right = TRUE)) %>%
  add_count(Species, Length_group, name = "Species_Length_Count") %>%
  group_by(Species, Year) %>%
  mutate(
    Mean_Weight_g = mean(Weight_g, na.rm = TRUE),
    Med_Weight_g = median(Weight_g, na.rm = TRUE),
    IndividualsSpeciesPerYear = n()
  ) %>%
  ungroup()
  
write.csv(x = FishCleaned, 'Output/FishProcessed.csv' )


#### Objective 4 #####

FishFiles <- list.files(path = './Multiple_files')

FishFilesMaster <- FishFiles %>%
  map_dfr(~ read.csv(file.path('./Multiple_files', .))) # using tidyverse purrr function map_dfr


#### Objective 5 #####

# modification of code provided in Canvas

# --- Setup: load base parallel, read data --------------------------------

library(parallel)                          # built-in; no install needed

fish <- read.csv("fish_bootstrap_parallel_computing.csv")     # adjust path if needed
species <- unique(fish$Species)            # list of species we'll loop over


# --- A tiny bootstrap function (no pipes, base R only) --------------------

boot_mean <- function(species_name, n_boot = 10000, sample_size = 200) {
  # Pull the Length_cm vector for just this species
  # this gets replaced by Weight_g
  x <- fish$Weight_g[fish$Species == species_name]
  
  # Do n_boot resamples WITH replacement; compute the mean each time
  # replicate(...) returns a numeric vector of bootstrap means
  means <- replicate(n_boot, mean(sample(x, size = sample_size, replace = TRUE)))
  
  # Return the average of those bootstrap means (a stable estimate)
  mean(means)
}


# --- SERIAL version: one core, one species after another ------------------

t_serial <- system.time({                   # time the whole serial run
  res_serial <- lapply(                     # loop over species in the main R process
    species,                                # input: vector of species names
    boot_mean,                              # function to apply
    n_boot = 10000,                         # number of bootstrap resamples per species
    sample_size = 200                       # bootstrap sample size
  )
})

# head(res_serial)


# --- PARALLEL version: many cores using a PSOCK cluster (portable) --------

n_cores <- max(1, detectCores() - 1)        # use all but one core (be nice to your laptop)
cl <- makeCluster(n_cores)                  # start worker processes

clusterSetRNGStream(cl, iseed = 123)        # make random numbers reproducible across workers

# Send needed objects to workers (function + data + species vector)
clusterExport(cl, varlist = c("fish", "boot_mean", "species"), envir = environment())

t_parallel <- system.time({                 # time the parallel run
  res_parallel <- parLapply(                # same API as lapply(), but across workers
    cl,                                     # the cluster
    species,                                # each worker gets one species (or more)
    boot_mean,                              # function to run
    n_boot = 1000,                          # same bootstrap settings as serial
    sample_size = 200
  )
})

stopCluster(cl)                             # always stop the cluster when done


# --- Compare runtimes & show speedup --------------------------------------

# Extract elapsed (wall) time and compute speedup = serial / parallel
elapsed_serial   <- unname(t_serial["elapsed"])
elapsed_parallel <- unname(t_parallel["elapsed"])
speedup <- elapsed_serial / elapsed_parallel

cat("Serial elapsed (s):   ", round(elapsed_serial, 3), "\n")
cat("Parallel elapsed (s): ", round(elapsed_parallel, 3), " using ", n_cores, " cores\n", sep = "")
cat("Speedup:               ", round(speedup, 2), "x\n", sep = "")


# Serial elapsed (s):    1.189 
# Parallel elapsed (s): 0.028 using 7 cores
# Speedup:               42.46x

# Parallel ends up WAY faster than serial (almost 42.5x faster???)
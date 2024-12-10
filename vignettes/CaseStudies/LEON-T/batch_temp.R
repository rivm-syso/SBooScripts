library(batch)
library(tidyverse)

## Choose a high enough seed for sequential organization
seed <- 20001

## Define batch parameters
batch_n <- 2
batch_max <- 1000  # Should be a multiple of batch_n for the loop logic to work

## Create parameter grid
pars <- expand.grid(
  RUN1 = seq(batch_n, batch_max, batch_n)
) %>%
  mutate(RUN2 = RUN1 - (batch_n - 1))

## Run batch jobs
for(i in 1:nrow(pars)) {
  # Define the sequence for RUNSamples based on RUN2 and RUN1
  RUNSamples <- pars$RUN2[i]:pars$RUN1[i]
  
  # Call rbatch with specific parameters
  seed <- rbatch("vignettes/CaseStudies/LEON-T/03_get_Solution_SB_batch.r", 
                 seed = seed, 
                 RUNSamples = RUNSamples
  )
  
  # Increment seed to ensure unique seeds for each job if needed
  seed <- seed + 1
}

## Selects a variety of parameter combinations to run

library("batch")

## Choose a high enough seed for later for pasting the results together
##  (1,...,9,10) sorts not the way you want, for example.
## Here setting any parameter=value will override the default in the R file
##  you are running

seed <- 20001

batch_n = 2
batch_max = 8 # should be multiple of batch_n

pars <- expand.grid(
  RUN1=seq(batch_n,batch_max,batch_n) #,
#  material = c("NR","SBR") # now not used, but can also be part of batch
)
library(tidyverse)
pars <-
  pars |> mutate(RUN2 = RUN1-(batch_n-1))

for(i in 1:length(pars[,1]))
  seed <- rbatch("vignettes/CaseStudies/03_get_Solution_SB_batch.r", 
                 seed = seed, 
                 RUNSamples = c(pars$RUN1[i]:pars$RUN2[i])
                 )

## Only for local (but it does not hurt to run in other situations,
##  so suggested in all cases).
## This actually runs all the commands when run on the local system.
rbatch.local.run(ncores=4)

## Selects a variety of parameter combinations to run

library("batch")

## Choose a high enough seed for later for pasting the results together
##  (1,...,9,10) sorts not the way you want, for example.
## Here setting any parameter=value will override the default in the R file
##  you are running

seed <- 10001

pars <- expand.grid(
  RUN1=seq(10,1000,10),
  material = c("NR","SBR")
)
pars <-
  pars |> mutate(RUN2 = RUN1-9)

pars <- pars[c(4,8),]

pars$rname <- "hom.het.Ilona"

for(i in 1:length(pars[,1]))
  seed <- rbatch("SimpleBox.r", seed = seed, 
                 alpha.hom = pars$alpha.hom[i],
                 alpha.het = pars$alpha.het[i],
                 NPMrho = pars$NPMrho[i],
                 Df = pars$Df[i],
                 G = pars$G[i],
                 C0npm = pars$C0npm[i],
                 amax = pars$amax[i],
                 a1 = pars$a1[i],
                 C0 = pars$C0[i],
                 avgNPMa=pars$avgNPMa[i],
                 runname = pars$rname[i],
                 psd=pars$psd[i],
                 nanoparticle=pars$nanoparticle[i]
  )

## Only for local (but it does not hurt to run in other situations,
##  so suggested in all cases).
## This actually runs all the commands when run on the local system.
rbatch.local.run(ncores=2)
GettingStarted
================
JS

## Introduction to SB, the OO version.

Chemical behavior in the environment is often modeled with multimedia
fate models. SimpleBox is one often-used multimedia fate model, firstly
developed in 1986. Since then, three updated versions were published and
the model is included within the EU chemical safety assessment referred
to as REACH. The SimpleBox 1.0, 2.0 3.0 and 4.0 versions are spreadsheet
models available in MS Excel. Here we present the SimpleBox 5.0 version
in R as which is the first SimpleBox Object Oriented (SBOO) version.  
The R version of Simple Box is partly object oriented (OO). In use you
will not notice much from the OO part; you can make R scripts like any
other, except for the use of the objects, which will be introduced here.
You don’t need to really understand the object oriented approach, except
that objects have both functions, which are called methods, and data.
Both can be accessed similar to dataframes using the \$ sign. This will
be demonstrated further below. During development, SB is split over two
projects. This is easier to maintain the future SBOO package from the
data and the scripts that help the developments. The repository in
gitlab is setup accordingly with separate repositories in a common
group: <https://gitl01-int-p.rivm.nl/sboogroup>

### Setup

In order to use SBOO you need two projects with the parent folder in
common. I have them (under campus) in S:\R\slootwej and can access them
from RStudio on one of the R-servers under respectively
/rivm/s/slootwej/sboo and /rivm/s/slootwej/sbooScripts More info on the
r-servers at rivm can be found at
<http://wiki.rivm.nl/inwiki/bin/view/StatNMod/RStudio%2BServer> For more
info on gitlab at rivm follow
<http://wiki.rivm.nl/inwiki/bin/view/Git/WebHome> Once you have access
and this setup completed, you can start working, most likely only in the
sbooScripts project

### Making changes

Before changing anything, don’t forget to make a branch (under the Git
tab, right from the Environment tab, where you can see the variables in
your environment). After you made you brilliant update in your local
branch, commit it with comments, switch to the main branch, or the
master, pull it, switch back to your branch and open a Shell (you are
now working in linux) and type the command: git merge main (or git merge
master, if that was your “origen”). If the merge fails, we have a
problem. Otherwise you can push your branch to the git-server using the
Push button. In gitlab you can then make a merge-request and assign the
task to merge to me (slootwej). Finally, a list of currently available
vignettes:

### Folder structure

In the sbooScripts you will find the following folders: data,
baseScripts, vignettes, testScripts and newAlgoritmsScripts In the data
folder are the csv files, and two versions of the excel version, the
original (Molecular) and a Nano version. The baseScripts contains R
scripts to help initiating the objects you will use. Other scripts in
the folder are explained in other vignettes. For testing of (your) new
scripts and “defining functions” (explained later) you will use
newAlgorithmScripts and testScripts

### Data

SB uses data of substances, of compartments and so on. These data are
stored in csv files. A description of exactly how the data is stored can
be found in in vignette “CSVdata.Rmd”

### Calculation steps

The “Box” in SimpleBox (SB) is a combination of space and compartment.
The space is a subdivision of the nothern hemisphere into 3 “global”
scales, and a nested continental and regional scale. The compartments
are split into subcompartments like freshwaters and sea, and different
type of soil. SB calculates a first-order rate of mass flow (“k”) from
each box (subcompartment/scale) into any other. The rates are associated
with processes, like “Advection” or “Deposition”. The resulting matrix
can then be solved for a steady state. Processes in SBOO are a special
class. A method of this class executes a function typical to that
process for all the from- and to boxes where this process takes place.
Calculating the k’s of the processes is usually preceded by calculating
variables and flows. These depend on the data in the csv-files and are
input to the process-function. Variables and flows also execute a
function typical for the variable or flow at hand. How this operates is
explained in the vignette “FirstVars.Rmd”

``` r
dir("vignettes", "\\.Rmd")
```

    ##  [1] "AirFlow.Rmd"            "Area.Rmd"               "CSVdata.Rmd"           
    ##  [4] "DAG.Rmd.old"            "Debugging.Rmd"          "defaults.Rmd"          
    ##  [7] "ErosionRunoff.Rmd"      "FirstVars.Rmd"          "FRACwas.Rmd"           
    ## [10] "METAdata.Rmd"           "partitioning.Rmd"       "processFlow.Rmd"       
    ## [13] "RhoRadSettling.Rmd"     "sedimentation.Rmd"      "start.Rmd"             
    ## [16] "testAzure.Rmd"          "testRainDropRadius.Rmd" "TraceTrack.Rmd"

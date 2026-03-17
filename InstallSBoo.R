################################################################################
# Script for installing SBoo and SBooScript                                    #
#                                                                              #
# This script installs SBoo and SBooScripts in a                               #
# folder of your choosing.                                                     #
#                                                                              #
# Authors: Anne Hids and Joris Quik                                            #
# Last updated: 10-02-2026                                                     # 
################################################################################

# Specify where the downloaded versions of sboo and sbooscripts should be saved to --
# this is the only change you need to make to this script. If SBInstallFolder is NULL,
# sboo and sbooscripts are installed in the current working directory
SBInstallFolder <- NULL

# you can specify a tag
# tag <- "2025.04.0"
# or if
# tag = NA
# The devBranch name is used, default is development branch which contains latest updates.

source("baseScripts/installRequirements.R")

InstallSBoo <- function(Release = "2025.04.0", # tag for release use NA for branch
                        devBranch = "development",
                        Temp_Folder = "C:/Temp" # an existing folder where SimpleBox is to be installed
){
  
  # check if directory is NULL or ends with a "/"
  if (is.null(Temp_Folder) || is.na(Temp_Folder)) {
    Temp_Folder <- NULL
  } else if (is.character(Temp_Folder)) {
    if (!endsWith(Temp_Folder, "/")) {
      Temp_Folder <- paste0(Temp_Folder, "/")
    }
  }
  
  # prepare directories:
  
  empty_folder <- function(target_folder){
    if (dir.exists(target_folder)) {
      items <- list.files(target_folder, full.names = TRUE, recursive = FALSE)
      if (length(items) > 0) {
        unlink(items, recursive = TRUE, force = TRUE)
      }
    }
  }
  
  if(dir.exists(paste0(Temp_Folder,"SBzips"))){
    oldfiles <- list.files(paste0(Temp_Folder,"/SBzips"), full.names = TRUE)
    file.remove(oldfiles)
    print("Old SBoo zipfiles deleted")
  }
  
  if(!dir.exists(paste0(Temp_Folder,"SBzips"))){
    dir.create(paste0(Temp_Folder,"SBzips"))
    print(paste0("Directory: ", Temp_Folder,"SBzips", " created."))
  } else print("SBzips directory already exists")
  
  empty_folder(target_folder = paste0(Temp_Folder, "SimpleBox"))
  
  # download files and unzip
  
  if(is.na(Release)){
    SBScriptsLink_Release <-
      paste0("https://github.com/rivm-syso/SBooScripts/archive/refs/heads/",devBranch,".zip")
    download.file(SBScriptsLink_Release,paste0(Temp_Folder,"SBzips/SBooScripts_",devBranch,".zip"))
    zipfile <- paste0(Temp_Folder,"SBzips/SBooScripts_", devBranch,".zip")
    # file.exists(zipfile)
    destination <- paste0(Temp_Folder, "SimpleBox")
    unzip(zipfile, exdir = destination)
    
    file.rename(file.path(destination, paste0("SBooScripts-", devBranch)), 
                file.path(destination, "SBooScripts"))
  } else{
    SBScriptsLink_Release <-
      paste0("https://github.com/rivm-syso/SBooScripts/archive/refs/tags/",Release,".zip")
    download.file(SBScriptsLink_Release,paste0(Temp_Folder,"/SBzips/SBooScripts_",Release,".zip"))
    zipfile <- paste0(Temp_Folder,"SBzips/SBooScripts_", Release,".zip")
    # file.exists(zipfile)
    destination <- paste0(Temp_Folder, "SimpleBox")
    unzip(zipfile, exdir = destination)
    
    file.rename(file.path(destination, paste0("SBooScripts-", Release)), 
                file.path(destination, "SBooScripts"))
  }
  
  if(is.na(Release)){
    SBooLink_Release <-
      paste0("https://github.com/rivm-syso/SBoo/archive/refs/heads/",devBranch,".zip")
    
    download.file(SBooLink_Release,paste0(Temp_Folder,"SBzips/SBoo_",devBranch,".zip"))
    
    zipfile <- paste0(Temp_Folder,"SBzips/SBoo_",devBranch,".zip")
    # file.exists(zipfile)
    destination <- paste0(Temp_Folder, "SimpleBox")
    unzip(zipfile, exdir = destination)
    
    file.rename(file.path(destination, paste0("SBoo-", devBranch)), 
                file.path(destination, "SBoo"))
  } else{
    SBooLink_Release <-
      paste0("https://github.com/rivm-syso/SBoo/archive/refs/tags/",Release,".zip")
    
    download.file(SBooLink_Release,paste0(Temp_Folder,"SBzips/SBoo_",Release,".zip"))
    
    zipfile <- paste0(Temp_Folder,"SBzips/SBoo_",Release,".zip")
    # file.exists(zipfile)
    destination <- paste0(Temp_Folder, "SimpleBox")
    unzip(zipfile, exdir = destination)
    
    file.rename(file.path(destination, paste0("SBoo-", Release)), 
                file.path(destination, "SBoo"))
  }
  
  # Remove SB zip files
  unlink(paste0(Temp_Folder, "SBzips"), recursive = TRUE)
  if(is.null(Temp_Folder)){
    return(paste0("The SimpleBox model can be found in ", getwd(), "/", destination))
  } else {
    return(paste0("The SimpleBox model can be found in ", destination))
  }
}

InstallSBoo(Release = NA,
                 Temp_Folder = NA)
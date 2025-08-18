################################################################################
# Script for installing SBoo and SBooScript                                    #
#                                                                              #
# This script installs SBoo and SBooScripts in a                               #
# folder of your choosing.                                                     #
#                                                                              #
# Authors: Anne Hids and Joris Quik                                            #
# Last updated: 18-08-2025                                                      # 
################################################################################

# Specify where the downloaded versions of sboo and sbooscripts should be saved to --
# this is the only change you need to make to this script. 
dest_folder <- "/mnt/scratch_dir/quikj/R_projects/TempSBmodel"


# you can specify a tag
tag <- "2025.04.0"
# or if
tag = NA
# The devBranch name is used, default is development branch which contains latest updates.

CompareFilesPrep <- function(Release = "2025.04.0", # tag for release use NA for branch
                             devBranch = "development",
                             Temp_Folder = "C:/Temp" # an existing folder
){
  
# prepare directories:
  
  empty_folder <- function(target_folder){
    if (dir.exists(target_folder)) {
      items <- list.files(target_folder, full.names = TRUE, recursive = FALSE)
      if (length(items) > 0) {
        unlink(items, recursive = TRUE, force = TRUE)
      }
    }
  }
  
  if(dir.exists(paste0(Temp_Folder,"/SBzips"))){
    oldfiles <- list.files(paste0(Temp_Folder,"/SBzips"), full.names = TRUE)
    file.remove(oldfiles)
    print("Old SBoo zipfiles deleted")
  }
  
  if(!dir.exists(paste0(Temp_Folder,"/SBzips"))){
    dir.create(paste0(Temp_Folder,"/SBzips"))
    print(paste0("Directory: ", Temp_Folder,"/SBzips", " created."))
  } else print("SBzips directory already exists")
  
  empty_folder(target_folder = paste0(Temp_Folder, "/SimpleBox"))
  
  # download files and unzip
  
  if(is.na(Release)){
    SBScriptsLink_Release <-
      paste0("https://github.com/rivm-syso/SBooScripts/archive/refs/heads/",devBranch,".zip")
    download.file(SBScriptsLink_Release,paste0(Temp_Folder,"/SBzips/SBooScripts_",devBranch,".zip"))
    zipfile <- paste0(Temp_Folder,"/SBzips/SBooScripts_", devBranch,".zip")
    # file.exists(zipfile)
    destination <- paste0(Temp_Folder, "/SimpleBox")
    unzip(zipfile, exdir = destination)
    
    file.rename(file.path(destination, paste0("SBooScripts-", devBranch)), 
                file.path(destination, "SBooScripts"))
  } else{
    SBScriptsLink_Release <-
      paste0("https://github.com/rivm-syso/SBooScripts/archive/refs/tags/",Release,".zip")
    download.file(SBScriptsLink_Release,paste0(Temp_Folder,"/SBzips/SBooScripts_",Release,".zip"))
    zipfile <- paste0(Temp_Folder,"/SBzips/SBooScripts_", Release,".zip")
    # file.exists(zipfile)
    destination <- paste0(Temp_Folder, "/SimpleBox")
    unzip(zipfile, exdir = destination)
    
    file.rename(file.path(destination, paste0("SBooScripts-", Release)), 
                file.path(destination, "SBooScripts"))
  }
  
  if(is.na(Release)){
    SBooLink_Release <-
      paste0("https://github.com/rivm-syso/SBoo/archive/refs/heads/",devBranch,".zip")
    
    download.file(SBooLink_Release,paste0(Temp_Folder,"/SBzips/SBoo_",devBranch,".zip"))
    
    zipfile <- paste0(Temp_Folder,"/SBzips/SBoo_",devBranch,".zip")
    # file.exists(zipfile)
    destination <- paste0(Temp_Folder, "/SimpleBox")
    unzip(zipfile, exdir = destination)
    
    file.rename(file.path(destination, paste0("SBoo-", devBranch)), 
                file.path(destination, "SBoo"))
  } else{
    SBooLink_Release <-
      paste0("https://github.com/rivm-syso/SBoo/archive/refs/tags/",Release,".zip")
    
    download.file(SBooLink_Release,paste0(Temp_Folder,"/SBzips/SBoo_",Release,".zip"))
    
    zipfile <- paste0(Temp_Folder,"/SBzips/SBoo_",Release,".zip")
    # file.exists(zipfile)
    destination <- paste0(Temp_Folder, "/SimpleBox")
    unzip(zipfile, exdir = destination)
    
    file.rename(file.path(destination, paste0("SBoo-", Release)), 
                file.path(destination, "SBoo"))
  }

  # Remove SB zip files
  unlink(paste0(Temp_Folder, "/SBzips"), recursive = TRUE)
  
  return(paste0("The SimpleBox model can be found in ", destination))
}

CompareFilesPrep(Release = tag,
                 Temp_Folder = dest_folder)

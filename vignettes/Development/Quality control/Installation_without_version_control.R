################################################################################
# Script for installing SBoo and SBooScript                                    #
#                                                                              #
# This script installs the development branch of SBoo and SBooScripts in a     #
# folder of your choosing.                                                     #
#                                                                              #
# Authors: Anne Hids and Joris Quik                                            #
# Last updated: 21-7-2025                                                      # 
################################################################################

# Specify where the downloaded versions of sboo and sbooscripts should be saved to --
# this is the only change you need to make to this script. 
dest_folder <- "/rivm/n/hidsa/Documents/Temp"

tag <- "2025.04.0"

CompareFilesPrep <- function(Release = "2025.04.0", # tag for release
                             devBranch = "development",
                             Temp_Folder = "C:/Temp" # an existing folder
){

    if(is.na(Release)){
    SBScriptsLink_Release <-
      paste0("https://github.com/rivm-syso/SBooScripts/archive/refs/heads/",devBranch,".zip")
  } else{
    SBScriptsLink_Release <-
      paste0("https://github.com/rivm-syso/SBooScripts/archive/refs/tags/",Release,".zip")
  }

  if(is.na(Release)){
    SBooLink_Release <-
      paste0("https://github.com/rivm-syso/SBoo/archive/refs/heads/",devBranch,".zip")
  } else{
    SBooLink_Release <-
      paste0("https://github.com/rivm-syso/SBoo/archive/refs/tags/",Release,".zip")
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
  
  download.file(SBScriptsLink_Release,paste0(Temp_Folder,"/SBzips/SBooScripts_",Release,".zip"))
  download.file(SBooLink_Release,paste0(Temp_Folder,"/SBzips/SBoo_",Release,".zip"))
  
  empty_folder <- function(target_folder){
    if (dir.exists(target_folder)) {
      items <- list.files(target_folder, full.names = TRUE, recursive = FALSE)
      if (length(items) > 0) {
        unlink(items, recursive = TRUE, force = TRUE)
      }
    }
  }

  target_folder <- paste0(Temp_Folder, "/SimpleBox")
  empty_folder(target_folder = target_folder)

  # Unzip the main folders
  zipfile <- paste0(Temp_Folder,"/SBzips/SBooScripts_", Release,".zip")
  file.exists(zipfile)
  destination <- paste0(Temp_Folder, "/SimpleBox")
  unzip(zipfile, exdir = destination)
  
  file.rename(file.path(destination, paste0("SBooScripts-", Release)), 
              file.path(destination, "SBooScripts"))
  
  zipfile <- paste0(Temp_Folder,"/SBzips/SBoo_",Release,".zip")
  file.exists(zipfile)
  destination <- paste0(Temp_Folder, "/SimpleBox")
  unzip(zipfile, exdir = destination)
  
  file.rename(file.path(destination, paste0("SBoo-", Release)), 
              file.path(destination, "SBoo"))
  
  # Return the file paths needed 
  main_path <- paste0(Temp_Folder, "/SimpleBox")
  
  # Remove SBzips
  unlink(paste0(Temp_Folder, "/SBzips"), recursive = TRUE)
  
  return(paste0("The SimpleBox model can be found in ", main_path))
}

CompareFilesPrep(Release = tag,
                 Temp_Folder = dest_folder)

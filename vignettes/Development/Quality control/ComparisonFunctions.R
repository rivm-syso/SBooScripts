CompareFilesPrep <- function(Release = "2025.04.0",
                             Test_SBoo = "FLux_work",
                             Test_SBooScripts = "Fluxwork",
                             Temp_Folder = "C:/Temp" # an existing folder
){
  SBScriptsLink_test <- 
    paste0("https://github.com/rivm-syso/SBooScripts/archive/refs/heads/",Test_SBooScripts,".zip")
  SBScriptsLink_Release <- 
    paste0("https://github.com/rivm-syso/SBooScripts/archive/refs/tags/",Release,".zip")
  
  SBooLink_test <- 
    paste0("https://github.com/rivm-syso/SBoo/archive/refs/heads/",Test_SBoo,".zip")
  SBooLink_Release <- 
    paste0("https://github.com/rivm-syso/SBoo/archive/refs/tags/",Release,".zip")
  
  if(dir.exists(paste0(Temp_Folder,"/SBzips"))){
    oldfiles <- list.files(paste0(Temp_Folder,"/SBzips"), full.names = TRUE)
    file.remove(oldfiles)
    print("Old SBoo zipfiles deleted")
  }
  
  if(!dir.exists(paste0(Temp_Folder,"/SBzips"))){
    dir.create(paste0(Temp_Folder,"/SBzips"))
    print(paste0("Directory: ", Temp_Folder,"/SBzips", " created."))
  } else print("SBzips directory already exists")
  
  download.file(SBScriptsLink_test,paste0(Temp_Folder,"/SBzips/SBooScripts_",Test_SBooScripts,".zip"))
  download.file(SBooLink_test,paste0(Temp_Folder,"/SBzips/SBoo_",Test_SBoo,".zip"))
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
  
  target_folder <- paste0(Temp_Folder, "/SBtest")
  empty_folder(target_folder = target_folder)
  
  target_folder <- paste0(Temp_Folder, "/SBmain")
  empty_folder(target_folder = target_folder)
  
  # Unzip the Test folders 
  zipfile <- paste0(Temp_Folder,"/SBzips/SBooScripts_",Test_SBooScripts,".zip")
  file.exists(zipfile)
  destination <- paste0(Temp_Folder, "/SBtest")
  unzip(zipfile, exdir = destination)
  
  file.rename(file.path(destination, paste0("SBooScripts-", Test_SBooScripts)), 
              file.path(destination, "SBooScripts"))
  
  zipfile <- paste0(Temp_Folder,"/SBzips/SBoo_",Test_SBoo,".zip")
  file.exists(zipfile)
  destination <- paste0(Temp_Folder, "/SBtest")
  unzip(zipfile, exdir = destination)
  
  file.rename(file.path(destination, paste0("SBoo-", Test_SBoo)), 
              file.path(destination, "SBoo"))
  
  # Unzip the main folders
  zipfile <- paste0(Temp_Folder,"/SBzips/SBooScripts_", Release,".zip")
  file.exists(zipfile)
  destination <- paste0(Temp_Folder, "/SBmain")
  unzip(zipfile, exdir = destination)
  
  file.rename(file.path(destination, paste0("SBooScripts-", Release)), 
              file.path(destination, "SBooScripts"))
  
  zipfile <- paste0(Temp_Folder,"/SBzips/SBoo_",Release,".zip")
  file.exists(zipfile)
  destination <- paste0(Temp_Folder, "/SBmain")
  unzip(zipfile, exdir = destination)
  
  file.rename(file.path(destination, paste0("SBoo-", Release)), 
              file.path(destination, "SBoo"))
  
  # Return the file paths needed 
  main_path <- paste0(Temp_Folder, "/SBmain")
  test_path <- paste0(Temp_Folder, "/SBtest")
  
  return(c(main_path, test_path))
}
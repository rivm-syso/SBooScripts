#' @title ClassicNanoProcess
#' @import R6
#' @description a process representing (all speed constants in) the classic nano version in excel
#' Creates functions that can be called from the World$ environment
ClassicNanoProcess <- R6::R6Class(
  "ClassicNanoProcess",
  inherit = ProcessModule,
  public = list(
    #' @description init
    #' @param TheCore SBCore object
    #' @param filename of the excel file
    initialize = function(TheCore, filename){
      super$initialize(TheCore, exeFunction = "LoadKaas"
                       # function(){
                       #   filename = private$ExcelFileName
                       #   private$LoadKaas(k.loc = filename)
                       # }, filename = filename
      )
      private$ExcelFileName <- filename
      if (exists("verbose") && verbose) {
        warning("MPClassicNano is not part of the calculation-graph!")
      }
    },
    
    #' @description find cells where the cellname conforms the grep, with their content
    #' @param grepstr see grep
    #' @param SenseCase is by default off, to comfort the novices
    Excelgrep = function(grepstr, SenseCase = F){
      private$ExcelGrep(grepstr, SenseCase)
    },
    
    #' @description find cells depending on the initial cell with CellName, and their descendance
    #' downto the maxDepth grandchildren; or vise-versa
    #' @param CellName starting point of the tree of descending cells
    #' @param dependingOn trace the origines for the cell(formula) or the dependencies (the default)
    #' @param maxDepth recursion depth 
    Exceltrace = function(CellName, maxDepth = 5){
      private$ExcelTrace(CellName, dependingOn = F, maxDepth = maxDepth)
    },
    #' @description convenient function to find cells depending on the initial cell with CellName, 
    #' and their descendance downto the maxDepth grandchildren
    #' @param CellName see Exceltrace
    #' @param maxDepth see Exceltrace
    Exceldependencies = function(CellName, maxDepth = 5){
      private$ExcelTrace(CellName, maxDepth = maxDepth)
    },
    
    #' @description read the emission data from the scenario sheet under the
    #' @param scenario_name column
    ExcelEmissions = function(scenario_name){
      filename <- private$ExcelFileName
      r <- openxlsx::read.xlsx(filename, sheet = "scenarios",
                               cols = c(7,9:21),
                               rows = c(3:65),
                               skipEmptyRows = FALSE,colNames = TRUE)
      #Only emissions; length of actual emnissions varies with version
      r <- r[!is.na(r[,1]) & startsWith(r[,1], "E."),]
      EStates <- gsub("E.", "", r[,1])
      #EStates <- gsub("[GD]$", "U", EStates) #Gas, Dissolved -> Unbound
      
      ScenNames <- colnames(r)[colnames(r) != ""]
      #conform to R name
      scenName <- gsub(pattern = " ", replacement = ".", scenario_name)
      if (! scenName %in% ScenNames) {
        stop(paste(scenName, "not found in emission scenarios, in", filename))
      } else {
        eCol <- match(scenName, colnames(r))
        eTable <- data.frame(
          Abbr = EStates,
          Emis = as.numeric(r[,eCol])
        )
        eTable[!is.na(eTable$Emis) & eTable$Emis > 0, ]
      }
    },
    
    #' @description read all the speed constants and their from~ and to box dimensions
    ExcelSB.K = function(){
      filename <- private$ExcelFileName
      #Maximum possible size of the matrix
      nStates <- nrow(private$MyCore$states$asDataFrame)
      Bcolumn <- openxlsx::read.xlsx(filename, sheet = "engine",
                                     cols = 2,
                                     skipEmptyRows = FALSE,colNames = TRUE)
      StPnt <- match("MODEL MATRIX", Bcolumn[,1]) + 1
      FirstNotTo <- rle(startsWith(Bcolumn[StPnt:nrow(Bcolumn),1],
                        "to"))
      AllToLength <- FirstNotTo$lengths[1]
      rK <- openxlsx::read.xlsx(filename, sheet = "engine",
                               rows = c(StPnt:(StPnt+AllToLength)),
                               cols = c(4:(4+AllToLength)),
                               skipEmptyRows = FALSE,colNames = TRUE)
      #Verify states
      FoundStates <- sapply(strsplit(names(rK), "\\."), function(x) x[2]) #after the "from" -part
      MatchedStates <- private$MyCore$findState(FoundStates)
      if (anyNA(MatchedStates)) {
        stop(do.call(paste, c("Unmatched States", as.list(FoundStates[is.na(MatchedStates)]))))
      }
      StateInd <- unique(c(private$MyCore$kaas$i, private$MyCore$kaas$j))
      if (!all(StateInd %in% MatchedStates)){
        warning(do.call(paste, c("States not all in core", as.list(private$MyCore$states$AsDataFrame[-MatchedStates]))))
        # remove everywhere? including kaas, ... TODO by core$solve()
      }
      rKNumbers <- as.data.frame(lapply(rK, as.numeric))
      if (any(is.na(rKNumbers))) {
        stop ("non-numbers in engine - matrix")
      }
      #Row2States <- order(MatchedStates)
      #rearrange rows and cols accordingly
      ret <- as.matrix(rKNumbers) # no, original order, to be matched by name; not[Row2States, Row2States]
      rownames(ret) <- self$myCore$states$asDataFrame$Abbr[MatchedStates]
      colnames(ret) <- rownames(ret) #dito
      return(ret)
    }
  ),
  active = list(
    #' @field type r.o . Nano or molecular 
    type = function(value) {
      if (missing(value)) {
        return(private$l_type)
      } else {stop("type is set by input xlsx")}
    },
    #' @field version r.o. as given in the 1rst sheet of the file
    version =  function(value) {
      if (missing(value)) {
        return(private$l_version)
      } else {stop("version is set by input xlsx")}
    },
    #' @field namedValues relevant cells r.o. 
    namedValues = function(value) {
      if (missing(value)) {
        return(private$l_namedValues)
      } else {stop("namedValues are set by input xlsx")}
    }
  ),
  
  private = list(
    ExcelFileName = NA,
    l_type = NA,
    l_version = NA,
    l_namedValues = NA,
    l_PrepGrep = NA,
    l_dependencies = NA,

    Execute = function(debugAt = NULL){ #debug can be list # content of list ignored for this sub class
      if (!is.null(debugAt)) debugonce(private$LoadKaas)
      private$LoadKaas(k.loc = private$ExcelFileName) #Function = LoadKaas, set at initialize
    },
    
    NeedVars = function() {NULL}, #overwrite!
    
    LoadKaas = function(k.loc=system.file("testdata","20190117 SimpleBox4.01-nano rev 21aug.xlsx",package="SBoo"),
                        Xcols=c(7,12), sheets=c("input","regional","continental","global")) {
      
      cells <- tidyxl::xlsx_cells(path = k.loc, check_filetype = T, include_blank_cells = F)
      # version; and conventional or nano?
      private$l_type <- cells$content[cells$sheet == "version" &
                                        cells$address == "B3"]
      private$l_version <- cells$date[cells$sheet == "version" &
                                        cells$address == "C3"]
      
      cells <- cells[cells$sheet %in% sheets,]
      
      #obtain all formulas that are names in excel
      AllNames <- tidyxl::xlsx_names(path = k.loc)
      AllNames <- AllNames[AllNames$is_range,]
      #sloppy, buggy not TIDY-xl
      AllNames$sheet <- sapply(sapply(AllNames$formula, strsplit, "!"), function(x) x[1])
      #Names of variables are in column 7, the value or formula is in column 11 
      VarNames <- cells[cells$col == 7 , c("sheet", "row", "character")]
      FormOrVal <- cells[cells$col == 11,c("sheet", "row", "formula", "numeric")]
      names(FormOrVal) <- c("sheet", "row", "Formula", "numeric")
      VarForm <- inner_join(VarNames, FormOrVal)
      
      rm(cells) 
      #substitute addresses like sheet!$c$i in VarForm$Formula by corresponding name with address ci; no $ signs
      #if the cell reference is on another sheet, there is the name in excel as string in the formula
      for (sheet in sheets){ #sheet = "regional"
        #substitute only the names for this sheet, filter others
        SheetRenames <- gsub(x = AllNames$formula[AllNames$sheet == sheet], pattern = "\\$", replacement = "")
        if (length(SheetRenames) > 0 ){
          SheetRenames <- gsub(x = SheetRenames, pattern = "\\$", replacement = "")
          SheetRenames <- gsub(x = SheetRenames, pattern = "\\!", replacement = "")
          SheetRenames <- gsub(x = SheetRenames, pattern = sheet, replacement = "")
          
          #order; longest first == greedy
          greedy <- order(nchar(SheetRenames), decreasing = T)
          for (i in 1:length(SheetRenames)) { #i = 2
            nms <- SheetRenames[greedy[i]]
            replaceby <- AllNames$name[AllNames$sheet == sheet][greedy[i]]
            if(is.na(nms) | is.na(replaceby)) browser()
            VarForm$Formula[VarForm$sheet == sheet] <- gsub(pattern = nms, replacement = replaceby, VarForm$Formula[VarForm$sheet == sheet])
          }
        }
      }
      #TODO References to outside of sheet ??
      
      #AllForm <- do.call(rbind, FormPsheet) %>% as.data.frame()
      alldf <- lapply(1:nrow(VarForm), function(iParent){ #iParent = 1189
        grepIn <- unique(unlist(str_extract_all(VarForm[iParent, "Formula"], pattern = "[a-zA-Z_][a-zA-Z_0-9\\.]*")))
        grepIn <- grepIn[!grepIn %in% c("E", tidyxl::excel_functions)]
        VarGrep <- VarForm$character %in% grepIn
        data.frame(
          ChildVar = rep(VarForm$character[iParent], times = length(VarForm$character[VarGrep])) ,
          ParentVar = VarForm$character[VarGrep]
        )
      })
      
      private$l_dependencies <- do.call(rbind, alldf)
      private$l_namedValues <- VarForm
      
      #get all k.* names and values
      SB.kaas <- VarForm[startsWith(VarForm$character, prefix = "k."), c("character", "numeric")]
      names(SB.kaas) <- c("knames","kvalue")
      
      #SB.kaas$kvalue <- as.numeric(SB.kaas$kvalue)
      #first split by the "." and lose the initial "k"
      #the [To...] part may be missing; for the diag() == removal
      SBsplit <- strsplit(SB.kaas$knames, split = "[.]")
      SBsplit2 <- lapply(SBsplit, function(Aline2or3) {
        unlistline <- as.character(unlist(Aline2or3))
        unlistline[2]
      })
      #If "to" is absent then TO <- From (degradation)
      SBsplit3 <- lapply(SBsplit, function(Aline2or3) {
        unlistline <- as.character(unlist(Aline2or3))
        ifelse(length(unlistline)==3, unlistline[3],unlistline[2])
      })
      
      SBsplit <- data.frame(
        OldName = SB.kaas$knames,
        fromAbbr = unlist(SBsplit2),
        toAbbr = unlist(SBsplit3),
        k = SB.kaas$kvalue
      )
      
      #secondly, find the state from and to which the k is for
      SBsplit$i <- private$MyCore$findState(SBsplit$fromAbbr)
      
      #btw, Species can be missing (meaning: for all species)
      SBsplitFromSpecna <- SBsplit[is.na(SBsplit$i),]
      SBsplit<-SBsplit[!is.na(SBsplit$i),]
      SBsplit$j <- private$MyCore$findState(SBsplit$toAbbr)
      #expand where species is.na to all species
      if (nrow(SBsplitFromSpecna) > 0) {
        ExpandSpec <- data.frame(
          FromSpec = c("U","S","A","P"),     
          stringsAsFactors = F
        )
        SBsplitFromSpecna <- expand.grid.df(SBsplitFromSpecna,ExpandSpec)
        SBsplitFromSpecna$From <- do.call(paste, c(data.frame(SBsplitFromSpecna$fromAbbr, SBsplitFromSpecna$FromSpec), sep=""))
        SBsplitFromSpecna$To <- do.call(paste, c(data.frame(SBsplitFromSpecna$toAbbr, SBsplitFromSpecna$FromSpec), sep=""))
        SBsplitFromSpecna$i <- private$MyCore$findState(SBsplitFromSpecna$fromAbbr)
        SBsplitFromSpecna$j <- private$MyCore$findState(SBsplitFromSpecna$toAbbr)
        
        #expand "OldName" with Species (to make them identifiable)
        SBsplitFromSpecna$OldName <- paste("k", SBsplitFromSpecna$fromAbbr, SBsplitFromSpecna$toAbbr, sep = ".")
        #merge back with SBsplit; NO LONGER (R4.0)  refactor
        SBsplit <- rbind(SBsplit, SBsplitFromSpecna[,names(SBsplit)])
      }
      SBsplit$process <- "LoadKaas"
      
      private$l_PrepGrep <- NA #prevent use of previous xls file
      #a "detour" separating k, to accommodate a normal process
      return(list(DimsIn = SBsplit[,-which(names(SBsplit) == "k")], AllOut = SBsplit$k))
    },
    
    #' return tree with variable and its pedegree
    #' #param cellName name (in excel) to look for
    #' #param dependingOn description
    #' #param as.DAG make a iGraph (default)? or as data.tree
    #' #param maxDepth max. depth of recursion
    ExcelTrace = function(cellName, dependingOn = T, as.DAG = T, maxDepth){ #cellName = "k.aRG.w0RD"
      #helper function; NB recursion
      GetNodes <- function(ParentNode, depth){ #ParentNode = ForeFather
        #find dependencies in private$l_dependencies
        if (dependingOn) {
          NodeDepend <- private$l_dependencies[private$l_dependencies$ChildVar == ParentNode$name,]
          NodeDepend <- private$l_namedValues[private$l_namedValues$character %in% NodeDepend$ParentVar,]
        } else {
          NodeDepend <- private$l_dependencies[private$l_dependencies$ParentVar == ParentNode$name,]
          NodeDepend <- private$l_namedValues[private$l_namedValues$character %in% NodeDepend$ChildVar,]
        }
        #which correspond to private$l_namedValues
        
        if (nrow(NodeDepend) > 0 & depth < maxDepth) {
          for (i in 1:nrow(NodeDepend)){ #i = 1
            if (is.na(NodeDepend$Formula[i])){
              NewChild <- ParentNode$AddChild(NodeDepend$character[i], Formula = NodeDepend$numeric[i])
            } else {
              NewChild <- ParentNode$AddChild(NodeDepend$character[i], Formula = NodeDepend$Formula[i])
              GetNodes(NewChild, depth = depth + 1)
            }
          }
        }
        ParentNode
      }
      
      # one or a vector of cellName? If multiple; we need a (fake) parent
      if (length(cellName) > 1) {
        #browser()
        TreeNodes <- data.tree::Node$new("o")
        TreeNodes$Formula <- ""
        NodeDepend <- private$l_namedValues[private$l_namedValues$character %in% cellName,]
        for (i in 1:nrow(NodeDepend)){ #i = 1
          if (is.na(NodeDepend$Formula[i])){
            NewChild <- TreeNodes$AddChild(NodeDepend$character[i], Formula = NodeDepend$numeric[i])
          } else {
            NewChild <- TreeNodes$AddChild(NodeDepend$character[i], Formula = NodeDepend$Formula[i])
            GetNodes(NewChild, depth = 1)
          }
        }
      } else {
        Parent <- private$l_namedValues[private$l_namedValues$character == cellName,]
        if (nrow(Parent) == 0) {return (NA)}
        ForeFather <- data.tree::Node$new(Parent$character)
        ForeFather$Formula <- Parent$Formula
        TreeNodes <- GetNodes(ForeFather, depth = 1)
      }
      
      if (!as.DAG) {return(TreeNodes)}
      
      # select nodes from dataframe and let iGraph do the work
      ret <- TreeNodes$Do(function(ThisNode) {
        print(ThisNode$name) #side effect only
      })
      ret <- do.call(rbind, lapply(ret, function(x){
        if (x$isRoot) {
          return(NULL)
        } else {
          return(c( x$name, x$parent$name))
        }
      })) %>% as.data.frame()
      
      if (!dependingOn) {#reverse all from/to
        ret <- ret[,c(2,1)]
      }

      if (length(cellName) > 1) {
        # remove the o, inserted for a single grandparent
        ret <- ret[ret$V2 != "o" & ret$V1 != "o" & (!is.na(ret$V1)),]
      }
      
      #names(ret) <- c("child", "parent")
      if (nrow(ret) == 0) {
        warning("No tree for this variable")
        return(NA)
      } else {
        igraph::graph_from_data_frame(unique(ret[,c(1,2)]))
      }
    },
    
    #' return data.frame with variable in sb4n spreatsheet and their values
    #' #param grepstr pattern
    #' #param filename sb4n spreatsheet
    ExcelGrep = function(grepstr, SenseCase) {
      if (length(private$l_PrepGrep) == 1 && is.na(private$l_PrepGrep)) {
        D3 <- list(
          Scale = private$MyCore$fetchData("AbbrS"),
          Species = private$MyCore$fetchData("AbbrP"),
          SubCompart = private$MyCore$fetchData("AbbrC")
        )
        names(D3$Scale) <- c("name", "abbr")
        names(D3$Species) <- c("name", "abbr")
        names(D3$SubCompart) <- c("name", "abbr")
        
        hier <- data.frame(
          varName = self$namedValues$character, 
          FormValue = self$namedValues$Formula,
          Numeric = self$namedValues$numeric
        )
        kspname <- strsplit(hier$varName, split = "[.]")
        kspDim1 <- sapply(kspname, function(x) {
          ifelse(length(x) > 1, x[2], "")
        })
        kspDim2 <- sapply(kspname, function(x) {
          ifelse(length(x) == 3, x[3], "")
        })
        
        GrepDims <- function(ksparts) {
          lapply(D3, function(dfD) {
            #dfD = D3[[1]]
            AllGrep <-
              lapply(dfD$abbr, function(x)
                regexpr(x, ksparts))
            WhichGrep <- do.call(cbind, AllGrep)
            MaxGrep <- apply(WhichGrep, 1, which.max)
            IsHit <- WhichGrep[cbind(seq_along(MaxGrep), MaxGrep)] > 0
            InclMin1Vec <- c(NA, dfD$name)
            WithinThat <- MaxGrep * IsHit + 1
            InclMin1Vec[WithinThat]
          }) %>% as.data.frame()
        }
        #debugonce(GrepDims)
        private$l_PrepGrep <- cbind(hier, GrepDims(kspDim1), GrepDims(kspDim2))
      }
      
      ret <- private$l_PrepGrep[grep(grepstr, private$l_PrepGrep$varName, ignore.case=!SenseCase),]
      #less dims?
      ret <- lapply(ret, function(x){
        if (all(is.na(x))) 
        {return (NULL)} else {
          return(x)
        }
      }) 
      Todel <- sapply(ret, is.null)
      as.data.frame(ret[!Todel])
    }
  )
)
#To generate globalFormulas, continentalFormulas and regionalFormulas:
#Sub Getformulas()
'From www.extendoffice.com
Dim Rng As Range
Dim WorkRng As Range
Dim xSheet As Worksheet
Dim xRow As Integer
xTitleId = "KutoolsforExcel"
Set WorkRng = Application.Selection
Set WorkRng = Application.InputBox("Range", xTitleId, WorkRng.Address, Type:=8)
Set WorkRng = WorkRng.SpecialCells(xlFormulas, 23)
If WorkRng Is Nothing Then Exit Sub
Application.ScreenUpdating = False
Set xSheet = Application.ActiveWorkbook.Worksheets.Add
xSheet.Range("A1:C1") = Array("Address", "Formula", "Value")
xSheet.Range("A1:C1").Font.Bold = True
xRow = 2
For Each Rng In WorkRng
    xSheet.Cells(xRow, 1) = Rng.Address(RowAbsolute:=False, ColumnAbsolute:=False)
    xSheet.Cells(xRow, 2) = " " & Rng.Formula
    xSheet.Cells(xRow, 3) = Rng.Value
    xRow = xRow + 1
Next
xSheet.Columns("A:C").AutoFit
Application.ScreenUpdating = True
End Sub
'


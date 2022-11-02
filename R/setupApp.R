setupApp <- function(questionnaire_file){
  
  # Loading of EU-EpiCap questionnaire  -----------------------------------------

  #Read in questionnaire from file and turn into df
  questionnaire <<- readQuestionnaire(questionnaire_file)
  #Turn questionnaire df into commands that will build questionnaire pages in App
  commands <<- questionnaire2Commands(questionnaire) 
 
  # Setup for plotting of results ----------------------------------------------------------------
  
  setupRadarPlot()
  setupLollipopPlot()

  # Setup for benchmarking ------------------------------------------------------------
  
  #Identify available reference datasets (for use in benchmarking dropdown menu)
  
  #ref_files<<-list.files("data/reference_datasets", pattern=".+_ST.+")
  #This identifies reference data files based on path and name.
  
  #With Carlijn's structure, there were TWO SEPARATE files per reference 
  #dataset: one for the indicator level, one for the target level
  #Both files were needed for the figures, but as they represented the same
  #dataset, the idea was to just have the user select the DATASET in the
  #dropdown menu.
  
  #The below extracts the unique benchmark dataset names (the part before "_ST")
  #from the reference file names.
  #ref_datasets<<-unique(sub(pattern = "_ST.+",replacement="",ref_files))
  
  #ref_datasets was used to populate the dropdown menu in benchmarkingPage.R
  #NB: ref_datasets is just a collection of strings (that are partial file
  #names), it does not contain full file paths, nor does it link to the files in 
  #any way.
}
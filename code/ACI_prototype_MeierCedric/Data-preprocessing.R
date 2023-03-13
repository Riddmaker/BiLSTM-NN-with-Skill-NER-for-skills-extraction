#Pre-processing of Data data job posts. Data is available here: https://www.kaggle.com/datasets/madhab/jobposts
###Create new data frame of 100 random observations of the attribute "JobRequirments" - omitting all NA's.

#Load necessary libraries
library(tidyverse)
library(stringr)

#Clean workspace
rm(list=ls())

#Set working directory
setwd("G:/OneDrive/FHNW/Modules/III_ACI/0_Assignments/Assignment_IV")
#Load data frame
job_posts <- read.table("data job posts.csv", sep = ",", header = TRUE)
#View data frame
#View(job_posts)

#Make new data frame
job_requirements <- select(job_posts, c(JobRequirment))
#View data frame
#View(job_requirements)
#Transform fake NA to real NA
job_requirements$JobRequirment <- ifelse(job_requirements$JobRequirment == "N/A", NA, job_requirements$JobRequirment)
#Cleanse NA's
job_requirements <- na.omit(job_requirements)
#Count NA's for proof
sum(is.na(job_requirements$JobRequirment))

#take 100 random observations
set.seed(420)
job_requirements_export <- as.data.frame(job_requirements[sample(nrow(job_requirements), size=100), ])
#Control
str(job_requirements_export)
#Correct attribute name
job_requirements_export <- plyr::rename(job_requirements_export, c("job_requirements[sample(nrow(job_requirements), size = 100), ]" = "job_requirements_attribute"))
#Control
str(job_requirements_export)

#Format the text
for (h in 1:nrow(job_requirements_export)) {
  
  job_requirements_export[h,1] <- gsub('-', '', as.character(job_requirements_export[h,1]), fixed = TRUE)
  job_requirements_export[h,1] <- gsub(';', '.', as.character(job_requirements_export[h,1]), fixed = TRUE)
  job_requirements_export[h,1] <- gsub(':', '.', as.character(job_requirements_export[h,1]), fixed = TRUE)
  job_requirements_export[h,1] <- gsub('\n', ' ', as.character(job_requirements_export[h,1]), fixed = TRUE)
  job_requirements_export[h,1] <- gsub('/', '', as.character(job_requirements_export[h,1]), fixed = TRUE)
  job_requirements_export[h,1] <- gsub('  ', ' ', as.character(job_requirements_export[h,1]), fixed = TRUE)
  job_requirements_export[h,1] <- gsub(',', '', as.character(job_requirements_export[h,1]), fixed = TRUE)
  job_requirements_export[h,1] <- trimws(job_requirements_export[h,1], which = c("both", "left", "right"))

}

#Export CSV
write.csv(job_requirements_export,"job_requirements_export.csv", col.names = TRUE, row.names = FALSE)


###At this point the data is treated with SpaCy and SkillNER in Google Colab. The output will be a new annotated data frame which is saved in google drive. 
###We download the data frame to the working directory, import into R and start treating it here.


##Load new annotated data frame
requirements_annotated <- read.table("annotations.csv", fill = TRUE, sep = ',', header = TRUE)
#Delete unnecessary full and partial matches attribute
requirements_annotated <- select(requirements_annotated, -c("X.1","X"))

##We create an empty new data-frame with our preferred final output format.
#Create column names.
columns <- c("jobpostnr","nodeid", "word", "tag")
#Create data.frame
annotated_job_posts <- data.frame(matrix(nrow = 0, ncol = length(columns)))
#Assign column names to data.frame
colnames(annotated_job_posts) <- columns

##Processing of final data frame
#Set iterator and job post id
i <- 1
job_post_id <- 1
#We have two observations per requirements post (full and partial matches). Therefore we need a while loop that iterates per two observations.
while (i <= nrow(requirements_annotated)) {
  
  ##Processing of results attribute of the current job post.
  #We merge full and partial matches.
  skills_summarized <- paste(requirements_annotated[i,2], requirements_annotated[i+1,2])
  #We delete some unnecessary characters and set a word for the string matcher afterwards.
  skills_summarized <- gsub('[', '', skills_summarized, fixed = TRUE)
  skills_summarized <- gsub(']', ' PATTERN_ ', skills_summarized, fixed = TRUE)
  skills_summarized <- gsub('}', '', skills_summarized, fixed = TRUE)
  skills_summarized <- trimws(skills_summarized, which = c("both", "left", "right"))
  #We create a list, where all found skills will be in one item.
  skills_list <- strsplit(skills_summarized, split = "{", fixed = TRUE)
  #We delete empty list items.
  skills_list <- lapply(skills_list, function(z){ z[!is.na(z) & z != ""]})
  
  ##Fill the skill_node_ids vector that will hold the node id's of all skills of the current job post.
  #Init skill_node_id's vector
  skill_node_ids <- NA
  #We iterate through the skills list.
  for (k in 1:lengths(skills_list)) {
    
    #Extract node id's of current list item.
    node_ids <- as.character(str_extract_all(skills_list[[1]][k],"(?<='doc_node_id': ).+(?= PATTERN_ )"))
    #Append skills to existing vector
    skill_node_ids <- append(skill_node_ids, node_ids)
    
  }
  
  #We delete all NA entries
  skill_node_ids <- skill_node_ids[!is.na(skill_node_ids)]
  #We delete all still remaining unnecessary characters
  skill_node_ids <- gsub("[^0-9, ]", "", skill_node_ids)
  #Remove all double spaces
  skill_node_ids <- gsub("  ", " ", skill_node_ids)
  #Make sure all values are separate vector items
  skill_node_ids <- unlist(strsplit(skill_node_ids,","))
  #Remove remaining spaces
  skill_node_ids <- gsub(" ", "", skill_node_ids, fixed = TRUE)
  #Make the vector numeric
  skill_node_ids <- as.numeric(skill_node_ids)
  #Off-set the -1 for skill node id's
  skill_node_ids <- skill_node_ids + 1
  
  ##We fill the final data frame
  #Get number of words of current job description
  job_description_length <- lengths(gregexpr("\\W+", requirements_annotated[i,1])) + 1
  #We make a for loop for the vector length
  for (j in 1:job_description_length) {
    
    #Add row for each word in final data frame
    annotated_job_posts[nrow(annotated_job_posts) + 1,] <- NA
    #Add current job post id
    annotated_job_posts[nrow(annotated_job_posts),1] <- as.numeric(job_post_id)
    #Add current position in string
    annotated_job_posts[nrow(annotated_job_posts),2] <- as.numeric(j)
    #Add current word
    annotated_job_posts[nrow(annotated_job_posts),3] <- as.character(word(requirements_annotated[i,1], j))
    
    ##Set the right tag
    #Check if current string position is present in the skill_node_ids, if yes the tag should be a skill.
    #Otherwise it should be tagged as ordinary word.
    if (j %in% skill_node_ids) {
      
      #B-SKILL should mark beginning of skills, I-SKILL mark the following words.
      if (annotated_job_posts[nrow(annotated_job_posts)-1,4] == "B-SKILL" || annotated_job_posts[nrow(annotated_job_posts)-1,4] == "I-SKILL") {
        
        annotated_job_posts[nrow(annotated_job_posts),4] <- "I-SKILL"
        
      } else {
        
        annotated_job_posts[nrow(annotated_job_posts),4] <- "B-SKILL"
        
      }
      
    } else {
      
      annotated_job_posts[nrow(annotated_job_posts),4] <- "O"
      
    }
    
  }
  
  #Augment iterator and job post id
  i <- i + 2
  job_post_id <- job_post_id + 1
  
}

#Export final csv
write.csv(annotated_job_posts,"annotated_job_posts.csv", col.names = TRUE, row.names = FALSE)

# You should create one R script called run_analysis.R that does the following.
# 
# Merges the training and the test sets to create one data set.
# Extracts only the measurements on the mean and standard deviation for each measurement.
# Uses descriptive activity names to name the activities in the data set
# Appropriately labels the data set with descriptive variable names.
# From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
# https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

library(dplyr)

zipfile <- "./Dataset.zip"

## Download and unzip the dataset:
if (!file.exists(zipfile)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
  download.file(fileURL, zipfile,mode='wb')
}  
if (!file.exists("UCI HAR Dataset")) { 
  unzip(zipfile) 
}

# read activity labels
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
activityLabels[,2] <- as.character(activityLabels[,2])
#read feature description
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

# Extract only the data on mean and standard deviation
featuresWanted <- features[grep("mean\\(\\)|std\\(\\)",features[,2]),]

#Reading training data
XTrain <- read.table("./UCI HAR Dataset/train/X_train.txt")
YTrain <- read.table("./UCI HAR Dataset/train/Y_train.txt")
SubjectTrain <- read.table("./UCI HAR Dataset/train/subject_train.txt")

# Reading test data
XTest <- read.table("./UCI HAR Dataset/test/X_test.txt")
YTest <- read.table("./UCI HAR Dataset/test/Y_test.txt")
SubTest <- read.table("./UCI HAR Dataset/test/subject_test.txt")

#Merges the training and the test sets to create one data set
XMerged <- rbind(XTrain, XTest)
YMerged <- rbind(YTrain, YTest)
SubMerged <- rbind(SubjectTrain, SubTest)

#Extracts only the measurements on the mean and standard deviation for each measurement
XMerged <- XMerged[,featuresWanted[,1]]

# Uses descriptive activity names to name the activities in the data set
colnames(YMerged) <- "activity"
YMerged$activitylabel <- factor(YMerged$activity, labels = as.character(activityLabels[,2]))
activitylabel <- YMerged[,-1]

# Appropriately labels the data set with descriptive variable names.
colnames(XMerged) <- features[featuresWanted,]


# From the data set in step 4, creates a second, independent tidy data set with the average
# of each variable for each activity and each subject.
colnames(SubMerged) <- "subject"
total <- cbind(XMerged, activitylabel, SubMerged)
total_mean <- total %>% group_by(activitylabel, subject) %>% summarize_each(funs(mean))
write.table(total_mean, file = "./UCI HAR Dataset/tidydata.txt", row.names = FALSE, col.names = TRUE)


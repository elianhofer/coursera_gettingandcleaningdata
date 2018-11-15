## Load packages
library("reshape2", "data.table")

## Download and unzip the dataset:
filename <- "getdata_dataset.zip"
if (!file.exists("filename")){
        fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
        download.file(fileURL, filename, method="curl")
}
if (!file.exists("UCI HAR Dataset")) { 
        unzip(filename) 
}

## Load activity Names & features
activityNames <- read.table("UCI HAR Dataset/activity_labels.txt")
activityNames[,2] <- as.character(activityNames$V2)
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features$V2)

## Extract features needed (mean, std), clean feature names
featuresRequired <- grep(".*mean.*|.*std.*", features[,2])
featuresRequired.names <- grep(".*mean.*|.*std.*", features[,2], value = TRUE)
featuresRequired.names <- gsub('mean','Mean', featuresRequired.names)
featuresRequired.names <- gsub('std','Std', featuresRequired.names)
featuresRequired.names <- gsub('\\()','', featuresRequired.names)
featuresRequired.names <- gsub('-','', featuresRequired.names)

## Load the datasets
testSubject <- read.table("UCI HAR Dataset/test/subject_test.txt")
testActivities <- read.table("UCI HAR Dataset/test/y_test.txt")
testData <- read.table("UCI HAR Dataset/test/X_test.txt")[,featuresRequired]
test <- cbind(testSubject, testActivities, testData)
trainSubject <- read.table("UCI HAR Dataset/train/subject_train.txt")
trainActivities <- read.table("UCI HAR Dataset/train/y_train.txt")
trainData <- read.table("UCI HAR Dataset/train/X_train.txt")[,featuresRequired]
train <- cbind(trainSubject, trainActivities, trainData)

## Merge all data in one dataset and rename columns
allData <- rbind(train, test)
colnames(allData) <- c("subject","activity", featuresRequired.names)

## Transform column subject and activity into factors
allData$subject <- as.factor(allData$subject)
allData$activity <- factor(allData$activity, levels = activityNames[,1], labels = activityNames[,2])

## Create new dataset with the mean of the variable for each activity and each subject
melted_data <- melt(allData, id = c("subject", "activity"))
final_data <- dcast(melted_data, subject + activity ~ variable, mean)

## Save the data to the file "tidy.txt"
write.table(final_data, "tidy.txt", row.names = FALSE, quote = FALSE)

# 1. Get the data
#Download the file and put it in the "data1" folder
if(!file.exists("./data1")){dir.create("./data1")}

fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./data1/Dataset.zip")

# Unzip dataSet to /data1 directory
unzip(zipfile="./data1/Dataset.zip",exdir="./data1")
#get the list of the fileset 
path_zp <- file.path("./data1" , "UCI HAR Dataset")
files<-list.files(path_zp, recursive=TRUE)
# 2. Read data from the target files
#reading data from the files into the variables

dataActivityTest  <- read.table(file.path(path_zp, "test" , "Y_test.txt" ),header = FALSE)
dataActivityTrain <- read.table(file.path(path_zp, "train", "Y_train.txt"),header = FALSE)
dataSubjectTrain <- read.table(file.path(path_zp, "train", "subject_train.txt"),header = FALSE)
dataSubjectTest  <- read.table(file.path(path_zp, "test" , "subject_test.txt"),header = FALSE)
dataFeaturesTest  <- read.table(file.path(path_zp, "test" , "X_test.txt" ),header = FALSE)
dataFeaturesTrain <- read.table(file.path(path_zp, "train", "X_train.txt"),header = FALSE)
#the properties of the above varibles
str(dataActivityTest)
str(dataActivityTrain)
str(dataSubjectTest)
str(dataSubjectTrain)
str(dataFeaturesTest)
str(dataFeaturesTrain)
# 3. Merges the training and the test sets to create one data set
#Concatenate the data tables by rows
dataSubject <- rbind(dataSubjectTrain, dataSubjectTest)
dataActivity<- rbind(dataActivityTrain, dataActivityTest)
dataFeatures<- rbind(dataFeaturesTrain, dataFeaturesTest)
#Set names to variables
names(dataSubject)<-c("subject")
names(dataActivity)<- c("activity")
dataFeaturesNames <- read.table(file.path(path_zp, "features.txt"),head=FALSE)
names(dataFeatures)<- dataFeaturesNames$V2
#Merge columns to get the data frame "Data" for all data
dataCombine <- cbind(dataSubject, dataActivity)
Data <- cbind(dataFeatures, dataCombine)
#4. Extracts only the measurements on the mean and standard deviation 
#for each measurement
subdataFeaturesNames<-dataFeaturesNames$V2[grep("mean\\(\\)|std\\(\\)", dataFeaturesNames$V2)]
selectedNames<-c(as.character(subdataFeaturesNames), "subject", "activity" )
Data<-subset(Data,select=selectedNames)
str(Data)

#Descriptive activity names from “activity_labels.txt”
activityLabels <- read.table(file.path(path_zp, "activity_labels.txt"),header = FALSE)
Data$activity<-factor(Data$activity)
Data$activity<- factor(Data$activity,labels=as.character(activityLabels$V2))
head(Data$activity,30)
#Names of Feteatures labelled using descriptive variable names
#prefix t is replaced by time
#Acc is replaced by Accelerometer
#Gyro is replaced by Gyroscope
#prefix f is replaced by frequency
#Mag is replaced by Magnitude
#BodyBody is replaced by Body
names(Data)<-gsub("^t", "time", names(Data))
names(Data)<-gsub("^f", "frequency", names(Data))
names(Data)<-gsub("Acc", "Accelerometer", names(Data))
names(Data)<-gsub("Gyro", "Gyroscope", names(Data))
names(Data)<-gsub("Mag", "Magnitude", names(Data))
names(Data)<-gsub("BodyBody", "Body", names(Data))
names(Data)
#Second,independent tidy data set and ouput it
library(plyr);
Data2<-aggregate(. ~subject + activity, Data, mean)
Data2<-Data2[order(Data2$subject,Data2$activity),]
write.table(Data2, file = "tidydata.txt",row.name=FALSE)

# for CodeBook
write(names(Data2), file = "variables.txt", ncolumns = 1)

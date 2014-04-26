#Download and unzip the data
if (!file.exists("data")) {
        dir.create("data")
}
setwd("./data/")

temp <- tempfile()
download.file("http://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",temp)
unzip(temp, exdir = "./data")
unlink(temp)

setwd("./UCI HAR Dataset")

#Read in XTest, YTest, XTrain and YTrain
xtest <- read.table("./test/X_test.txt")
ytest <- read.table("./test/y_test.txt")
subject_test <- read.table("./test/subject_test.txt")

xtrain <- read.table("./train/X_train.txt")
ytrain <- read.table("./train/Y_train.txt")
subject_train <- read.table("./train/subject_train.txt")

features <- read.table("./features.txt")
activity_labels <- read.table("./activity_labels.txt")

#Combine Test and Train data sets (Objective #1)
test <- cbind(subject_test,ytest,xtest)                                                         
train <- cbind(subject_train, ytrain, xtrain)
final <- rbind(train, test)                                                                     

#Apply labels to features and activities (Objectives #3 and #4)
colnames(final) <- c("subject_num","activity",as.character(features[,2]))                       #assign the variables/feature names from "features" file
final$activity <- factor(final$activity, labels = as.character(activity_labels[,"V2"]))         #replace activity numbers with labels from "activity_labels" file

#Extract only means and standard deviation measurements (Objective #2)
output <- sapply(c("mean\\(\\)","std\\(\\)"), grepl, colnames(final))                           #try matching either mean or std in description
output2 <- apply(output,1, any)                                                                 #take if either word matched
tidyData <- final[,c(T,T,output2[3:length(output2)])]                                           #select only the chosen columns

#Provide averages by each subject and activity (Objective #5)
library(reshape2)
melted <- melt(tidyData, id.vars=c("subject_num","activity"))                                   #melt down data by subject and activity
tidyData2 <- dcast(melted, formula = subject_num + activity ~ variable, fun.aggregate = mean)   #dcast to get averages

#Write output to file in data folder
setwd("..")
write.table(tidyData2, "tidyData2.txt", sep='\t')                                               #write to file
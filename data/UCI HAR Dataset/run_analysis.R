
# create a data directory if not exists
if(!file.exists("data")){dir.create("data")}

url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

# Download the zip file into data directory
download.file(url, destfile = "./data/Dataset.zip", method = "libcurl")

# Unzip the zip file
unzip(zipfile="./data/Dataset.zip",exdir="./data")

# Read the train and test files
X_train <- read.table("./data/UCI HAR Dataset/train/X_train.txt")
Y_train <- read.table("./data/UCI HAR Dataset/train/y_train.txt")
subject_train <- read.table("./data/UCI HAR Dataset/train/subject_train.txt")

X_test <- read.table("./data/UCI HAR Dataset/test/X_test.txt")
Y_test <- read.table("./data/UCI HAR Dataset/test/y_test.txt")
subject_test <- read.table("./data/UCI HAR Dataset/test/subject_test.txt")

dim(X_train); dim(Y_train); dim(subject_train)
names(X_train)
dim(X_test); dim(Y_test); dim(subject_test)

# Merge Subject, input and output columns for train and test data sets
trainset <- cbind(subject_train, X_train, Y_train)
testset <- cbind(subject_test, X_test, Y_test)

dim(trainset); dim(testset)

# Merge train and test datasets
HAR_Dataset <- rbind(trainset, testset)
dim(HAR_Dataset)
names(HAR_Dataset)

# Read feature file
features <- read.table("./data/UCI HAR Dataset/features.txt")
head(features,20)
dim(features)
features$V2 <- as.character(features$V2)

# Read activity labels file
activity_labels <- read.table("./data/UCI HAR Dataset/activity_labels.txt")
head(activity_labels,20)
dim(activity_labels)
colnames(activity_labels) <- c("ActivityId", "ActivityType")

featureNames <- c("SubjectId", features$V2, "ActivityId")
colnames(HAR_Dataset)
# Override the existing names
colnames(HAR_Dataset) <- featureNames

# Read column names into a var_names variable
var_names <- colnames(HAR_Dataset)
var_names

# 2. Extracting only the measurements on the mean and 
# standard deviation for each measurement

mean_sd = grepl("ActivityId" , var_names) | grepl("SubjectId" , var_names) | grepl("mean.." , var_names) | grepl("std.." , var_names)
#A subtset has to be created to get the required dataset
mean_sd_dataset <- HAR_Dataset[ , mean_sd == TRUE]

# 3. Use descriptive activity names to name the activities in the data set
HAR_mean_sd <- merge(x = mean_sd_dataset, 
                     y = activity_labels, 
                     by='ActivityId', 
                     all.x = TRUE)

# all.x = TRUE to avoid Error in fix.by(by.x, x) : 'by' must specify uniquely valid columns


Grp_Sub_Act <- aggregate( . ~ SubjectId + ActivityId, HAR_mean_sd, mean)
# Order the result by SubjectId and ActivityId
Grp_Sub_Act <- Grp_Sub_Act[order(Grp_Sub_Act$SubjectId, Grp_Sub_Act$ActivityId),]

# Writing the group data by  SubjectId and ActivityId in txt file
write.table(Grp_Sub_Act, 
            "./data/UCI HAR Dataset/Avg_Sub_Act.txt", 
            row.names = FALSE,
            col.names = TRUE)

Average_mean_sd_dataset <- 
  read.table("./data/UCI HAR Dataset/Avg_Sub_Act.txt")
dim(Average_mean_sd_dataset)
head(Average_mean_sd_dataset)

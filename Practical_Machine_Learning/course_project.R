library(caret)
library(rpart)
library(rpart.plot)
library(RColorBrewer)
library(rattle)
library(randomForest)

trainRaw <- read.csv("pml-training.csv")
testRaw <- read.csv("pml-testing.csv")

trainRaw <- trainRaw[, colSums(is.na(trainRaw)) == 0] 
testRaw <- testRaw[, colSums(is.na(testRaw)) == 0] 

classe <- trainRaw$classe
trainRemove <- grepl("^X|timestamp|window", names(trainRaw))
trainRaw <- trainRaw[, !trainRemove]
trainCleaned <- trainRaw[, sapply(trainRaw, is.numeric)]
trainCleaned$classe <- classe
testRemove <- grepl("^X|timestamp|window", names(testRaw))
testRaw <- testRaw[, !testRemove]
testCleaned <- testRaw[, sapply(testRaw, is.numeric)]
nearZeroVar(trainCleaned, saveMetrics=TRUE)

set.seed(22519) # For reproducibile purpose
inTrain <- createDataPartition(y=trainCleaned$classe, p=0.6, list=FALSE)
trainData <- trainCleaned[inTrain, ]; testData <- trainCleaned[-inTrain, ]
dim(trainData); dim(testData)

modFitA1 <- rpart(classe ~ ., data=trainData, method="class")
fancyRpartPlot(modFitA1)
predictionsA1 <- predict(modFitA1, testData, type = "class")
confusionMatrix(predictionsA1, testData$classe)
 
modFitB1 <- randomForest(classe ~. , data=trainData)
predictionsB1 <- predict(modFitB1, testData, type = "class")
confusionMatrix(predictionsB1, testData$classe)

predictionsB2 <- predict(modFitB1, testCleaned, type = "class")

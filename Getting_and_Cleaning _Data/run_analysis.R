library(data.table)

run_analysis = function() {
  x_train = as.data.frame(readLines("UCI HAR Dataset/train/X_train.txt"), stringsAsFactors=FALSE)
  rownames(x_train) = 1:nrow(x_train)
  colnames(x_train) = "features"
  y_train = as.data.frame(readLines("UCI HAR Dataset/train/y_train.txt"))
  colnames(y_train) = "activity"
  subject_train = as.data.frame(readLines("UCI HAR Dataset/train/subject_train.txt"))
  colnames(subject_train) = "subject"
  
  x_test = as.data.frame(readLines("UCI HAR Dataset/test/X_test.txt"), stringsAsFactors=FALSE)
  rownames(x_test) = 1:nrow(x_test)
  colnames(x_test) = "features"
  y_test = as.data.frame(readLines("UCI HAR Dataset/test/y_test.txt"))
  colnames(y_test) = "activity"
  subject_test = as.data.frame(readLines("UCI HAR Dataset/test/subject_test.txt"))
  colnames(subject_test) = "subject"
  
  x_merge = rbind(x_train, x_test)
  y_merge = rbind(y_train, y_test)
  subject_merge = rbind(subject_train, subject_test)
  
  feature_names = as.data.frame(readLines("UCI HAR Dataset/features.txt"), stringsAsFactors = FALSE)
  colnames(feature_names) = "feature_names" 
  meanStdFeatures = grep("mean|std", feature_names$feature_names)

  measurements = vapply(x_merge$features, function(elem) strsplit(elem, " "), FUN.VALUE=list(1))
  measurements = lapply(measurements, function(elem) as.numeric(elem))
  measurements = lapply(measurements, function(elem) elem[complete.cases(elem)])
  measurements = lapply(measurements, function(elem) elem[meanStdFeatures])
  measurements = as.data.frame(measurements)
  colnames(measurements) = 1:ncol(measurements)                               
  measurements = t(measurements)
  
  activity_label = as.data.frame(readLines("UCI HAR Dataset/activity_labels.txt"), stringsAsFactors=FALSE)
  activity_label = as.data.frame(vapply(strsplit(activity_label[,1], " "), function(elem) elem[2], FUN.VALUE=character(1)))
  activitySet = data.frame(activity=1:6, activityLabel=activity_label[,1])
  y_merge$id  = 1:nrow(y_merge)
  y_merge_des = merge(y_merge, activitySet, by="activity", all.x=TRUE)
  y_merge_des = y_merge_des[order(y_merge_des$id),]
  
  features_names = vapply(strsplit(feature_names[,1], " "), function(elem) return(elem[2]), FUN.VALUE=character(1))
  feature_names = features_names[meanStdFeatures]

  merged_data = data.table(measurements)
  setnames(merged_data, names(merged_data), feature_names)
  merged_data$subject = as.numeric(subject_merge[,1])
  merged_data$activity = y_merge_des$activityLabel

  mean_by_subject = merged_data[,lapply(.SD,mean),by="subject",.SDcols=1:length(meanStdFeatures)]
  mean_by_subject = mean_by_subject[order(subject)]
  mean_by_activity = merged_data[,lapply(.SD,mean),by="activity",.SDcols=1:length(meanStdFeatures)]
  mean_merge = rbind(mean_by_subject, mean_by_activity, fill=TRUE)
  write.table(mean_merge, "./tidy_data.txt", row.names=FALSE)
  
}
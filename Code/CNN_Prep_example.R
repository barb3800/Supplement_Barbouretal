# EXAMPLE CODE: Barbour et al, "Using machine learning approaches to classify vertical movement profiles and behavior"
## Contact code author with any questions: Nicole Barbour, nbarbour@umd.edu

# CNN Prep
## Here, we prep the images of individual dive profiles for the Convolutional Neural Network Model (CNN)
## we do so by simply exporting the image of each dive profile to a folder
## we also create a training dataset, where the dives are "ground-truthed" or hand-labeled with their best-fitting dive shape in order to train the model on these different categories
## The dive shapes we use (N=5, Type A, C, D, E, F) are all published shapes known for sea turtles performing pelagic behaviors (see Hochscheid et al. 2014)

# load packages
library(ggplot2)

# set your working directory (good practice)
setwd("./Example_Files")

# load in data from DTW
load(file="./Data/dtw_output_data.rda")


#####################################################################################
# Step 1: Create Training Dataset

# we will randomly sample 50 dives from each cluster and "hand-label" them by their shape
# subset by cluster
c1<-subset(cluster_dive_data_k2,cluster==1)
c2<-subset(cluster_dive_data_k2,cluster==2)

# CLUSTER 1 ______________________________________________________

# random sample of 50 dives, save their ids to a vector
sample1<-sample(unique(c1$dive_id),size=50,replace=FALSE)
sample1

# create plots to score with dive profile type
# save type (shape) to vector same length as sample

plots1<-list()
for (i in c(1:length(sample1))){
  plots1[[i]]<-ggplot()+
    geom_line(data=subset(c1,dive_id==sample1[i]),aes(int_dive_time,-(int_dive_depth),group=dive_id),size=1)+
    theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
          panel.background = element_blank(), axis.line = element_line(colour = "black"),axis.title=element_blank(),axis.text = element_blank())+
    ggtitle(paste("Dive ID",sample1[i]))
}
plots1

# here, save the shape label to a vector same length as the id vector (sample1)
## Note: this is an example and because you are drawing random samples, if you run the code yourself, the order won't match this
type1<-c("C","C","F","F","E","A","A","D","C","E","E","C","F","A","C","F","C","A","D","C","D","A","D","E","E","F","A","D","C","E","E","C","A","C","A","E","C","E","A","F","E","C","E","F","F","F","C","E","D","F")

# create dataframe of id's with type
c1_type<-data.frame(x=sample1,y=type1)
colnames(c1_type)<-c("dive_id","dive_type")

# merge with original data
c1_type_data<-merge(c1,c1_type,by="dive_id")

# subset by type
c1_C<-subset(c1_type_data,dive_type=="C")
c1_F<-subset(c1_type_data,dive_type=="F")
c1_E<-subset(c1_type_data,dive_type=="E")
c1_A<-subset(c1_type_data,dive_type=="A")
c1_D<-subset(c1_type_data,dive_type=="D")

# print plots (images) of dives from each shape type to individual folders 
## Type C
for(i in c(unique(c1_C$dive_id))){
  plot<-ggplot()+
    geom_line(data=subset(c1_C,dive_id==i),aes(int_dive_time,-(int_dive_depth),group=dive_id),size=1)+
    theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
          panel.background = element_blank(), axis.line = element_line(colour = "black"),axis.title=element_blank(),axis.text = element_blank(),axis.ticks = element_blank(),axis.line.x = element_blank(),axis.line.y = element_blank())
  jpeg(paste0("yourfilepathhere/train/TypeC/",paste0(i,".jpg")))
  print(plot)
  dev.off()
}
## Type F
for(i in c(unique(c1_F$dive_id))){
  plot<-ggplot()+
    geom_line(data=subset(c1_F,dive_id==i),aes(int_dive_time,-(int_dive_depth),group=dive_id),size=1)+
    theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
          panel.background = element_blank(), axis.line = element_line(colour = "black"),axis.title=element_blank(),axis.text = element_blank(),axis.ticks = element_blank(),axis.line.x = element_blank(),axis.line.y = element_blank())
  jpeg(paste0("yourfilepathhere/train/TypeF/",paste0(i,".jpg")))
  print(plot)
  dev.off()
}

## Type E
for(i in c(unique(c1_E$dive_id))){
  plot<-ggplot()+
    geom_line(data=subset(c1_E,dive_id==i),aes(int_dive_time,-(int_dive_depth),group=dive_id),size=1)+
    theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
          panel.background = element_blank(), axis.line = element_line(colour = "black"),axis.title=element_blank(),axis.text = element_blank(),axis.ticks = element_blank(),axis.line.x = element_blank(),axis.line.y = element_blank())
  jpeg(paste0("yourfilepathhere/train/TypeE/",paste0(i,".jpg")))
  print(plot)
  dev.off()
}
## Type A
for(i in c(unique(c1_A$dive_id))){
  plot<-ggplot()+
    geom_line(data=subset(c1_A,dive_id==i),aes(int_dive_time,-(int_dive_depth),group=dive_id),size=1)+
    theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
          panel.background = element_blank(), axis.line = element_line(colour = "black"),axis.title=element_blank(),axis.text = element_blank(),axis.ticks = element_blank(),axis.line.x = element_blank(),axis.line.y = element_blank())
  jpeg(paste0("yourfilepathhere/train/TypeA/",paste0(i,".jpg")))
  print(plot)
  dev.off()
}
## Type D
for(i in c(unique(c1_D$dive_id))){
  plot<-ggplot()+
    geom_line(data=subset(c1_D,dive_id==i),aes(int_dive_time,-(int_dive_depth),group=dive_id),size=1)+
    theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
          panel.background = element_blank(), axis.line = element_line(colour = "black"),axis.title=element_blank(),axis.text = element_blank(),axis.ticks = element_blank(),axis.line.x = element_blank(),axis.line.y = element_blank())
  jpeg(paste0("yourfilepathhere/train/TypeD/",paste0(i,".jpg")))
  print(plot)
  dev.off()
}

# CLUSTER 2 ______________________________________________________

# random sample of 50 dives, save their ids to a vector
sample2<-sample(unique(c2$dive_id),size=50,replace=FALSE)
sample2

# create plots to score with dive profile type
# save type (shape) to vector same length as sample

plots2<-list()
for (i in c(1:length(sample2))){
  plots2[[i]]<-ggplot()+
    geom_line(data=subset(c2,dive_id==sample2[i]),aes(int_dive_time,-(int_dive_depth),group=dive_id),size=1)+
    theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
          panel.background = element_blank(), axis.line = element_line(colour = "black"),axis.title=element_blank(),axis.text = element_blank())+
    ggtitle(paste("Dive ID",sample2[i]))
}
plots2

# here, save the shape label to a vector same length as the id vector (sample1)
## Note: this is an example and because you are drawing random samples, if you run the code yourself, the order won't match this
type2<-c("C","E","C","E","C","C","F","A","D","C","F","A","A","F","E","C","F","D","F","E","C","C","C","E","F","A","D","D","D","C","D","C","A","C","E","C","D","E","E","E","E","C","A","F","A","F","A","A","C","E")

# create dataframe of id's with type
c2_type<-data.frame(x=sample2,y=type2)
colnames(c2_type)<-c("dive_id","dive_type")

# merge with original data
c2_type_data<-merge(c2,c2_type,by="dive_id")

# subset by type
c2_C<-subset(c2_type_data,dive_type=="C")
c2_F<-subset(c2_type_data,dive_type=="F")
c2_E<-subset(c2_type_data,dive_type=="E")
c2_A<-subset(c2_type_data,dive_type=="A")
c2_D<-subset(c2_type_data,dive_type=="D")

# print plots of dives to folder 
## Type C
for(i in c(unique(c2_C$dive_id))){
  plot<-ggplot()+
    geom_line(data=subset(c2_C,dive_id==i),aes(int_dive_time,-(int_dive_depth),group=dive_id),size=1)+
    theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
          panel.background = element_blank(), axis.line = element_line(colour = "black"),axis.title=element_blank(),axis.text = element_blank(),axis.ticks = element_blank(),axis.line.x = element_blank(),axis.line.y = element_blank())
  jpeg(paste0("yourfilepathhere/train/TypeC/",paste0(i,".jpg")))
  print(plot)
  dev.off()
}
## Type F
for(i in c(unique(c2_F$dive_id))){
  plot<-ggplot()+
    geom_line(data=subset(c2_F,dive_id==i),aes(int_dive_time,-(int_dive_depth),group=dive_id),size=1)+
    theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
          panel.background = element_blank(), axis.line = element_line(colour = "black"),axis.title=element_blank(),axis.text = element_blank(),axis.ticks = element_blank(),axis.line.x = element_blank(),axis.line.y = element_blank())
  jpeg(paste0("yourfilepathhere/train/TypeF/",paste0(i,".jpg")))
  print(plot)
  dev.off()
}
## Type E
for(i in c(unique(c2_E$dive_id))){
  plot<-ggplot()+
    geom_line(data=subset(c2_E,dive_id==i),aes(int_dive_time,-(int_dive_depth),group=dive_id),size=1)+
    theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
          panel.background = element_blank(), axis.line = element_line(colour = "black"),axis.title=element_blank(),axis.text = element_blank(),axis.ticks = element_blank(),axis.line.x = element_blank(),axis.line.y = element_blank())
  jpeg(paste0("yourfilepathhere/train/TypeE/",paste0(i,".jpg")))
  print(plot)
  dev.off()
}
## Type A
for(i in c(unique(c2_A$dive_id))){
  plot<-ggplot()+
    geom_line(data=subset(c2_A,dive_id==i),aes(int_dive_time,-(int_dive_depth),group=dive_id),size=1)+
    theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
          panel.background = element_blank(), axis.line = element_line(colour = "black"),axis.title=element_blank(),axis.text = element_blank(),axis.ticks = element_blank(),axis.line.x = element_blank(),axis.line.y = element_blank())
  jpeg(paste0("yourfilepathhere/train/TypeA/",paste0(i,".jpg")))
  print(plot)
  dev.off()
}
## Type D
for(i in c(unique(c2_D$dive_id))){
  plot<-ggplot()+
    geom_line(data=subset(c2_D,dive_id==i),aes(int_dive_time,-(int_dive_depth),group=dive_id),size=1)+
    theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
          panel.background = element_blank(), axis.line = element_line(colour = "black"),axis.title=element_blank(),axis.text = element_blank(),axis.ticks = element_blank(),axis.line.x = element_blank(),axis.line.y = element_blank())
  jpeg(paste0("yourfilepathhere/train/TypeD/",paste0(i,".jpg")))
  print(plot)
  dev.off()
}

#####################################################################################
# Step 1: Create Master Dataset

# the master dataset will contain unlabeled images of all dive profiles
## these will be provided to the trained CNN for it to label according to what shape it thinks each image matches best

for(i in c(unique(cluster_dive_data_k2$dive_id))){
  plot<-ggplot()+
    geom_line(data=subset(cluster_dive_data_k2,dive_id==i),aes(int_dive_time,-(int_dive_depth),group=dive_id),size=1)+
    theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
          panel.background = element_blank(), axis.line = element_line(colour = "black"),axis.title=element_blank(),axis.text = element_blank(),axis.ticks = element_blank(),axis.line.x = element_blank(),axis.line.y = element_blank())
  jpeg(paste0("yourfilepathhere/master/",paste0(i,".jpg")))
  print(plot)
  dev.off()
}

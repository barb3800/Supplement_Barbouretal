# EXAMPLE CODE: Barbour et al, "Using machine learning approaches to classify vertical movement profiles and behavior"
## Contact code author with any questions: Nicole Barbour, nbarbour@umd.edu

# DTW ANALYSIS
## This uses the "dtwclust" package to dynamically cluster time series
## Here, the time series are dive profiles for leatherback sea turtles, composed of surface and intermediate depth values for each dive
## time series can be of unequal lengths, but points need to be equidistant apart (time series should have regular values)

# make sure these packages are installed (only need to do this once):
## imputeTS, dplyr, data.table, dtwclust, ggplot2, parallel

# load libraries
library(parallel);library(dtwclust);library(dplyr);library(ggplot2)

# set your working directory (good practice)
setwd("./Example_Files")

###################################################################################
# Step 1: Interpolate Time Series (Regular Values)

# load in data
load("./Data/dive_dataframes.rda")
## list of dives
## each dive dataframe has:
## dive id ("dive_id")
## dive depths ("int_dive_depth", 3 intermediate dive depths, and surface points)
## dive duration ("int_dive_time", seconds passed for each dive depth)

# Create cluster to run the data munging in parallel (efficient)
cl <- makeCluster(detectCores(logical = F) - 1)
clusterEvalQ(cl, {library(imputeTS); library(data.table)})

# Create a list of dive series with interpolated dive depths at 20 sec intervals
## we are basically fitting a straight line between dive depth points and then extracting depths at 20 sec intervals along that line
dive_interpolate <- parLapply(cl, 
                          dive_dataframes,
                          function(.){
                            times <- data.table(
                              # Create sequence of time stamps from 0 to the maximum int dive time (dive duration) + 20 sec
                              int_dive_time = seq(0, max(.$int_dive_time)),
                              # Label the time stamps with the dive's ID
                              dive_id = .$dive_id[1]
                            )
                            # bind back to data
                            # need to use merge or join so that original data is kept
                            hold<-merge(.,times,by=c("int_dive_time","dive_id"),all.x=TRUE,all.y=TRUE) # want to keep all dates
                            # Interpolate missing dive depths for all available times
                            hold[, int_dive_depth := na_interpolation(int_dive_depth)]
                            interval <- data.table(
                              # create vector of intervals every 20 sec to end of dive duration + 20 sec 
                              int_dive_time = seq(0, max(.$int_dive_time)+20,by=20), 
                              # Label the time stamps with the dive's ID
                              dive_id = .$dive_id[1] 
                            )
                            hold2<-merge(hold,interval,by=c("int_dive_time","dive_id"),all.y=TRUE) # only want to keep matching intervals 
                            # change Na value for int dive depth to 0
                            hold2[which(is.na(int_dive_depth))]$int_dive_depth <- 0
                            # Return just the dive depths to be used for clustering
                            #   Note that the time steps are implied by the length of
                            #     the vector
                            as.numeric(-hold2$int_dive_depth)
                          }
)

# Close the parallel cluster
stopCluster(cl)

## end up with list of 28,217 dives
## time steps are implied by the vector (length of the list is = to dive duration in sec)
## each depth point is 20 sec apart
## depth at each time step/position is interpolated and in m (-)

############################################################################
# Step 2: Evaluate Optimal Cluster Number

## Evaluate "optimal" cluster number using CVI's (cluster validity indices)
## internal CVI's: consider partioned data and try to define measure of cluster purity
## external CVI's: compare obtained partition to correct one (need a ground truth for this- we won't use these)
## note: which CVI to use is also subjective/needs testing... can go with "majority vote" from indices but you should check that the final result makes biological sense!
## note: can also use "clue" package to evaluate clusters

# look at cluster no. of 2 to 6 max
# NOTE: this can take a long time to run! suggest running on a computer with lots of RAM/memory...
dive_clust_k <- tsclust(series=dive_interpolate, k = 2:7, centroid="pam", distance = "dtw_basic")

names(dive_clust_k) <- paste0("k_", 2:7)

k_table<-sapply(dive_clust_k, cvi, type = "internal")

# print table
k_table
# Note:
## some indices should maximized ("Sil","SF","CH","D") and some should be minimized ("DB","DBstar","COP")

# majority vote shows that k=4 or k=2 are both preferable
## we choose a k=2, based on the law of parsimony and additional exploration of spatio-temporal trends in these clusters (see Supplement of Barbour et al)

############################################################################
# Step 3: Performing DTW Clustering

# Choices of parameters for dtw clustering:

# window size: limits distance that points can be matched to each other
## I don't want a limit ( I want all observations for a dive to be considered)

# k = no. of clusters
## can use selection criteria with dtwclust package to determine optimal no. for k
## we chose k=2 above

# centroid = time series prototype (time-series averaging method = summarizes imp. characteristics for all series in a given cluster, which here= dive type)
## PAM centroid is likely the best candidate- time series with minimum sum of distances to others in cluster (also allows series of diff lengths)
## for PAM: cluster centroids are generally one of the time series from the data
## from the manual (Sarda-Espinosa 2019): 
## " partitional clustering creates k number of clusters from data
## k centroids are randomly initialized (choose k objects from dataset at random = k dives)
## each is then assigned to individual clusters
## distance between all data objects (dives) and all centroids (random k dives) is calculated
## each object/dive is assigned to the cluster of its closest centroid (random k dive time series)
## protyping function iS then applied to each cluster to update the corresponding centroid (e.g. median)
## distances and centroids are updated iteratively (until no more objects can change clusters)"
## note: clustering is generally unsupervised but clusters can be evaluated...

# we also use the "dtw_basic" distance measure
## core calculations for distances of dtwclust are performed in C++ (fast)
## basic uses DTW distance measure and has less functionality than other options (?) but is faster


# run analysis with k=2
dive_clust_k2 <- tsclust(series = dive_interpolate, k = 2, distance = 'dtw_basic',centroid="pam")

############################################################################
# Step 4: Merge Cluster Data With OG Data

# format cluster data
## 28,217 was the # of original dives
cluster_data1<-as.data.frame(list(dive=list(cumsum(rep(1,28217))),cluster=list(dive_clust_k2@cluster)))
colnames(cluster_data1)<-c("dive_id","cluster")

# merge OG data df's together
dives<-do.call("rbind",dive_dataframes)

# merge dive and cluster data, using dive_id as matching/key column
cluster_dive_data_k2<-merge(dives,cluster_data1,by="dive_id")

###########################################################################
# Step 5: Plot Centroids

# there are a couple ways to plot results
## 1- with the output of the dtwclust function
plot(dive_clust_k2)

## 2- extract the centroid from each dtwclust object and plot with ggplot
# can find centroids (by their list number) in the output of the dtwclust function
attr(dive_clust_k2@centroids,"series_id")
## dives 7905 and 13585 are the centroids for each cluster

ggplot()+
  geom_line(data=dive_dataframes[[7905]],aes(int_dive_time/60,-(int_dive_depth)),size=2)+
  geom_line(data=dive_dataframes[[13585]],aes(int_dive_time/60,-(int_dive_depth)),size=2,color="#D55E00")+ # red
  theme_classic()+
  xlab("Time (min)")+ylab("Depth (m)")

###########################################################################
# Save Data!

# it's good practice to always save input, intermediate, and output data products
## saves lots of time also when dealing with code that takes a long time to run (you don't have to run it every time you want to look at the output)

# save to an .rda format
## can also export as csv, etc...
save(cluster_dive_data_k2,file="./Data/dtw_output_data.rda")




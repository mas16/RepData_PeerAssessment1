## Reproducible Research Week 2 Course Project 1
## by mas16
## Nov 2018

library(lubridate)
library (ggplot2)

## Set variable names for accessing data:
## URL of where the zipped data can be obtained
url <- "https://d396qusza40orc.cloudfront.net/repdata%2Fdata%2Factivity.zip"
## Name of the zipped data 
zipfilename <- "repdata%2Fdata%2Factivity.zip"
## Name of the unzipped data file
unzipfilename <- "activity.csv"

## Case where unzipped data are not in working directory
if (!file.exists(unzipfilename)) {
        
        ## Case where zipped data are not in working directory
        ## Download and unzip
        ## I'm using a Mac, use method = 'curl'
        if (!file.exists(zipfilename)) {
                download.file(url, zipfilename, method='curl')
                unzip(zipfilename)
                
                ## Case where zipped data are in working directory
                ## Unzip
        } else if (file.exists(zipfilename)) {
                unzip(zipfilename)
        } 
}

## Loading and Preprocessing the Data
## 1. Load the Data

## Load the data into variable, activity_data
activity_data <- read.csv("activity.csv")

## Get som information about the data
str(activity_data)

summary(activity_data)

head(activity_data)

## 2. Transformaing the Data

## Convert to date
activity_data$date <- ymd(activity_data$date)

## What is Mean Total Number of Steps Taken per Day?
## 1. Calculate the Total Number of Steps Taken per Day

## Sum number of steps by day
total_steps <- aggregate(steps ~ date, data=activity_data, FUN=sum, na.action=na.omit)

## Look at the first few sums
head(total_steps)

## 2. Make a Histogram of the Total Number of Steps Taken Each Day

## Calculate number of bins using Sturge's Formula
log2(length(total_steps$steps)) + 1

## Generate a histogram of total steps taken per day
g <- ggplot(total_steps, aes(steps))
g + geom_histogram(bins=7, color="black", fill="blue") +
        xlab("Steps") + ylab("Count") + 
        ggtitle("Distribution of Total Number of Steps Taken per Day") +
        theme(plot.title = element_text(face="bold", hjust=0.5, size=12)) +
        theme(axis.text = element_text(size=10)) +
        theme(axis.title = element_text(face="bold", size=12))

## 3. Calculate and Report the Mean and Median of the Total Number of Steps Taken 
## per Day

## Calculate the mean
mean_total_steps <- mean(total_steps$steps)
mean_total_steps

## Calculate the median
median_total_steps <- median(total_steps$steps)
median_total_steps

## What is the Average Daily Activity Pattern?

## 1. Make a Time Series Plot

## Calculate the mean number of steps taken during a given interval where the 
## mean is calculate across all days.
mean_stepint <- aggregate(steps ~ interval, data=activity_data, FUN=mean, na.action = na.omit)

## Look at the first few means
head(mean_stepint)

## Plot the time series data
g <- ggplot(mean_stepint, aes(interval,steps), type="l")
g + geom_line() + xlab("Interval") + ylab("Steps") +
        ggtitle("Average Number of Steps Taken per Time Interval") +
        theme(plot.title = element_text(face="bold", hjust=0.5, size=12)) +
        theme(axis.text = element_text(size=10)) +
        theme(axis.title = element_text(face="bold", size=12))

## 2. Which 5-minute Interval, on Average Across All the Days in the Dataset, 
## Contains the Maximum Number of Steps? 

## Get the index of the maximum average number of steps
max_steps <- max(mean_stepint$steps)
max_steps

## Use the which function to determine which interval corresponds to the 
## maximum number of steps
max_stepint <- mean_stepint$interval[which(mean_stepint$steps==max_steps)]
max_stepint

## Imputing Missing Values
## 1. Calculate and Report the Total Number of Missing Values in the Dataset

## Determine number of NAs
sum(is.na(activity_data$steps))

## 2. Devise a Strategy for Filling in All of the Missing Values in the Dataset

## Get Rows with NAs in steps
na_index <- is.na(activity_data$steps)

## Determine number of times the intervals are repeated
repeats = length(activity_data$steps)/length(mean_stepint$interval)

## Vector of time intervals repeated 61 times
test <- rep(mean_stepint$interval, repeats)

## Check for missing intervals
identical(activity_data$interval, test)

## Generate a vector of mean steps per interval repeated 61 times
rep_meanstepint <- rep(mean_stepint$steps, repeats)

## Make a new data frame with an extra column containing the mean step per 
## interval
activity_msi <- cbind(activity_data, rep_meanstepint)

## Imput the NA values using index vector
activity_msi$steps[na_index] <- activity_msi$rep_meanstepint[na_index]

## 3. Create a new dataset that is equal to the original dataset but with the 
## missing data filled in.

## Make new data set
activity_datanew <- activity_msi[,-4]

## Look at the first few rows of the new dataaset
head(activity_datanew)

## Calculate total number of steps taken per day using the imputed data
total_stepsnew <- aggregate(steps ~ date, data=activity_datanew, FUN=sum, na.action=na.pass)

## Generate a histogram of total steps taken per day
g <- ggplot(total_stepsnew, aes(steps))
g + geom_histogram(bins=7, color="black", fill="blue") +
        xlab("Steps") + ylab("Count") + 
        ggtitle("Total Number of Steps Taken per Day NA Imputed") +
        theme(plot.title = element_text(face="bold", hjust=0.5, size=12)) +
        theme(axis.text = element_text(size=10)) +
        theme(axis.title = element_text(face="bold", size=12))

## Calculate the mean
mean_total_stepsnew <- mean(total_stepsnew$steps)
mean_total_stepsnew

## Calculate the median
median_total_stepsnew <- median(total_stepsnew$steps)
median_total_stepsnew

## Import xtable package
library(xtable)

## Make a new dataframe
means <- c(mean_total_steps, mean_total_stepsnew)
medians <- c(median_total_steps, median_total_stepsnew)
table_df <- cbind(means,medians)
rownames(table_df) <- c("Original Data", "Data with NA Imputed")
colnames(table_df) <- c("Mean", "Median")
table_df <- as.data.frame(table_df)

## Make a table
xt <- xtable(table_df)
#print(xt, type="html")

## Are There Differences in Activity Patterns between Weekdays and Weekends?
## 1. Create a New Factor Variable in the Dataset 
## with Two Levels – “Weekday” and “Weekend”

## Make a new data frame to avoid corrupting the original 
activity_dataday <- activity_datanew

## Convert the dates to days of the week
activity_dataday$date <- weekdays(activity_dataday$date)

## Take a look at the first few rows
head(activity_dataday)

## Index the weekdays
days <- !(activity_dataday$date == "Saturday" | activity_dataday$date == "Sunday")

## Index the weekends
ends <- (activity_dataday$date == "Saturday" | activity_dataday$date == "Sunday")
activity_dataday$day_class[days] <- "Weekday"
activity_dataday$day_class[ends] <- "Weekend"

## Convert to factor
activity_dataday$day_class <- as.factor(activity_dataday$day_class)

## 2. Make a Panel Plot Containing a Time Series Plot of the 5-Minute Interval 
## and the Average Number of Steps Taken, Averaged Across All Weekday Days or 
## Weekend Days

## Calculate mean number of steps taken averaged across all weekday days or weekend days
mean_stepintday <- aggregate(steps ~ interval + day_class, data=activity_dataday, FUN=mean, na.action = na.pass)

## Take a look at the first few rows
head(mean_stepintday)

## Plot
g <- ggplot(mean_stepintday, aes(interval, steps), type="l")
g + facet_grid(day_class ~ .) + geom_line() +
        xlab("5-Minute Interval") +
        ylab("Number of Steps") +
        ggtitle("Number of Steps per 5-minute Interval: Weekday vs. Weekend") +
        theme(plot.title = element_text(face="bold", hjust=0.5, size=12)) +
        theme(axis.text = element_text(size=10))+
        theme(axis.title = element_text(face="bold", size=12))+
        theme(strip.text.y = element_text(size = 12))



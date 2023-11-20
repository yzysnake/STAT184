# Dependency
library(ggplot2)
library(GGally)
library(car)
library(lmtest)



# Data
mydata1 = read.table("http://faculty.chicagobooth.edu/nicholas.polson/teaching/41000/bordeaux.txt",header=T)
mydata2 = read.table("http://faculty.chicagobooth.edu/nicholas.polson/teaching/41000/bordeauxp.txt",header=T)



#--------------------------------
#  EDA
#--------------------------------

# Boxplot
par(mfrow = c(3, 3))
for (variable in names(mydata1)) {
  boxplot(mydata1[[variable]], main = paste("Boxplots of", variable), xlab = variable, col ="red")
}
par(mfrow = c(1, 1))
hist(mydata1$price)

# Histogram
par(mfrow = c(3, 3))
for (variable in names(mydata1)) {
  hist(mydata1[[variable]], main = paste("Histogram of", variable), xlab = variable, col ="red")
}

# Correlation Matrix
ggpairs(mydata1, title = "Correlation Matrix")


#--------------------------------
#  Model Selection
#--------------------------------

# Remove the outlier
mydata1 <- subset(mydata1, price != 100)

# Simple multiple regression with all variables concerned and log-transformation
initial_model = lm(log(price)~log(summer)+log(har)+log(win)+log(sep)+log(age),data=mydata1)
summary(initial_model)

# Using Stepwise methods ta choose the best model
stepwise_model <- step(initial_model, direction="both")
summary(stepwise_model)

# Normality Test by QQ and Shapiro-Wilk
par(mfrow = c(1, 1))
residuals_model <- residuals(stepwise_model)
qqnorm(residuals_model)
qqline(residuals_model, col="red")
shapiro.test(residuals_model)

# Serial Correlation by DW
par(mfrow = c(1, 1))
durbinWatsonTest(stepwise_model)

# Heteroskedasticity by fitted vs residuals
par(mfrow = c(1, 1))
plot(fitted(stepwise_model), residuals_model)
abline(h=0, col="red")
bptest(stepwise_model)

# Model
model <- lm(formula = log(price) ~ log(summer) + log(har) + log(win) + log(age), data = mydata1)


#--------------------------------
#  Model Prediction
#--------------------------------

# Predict the year from 1981 to 1991
pred = predict(model,mydata2,interval="prediction")
pred <- exp(pred)
pred

# out-of-sample prediction line
plot(mydata2[,1],pred[,1],type="l",xlab="year",ylab="price",ylim=c(0,100),
     col=2, lty=2, lwd=2,main="out-of-sample prediction line")
lines(mydata2[,1],pred[,2],col=3, lty=3, lwd=3)
lines(mydata2[,1],pred[,3],col=4, lty=4, lwd=4)
legend("topleft", c("fit","lwr","upr"),col=2:4, lty=2:4, lwd=2:4, bty="n")


highlighted_years <- c(1986) # Hightlight the year 1986
highlighted_points <- which(mydata2[,1] %in% highlighted_years)
points(mydata2[highlighted_points,1], pred[highlighted_points,1], pch=16, col="gold", cex=1.5)

# predict new observation, for year 2017, 2018, 2019
current_year <- as.numeric(format(Sys.Date(), "%Y")) # Get Current Year

newdata_2017 = data.frame(win = 521.07, summer = 19, sep = 19, har = 86.2, age = current_year - 2017)

newdata_2018 = data.frame(win = 691, summer = 20, sep = 22, har = 84.9, age = current_year - 2018)

newdata_2019 = data.frame(win = 550, summer = 21, sep = 19, har = 110, age = current_year - 2019)

prediction_2017 <- exp(predict(model,newdata_2017))
prediction_2017

prediction_2018 <- exp(predict(model,newdata_2018))
prediction_2018

prediction_2019 <- exp(predict(model,newdata_2019))
prediction_2019






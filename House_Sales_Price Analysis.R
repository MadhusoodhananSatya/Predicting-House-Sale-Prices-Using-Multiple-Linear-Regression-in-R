library(car)
library(corrplot)
library(caret)
library(carData)
library(ggplot2)
library(lattice)



house <- read.csv(file = 'ameshousing3.csv')
head(as.data.frame(house))



str(house)



house_reduced <- house[ ,c('Lot_Area', 'Year_Built', 'Gr_Liv_Area',
                           'Garage_Area','Yr_Sold','SalePrice',
                           'Basement_Area','Deck_Porch_Area','Age_Sold')]




cor(house_reduced)



corrplot(cor(house_reduced))



model_1 <-lm(SalePrice ~ Gr_Liv_Area, house_reduced)
summary.lm(model_1)




plot(SalePrice ~ Gr_Liv_Area, house_reduced,
     col = "blue",
     main = "Regression: House Sale Price & Total Ground Area",
     xlab = "Totoal Ground Area",
     ylab = "House Sale Price")




abline(model_1, col="red")



plot(model_1, 1)


plot(model_1, 2)


plot(model_1, 3)



corrplot(cor(house_reduced))




model_2 <-lm(SalePrice ~ Gr_Liv_Area + Garage_Area, house_reduced)
summary.lm(model_2)



model_3 <-lm(SalePrice ~ Gr_Liv_Area + Garage_Area + Basement_Area , house_reduced)
summary.lm(model_3)



model_4 <-lm(SalePrice ~ Gr_Liv_Area + Garage_Area + Basement_Area + Age_Sold , house_reduced)
summary.lm(model_4)




model_5 <-lm(SalePrice ~ Gr_Liv_Area + Basement_Area + Age_Sold , house_reduced)
summary.lm(model_5)



data.frame(colnames(house_reduced))



SalePrice ~ Gr_Liv_Area + Garage_Area + Basement_Area + Age_Sold



pairs(house_reduced[,c(6,3,4,7,9)], lower.panel = NULL, pch = 19,cex = 0.2)



plot(model_4, 1)


plot(model_4, 2)


plot(model_4, 3)



vif(model_4)



# Compare nested models
anova(model_1, model_2)

# Compare all models using AIC and BIC
AIC(model_1, model_2, model_3, model_4, model_5)
BIC(model_1, model_2, model_3, model_4, model_5)




# Load the caret library if it's not already
library(caret)

# Set up 10-fold cross-validation
train_control <- trainControl(method = "cv", number = 10)

# Train model_4 using cross-validation
model_4_cv <- train(SalePrice ~ Gr_Liv_Area + Garage_Area + Basement_Area + Age_Sold,
                    data = house_reduced,
                    method = "lm",
                    trControl = train_control)

# Print the results
print(model_4_cv)





# Create a new feature for total square footage
house_reduced$Total_Sq_Ft <- house_reduced$Gr_Liv_Area + house_reduced$Basement_Area + house_reduced$Garage_Area

# Build a new model with the engineered feature
model_6 <- lm(SalePrice ~ Total_Sq_Ft + Age_Sold, house_reduced)
summary.lm(model_6)




# Reload the full dataset if you've been using 'house_reduced'
house_full <- read.csv('ameshousing3.csv')

# Add 'Overall_Qual' to your model
# R automatically creates dummy variables for a factor variable
model_qual <- lm(SalePrice ~ Gr_Liv_Area + Overall_Qual, data = house_full)
summary.lm(model_qual)




# Install and load the 'lmtest' package
# install.packages("lmtest")
library(lmtest)

# Run the Breusch-Pagan test on model_4
bptest(model_4)




# Get Cook's distances for model_4
cooks_d <- cooks.distance(model_4)

# Identify observations with a high Cook's distance (e.g., > 4/n)
# where n is the number of observations
influential_points <- which(cooks_d > (4/length(cooks_d)))

# Print the row numbers of these influential points
print(influential_points)







# Install and load the 'glmnet' package
# install.packages("glmnet")
library(glmnet)

# Prepare the data for glmnet
# It requires the dependent variable and a matrix of predictors
x_vars <- as.matrix(house_reduced[, c('Gr_Liv_Area', 'Garage_Area', 'Basement_Area', 'Age_Sold')])
y_var <- house_reduced$SalePrice

# Perform Ridge regression
# The alpha=0 argument specifies Ridge regression
ridge_model <- glmnet(x_vars, y_var, alpha = 0)

# Plot the coefficients as the penalty term (lambda) changes
plot(ridge_model, xvar = "lambda", label = TRUE)

# Use cross-validation to find the optimal lambda
cv_ridge <- cv.glmnet(x_vars, y_var, alpha = 0)

# Print the best lambda value and its corresponding coefficients
print(cv_ridge$lambda.min)
coef(cv_ridge, s = "lambda.min")

# Examine the data for these specific rows
house_reduced[influential_points, ]
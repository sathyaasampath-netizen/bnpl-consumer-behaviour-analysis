library(dplyr)
library(tidyverse)
library(readxl)
library(lmtest)
library(ggpubr)
library(janitor)
# LOAD DATA
purchasing_data <- read.csv('Purchasing_data.csv')

#Inspect the data   # identify the dependent and independent variables
glimpse(purchasing_data)

colnames(purchasing_data)

summary(purchasing_data)

#We need to drop first row as it contains Questions

df_purchasing_data <- purchasing_data[-1, ]
df_purchasing_data_copy <- df_purchasing_data  #Backup
head(df_purchasing_data)

#Making Column names snake case

df_purchasing_data <- janitor::clean_names(df_purchasing_data)
df_purchasing_data <- readr::type_convert(df_purchasing_data)
colnames(df_purchasing_data)

#Data Dimensions-number of rows and columns

cat("Dimensions:", nrow(df_purchasing_data), "rows x", ncol(df_purchasing_data), "cols")

#Structure first 20 columns

str(df_purchasing_data[1:min(20, ncol(df_purchasing_data))])

#Finding Missing Values

na_summary <- sapply(df_purchasing_data, function(x) sum(is.na(x)))
cat("Top missingness:")
print(sort(na_summary, decreasing = TRUE)[1:min(20, length(na_summary))])

#Handling NA

df_purchasing_data <- na.omit(df_purchasing_data)

cat("Dimensions after dropping rows with any NA:",
    nrow(df_purchasing_data), "rows x", ncol(df_purchasing_data), "cols")

#3080 rows were removed because they had at least one missing value

#Variable selection (DV & 3 IVs)

#Re-code DV and IVs

#DV: q11_1 (likelihood to use BNPL) 
#It is a behavioral outcome 
#It relates to consumer finance decision-making
#It is ordinal categorical, easily converted to 1–5 numeric
#customer behavior analytics
df_purchasing_data <- df_purchasing_data %>%
  mutate(q11_1_factor = factor(q11_1, ordered = TRUE,levels = c(
        "Not at all likely",
        "Slightly likely",
        "Somewhat likely",
        "Very likely",
        "Extremely likely"
      ) ),
   
    q11_1_num = as.numeric(q11_1_factor)  # 1 = Not at all, 5 = Extremely
  )

#IV 1: q02 – number of credit cards 
#Categories like One, Two, Three can be converted to numeric
#Perfect for regressions -simple and multiple
df_purchasing_data <- df_purchasing_data %>%
  mutate(q02_num = case_when(
      str_detect(q02, regex("None|Zero", ignore_case = TRUE)) ~ 0,
      str_detect(q02, regex("\\bOne\\b", ignore_case = TRUE)) ~ 1,
      str_detect(q02, regex("\\bTwo\\b", ignore_case = TRUE)) ~ 2,
      str_detect(q02, regex("\\bThree\\b", ignore_case = TRUE)) ~ 3,
      str_detect(q02, regex("\\bFour\\b", ignore_case = TRUE)) ~ 4,
      str_detect(q02, regex("\\bFive\\b", ignore_case = TRUE)) ~ 5,
      str_detect(q02, regex("More than", ignore_case = TRUE)) ~ 6,
      TRUE ~ NA_real_
    ))
 
#IV 2: q03 – outstanding non-mortgage debt / loans
#Ordinal categories can be converted to numeric (1–8)
#Strong conceptual link to financial behavior
#Good predictor for regression

df_purchasing_data <- df_purchasing_data %>%
  mutate(q03_num = case_when(
      str_detect(q03, "(?i)Less than \\$500") ~ 1,
      str_detect(q03, "(?i)\\$500 to \\$1,000") ~ 2,
      str_detect(q03, "(?i)\\$1,001 to \\$2,000") ~ 3,
      str_detect(q03, "(?i)\\$2,001 to \\$3,000") ~ 4,
      str_detect(q03, "(?i)\\$3,001 to \\$5,000") ~ 5,
      str_detect(q03, "(?i)\\$5,001 to \\$7,000") ~ 6,
      str_detect(q03, "(?i)\\$7,001 to \\$10,000") ~ 7,
      str_detect(q03, "(?i)More than \\$10,000") ~ 8,
      TRUE ~ NA_real_
    ))
 
#IV 3: d16 – savings level
#Ordered categories
#Can convert to numeric scale: 0–6
# It Provides another financial predictor wealth to less BNPL usage

df_purchasing_data <- df_purchasing_data %>%
  mutate(d16_num = case_when(
      str_detect(d16, "(?i)I have no savings") ~ 0,
      str_detect(d16, "(?i)Less than \\$1,000") ~ 1,
      str_detect(d16, "(?i)\\$1,000 and \\$2,500") ~ 2,
      str_detect(d16, "(?i)\\$2,500 and \\$5,000") ~ 3,
      str_detect(d16, "(?i)\\$5,000 and \\$10,000") ~ 4,
      str_detect(d16, "(?i)\\$10,000 and \\$25,000") ~ 5,
      str_detect(d16, "(?i)More than \\$25,000") ~ 6,
      TRUE ~ NA_real_
    ))
  
#Keep only rows with complete data for DV and chosen IVs
df_model <- df_purchasing_data %>%
  select(q11_1_num, q02_num, q03_num, d16_num) %>%
  drop_na()
#How many rows and columns (DV+3IVs)
cat("Modeling data dimensions:", nrow(df_model), "rows x", ncol(df_model), "cols")
summary(df_model)

#Exploratory Visualization

# Correlation matrix
cor_mat <- cor(df_model, use = "pairwise.complete.obs")
print(round(cor_mat, 3))

# Scatterplots: DV vs each numeric IV
ggplot(df_model, aes(x = q02_num, y = q11_1_num)) +
geom_jitter(alpha = 0.4) +
geom_smooth(method = "lm", se = FALSE, color = "yellow") +
geom_smooth(method = "loess", se = FALSE, linetype = 2) +
labs(title = "BNPL likelihood vs Number of Credit Cards",x = "Number of credit cards (q02_num)",
        y = "BNPL likelihood (q11_1_num)" ) + theme_minimal()
 
ggplot(df_model, aes(x = q03_num, y = q11_1_num)) +
geom_jitter(alpha = 0.4) +
geom_smooth(method = "lm", se = FALSE, color = "purple") +
geom_smooth(method = "loess", se = FALSE, linetype = 2) +
labs(title = "BNPL likelihood vs Non-mortgage Debt Level",x = "Debt level category (q03_num)",
           y = "BNPL likelihood (q11_1_num)" ) + theme_minimal()
  
ggplot(df_model, aes(x = d16_num, y = q11_1_num)) +
geom_jitter(alpha = 0.4) +
geom_smooth(method = "lm", se = FALSE, color = "green") +
geom_smooth(method = "loess", se = FALSE, linetype = 2) +
labs(title = "BNPL likelihood vs Savings Level",x = "Savings level (d16_num)",
            y = "BNPL likelihood (q11_1_num)" ) + theme_minimal()
 
#Model Building 

# Model 1: Simple linear regression (q11_1_num ~ q02_num)
model1 <- lm(q11_1_num ~ q02_num, data = df_model)
summary(model1)
# Model 2: Multiple regression (q11_1_num ~ q02_num + q03_num + d16_num)
model2 <- lm(q11_1_num ~ q02_num + q03_num + d16_num, data = df_model)
summary(model2)

# Extract R-squared and Adjusted R-squared
r2_m2     <- summary(model2)$r.squared
adj_r2_m2 <- summary(model2)$adj.r.squared

cat("Model 2 R-squared: ", round(r2_m2, 3))
cat("Model 2 Adjusted R-squared: ", round(adj_r2_m2, 3))
#R² = 0.089 - This model explains 8.9% of the variation in BNPL likelihood
#Adjusted R² = 0.084 -  After adjusting for 3 predictors, the explained variance is 8.4%
#Model2 predicts BNPL likelihood better than Model1's R² = 0.012

#Model Performance – RMSE & MAE 

#calculating RMSE and MAE Root Mean Squared Error & Mean Absolute Error
rmse <- function(a, p) sqrt(mean((a - p)^2))
mae  <- function(a, p) mean(abs(a - p))
y <- df_model$q11_1_num
# Predictions
pred_m1 <- predict(model1)
rmse_m1 <- rmse(y, pred_m1)
mae_m1  <- mae(y, pred_m1)
# Model 2
pred_m2 <- predict(model2)
rmse_m2 <- rmse(y, pred_m2)
mae_m2  <- mae(y, pred_m2)
# Calculate metrics
cat("Model 1 – RMSE:", round(rmse_m1, 3), " MAE:", round(mae_m1, 3))
cat("Model 2 – RMSE:", round(rmse_m2, 3), " MAE:", round(mae_m2, 3))
#Model 2 has a lower RMSE, meaning it predicts BNPL likelihood more accurately than Model 1.
#MAE also improves in Model 2, showing it makes smaller average prediction errors, Model 2 
#performs better than Model 1 on both RMSE and MAE


#Diagnostic Testing 
# Add residuals & fitted for model2
df_model$model2_fitted <- fitted(model2)
df_model$model2_resid  <- resid(model2)

# 1.Linearity - Residual 
plot(model2$fitted.values, model2$residuals,
     xlab="Fitted Values", ylab="Residuals",col="green",
     main="Residuals vs Fitted (Linearity Check)")
abline(h = 0, col = "purple", lwd = 2)


#QQ plot indicates that the Model 2 residues are approximately 
#normally distributed around the mid line but do not follow the normal distribution at the ends. 
#This shows slight non normality and mild skewness. 
#Such small departures are normal with ordinal survey data and do not pose 
#serious mistakes to the validity of the model.

# 2.Normality of Residuals
ggqqplot(df_model$model2_resid,title = "QQ Plot of Residuals – Model 2",col="orange")
#The histogram indicates that the residuals do not follow a normal distribution and 
#they have a skew to the right. Ordinal survey data are likely to exhibit this modest non-normality and makes no significant impact on the model.

# 3. Histogram of Residuals
hist(df_model$model2_resid, breaks=30,main="Histogram of Residuals (Model 2)",xlab="Residuals", col="purple")

# 4.Multicollinearity
library(car)
vif(model2)
#All VIF values are very low (around 1.03–1.06), indicating no multicollinearity among the predictors. 
#This means the independent variables do not overlap in what they measure

#5.Homoscedasticity Check
plot(model2, which = 3,col="green")

#The red line moves upwards and the scatter widens slightly as fitted values grow towards Fitting values Fitted values 
#grow and the residual variance is likely to grow with the fitted values (heteroscedasticity).

#6.Breusch–Pagan Test (Homoscedasticity Test)
library(lmtest)
bptest(model2)
library(sandwich)
library(lmtest)

coeftest(model2, vcovHC(model2, type = "HC3"))
#The Breusch-Pagan test is also significant (p < 0.001) and it means that the residual variance is not constant (heteroscedasticity).
#This implies that the model does not follow homoscedasticity assumption thus robust standard errors (HC3) must be applied in making reliable inferences.

# 7.Cook's distance
cooksd <- cooks.distance(model2)
plot(cooksd, type = "h", col="coral",main = "Cook's Distance – Model 2",ylab = "Cook's distance")
which(cooksd > (4 / nrow(df_model))) 

# potentially influential rows
#Most Cook’s Distance values are very small, so there are no influential points.
#A few points spike slightly, but none are close to the cutoff of 1.
#This means the model is stable and not affected by outliers.





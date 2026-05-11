# BNPL Consumer Behaviour Analysis Using Marketing Analytics

This project analyzes consumer behaviour related to Buy Now, Pay Later (BNPL) services using predictive analytics and regression modeling techniques. The study investigates how financial factors such as credit card ownership, debt levels, and savings influence consumers’ likelihood of adopting BNPL services.

## Academic Information
Course: DAMO-502-21 Marketing Analytics  
Program: Master of Data Analytics  
Institution: University of Niagara Falls, Canada  
Student: SathiyaBama Sampath  

## Project Objectives
- Analyze factors influencing BNPL adoption
- Compare Simple Linear Regression and Multiple Regression models
- Perform exploratory data analysis (EDA)
- Evaluate regression assumptions and model diagnostics
- Generate business insights for marketing strategy optimization

## Dataset
Dataset: `Purchasing_data.csv`

### Key Variables
- `q11_1_num` → Likelihood to Use BNPL (Dependent Variable)
- `q02_num` → Number of Credit Cards
- `q03_num` → Outstanding Non-Mortgage Debt
- `d16_num` → Savings Level

## Tools & Technologies
- Python
- Pandas
- NumPy
- Statsmodels
- Scikit-learn
- Matplotlib
- Seaborn
- Jupyter Notebook

## Exploratory Data Analysis
The project includes:
- Correlation matrix analysis
- Scatterplots with LOESS smoothing
- Residual analysis
- Distribution analysis
- Diagnostic visualizations

### Key Insights
- BNPL usage increases with higher debt levels
- Customers with higher savings are less likely to use BNPL
- Consumers with multiple credit cards show lower BNPL adoption

## Predictive Models

### Model 1 – Simple Linear Regression
Predictor:
- Number of Credit Cards

### Model 2 – Multiple Linear Regression
Predictors:
- Credit Card Count
- Debt Level
- Savings Level

## Model Evaluation Metrics
- RMSE
- MAE
- R² Score
- Breusch–Pagan Test
- Variance Inflation Factor (VIF)
- Cook’s Distance

## Results
- Multiple Regression (Model 2) outperformed the Simple Regression model
- Debt level was identified as the strongest predictor of BNPL adoption
- Robust HC3 standard errors were applied to address heteroscedasticity

## Business Implications
- High-debt customers are more likely to adopt BNPL services
- Marketing campaigns should target financially constrained consumers
- Blanket advertising strategies are less effective than behavioural segmentation

## Limitations
- Low R² values typical of behavioural datasets
- Presence of heteroscedasticity
- Dependent variable treated numerically despite ordinal nature
- Potential nonlinear patterns not fully captured

## Future Improvements
- Apply nonlinear models such as Decision Trees and Polynomial Regression
- Explore Ordinal Logistic Regression
- Include demographic and behavioural variables
- Test regularized regression models (LASSO/Ridge)

## Repository Structure

```text
bnpl-consumer-behaviour-analysis/
│
├── data/
├── notebooks/
├── visualizations/

# Home-Credit-Default-Risk-Applied-Stat-project
Home Credit Risk Default Competition (https://www.kaggle.com/c/home-credit-default-risk)

(Project done for the course Applied Statistics)

This project, based on the Kaggle competition https://www.kaggle.com/c/home-credit-default-risk, use the previously loan dataset
from Home Credit, a financial institute, to predict the capability of a subject to repay a loan.

This problem is a binary classification problem, where the outcome Y is equal to 1 if a subject has not repaid the debt, 0 otherwise.
The problem is very unbalanced, with the proportion of 1 is more or less 8%, and for this reason detecting the "defaulters" 
is a very challenging task.

# Pre-Processing

The dataset consist of 307511 subjects with 344 variables. After some feature selection and data trasformation, 
we come up with the first dataset (power_trans_data.csv) and then we add some features from other Kaggle resources (preparation_definitive_full_feature.R) and we end up with definitive_full_feature.csv

Another important problem was how to deal with Missing Values, a significance part of the dataset.
We use three different methods:
- Na omit -> too many observations deleted
- Fill with median -> the best option
- Multivariate imputation by chained equations (using package MICE) -> overfitting problem

# Models

## Overlapping problem

The methods involving distance such as SVM, KNN or clustering approaches have been neglected due to the overlapping of the two classes and the curse of dimensionality.

<table border="0">
<tr><td> <img src="https://github.com/danielececcarelli/Home-Credit-Default-Risk-Applied-Stat-project/blob/master/images/income%20vs%20credit.jpg" width="380"> </td><td> <img src="https://github.com/danielececcarelli/Home-Credit-Default-Risk-Applied-Stat-project/blob/master/images/ext_sources%203%20vs%202.jpg" width="380"> <td> </td></tr>
</table>

## Logistic Regression

The natural choice for this type of problem was of course a logistic regression.
We choose a simple model with in the end just 30 variables, in order to focus more on the simplicity and interpretability of the model, that achieves a quite good score of AUC=0.758 on Kaggle testset. These are our results:

## Logistic Regr. with LASSU penalization

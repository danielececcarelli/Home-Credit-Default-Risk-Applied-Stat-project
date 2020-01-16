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
We choose a simple model with in the end just 30 variables, in order to focus more on the simplicity and interpretability of the model, that achieves a quite good score of AUC=0.758 on Kaggle testset. 

We can sum up the main variables that influence the probability of default:
- Type of education
- Number of previous refused applications at Home Credit
- Previous installments for past loans at Home Credit
- Scores of the applicant coming from other financial institutions
- Interests on previous credits
- The ratio between the interests and the value of the good of previous credits
- The ratio between the interests and the credit of previous credits
<table border="0">
<tr><td><img src="https://github.com/danielececcarelli/Home-Credit-Default-Risk-Applied-Stat-project/blob/master/images/CROSS_VALIDATION_AUC.jpg" width="380"> </td><td>
<img src="https://github.com/danielececcarelli/Home-Credit-Default-Risk-Applied-Stat-project/blob/master/images/roc_curve_test_0.769.jpg" width="380"> <td> </td></tr>
</table>

## Logistic Regr. with LASSU penalization
After that, we try a logistic regression with a Lassu Penalization with as result a model with just 9 variables, and this model can achieve a good AUC of 0.740.
The selected variables are the 3 ext_scores (banking score for a subject made by some external financial institutes), a factor indicates if the subject has at least high school education, 3 variables on previous applications and 2 variables for Goods and Credit of a person.

## Some Factor Analysis
<table border="0">
<tr><td> <img src="https://github.com/danielececcarelli/Home-Credit-Default-Risk-Applied-Stat-project/blob/master/images/density_gender.jpg" width="380"> </td><td> Difference in density from Male and Female. Male seems to be worse payers <td> </td></tr>
</table>

<table border="0">
<tr><td> Higher education means less probability to be a bad payer </td><td><td> <img src="https://github.com/danielececcarelli/Home-Credit-Default-Risk-Applied-Stat-project/blob/master/images/density_educ.jpg" width="380"></td></tr>
</table>

<table border="0">
<tr><td> <img src="https://github.com/danielececcarelli/Home-Credit-Default-Risk-Applied-Stat-project/blob/master/images/density_region.jpg" width="480"> </td><td> And finally a difference between region (in terms of quality rating: High, Medium or Low) in which the subject lives <td> </td></tr>
</table>

# Threshold choice

The output of the logistic regression for each observation is just a probability between 0 and 1, now an interesting question is:
what threshold p shold we use to select subjects that, in according to our model (prob_subject > p), we predict as "defaulters" (and of course we don't give him loan)?

We follow three different way:

## Minimize cost function
how can we estimate the cost function? cost if we misclassified a customer:

1) If I predict that a customer will be a GOOD PAYER and he is not (so, his true Y is = 1)
    I give him a loan, and then the bank lost the credit 
     (or part of it, if I suppose that a customer will pay just some months)

2) If I predict that a customer will be a BAD PAYER and he is not (so, his true Y is = 0)
     I decide to not give him a loan, even if, a posteriori, he could repay it:
     the loss is in terms of interest that I can make through this loan
    
<img src="https://github.com/danielececcarelli/Home-Credit-Default-Risk-Applied-Stat-project/blob/master/images/misclassification_cost.jpg" width="580">    

We found a minimum in p=0.3

## Density plot
<img src="https://github.com/danielececcarelli/Home-Credit-Default-Risk-Applied-Stat-project/blob/master/images/density_estimated_p%3D0.08.jpg" width="580">    

We can see that after p=0.08 the density of BAD PAYER is above the density of GOOD PAYER

## Real proportion
If we want to use the true proportion of the dataset (8% of observations are Bad Payer) we have to select as threshold p=0.195

# Misclassification Table with these three choice
<img src="https://github.com/danielececcarelli/Home-Credit-Default-Risk-Applied-Stat-project/blob/master/images/conclusion.jpg" width="780">    

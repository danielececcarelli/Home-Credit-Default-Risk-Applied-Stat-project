#########################################################################################
#######      LOGISTIC REGRESSION with Cross Validation       ############################
####### to see the distribution of AUC changing the test set #############################
###########################################################################################

data_full<-read.csv("definitive_features.csv", header=TRUE)

library(ROSE)
library(na.tools)

set.seed(101)   # Set Seed so that same sample can be reproduced in future also

M = 30    # number of different evaluations
nn = dim(data_full)[2]
auc_test = 0*c(1:M)

for(j in c(1:M))
  {
  
  ### Now Selecting 90% of data as sample from total rows of the data  
  sample <- sample.int(n = nrow(data_full), size = floor(.90*nrow(data_full)), replace = F)
  train <- data_full[sample, ]
  test  <- data_full[-sample, ]
  
  ### since the median of the train and test set change with j in 1:M, 
  ### we need to evaluate at each iteration and fill the NA with the new values
  med_train <- 0*c(1:nn)
  med_test <- 0*c(1:nn)
  
  for(i in c(1:nn))
  {
    med_train[i] = median(na.omit(train[,c(i)]))
    med_test[i] = median(na.omit(test[,c(i)])) 
  }
  
  for(i in c(1:nn))
  {
    
    train[,c(i)] = na.replace(train[,c(i)], med_train[i])
    test[,c(i)] = na.replace(test[,c(i)], med_test[i])
  }
  
  ### our final logistic_regression
  log_reg = glm(formula = train$TARGET ~ EXT_SOURCE_2 + EXT_SOURCE_3 + CODE_GENDER_F + 
                  NAME_EDUCATION_TYPE_Higher.education + REGION_RATING_CLIENT + 
                  bureau_CREDIT_ACTIVE_Active_count_norm + previous_loans_NAME_YIELD_GROUP_XNA_count_norm + 
                  OCCUPATION_TYPE_Laborers + YEARS_BIRTH + bureau_YEARS_CREDIT_mean + 
                  previous_loans_YEARS_DECISION_mean + EXT_SOURCE_1 + YEARS_ID_CHANGE_PUBLISH + 
                  na_count + client_installments_AMT_PAYMENT_min_sum_cubic_root + 
                  previous_loans_NAME_CONTRACT_STATUS_Refused_count_norm_square_root + 
                  bureau_CREDIT_ACTIVE_Active_count_square_root + previous_loans_NAME_PRODUCT_TYPE_walk.in + 
                  previous_loans_NAME_YIELD_GROUP_high_count_cubic_root + bureau_YEARS_CREDIT_min_square_root + 
                  AMT_CREDIT_log + AMT_INCOME_TOTAL_log + PAYMENT_RATE + ANNUITY_INCOME_RATIO_log + 
                  INTEREST_RATE + INTEREST_SHARE + rate_goods + rate_credit + TOTAL_INTEREST + MONTHS, family = "binomial", 
                data = train[, c(-1)])
  
  probabilities_test <- predict(log_reg,test,type = "response")
  
  cr_test<-roc.curve(test$TARGET, probabilities_test, plotit = TRUE)
  
  auc_test[j] = cr_test$auc
}


x11()
boxplot(auc_test,xlab = "BoxPlot of AUC on different test sets", ylab = "AUC", col ="gold")
title("Cross-Validation for the AUC on test set with Logistic Regression ")

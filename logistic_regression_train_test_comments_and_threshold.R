#############################################################################
############ Comments on Logistic Regression and choice of thresholds #######
############################################################################

#logistic regression with our train and test set
data_full<-read.csv("definitive_features.csv", header=TRUE)

set.seed(101) 

####### divide train and test (90%/10%) ##############################################
sample <- sample.int(n = nrow(data_full), size = floor(.90*nrow(data_full)), replace = F)
train <- data_full[sample, ]
test  <- data_full[-sample, ]

####### fill NA with median of train and test separately ########################
nn = dim(data_full)[2]
med_train <- 0*c(1:nn)
med_test <- 0*c(1:nn)
for(i in c(1:nn))
{
    med_train[i] = median(na.omit(train[,c(i)]))
    med_test[i] = median(na.omit(test[,c(i)])) 
}

library(na.tools)
for(i in c(1:nn))
{
  
    train[,c(i)] = na.replace(train[,c(i)], med_train[i])
    test[,c(i)] = na.replace(test[,c(i)], med_test[i])
}


library(ROSE)
log_reg_full <- glm(train$TARGET~.,family="binomial",data=train[,c(-1)])
probabilities_train <- predict(log_reg_full,train,type = "response")
cr<-roc.curve(train$TARGET, probabilities_train, plotit = TRUE)
cr
#AUC 0.760


probabilities_test <- predict(log_reg_full,test,type = "response")
cr_test<-roc.curve(test$TARGET, probabilities_test, plotit = TRUE)
cr_test
#0.769

summary(log_reg_full)
########## we need a model reduction -> variables selection through step() #########

#step(log_reg_full)

# result:
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

probabilities_train <- predict(log_reg,train,type = "response")
cr<-roc.curve(train$TARGET, probabilities_train, plotit = TRUE)
cr
#AUC 0.760


probabilities_test <- predict(log_reg,test,type = "response")
x11()
cr_test<-roc.curve(test$TARGET, probabilities_test, plotit = TRUE, main = "ROC Curve Logistic Regression on Test Set")
cr_test
#0.769

library(pROC)
cr_roc = roc(test$TARGET, probabilities_test)
plot(cr_roc)




########################### THRESHOLD SELECTION ###########################################

# -> what is the best threshold such that 
# if our predict P('subject_i is a bad payer')>threshold => the bank don't give 
#                                                             a loan to subject_i

### 1st way -> probability plot -> distribution
library(car)
x11() 
True.TARGET = as.factor(train$TARGET == TRUE)
levels(True.TARGET) = c("Good Payer","Bad Payer")
### density plot of our probabilities and the true Y
densityPlot(probabilities_train, True.TARGET, normalize = TRUE)
abline(v = 0.08, col = "red")

x11()
True.TARGET = as.factor(test$TARGET == TRUE)
levels(True.TARGET) = c("Good Payer","Bad Payer")
densityPlot(probabilities_test, True.TARGET, normalize = TRUE, col = c("black", "red"), main = "Density of estimated probabilities on test set", xlab = "Estimated Probabilities", ylab = "density", rug = FALSE, grid = FALSE)
abline(v = 0.08, col = "blue")
########## si vede che per p>= 0.08 la densità dei TRUE è maggiore di quella dei FALSE
# we can see that for p>=0.08 the density of BAD PAYER is bigger than density of GOOD PAYER

#or
x11()
hist(probabilities_test[test$TARGET == FALSE], breaks = 0.01*c(0:100), xlab = "Estimated Probabilities", ylab = "Frequency", main = "Frequency of test set", ylim = c(0,4000), probability = FALSE, col = "blue")
par(new = TRUE)
hist(probabilities_test[test$TARGET == TRUE], breaks = 0.01*c(0:100), xlab = "", ylab = "", main = "", ylim = c(0,4000), probability = FALSE, col = "red")
grid()
legend(x = 0.7, y = 3500,legend = c("Good Payers", "Bad Payers"), fill = c(4, 2))

#or
x11()
densityPlot(probabilities_test[test$TARGET == FALSE], normalize = FALSE, col = c("black"), main = "Density of estimated probabilities on test set", xlab = "Estimated Probabilities", ylab = "density", xlim = c(0,1), ylim = c(0,15), rug = FALSE)
par(new = TRUE)
densityPlot(probabilities_test[test$TARGET == TRUE], normalize = FALSE, col = c("red"), main = "Density of estimated probabilities on test set", xlab = "Estimated Probabilities", ylab = "density",  xlim = c(0,1), ylim = c(0,15), rug = FALSE)

TrueTARGET = as.factor(test$TARGET == TRUE)
levels(TrueTARGET) = c("Good Payer","Bad Payer")
EstimatedTARGET = as.factor(probabilities_test > 0.08)
levels(EstimatedTARGET) = c("Get a loan (p < 0.08)","No loan (p > 0.08)")

### table: TrueTarget vs Estimated Target when threshold == 0.08
table(TrueTARGET, EstimatedTARGET)



#### 2nd way -> minimize a cost function

# how can we estimate the cost function? cost if we misclassified a customer:

# 1) If I predict that a customer will be a GOOD PAYER and he is not (so, his true Y is = 1)
#     I give him a loan, and then the bank lost the credit 
#     (or part of it, if I suppose that a customer will pay just some months)

# 2) If I predict that a customer will be a BAD PAYER and he is not (so, his true Y is = 0)
#     I decide to not give him a loan, even if, a posteriori, he could repay it:
#     the loss is in terms of interest that I can make through this loan

test_cost = test[c(10)] #add TARGET
test_cost$probabilities = probabilities_test #add probabilities
test_cost$AMT_CREDIT =  exp(test$AMT_CREDIT_log)
test_cost$AMT_ANNUITY =  exp(test$AMT_ANNUITY_log)
test_cost$MONTHS = test$MONTHS
test_cost$TOTAL_INTEREST = test$TOTAL_INTEREST


alpha = 0.8 #percentage of interest loss (due to fixed cost and taxes)
beta = 0.7 #percentage of credit loss (assumption: a subject will pay the first months)

cost = 0*c(1:90);
p =  0.01*c(1:90) + 0.08;

for (j in c(1:90)){
    estimated_target = test_cost$probabilities > p[j]
    interest_index = which(estimated_target==TRUE & test_cost$TARGET==0)
    credit_index = which(estimated_target == FALSE & test_cost$TARGET==1)
    
    for(i in interest_index){
        cost[j] = cost[j] + alpha*min(test_cost$TOTAL_INTEREST[i],test_cost$AMT_CREDIT[i]*0.5) 
                #because in some case it's overestimated!
    }
    
    for (i in credit_index){
        cost[j] = cost[j] + beta*test_cost[i, ]$AMT_CREDIT
    }
}
p[which(cost == min(cost))]

x11()
plot(p, cost, type = "l", main = "Misclassification Cost Function, alpha = 0.8, beta = 0.7", xlab = "Threshold p", ylab = "Misclassification Cost")
grid()
points(p, cost, pch = 18, col = "red")
p_min = p[which(cost == min(cost))]
points(p_min, min(cost), pch=19, cex = 1.5 ,col = "blue")
#abline(v = 0.3, col = "black")
abline(h = min(cost), col = "blue")
###########we can see a min woth the threshold = 0.3
graphics.off()


TrueTARGET = as.factor(test$TARGET == TRUE)
levels(TrueTARGET) = c("Good Payer","Bad Payer")
EstimatedTARGET = as.factor(probabilities_test > 0.3)
levels(EstimatedTARGET) = c("Get a loan (p < 0.30)","No loan (p > 0.30)")

### table: TrueTarget vs Estimated Target when threshold == 0.30
table(TrueTARGET, EstimatedTARGET)


# 3rd way -> true proportion in the dataset -> since this is a UNBALANCED PROBLEM
# prop. in data_full 0.08072882
# prop. in train     0.08071644
# prop. in test      0.08084027
############# => more or less 8.1%  ################

x11()
densityPlot(probabilities_test, normalize = TRUE ,main = "Density of estimated probabilities on test set", xlab = "Estimated Probabilities", ylab = "density", rug = FALSE, grid = FALSE)

###30752*0.081 = 2491 
prova = sum(probabilities_test > 0.195) #more or less 2500
abline(v = 0.195, col = "red")
abline(h = 0, col = "grey")
############### p = 0.195

TrueTARGET = as.factor(test$TARGET == TRUE)
levels(TrueTARGET) = c("Good Payer","Bad Payer")
EstimatedTARGET = as.factor(probabilities_test > 0.195)
levels(EstimatedTARGET) = c("Get a loan (p < 0.195)","No loan (p > 0.195)")

### table: TrueTarget vs Estimated Target when threshold == 0.195
table(TrueTARGET, EstimatedTARGET)



# 
# # 4° way -> classify 30% of TARGET TRUE?
# 
# x11()
# densityPlot(probabilities_test[test$TARGET == FALSE], normalize = FALSE, col = c("black"), main = "Density of estimated probabilities on test set", xlab = "Estimated Probabilities", ylab = "density", xlim = c(0,1), ylim = c(0,15), rug = FALSE)
# par(new = TRUE)
# densityPlot(probabilities_test[test$TARGET == TRUE], normalize = FALSE, col = c("red"), main = "Density of estimated probabilities on test set", xlab = "Estimated Probabilities", ylab = "density",  xlim = c(0,1), ylim = c(0,15), rug = FALSE)

# ### 2486*0.3 = 746 => p = 0.2

# abline(v = 0.2, col = "red")
# ############### p = 0.2
# 
# table(test$TARGET, probabilities_test>0.2)
# #good classify of TARGET == TRUE
# #error in 6% of TARGET == FALSE




# PLOTS:
########## factor density plot ###########

library(car)
x11() 
Higher.Education = as.factor(test$NAME_EDUCATION_TYPE_Higher.education == TRUE)
levels(Higher.Education) = c("NO","YES")
densityPlot(probabilities_test, Higher.Education, normalize = TRUE, rug = FALSE, grid = FALSE, main = "Density & Education")


x11() 
Region.Rating = as.factor(test$REGION_RATING_CLIENT)
levels(Region.Rating) = c("High","Medium","Low")
densityPlot(probabilities_test, Region.Rating, normalize = TRUE, rug = FALSE,  grid = FALSE, main = "Density & Region Rating", col = c(1,4,2))


x11() 
Gender = as.factor(test$CODE_GENDER_F)
levels(Gender) = c("Male", "Female")
densityPlot(probabilities_test, Gender, normalize = TRUE, rug = FALSE,  grid = FALSE, col = c(1,2), main = "Density & Gender")
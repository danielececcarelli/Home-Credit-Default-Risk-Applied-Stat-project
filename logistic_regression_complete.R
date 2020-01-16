#######################################################################################
###################### LOGISTIC REGRESSION ON FULL DATASET ############################
#######################################################################################
data_full<-read.csv("definitive_full_features.csv", header=TRUE)

# data_full = data_full[data_full$TOTAL_INTEREST>0,]
# data_full = data_full[data_full$PREVIOUS_INTEREST>0,]
# data_full = data_full[data_full$INTEREST_RATE>0,]
# data_full = data_full[data_full$INTEREST_SHARE>0,]


library(ROSE)
log_reg_full <- glm(data_full$TARGET~.,family="binomial",data=data_full[,c(-1)])
probabilities <- predict(log_reg_full,data_full,type = "response")
cr<-roc.curve(data_full$TARGET, probabilities, plotit = TRUE)
cr
########## AUC 0.761 ############################## 

#step(log_reg_full)
############### USING STEP, we can finally select these covariates ###################
log_reg = glm(formula = data_full$TARGET ~ EXT_SOURCE_2 + EXT_SOURCE_3 + CODE_GENDER_F + 
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
              data = data_full[, c(-1)])

probabilities <- predict(log_reg,data_full,type = "response")
cr<-roc.curve(data_full$TARGET, probabilities, plotit = TRUE)
cr
########## AUC 0.761 ############################################ 
########## we get the same AUC with less covariates #############


####################### evaluation on kaggle of our solution ##############
test_full<-read.csv("test_full_features.csv", header=TRUE)
probabilities_test <- predict(log_reg,test_full,type = "response")
response = cbind(test_full$SK_ID_CURR, probabilities_test)

write.csv(response, "response_full_features.csv", row.names = FALSE)
######################  AUC 0.758 on KAGGLE!###########################

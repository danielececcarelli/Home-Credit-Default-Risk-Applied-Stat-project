library(car)
################################################################################
############# prep. of definitive_full_features.csv ######################
########################################################################


######## dataset used -> comes from Kaggle with some other preprocessing ############
data_full<-read.csv("datasets/power_trans_data.csv", header=TRUE)
test_full<-read.csv("datasets/power_trans_test.csv", header=TRUE)


#################### add new variables -> other credit variables###############

data_full$PAYMENT_RATE = exp(data_full$AMT_CREDIT_log) / exp(data_full$AMT_ANNUITY_log)
data_full$LOAN_INCOME_RATIO_log = log(exp(data_full$AMT_CREDIT_log) / exp(data_full$AMT_INCOME_TOTAL_log))
data_full$ANNUITY_INCOME_RATIO_log = log(exp(data_full$AMT_ANNUITY_log)/exp(data_full$AMT_INCOME_TOTAL_log))

test_full$PAYMENT_RATE = exp(test_full$AMT_CREDIT_log) / exp(test_full$AMT_ANNUITY_log)
test_full$LOAN_INCOME_RATIO_log = log(exp(test_full$AMT_CREDIT_log) / exp(test_full$AMT_INCOME_TOTAL_log))
test_full$ANNUITY_INCOME_RATIO_log = log(exp(test_full$AMT_ANNUITY_log)/exp(test_full$AMT_INCOME_TOTAL_log))


late_payment_tot = read.csv("datasets/late_payment.csv", header = TRUE)
late_payment_tot$LATE_PAYMENT = late_payment_tot$x
late_payment_tot = late_payment_tot[,c(-2)]

data_full = merge(data_full, late_payment_tot, all.x = TRUE)
test_full = merge(test_full, late_payment_tot, all.x = TRUE)

prev_app_feature = read.csv("datasets/prev_app_feature.csv", header = TRUE)
data_full = merge(data_full, prev_app_feature, all.x = TRUE)
test_full = merge(test_full, prev_app_feature, all.x = TRUE)


################### add a variable to count na in test_full (already present in data_full)
nn = dim(test_full)[1]
na_count = 0*c(1:nn)
for(i in c(1:nn)){
  na_count[i] = sum(is.na(test_full[c(i),]))
}
test_full$na_count = na_count

cnt_data = read.csv("datasets/lgbm_CNT_train.csv", header = TRUE)
cnt_test = read.csv("datasets/lgbm_CNT_test.csv", header = TRUE)
data_full = merge(data_full, cnt_data, all.x = TRUE)
test_full = merge(test_full, cnt_test, all.x = TRUE)

library(na.tools)
library(dplyr)
data_full$lgbm_CNT = na_if(data_full$lgbm_CNT, 0.00)
test_full$lgbm_CNT = na_if(test_full$lgbm_CNT, 0.00)

nn = dim(data_full)[2]
med <- 0*c(1:nn)
for(i in c(1:nn)){
  med[i] = median(na.omit(data_full[,c(i)]))
}

for(i in c(1:nn)){
  data_full[,c(i)] = na.replace(data_full[,c(i)], med[i])
}


nn = dim(test_full)[2]
med <- 0*c(1:nn)
for(i in c(1:nn)){
  med[i] = median(na.omit(test_full[,c(i)]))
}

for(i in c(1:nn)){
  test_full[,c(i)] = na.replace(test_full[,c(i)], med[i])
}


data_full$TOTAL_INTEREST = (exp(data_full$AMT_ANNUITY_log) * data_full$lgbm_CNT - exp(data_full$AMT_CREDIT_log))
test_full$TOTAL_INTEREST = (exp(test_full$AMT_ANNUITY_log) * test_full$lgbm_CNT - exp(test_full$AMT_CREDIT_log))


colnames(data_full)[colnames(data_full)=="INTEREST"] = "PREVIOUS_INTEREST"
colnames(test_full)[colnames(test_full)=="INTEREST"] = "PREVIOUS_INTEREST"

colnames(data_full)[colnames(data_full)=="lgbm_CNT"] = "MONTHS"
colnames(test_full)[colnames(test_full)=="lgbm_CNT"] = "MONTHS"


write.csv(data_full, file = "definitive_full_features.csv", quote=F ,sep=";", dec=",", na="", row.names =F,  col.names=T)
write.csv(test_full, file = "test_full_features.csv", quote=F ,sep=";", dec=",", na="", row.names =F,  col.names=T)


# 
# sample <- sample.int(n = nrow(data_full), size = floor(.01*nrow(data_full)), replace = F)
# prova <- data_full[sample, ]
# goodpayer = prova[prova$TARGET == FALSE,]
# badpayer = prova[prova$TARGET == TRUE,]
# x11()
# plot(goodpayer$AMT_CREDIT_log, goodpayer$AMT_INCOME_TOTAL_log, col = 'blue', pch = 16)
# points(badpayer$AMT_CREDIT_log, badpayer$AMT_INCOME_TOTAL_log, col = 'red', pch = 16)
# 
# 
# library(MASS)
# library(car)
# library(rgl)
# open3d()
# points3d(x=prova$EXT_SOURCE_1, y=prova$EXT_SOURCE_2, z=prova$EXT_SOURCE_3, size=4, col=prova$TARGET+1, aspect = T)
# axes3d()
# 

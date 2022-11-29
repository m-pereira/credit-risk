
#
# This is a Plumber API. You can run the API by clicking
# the 'Run API' button above.
#
# Find out more about building APIs with Plumber here:
#
#    https://www.rplumber.io/
#

library(plumber)
library(tidymodels)
library(tidyverse)
model <- readRDS("light-model.RDS")

#* @apiTitle API to forecast credit risk
#* @apiDescription Fore more information check out in :
#* Echo back the input
#* @param otpnp Numeric: 0
#* @param lpa Numeric: 119.66
#* @param lcpd Date: "Sep-2013"
#* @param tpi Numeric 1008.91
#* @get /predict
function(otpnp,lpa,
         lcpd,tpi){
  df <- 
    tibble(out_prncp = as.numeric(otpnp),
           last_pymnt_amnt = as.numeric(lpa),
           last_credit_pull_d = as.character(lcpd),
           total_pymnt_inv = as.numeric(tpi)
    )
  predict(model,df) %>% slice(1) %>% pluck(1)
}

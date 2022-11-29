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
#* @param out_prncp Numeric: 0
#* @param last_pymnt_amnt Numeric: 119.66
#* @param last_credit_pull_d Date: "Sep-2013"
#* @param total_pymnt_inv Numeric 1008.91
#* @post /predict
function(out_prncp,last_pymnt_amnt,
                 last_credit_pull_d,total_pymnt_inv){
  df <- 
  tibble(out_prncp = as.numeric(out_prncp),
         last_pymnt_amnt = as.numeric(last_pymnt_amnt),
         last_credit_pull_d = as.character(last_credit_pull_d),
         total_pymnt_inv = as.numeric(total_pymnt_inv)
  )
  predict(model,df) %>% slice(1) %>% pluck(1)
}

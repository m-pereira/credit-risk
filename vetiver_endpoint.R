library(vetiver)
endpoint <- vetiver_endpoint("http://127.0.0.1:8088/credit-risk")
endpoint
my_df <- readRDS(here::here("data","loan.RDS"))  
predict(endpoint, my_df[1:10,])

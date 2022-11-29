## check API
library(httr)
library(jsonlite)

url <- "https://deployapicredit-6o2dvvrxhq-rj.a.run.app/check"
response <-  POST(url)
response
content <- content(response, type = "text", encoding = "utf-8")
fromJSON(content)




url <- "https://deployapicredit-6o2dvvrxhq-rj.a.run.app/predict?otpnp=0&lpa=119.96&lcpd=Set-2013&tpi=1008.91"
response <-  POST(url)
response
content <- content(response, type = "text", encoding = "utf-8")
fromJSON(content)



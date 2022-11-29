## check API
library(httr)
library(jsonlite)
url  <-  "https://api-rk6gh2l6da-ew.a.run.app/clasificador?sepal_width=2&sepal_length=2&petal_width=1&petal_length=3"
response <-  POST(url)
content <- content(response, type = "text", encoding = "utf-8")
fromJSON(content)



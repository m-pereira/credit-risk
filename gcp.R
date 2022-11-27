## secrets to VM
project = "My First Project" #creditrisk1
zona = "us-central1-b"
account_key = "key1.json"

Sys.setenv(GCE_AUTH_FILE = account_key,
           GCE_DEFAULT_PROJECT_ID = project,
           GCE_DEFAULT_ZONE = zona
)

library(googleComputeEngineR)

## setting vm
vm <- gce_vm(template = "rstudio", 
             name="demo-rstudio",
             predefined_type = "f1-micro", 
             username = "user1",
             password = "pass1")

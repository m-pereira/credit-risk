library(googleCloudRunner)
googleCloudRunner::cr_setup()
googleCloudRunner::cr_setup_test()
## deploy
cr <- cr_deploy_plumber(here::here("API"))

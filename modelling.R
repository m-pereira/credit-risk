## packages and importing dataset
library(tidymodels)
my_df <- readRDS(here::here("data","loan.RDS"))  %>% 
  tibble() %>% 
  mutate(risky_loan = as.factor(risky_loan))
my_df %>% glimpse()
### initial split
set.seed(458)
my_df_split <- initial_split(my_df, prop = 0.75, strata = risky_loan)
## in case you want use bootstrap bootstrap
k_fold <- vfold_cv(training(my_df_split), v = 5)
## recipe
ranger_recipe <-
  recipe(formula = risky_loan ~ ., data = training(my_df_split)) %>%
  step_impute_median(all_numeric_predictors()) %>% 
  step_zv(all_numeric_predictors()) %>% 
  step_normalize(all_numeric_predictors()) %>% 
  step_corr(all_numeric_predictors(),threshold = 0.8) %>% 
  step_novel(all_nominal_predictors()) %>% 
  step_unknown(all_nominal_predictors()) %>% 
  step_other(all_nominal_predictors(), threshold = 0.1) %>%
  step_dummy(all_nominal_predictors(),one_hot = FALSE) 

##spec
ranger_spec <-
  rand_forest(mtry = tune(), 
              min_n = tune(), 
              trees = tune()) %>%
  set_mode("classification") %>%
  set_engine("ranger")
##workflow
ranger_workflow <-
  workflow() %>%
  add_recipe(ranger_recipe) %>%
  add_model(ranger_spec)
ranger_workflow
## tune grid
set.seed(7785)
doParallel::registerDoParallel()

ranger_tune <-
  tune_grid(ranger_workflow,
            k_fold,
            grid = 10
  )


show_best(ranger_tune, metric = "rmse")

show_best(ranger_tune, metric = "rsq")


autoplot(ranger_tune)
## workflow
final_rf <- ranger_workflow %>%
  finalize_workflow(select_best(ranger_tune))

final_rf
## last fit
my_df_fit <- last_fit(final_rf, my_df_split)
my_df_fit

collect_metrics(my_df_fit)

collect_predictions(my_df_fit) %>%
  ggplot(aes(price, .pred)) +
  geom_abline(lty = 2, color = "gray50") +
  geom_point(alpha = 0.5, color = "midnightblue") +
  coord_fixed()

predict(my_df_fit$.workflow[[1]], my_df_test[15, ])

## save the model
library(vetiver)
## understand the model
library(vip)

imp_spec <- ranger_spec %>%
  finalize_model(select_best(ranger_tune)) %>%
  set_engine("ranger", importance = "permutation")

workflow() %>%
  add_recipe(ranger_recipe) %>%
  add_model(imp_spec) %>%
  fit(my_df_train) %>%
  pull_workflow_fit() %>%
  vip(aesthetics = list(alpha = 0.8, fill = "midnightblue"))



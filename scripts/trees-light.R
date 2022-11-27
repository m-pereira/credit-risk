## packages and importing dataset
library(tidymodels)
my_df <- readRDS(here::here("data","loan.RDS")) %>%   
  select(out_prncp,last_pymnt_amnt,last_credit_pull_d,
         total_pymnt_inv,risky_loan)

my_df %>% glimpse()
### initial split------------------
set.seed(458)
my_df_split <- initial_split(my_df, prop = 0.5, strata = risky_loan)
## in case you want use bootstrap bootstrap
k_fold <- vfold_cv(training(my_df_split), v = 5)
## recipe-------------------
tree_recipe <-
  recipe(formula = risky_loan ~ ., data = training(my_df_split)) %>%
  step_impute_median(all_numeric_predictors()) %>% 
  step_zv(all_numeric_predictors()) %>% 
  step_normalize(all_numeric_predictors()) %>% 
  step_corr(all_numeric_predictors(),threshold = 0.8) %>% 
  step_novel(all_nominal_predictors()) %>% 
  step_unknown(all_nominal_predictors()) %>% 
  step_other(all_nominal_predictors(), threshold = 0.1) %>%
  step_dummy(all_nominal_predictors(),one_hot = FALSE) 

##spec-------------------
tree_spec <-
decision_tree(cost_complexity = tune(),
            tree_depth = tune(),
            min_n = tune()) %>%
  set_mode("classification") %>%
  set_engine("rpart")
##workflow----------------------
tree_workflow <-
  workflow() %>%
  add_recipe(tree_recipe) %>%
  add_model(tree_spec)
tree_workflow
## tune grid------------------
set.seed(7785)

tree_grid <- grid_latin_hypercube(
  cost_complexity(c(-10, -1)), 
  tree_depth(c(1,15)), 
  min_n(c(2,40)), 
  size = 10)
tree_grid
set.seed(7785)
doParallel::registerDoParallel()
tree_tune <-
  tune_grid(tree_workflow,
            k_fold,
            grid = tree_grid,
            metrics = metric_set(accuracy, 
                      roc_auc, sensitivity, specificity)
  )
tree_tune
### show best ------------------------
show_best(tree_tune,metric = "roc_auc")

autoplot(tree_tune)
## finalize workflow---------------
final_tree <- tree_workflow %>%
  finalize_workflow(select_best(tree_tune,metric = "roc_auc"))
final_tree

## last fit----------------------
my_df_fit <- last_fit(final_tree, my_df_split)


my_df_fit
saveRDS(my_df_fit,here::here("artifacts","wkflw.RDS"))

collect_metrics(my_df_fit)
predict(
  my_df_fit$.workflow[[1]],
  slice_tail(testing(my_df_split),n=20))
predict(
  my_df_fit$.workflow[[1]],
  slice_head(testing(my_df_split),n=20))


## understand the model--------------------

library(vip)
my_df_fit %>% 
  extract_fit_parsnip() %>% 
  vip(aesthetics = list(alpha = 0.8, fill = "midnightblue"))
my_df_fit %>% 
  extract_fit_parsnip() %>% vi()

library(DALEXtra)
final_fitted <- my_df_fit$.workflow[[1]]
predict(final_fitted, my_df[10:12, ])

tree_explainer <- explain_tidymodels(
  final_fitted,
  data = dplyr::select(testing(my_df_split),
                       -risky_loan),
  y = dplyr::select(training(my_df_split),
                    risky_loan),
  verbose = FALSE
)

library(modelStudio)
new_observation <- testing(my_df_split) %>% slice_head()
modelStudio(tree_explainer, new_observation)

## save the model------------------
library(vetiver)
v <- my_df_fit %>%
  extract_workflow() %>%
  vetiver_model(model_name = "credit-risk")
v
library(pins)
board <- board_temp(versioned = TRUE)
board %>% vetiver_pin_write(v)
vetiver_write_plumber(board, "credit-risk", 
                      rsconnect = FALSE)
vetiver_write_docker(v)


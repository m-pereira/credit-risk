library(dplyr)
my_df <- read.csv(here::here("data","loan.csv"))
my_df
my_df %>% glimpse()
my_df %>% summarise_all(~ sum(is.na(.)))
my_df <- 
my_df %>% select(
  id,loan_amnt:inq_last_6mths,
  open_acc:collections_12_mths_ex_med,
  policy_code, application_type,
  verification_status_joint:tot_cur_bal
) 


my_df %>% count(term)
my_df %>% count(next_pymnt_d)
my_df %>% count(verification_status_joint)
my_df %>% count(addr_state)
my_df %>% count(purpose)
my_df %>% count(title)
my_df %>% count(application_type)
my_df %>% count(pymnt_plan)
my_df %>% count(grade)
my_df %>% count(sub_grade)
my_df %>% count(emp_title)
my_df %>% count(home_ownership)
my_df %>% count(emp_length)
my_df %>% count(last_credit_pull_d)
my_df %>% count(tot_coll_amt)
my_df %>% count(tot_cur_bal)

my_df %>% filter(next_pymnt_d=="") %>% count()

my_df <- 
my_df %>% select(-verification_status_joint,-zip_code,-emp_title,
                 -addr_state,-url,-desc,-title,-next_pymnt_d,
                 -application_type,-pymnt_plan,)

my_df %>% glimpse()
my_df %>% pull(loan_status) %>% 
  table() %>% prop.table() %>% round(3)
# Let's transform them. Assign the negative to 1, the rest to 0.
my_df <-
  my_df %>% 
  mutate(risky_loan = case_when(loan_status == "Charged Off" ~ 1,
                                loan_status == "Current" ~ 0,
                                loan_status == "Default" ~ 1,
                                loan_status == "Does not meet the credit policy. Status:Charged Off" ~ 1,
                                loan_status == "Does not meet the credit policy. Status:Fully Paid" ~ 0,
                                loan_status == "Fully Paid" ~ 0,
                                loan_status == "In Grace Period" ~ 0,
                                loan_status == "Late (16-30 days)" ~ 1,
                                loan_status == "Late (31 - 120)" ~ 1,
  )) %>% select(-loan_status)

my_df %>% count(risky_loan)
my_df <- rbind(my_df %>% filter(risky_loan == 1),
               my_df %>% filter(risky_loan == 0) %>% 
                 slice_sample(n=50000)) %>% 
  tibble() %>% 
  mutate(risky_loan = as.factor(risky_loan))
my_df %>% glimpse()
my_df %>% select(loan_amnt,term:verification_status,
                 purpose:initial_list_status,
                 total_rec_int,recoveries,issue_d,
                 last_pymnt_amnt,last_credit_pull_d,
                 risky_loan,total_pymnt_inv,policy_code,out_prncp,
                 ) %>% 
  saveRDS(here::here("data","loan.RDS"))


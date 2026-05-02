library(tidymodels)
library(vetiver)
library(broom)
library(pins)

data(mtcars)

split <- initial_split(mtcars, prop = 0.8)
train <- training(split)
test <- testing(split)

rec <- recipe(mpg ~ ., data = train)

mod <- rand_forest(trees = 500) |>
  set_engine("ranger") |>
  set_mode("regression")

wf <- workflow() |>
  add_recipe(rec) |>
  add_model(mod)

fit_wf <- fit(wf, data = train)


preds_df <- tibble(
  mpg = test$mpg,
  preds = predict(fit_wf, new_data = test)$.pred
)
preds_df
preds_df |>
  rmse(truth = mpg, estimate = preds)

v <- vetiver_model(
  fit_wf,
  model_name = "mtcars_mpg_model",
  save_prototype = train |> dplyr::select(-mpg)
)

v
#This stores the model plus its input prototype, so vetiver knows what new prediction data should look like

board <- board_folder("models", versioned = TRUE)
board
vetiver_pin_write(board, v)

v2 <- vetiver_pin_read(board, "mtcars_mpg_model")
v2

library(plumber)

pr() |>
  vetiver_api(v2) |>
  pr_run(port = 8000)


endpoint <- vetiver_endpoint("http://127.0.0.1:8000/predict")

new_data <- test |> select(-mpg)

predict(endpoint, new_data)

# deploy as a real public API --------------------------------------------

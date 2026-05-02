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


model_board <- board_folder("model", versioned = TRUE)

vetiver_model <- vetiver_model(fit_wf, "car-mpg-model")

vetiver_pin_write(model_board, vetiver_model)


rsconnect::writeManifest()






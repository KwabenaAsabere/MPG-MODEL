library(plumber)
library(vetiver)
library(pins)

board <- board_folder("model")

model <- vetiver_pin_read(board, "car-mpg-model")

pr() |>
  vetiver_api(model)

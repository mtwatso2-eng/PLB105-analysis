require(shiny); require(shinyWidgets)
require(plotly)
require(tidyverse); require(magrittr)
source("utils.R")

observations <- "class data.csv" %>%
  read_csv() %>%
  rename_with(str_to_sentence) %>%
  mutate(
    Class = case_when(
      Class == "H" ~ "Hyphae",
      Class == "A" ~ "Arbuscules",
      Class == "V" ~ "Vesicles"
    )
  ) %>%
  rowwise() %>%
  mutate(
    Value = min(c(Value * 10 / Total_windows, 10)),
    Group = last(str_split(Group, "-")[[1]]),
  ) %>%
  ungroup()

sapply(list.files(path = "modules", recursive = TRUE, pattern = "^.*\\.R$", full.names = TRUE), source)
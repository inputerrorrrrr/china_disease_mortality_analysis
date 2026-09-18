library(tidyverse)
library(readxl)

function_files <- list.files(
  "functions",
  pattern = "\\.R$",
  recursive = TRUE,
  full.names = TRUE
)

purrr::walk(function_files, source)

urban_data <- clean_excel(file_path = "data_raw/urban_crude_mortality_by_cause.xlsx")
rural_data <- clean_excel(file_path = "data_raw/rural_crude_mortality_by_cause.xlsx")

urban_data <- urban_data |> 
  mutate(population_group = "urban")

rural_data <- rural_data |> 
  mutate(population_group = "rural")

death_long <- bind_rows(
  urban_data,
  rural_data
)

selected_causes <- c(
  "恶性肿瘤",
  "心脏病",
  "脑血管病",
  "呼吸系统疾病",
  "内分泌,营养和代谢疾病"
)

death_selected <- death_long |> 
  filter(str_detect(
    indicator,
    str_c(selected_causes, collapse = "|")
  ))

view(death_selected)

death_selected <- clean_indicator_units(
  data = death_selected, 
  rules = c("per 100,000 population" = "\\(1/10万\\)"),
  new_column = "unit")

death_selected <- clean_indicator_units(
  data= death_selected,
  rules = c(
    "malignant_neoplasms" = "恶性肿瘤",
    "heart_disease" = "心脏病",
    "cerebrovascular_disease" = "脑血管病",
    "respiratory_diseases" = "呼吸系统疾病",
    "endocrine_nutritional_metabolic_diseases" = "内分泌,营养和代谢疾病"
  ),
  new_column = "disease"
)

death_selected <- clean_indicator_units(
  data = death_selected,
  rules = c(
    "female" = "女性",
    "male" = "男性"
  ),
  new_column = "sex",
  default = "all"
)

death_selected <- death_selected |> mutate(indicator = "crude_mortality")

write.csv(
  death_selected,
  "data_clean/death_mortality_clean.csv",
  row.names = FALSE
)

mortality_plot <- death_selected |> 
  filter(sex == "all") |> 
  ggplot(
    aes(
      x = year,
      y = value,
      color = population_group
    )
  ) +
  geom_line() +
  facet_wrap(
    ~ disease,
    scales = "free_y",
    labeller = as_labeller(c(
      cerebrovascular_disease = "Cerebrovascular disease",
      endocrine_nutritional_metabolic_diseases = "Endocrine, nutritional & metabolic diseases",
      heart_disease = "Heart disease",
      malignant_neoplasms = "Malignant neoplasms",
      respiratory_diseases = "Respiratory diseases"
    ))
  ) +
  labs(
    title = "Crude Mortality Rates by Major Cause of Death",
    x = "Year",
    y = "Deaths per 100,000 population",
    color = "Population Group"
  )

ggsave(
  "figures/mortality_by_cause.png",
  plot = mortality_plot,
  width = 10,
  height = 6,
  dpi = 300
)

urban_rural_gap <- death_selected |> 
  filter(sex == "all") |> 
  select(year, disease, population_group, value) |> 
  pivot_wider(
    names_from = population_group,
    values_from = value
  )

View(urban_rural_gap)

urban_rural_gap <- urban_rural_gap |> 
  mutate(
    gap = urban - rural
  )

urban_rural_mortality_gap_plot <- urban_rural_gap |> 
  ggplot(
    aes(
      x = year,
      y = gap
  )) +
  geom_hline(yintercept = 0, linetype = "dashed") +
  geom_line() +
  facet_wrap(~ disease, scales = "free_y") +
  labs(
    title = "Urban–Rural Gap in Crude Mortality Rates",
    subtitle = "Positive values indicate higher urban mortality rates",
    x = "Year",
    y = "Urban − Rural mortality rate"
  )

ggsave(
  "figures/urban_rural_mortality_gap_plot.png",
  plot = urban_rural_mortality_gap_plot,
  width = 10,
  height = 6,
  dpi = 300
)

mortality_by_sex_plot <- death_selected |> 
  filter(sex != "all") |> 
  ggplot(
    aes(
      x = year,
      y = value,
      color = sex
    )
  ) +
  geom_line() +
  facet_grid(disease ~ population_group, scales = "free_y", switch = "y") +
  theme(
    strip.placement = "outside",
    strip.text.y.left = element_text(angle = 0)
  ) +
  labs(
    title = "Crude Mortality Rates by Sex",
    x = "Year",
    y = "Deaths per 100,000 population",
    color = "Sex"
  )

ggsave(
  "figures/mortality_by_sex_plot.png",
  plot = mortality_by_sex_plot,
  width = 10,
  height = 6,
  dpi = 300
)

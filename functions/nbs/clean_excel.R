clean_excel <- function(file_path, skip_rows = 2) {
  data <- read_excel(file_path, skip = skip_rows)
  
  
  
  data_long <- data |> 
    filter(!str_detect(指标, "数据来源|注")) |>
    pivot_longer(
      cols = -指标,
      names_to = "year",
      values_to = "value"
    ) |>
    rename(indicator = 指标) |>
    mutate(
      year = gsub("年", "", year),
      year = as.numeric(year),
      value = as.numeric(value)
    )
  
  return(data_long)
}
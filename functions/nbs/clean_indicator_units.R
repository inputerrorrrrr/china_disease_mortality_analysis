clean_indicator_units <- function(data, rules, new_column, default = NA_character_)
{
  result <- rep(default, nrow(data))
  
  for (label in names(rules)) 
  {
    result[str_detect(data$indicator, rules[[label]])] <- label
    #拆开写就是
    #pattern <- rules[[label]]
    #matched <- str_detect(data$indicator, pattern)
    #result[matched] <- label
  }
  
  pattern_all <- paste(rules, collapse = "|")
  
  data |> 
    mutate("{new_column}" := result,
           indicator = str_replace_all(indicator, pattern_all, "")
           )
}
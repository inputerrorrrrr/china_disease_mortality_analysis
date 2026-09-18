x_paren_small <- function(data, column)
{
  data |> 
    mutate(
      {{ column }} := str_replace_all({{ column }}, "[()]", "")
    )
}
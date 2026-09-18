x_paren_big <- function(data, column)
{
  data |> 
    mutate(
      {{ column }} := str_replace_all({{ column }}, "\\(.*?\\)", "")
    )
}
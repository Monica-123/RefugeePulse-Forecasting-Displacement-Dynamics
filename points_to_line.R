library(sp)
library(tmaptools)

# Adapted from 
# https://stackoverflow.com/questions/32275213/how-do-i-connect-two-coordinates-with-a-line-using-leaflet-in-r

points_to_line <- function(data, long, lat, id_field = NULL, sort_field = NULL) {
  
  # Convert to SpatialPointsDataFrame
  coordinates(data) <- c(long, lat)
  
  # If there is a sort field...
  if (!is.null(sort_field)) {
    if (!is.null(id_field)) {
      data <- data[order(data[[id_field]], data[[sort_field]]), ]
    } else {
      data <- data[order(data[[sort_field]]), ]
    }
  }
  
  # If there is only one path...
  if (is.null(id_field)) {
    
    lines <- SpatialLines(list(Lines(list(Line(data)), "id")))
    
    return(lines)
    
    # Now, if we have multiple lines...
  } else if (!is.null(id_field)) {  
    # Split into a list by ID field
    paths <- sp::split(data, data[[id_field]])
    
    sp_lines <- SpatialLines(list(Lines(list(Line(paths[[1]])), names(paths)[1])))
    
    # I like for loops, what can I say...
    if (length(paths) > 1) {
      for (p in 2:length(paths)) {
        id <- names(paths)[p]
        l <- SpatialLines(list(Lines(list(Line(paths[[p]])), id)))
        sp_lines <- spRbind(sp_lines, l)
      }
    }
    
    return(sp_lines)
  }
}

library(ggplot2)

getCharacters <- function(n, nPoints, curvature){
  characters <- lapply(seq(n), function(i){
    df <- data.frame(x = c(0, 1+rnorm(nPoints, sd = 0.5), 2),
                     y = c(0.25, runif(nPoints, max = 2), 0.25),
                     color = "black",
                     linetype = "solid",
                     curvature = runif(nPoints + 2, min = -curvature, max = curvature),
                     linewidth = runif(nPoints + 2, min = 0.8, max = 1.2))
    df$xend <- c(df$x[-1], df$x[1])
    df$yend <- c(df$y[-1], df$y[1])
    thicker <- (df$yend <= df$y) & (df$x < df$xend)
    df$linewidth[thicker] <- runif(sum(thicker), min = 1.5, max = 1.6)
    leave_out <- c(sample(nrow(df),
                          sample(0:(nPoints-1),1),
                          prob = c(1, rep(3, nrow(df)-2), 1)),
                   nPoints+2)
    df[-leave_out,]
  })
  return(characters)
}

layout <- function(characters, nrow, ncol, x_off = 2, y_off = 2.5){
  df <- do.call(rbind, characters)
  df$id <- rep(seq_along(characters), times = sapply(characters, nrow))
  
  x_offset_per_char <- rep(seq(1, by = x_off, length.out = ncol), 
                           length.out = length(characters))
  df$x_offset <- rep(x_offset_per_char, times = sapply(characters, nrow))
  
  y_offset_per_char <- sort(rep(seq(1, by = y_off, length.out = nrow), 
                                length.out = length(characters)))
  df$y_offset <- rep(y_offset_per_char, times = sapply(characters, nrow))
  
  return(df)
}

write <- function(df){
  bg_df <-  expand.grid(x=seq(1, max(df$x_offset)+5, length.out = 100), 
                        y=seq(1, max(df$y_offset)+5, length.out = 100))
  bg_df$noise <- as.numeric(ambient::noise_perlin(c(100, 100)))
  
  ggplot() + 
    geom_raster(data = bg_df, aes(x, y,fill = noise), alpha = 0.5)+
    scale_fill_gradientn(colors =  c("white", "#FCF5E5"), guide = "none") +
    lapply(split(df, 1:nrow(df)), function(dat){
      geom_curve(data = dat,
                 aes(x = x + x_offset, y = y + y_offset, 
                     xend = xend + x_offset, yend = yend+ y_offset,
                     size = linewidth, color = color, linetype = linetype),
                 curvature = dat["curvature"],
                 lineend = "round") }) +
    scale_size_identity() + scale_color_identity() + scale_linetype_identity() +
    coord_fixed() + theme_void()
}


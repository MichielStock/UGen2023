n_rect <- 30
n_curves <- 5
for(seed in c(1:5, 2023, 20230120)){
  set.seed(seed)
  df <- data.frame(x = runif(n_rect),
                   y = rexp(n_rect),
                   fill = sample(c("#faf5f2", "#8c847f", "#45413f"), n_rect, replace = TRUE),
                   color = sample(c("#faf5f2", "#8c847f", "#45413f"), n_rect, replace = TRUE))
  
  df <- df[order(df$y),]
  df$size <- 0.1+rev(df$y)/10
  df_mirror <- df
  start_mirror <- max(df$x+df$size) * 1.1
  df_mirror$x <- start_mirror + (start_mirror - df$x)
  df <- rbind(df, df_mirror, df, df_mirror)
  df$x <- df$x + rep(c(0, start_mirror * 2.5), each = n_rect*2)
  
  df_curves <- df[sample(n_rect, n_curves),]
  df_curves$x <- df_curves$x - df_curves$size/2
  df_curves$start <- 0
  df_curves$end <- pi/2
  df_curves_mirror <- df_curves
  df_curves_mirror$x <- start_mirror + (start_mirror - df_curves$x)
  df_curves_mirror$end <- -pi/2
  df_curves <- rbind(df_curves, df_curves_mirror, df_curves, df_curves_mirror)
  df_curves$x <- df_curves$x + rep(c(0, start_mirror * 2.5), each = n_curves*2)
  
  ggplot(df) +
    geom_rect(xmin = min(df$x - df$size) - 1,
              ymin = min(-(df$y + df$size)) - 1,
              xmax = max(df$x + df$size) + 1,
              ymax = max(df$y) + 1,
              fill = "black") +
    geom_rect(aes(xmin = x-size/2, xmax = x+size/2,
                  ymin = (y), ymax = (y+size), 
                  fill = fill,
                  color = color)) +
    ggforce::geom_arc(aes(x0 = x, y0 = y, r = size*2/3,
                          start = start, end = end, color = color),
             data = df_curves) +
    ggforce::geom_arc(aes(x0 = x, y0 = y, r = size*2.5/3,
                          start = start, end = end, color = color),
                      data = df_curves, linewidth = 1) +
    ggforce::geom_arc(aes(x0 = x, y0 = y, r = size*1.5/3,
                          start = start, end = end, color = color),
                      data = df_curves, linewidth = 2) +
    scale_fill_identity() +
    scale_color_identity() +
    coord_fixed()+
    theme_void()
  
  ggsave(paste0("artdeco/artdeco_", seed, ".png"),
         width = 8, height = 6)
}
# ideas
#
# Soft pastel colors + bright oranges
# Cirkels, spirals, flowers
# Include some of the asemic text?
setwd("D:/Other/AdventOfCode2022/")
library(ggplot2)


seed <- 1
plots <- list()
for(seed in 1:3){

  inspiration <- jpeg::readJPEG("HilmaAfKlint_original.jpg")
  
  inspiration_uni <- inspiration
  dim(inspiration_uni) <- c(dim(inspiration)[1]*dim(inspiration)[2], dim(inspiration)[3])
  
  set.seed(seed)
  som <- FlowSOM:::SOM(inspiration_uni)
  som_counts <- as.numeric(table(som$mapping[,1]))
  som$codes
  
  library(ggplot2)
  to_plot <- data.frame(som$grid,
                        som$codes,
                        count = som_counts)
  colnames(to_plot) <- c("x", "y", "R", "G", "B", "count")
  ggplot(to_plot) +
    geom_point(aes(x, y, size = 100*count/max(som_counts), col = rgb(R, G, B))) +
    scale_size_identity() +
    scale_color_identity() +
    theme_void()
  
  colors <- rgb(som$codes[,1],som$codes[,2],som$codes[,3])
  
  
  set.seed(seed)
  circles <- data.frame(center_x = 10*runif(5),
                        center_y = 10*runif(5),
                        diameter = rnorm(5, mean = 5),
                        color = sample(colors, 5, prob = som_counts))
  
  circleFun <- function(center = c(0,0), diameter = 1, npoints = 100, color = "black"){
    r = diameter / 2
    tt <- seq(0,2*pi,length.out = npoints)
    xx <- center[1] + r * cos(tt)
    yy <- center[2] + r * sin(tt)
    return(data.frame(x = xx, y = yy))
  } # from stackoverflow
  
  dat <- lapply(seq(nrow(circles)), function(i) data.frame(circleFun(c(circles[i, "center_x"],
                                                                       circles[i, "center_y"]),
                                                                     circles[i, "diameter"], 
                                                                     npoints = 100),
                                                           id = i,
                                                           color = circles[i, "color"]))
  
  dat2 <- do.call(rbind, dat)
  dat2$x <- dat2$x + rnorm(nrow(dat2), sd = 0.01)
  dat2$y <- dat2$y + rnorm(nrow(dat2), sd = 0.01)
  
  
  source("asemic_functions.R")
  add_writing <- function(df, p){
    p + 
      lapply(split(df, 1:nrow(df)), function(dat){
        geom_curve(data = dat,
                   aes(x = x + x_offset, y = y + y_offset, 
                       xend = xend + x_offset, yend = yend+ y_offset,
                       size = linewidth, color = color, linetype = linetype),
                   curvature = dat["curvature"],
                   lineend = "round") }) +
      scale_size_identity() + scale_color_identity() + scale_linetype_identity()
  }
  
  set.seed(seed)
  characters <- getCharacters(20, 4, 0.9)
  text <- layout(characters[sample(20,7)], 1, 8, x_off = 2, y_off = 0)
  text$color <- sample(colors,1)
  text$x <- text$x * 0.5
  text$y <- text$y * 0.7
  text$xend <- text$xend * 0.5
  text$yend <- text$yend * 0.7
  text$x_offset <- (text$x_offset-1) * 0.5 + min(dat2$x)*0.9
  text$y_offset <- -2*sin(seq(0,pi/2,length.out = nrow(text))) + 2 + min(dat2$y)
  
  spirals <- lapply(seq_along(dat), function(i){
    dat_sub <- dat[[i]]
    dat_sub$x <- dat_sub$x - circles$center_x[i]
    dat_sub$y <- dat_sub$y - circles$center_y[i]
    dat_sub$x <- dat_sub$x * seq(1, 0, length.out = nrow(dat_sub))
    dat_sub$y <- dat_sub$y * seq(1, 0, length.out = nrow(dat_sub))
    dat_sub$x <- dat_sub$x + circles$center_x[i]
    dat_sub$y <- dat_sub$y + circles$center_y[i]
    dat_sub
  })
  
  flower_center <- list(x = 10*runif(2),
                     y = 10*runif(2))
  flower <- data.frame(x = rep(flower_center$x, each = 8),
                       y = rep(flower_center$y, each = 8),
                       xend = rep(flower_center$x, each = 8) + cos((0:7)*pi/4),
                       yend = rep(flower_center$x, each = 8) + sin((0:7)*pi/4),
                       color = rep(c("black","#F9C54A"), each = 8))
  flower_center <- list(x = 10*runif(2),
                        y = 10*runif(2))
  flower2 <- data.frame(x = rep(flower_center$x, each = 8),
                        y = rep(flower_center$y, each = 8),
                        xend = rep(flower_center$x, each = 8) + cos((0:7)*pi/4),
                        yend = rep(flower_center$y, each = 8) + sin((0:7)*pi/4),
                        color = rep(c("black","#F9C54A"), each = 8))
  
  bg_df <-  expand.grid(x=seq(min(flower[,1:4], dat2$x), 
                              max(flower[,1:4], dat2$x), 
                              length.out = 100), 
                        y=seq(min(flower[,1:4], dat2$y), 
                              max(flower[,1:4], dat2$y),
                              length.out = 100))
  bg_df$noise <- as.numeric(ambient::noise_perlin(c(100, 100)))
  
  p <- ggplot() + 
    geom_raster(data = bg_df, aes(x, y, fill = noise))+
    scale_fill_gradientn(colors =  c(colors[51], colors[81]), guide = "none")
  
  
  p <- p +
    ggnewscale::new_scale("fill") +
    geom_polygon(aes(x, y, group = id, fill = color), data = dat2, alpha = 0.8) +
    scale_fill_identity() +
    theme_void()
  
  p2 <- add_writing(text, p)
  
  p3 <- p2 + geom_path(aes(x, y, group = id, color = color), data = do.call(rbind, spirals),
                       linetype = "dashed")
  
  p4 <- p3 + 
    geom_curve(aes(x=x, y=y, xend = xend, yend = yend, color = color),
               data = rbind(flower, flower2)) +
    geom_curve(aes(x=x, y=y, xend = xend, yend = yend, color = color),
               data = rbind(flower, flower2),
               curvature = -0.5)
  p4
  
  plots[[seed]] <- p4
}
  
library(patchwork)
plots[[1]] + plots[[2]] + plots[[3]]
ggsave("HilmaAfKlint_R.png", width = 20, height = 10)

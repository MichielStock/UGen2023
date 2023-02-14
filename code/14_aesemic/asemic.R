seed_offset <- 2022
nPointsPerChar <- 4
curvature <- 0.8
for(seed_offset in c(1,42,2023,20230114)){
  for(nPointsPerChar in c(3,4,5)){
    for(curvature in c(0.5, 1)){
      name <- paste0("v3_",nPointsPerChar, "_", 100*curvature,"_",seed_offset)
      set.seed(seed_offset)
      
      print(paste0("Starting on ", name,".png"))
      characters <- getCharacters(20, nPointsPerChar, curvature)
      
      write(layout(characters, 4, 5, x_off = 3, y_off = 3.5))
      ggsave(paste0("asemic/alphabet_", name, ".png"),
             width = 10,
             height = 10, bg = "white")
      
      # 2 x 60 
      alphabet_row <- layout(characters, 1, 20, x_off = 3)
      alphabet_row$linetype <- "dotted"
      alphabet_row$linewidth <- 0.3
      
      # 5 + 12 * 2.5  x   5 + 20 * 2
      text_width <- 20
      text_height <- 22
      text_length <- text_width * text_height
      char_prob <- rexp(length(characters))
      text <- sample(seq_along(characters), text_length, replace = TRUE, 
                     prob = char_prob)
      text <- layout(characters[text], text_height, text_width)
      spaces <- sample(text_length, text_length/5)
      text$color[text$id %in% (spaces+1)] <- "#685369"
        text$curvature <- text$curvature * runif(nrow(text), min = 0.5, max = 1.5)
        text <- text[!text$id %in% spaces,]
        text$y_offset <- text$y_offset + 5
        text$x_offset <- text$x_offset + 5
        
        alpha <- layout(characters[c(3,2,1)],3,1)
        alpha$x_offset <- alpha$x_offset*3 + 52
        alpha$y_offset <-  alpha$y_offset*3 + 52
        alpha$x <- alpha$x * 3
        alpha$y <- alpha$y * 3
        alpha$xend <- alpha$xend * 3
        alpha$yend <- alpha$yend * 3
        alpha2 <- alpha
        alpha2$curvature <- alpha$curvature * 1.3
        alpha2$color <- "#68536922"
          alpha2$linetype <- "dotted"
          
          all <- rbind(alphabet_row, text, alpha2, alpha)
          write(all)
          
          ggsave(paste0("asemic/full_",name,".png"),
                 plot = write(all),
                 width = 10,
                 height = 10, bg = "white")
    }
  }
}
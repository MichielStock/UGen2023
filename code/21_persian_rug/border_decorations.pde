int artefact_height = 5;
int artefact_width = 5;
int artefact_double_width = 2*artefact_width-1;
color artefact_color = color(0 + random(40), 60 + random(60), 60 + random(60));
float true_probability = 0.1 + random(0.9);


void add_border_decorations(){
  //adds decorations outside of ribbon
  boolean[][] artefact = generate_artefact();
 for (int x = artefact_height; x < width/2; x+=artefact_double_width){
   add_artefact(artefact, x, 0, 0);
 }
 boolean[][]transposed_artefact = transposed_artefact(artefact);
 for (int y = artefact_height; y < height/2; y+=artefact_double_width){
   add_artefact(transposed_artefact, 0, y, 1);
 }
 
 //adds decorations inside of ribbon
 boolean[][] artefact2 = generate_artefact();
 for (int x = border_size; x < width/2; x+=artefact_double_width){
   add_artefact(artefact2, x, border_size, 0);
 }
 boolean[][]transposed_artefact2 = transposed_artefact(artefact2);
 for (int y = border_size; y < height/2; y+=artefact_double_width){
   add_artefact(transposed_artefact2, border_size, y, 1);
 }
}

boolean[][] generate_artefact(){
  boolean[][] artefact = new boolean[artefact_width][artefact_height];
  for (int i = 0; i < artefact_width; i++){
    for (int j = 0; j < artefact_height; j++){
      //for each element in the artefact, set to true with probability true_probability
      artefact[i][j] = (random(1)<=true_probability);
    }
  }
  return artefact;
}

void add_artefact(boolean[][] artefact, int x0, int y0, int rotation){
  loadPixels();
  for (int i = 0; i < artefact_width; i++){
    for (int j = 0; j < artefact_height; j++){
      //add artefact regularly, then add mirrored artefact next to it, with overlap in the last pixels
      if (artefact[i][j]){
        pixels[loc(x0+i, y0 + j)] = artefact_color;
        //horizontal line
        if (rotation == 0){
          int x_pixel = x0+artefact_double_width - i -  1;
          int y_pixel = y0+j;
          pixels[loc(x_pixel,y_pixel)] = artefact_color;
        }
        //vertical line
        else pixels[loc(x0 + i,y0 + artefact_double_width - j - 1)] = artefact_color;
      }
    }
  }
  updatePixels();
}

boolean[][] transposed_artefact(boolean[][] artefact){
  int row = artefact.length;
  int column = artefact[0].length;
  boolean[][] transpose = new boolean[column][row];
        for(int i = 0; i < row; i++) {
            for (int j = 0; j < column; j++) {
                transpose[j][i] = artefact[i][j];
            }
        }
  return transpose;
}

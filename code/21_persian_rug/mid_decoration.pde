int y_bigdeco_top = 10000;
int x_bigdeco_left = 0;
int midsection_width; //<>//
int midsection_height;
color mid_color = color(150 + random(100),100 + random(80),random(100)); 

void add_midsection_decorations(){
  loadPixels();
  midsection_width = width - 2*border_size;
  midsection_height = height/2 - 2*border_size;
 int start_x = border_size + round(midsection_width*0.2);
 x_bigdeco_left = start_x;
 add_big_deco(start_x, mid_color); 
 add_big_deco(border_size + floor(midsection_width*0.3), color(random(50), random(50), 40 + random(60))); //<>//
 updatePixels(); //<>//
 loadPixels();
 add_side_deco();
 updatePixels();
}

void add_big_deco(int start_x, color c){
  int x = start_x;
  
  int y_top = height/2;
  while (x < width/2){
    for (int y = y_top; y < height/2; y++){
      pixels[loc(x,y)] = c;
    }
    y_top -= -2 + floor(random(4));
    x++;
  }
 y_bigdeco_top = min(y_top, y_bigdeco_top);
}

void add_side_deco(){
  //add top deco
  int x_min = width/2-1;
  for (int y = border_size; y <= (border_size + y_bigdeco_top)/2; y++){ //<>//
    for (int x = x_min; x < width/2; x++){
      pixels[loc(x,y)] = mid_color;
      pixels[loc(x, y_bigdeco_top-y+border_size)] = mid_color;
    }
    x_min -= round(0.5 + 1.7*randomGaussian());
  }
  //add side deco
  int y_min = height/2-1;
  for (int x = border_size; x < (border_size + x_bigdeco_left)/2; x++){ //<>//
    for (int y = y_min; y < height/2; y++){
      pixels[loc(x,y)] = mid_color;
      pixels[loc(x_bigdeco_left-x + border_size, y)] = mid_color;
    }
    y_min -= round(0.5+1.7*randomGaussian());
  }
}

color background_color = color(104, 9, 14);
color ribbon_color = color(60 + random(100), 60 + random(100), 20 + random(100));
int border_size = 8;


//first draw top left quarter, then mirror into other quadrants
void setup(){
  //border width = 6, big square = 60 x 120 => 72 x 132
 size(86, 126);
 background(background_color);
 add_ribbon(ribbon_color);
 add_border_decorations();
 add_midsection_decorations();
 
 mirror_to_other_quadrants(); //<>//
 save("rugs/rug3.png");
}

void draw(){
  ribbon_color = color(160 + random(90), 160 + random(40), 20 + random(20));
  artefact_height = 2 + floor(random(5));
  artefact_width = artefact_height;
  border_size = artefact_height + 1 + floor(random(5));
  artefact_double_width = 2*artefact_width-1;
  artefact_color = color(0 + random(40), 60 + random(60), 60 + random(60));
  
  mid_color = color(50 + random(200),50 + random(200),random(200)); 
  
  true_probability = 0.1 + random(0.9);
  
  if (random(1) <= 0.3){
    clear_all();
  }
  
  add_ribbon(ribbon_color);
 add_border_decorations();
 add_midsection_decorations();
 
 mirror_to_other_quadrants();
 saveFrame("rugs/rug-####.png");

}

void add_ribbon(color ribbon_color){
  int ribbon_thickness = border_size - artefact_height;
  //top-right corner
  int x1 =  border_size - ribbon_thickness;
  int y1 = border_size - ribbon_thickness;
  int x2 = width - border_size;
  int y2 = height - border_size;
  noStroke();
  fill(ribbon_color);
  //left vertical part
  rect(x1,y1, ribbon_thickness, y2-y1 + ribbon_thickness);
  //upper horizontal part
  rect(x1,y1, x2 - x1 + ribbon_thickness, ribbon_thickness);
}

void mirror_to_other_quadrants(){
 loadPixels();
 for (int x = 0; x < width/2; x++){
   for (int y = 0; y < height/2; y++){
     int original_loc = loc(x, y);
     int x2 = width - x-1;
     int y2 = height - y-1;
     //mirror to bottom left
     pixels[loc(x, y2)] = pixels[original_loc];
     //mirror to top right
     pixels[loc(x2, y)] = pixels[original_loc];
     // mirror to bottom right
     pixels[loc(x2, y2)] = pixels[original_loc];       
   }
 }
 updatePixels();
}

void clear_all(){
  loadPixels();
  for (int x = 0; x < width/2; x++){
   for (int y = 0; y < height/2; y++){
     pixels[loc(x,y)] = background_color;
   }
  }
  updatePixels();
  
}

int loc(int x, int y){
  return x + y * width; //<>//
}

float[] distribution = new float[360];
color color1 = color(floor(random(100)), floor(random(100)), floor(random(100)));
  color color2 = color(50+floor(random(100)), 50+floor(random(100)), 50+floor(random(100)));
  color color3 = color(50+floor(random(100)), 50+floor(random(100)), 50+floor(random(100)));
  
color[] base_colors = {color1, color2, color3};
float base_rotation = random(2*PI);


void setup() {
  size(800, 800);
  background(222, 222, 180);
  
  add_dirtyness();
  draw_circle();
  int amount_triangles_dir1 = round(abs(10*randomGaussian()) + 2);
  for (int i = 0; i < amount_triangles_dir1; i++){
   draw_rectangle(); 
  }
  add_dirtyness();
  String savename = "Suprematism" + round(random(10000)) + ".png"; 
  save(savename);
}

void draw() {  
  
}

void add_dirtyness(){
  float dirt_factor = 10;
  loadPixels();
  
  
  for (int i = 0; i < width*height; i++){
   pixels[i] = color(pixels[i]) + color(dirt_factor*randomGaussian(), dirt_factor*randomGaussian(), dirt_factor*randomGaussian());
  }  
  updatePixels();
}


void draw_rectangle(){
 int offset = 100;
 float rect_width = 10+floor(random(width/10));
 float rect_height = (1+random(5))*rect_width;
 float top_left_x = width/2 + (width - rect_width -offset)/4*randomGaussian();
 float top_left_y = height/2 + (height - rect_height -offset)/4*randomGaussian();
 
 pushMatrix();
 translate(top_left_x, top_left_y);
 rotate(base_rotation);
 fill(base_colors[floor(random(3))]);
 if (random(10)<9){
   rect(0, 0, rect_width, rect_height);
 }
 else{
   fill(222, 100, 50);
   rect(0, 0, rect_height, rect_width);
 }
 popMatrix();
}

void draw_circle(){
 color circ_color = color(100+floor(random(100)), 100+floor(random(100)), 100+floor(random(100)));
 float radius = width/10 + random(width/3);
 float centre_x = radius + random(width - 2*radius);
 float centre_y = radius + random(height - 2*radius);;
 fill(circ_color);
 circle(centre_x, centre_y, radius);
}

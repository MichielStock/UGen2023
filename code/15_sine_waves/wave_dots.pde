float theta = 0.0;  // Start angle at 0
float amplitude = 75.0;  // Height of wave
float period = 500.0;  // How many pixels before the wave repeats

class Wave_dot{
  int x;
  float y;
  float y_base;
  int last_colision;
  
  Wave_dot(int x){
   this.x = x;
  }
  
  void update_y(){
   y_base =  sin(x*dx+theta)*amplitude;
   float delta_y_collisions = calculate_collision_y();
   //delta_y = sin(t-delay-pi)/(t-delay-pi)*exp(-delta_x)
   y = y_base + delta_y_collisions + height/2;
  }
  
  float calculate_collision_y(){
    //delta_y = sin(t-delay-pi)/(t-delay-pi)*exp(-|delta_x|)
    float dy = 0;
    float delay_per_x = 5;
    float t = theta - last_colision;
    
    for (int i = 0; i < wavelist.length; i++){
      int delta_x = abs(x-i);
      dy += sin(t - delta_x*delay_per_x - PI)*exp(-delta_x);
    }
    return dy;
  }
  
  
  void render(){
    noStroke();
    fill(255);
    // A simple way to draw the wave with an ellipse at each location
    ellipse(x*xspacing, y, dropsize, dropsize);
  }
  
}

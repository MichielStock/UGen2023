class Drop{
  float y = 0;
  int x = floor(random(wavelist.length));
  int yspeed = 0;
  boolean collided = false;
  int acceleration = 1;
  int collision_frame = -1;
  
  void update_position(){
    if (collided == false){
      yspeed += 1;
      y += yspeed;
    }
    else{
     float t = ((frameCount-collision_frame)-3.14)*dx;
     y = amplitude/2*sin(t)/t + height/2;
    }
  }
  
  void update_acceleration(){
  
  }
  
  void render(){
    noStroke();
    fill(50, 50, 200);
     ellipse(x*xspacing, y, dropsize, dropsize);
  }
  
  void update_all_and_render(){
    collides_with_wave();
    this.update_position();
    this.render();
  }
  
  void collides_with_wave(){
    if (y >= wavelist[x].y - dropsize && collided == false){ //<>//
     collided = true;  //<>//
     collision_frame = frameCount;
    }
  }
}

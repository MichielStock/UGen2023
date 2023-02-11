int rippling_animation_duration = 20;
int pushing_animation_duration = 4;
float pushing_depth_per_step = 1.05;


void push_down(PImage img){
  
  img.resize(floor(img.width/pushing_depth_per_step), floor(img.height/pushing_depth_per_step));
}

void pull_up(PImage img){
  img.resize(ceil(img.width*pushing_depth_per_step),ceil(img.height*pushing_depth_per_step));
}

void do_pushing_animation(){
  if (frameCount-clicked_frame <= pushing_animation_duration/2){ 
    
    push_down(coupure_img_copy);
  }
  else if (frameCount - clicked_frame <= pushing_animation_duration){
    pull_up(coupure_img_copy);
  }
  
  else{
    coupure_img_copy = coupure_img.copy();
    place_image(coupure_img_copy);
  }
}


void do_ripple_effect(){
  int amount_of_waves = 6;
  
  if (frameCount-clicked_frame <= rippling_animation_duration){
    draw_sdf(floor((frameCount-clicked_frame)*3.14*2/rippling_animation_duration*amount_of_waves));
  }
  else{
    animate_pushing = false;
  }
}

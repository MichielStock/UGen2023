

int get_ymin(int x) {
  for (int y = 0; y < height; y++){
      int loc = x + y * width;
      if (pixels[loc] != color(0)){
            return y;
      }
   }
   return 0;
}

void set_ymin() {
  loadPixels();
  
  //gives the start and end x- coordinate of the coupure figure on the canvas
  int x_start = (width - coupure_img.width)/2;
  int x_end = (width + coupure_img.width)/2-1;
  for (int x = 0; x < x_start; x++){
     ymin_array[x] = get_ymin(x_start);
  }
  for (int x = x_start; x < x_end; x++){
      ymin_array[x] = get_ymin(x);
  }
  for (int x = x_end; x < width; x++){
      ymin_array[x] = get_ymin(x_end);
  }
  for (int x = x_start + 460; x < x_start + 470; x++){
    ymin_array[x] = ymin_array[x_start + 450];
  }
  for (int x = x_start + 696; x < x_start + 710; x++){
    ymin_array[x] = ymin_array[x_start + 720];
  }
  for (int x = x_start + 470; x < x_start + 698; x++){
    ymin_array[x] -= 0;
  }
}


float signed_distance(int x, int y){
  // Gives the edges of the coupure figure
 int xmin = (width - coupure_img.width)/2;
 int xmax = (width + coupure_img.width)/2;
 
 int ymax = (height + coupure_img.height)/2;
 
 // Calculates signed distance functions 
 float[] dlist = new float[4];
 dlist[0] = sqrt( sq( max(xmin-x,0) ) + sq( max(y-ymax,0) ) );
 dlist[1] = sqrt( sq( max(x-xmax,0) ) + sq( max(y-ymax,0) ) );
 dlist[2] = calculate_top_distance(x,y);
 if (x >= xmax) {
   dlist[3] = sqrt( sq( max(x-xmax,0) ) + sq( max(ymin_array[width-1] - y,0) ) );
 }
 else dlist[3] = 0;
 //float top_distance = calculate_top_distance();
 
 //return dlist[2];
 //return max(dlist[3], dlist[2]);
 return max(dlist);
}

float calculate_top_distance(int x, int y){
  int xmin = (width - coupure_img.width)/2;
  int xmax = (width + coupure_img.width)/2;
  int ytop = (height - coupure_img.height)/2;
  int ymin = ymin_array[x];
  
  float[] dlist = new float[4];
  
  int xstop1 = 145+xmin;
  int ystop1 = ymin_array[xstop1];
  
  int xpoi1 = 165 + xmin;
  int ypoi1 = ymin_array[xpoi1];
  int xpoi2 = 470 + xmin;
  int ypoi2 = ymin_array[xpoi2];
  
  int xpoi3 = 695 + xmin;
  int ypoi3 = ymin_array[xpoi3];
  
 
  
  // convergention to right side of box 2
  
  dlist[2] = 0;
  // convergention to left side of box 3
  
  dlist[3] = sqrt( sq(xpoi2-x) + sq( min(0, ypoi2-y) ) );
  
  
   
  //Zone 1
  if (x < xstop1) {
    return sqrt( sq( max(xmin-x,0) ) + sq( max(ymin-y,0) ) );
  }
  //Zone 2
  float intercept_line1 = 316 + ytop +2*xmin;
  float intercept_line2 = 370 + 2*xmin + ytop;

  if (x < (intercept_line1-y)/(2)){
    float d1 = sqrt( sq( max(x - xstop1,0) ) + sq( max(ystop1-y, 0)) );
    float d2 = max(ymin - y,0);
    return min(d1, d2);
  }
  //Zone 3
  if (x < (intercept_line2-y)/(2)){
    float d1 = max(distance_point_line(0.5, ypoi1-xpoi1/2, x,y), 0);
    float d2 = max(ymin - y,0);
    float d3 = sqrt( sq(xpoi2 - x) + sq( max(0, ypoi2-y) ) );
    return min(d1, d2, d3);  
    //return d2;
    //return 9999;
  }
  // Zone 4
  if (x < xpoi2){
    float[] di= new float[4];
    // how far from POI1 or right side of box 2
    di[0] = sqrt( sq(x-xpoi1) + sq( max(0, ypoi1 - y) ) );
    // How far from box 1 //<>//
    di[1] = max(ymin - y,0); //<>//
    // How far from POI 2 or box 3
    di[2] = sqrt( sq(xpoi2 - x) + sq( max(0, ypoi2-y) ) );
    
    di[3] = distance_point_line(0.5, ypoi1-xpoi1/2, x,y);
    di[3] = 999;

    return min(di);
    //return di[1];
    //return 0;
  }
  // Zone 5
  if (x < xpoi3){
    donothing(ypoi3);
    return max(0, ymin - y);
  }
  // Zone 6
  float d1 = sqrt( sq( x - xpoi3) + sq( max(0, ypoi3 - y)));
  float d2 = max(ymin - y, 0);
  float d3 = max(0, x - xpoi3);
  d3 = 99999;
  return min(d1,d2, d3);
}

// distance to line given by y=a*x+b
float distance_point_line(float a, float b, int x, int y){
  return abs((y-a*x-b)/sqrt(sq(a) + sq(1)));
}

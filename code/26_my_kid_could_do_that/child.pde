PImage brush;
PImage buffer;
PImage mask;


void setup() {
    size(1000, 800);
    background(220, 220, 200);
    
    buffer = createImage(width, height, RGB);

    int r = 6;
    mask = createImage(2*r, 2*r, ALPHA);
    brush = createImage(2*r, 2*r, ARGB);
    ellipseMode(RADIUS);
    
    noStroke();
    fill(210, 80, 120);
    generateBrush(r);
    drawCycloid(0, 720, 30, 0.001);

    fill(23, 61, 240);
    generateBrush(r);
    drawLoops(0, 80, 30, 32, 0.01, 0.001, 1.5e-12);

    fill(220, 115, 50);
    generateBrush(r);
    drawTeeth(0, 560, 0.01, 1, 40);
    
    fill(115, 190, 50);
    generateBrush(r);
    drawWave(0, 240, 0.01, 0.1, 40, 8e-5);
    

    fill(80, 190, 200);
    generateBrush(r);
    drawLine(0, 400, 0.01, 1e-14);
}

void drawLoops(float x, float y, float a1, float a2, float b, float f, float r) {

    for (float t = 0.; b*t - a1 < width; t += 64) {
        image(brush, (x + b*t + a1*cos(f*t - 0.5*PI)), (y + a2*sin(f*t - 0.5*PI) + r*t*t*t)%height);
    }

}

void drawTeeth(float x0, float y0, float b, float dy, float a) {
    float y = y0;
    for (float t = 0.; b*t < width; t += 20) {
        if (abs(y - y0) > a) {
            dy *= -1;
            if (b*t > 200) {
                dy *= 1.05;
                a *= 1.1;
            }
        }
        y += dy;
        image(brush, (x0 + b*t)%width, y%height);
    }
}

void drawCycloid(float x0, float y0, float a, float f) {
    float a2 = a;
    for (float t = 0.; a2*f*t - a2 < width; t += 64) {
        a2 = max(3, a2*0.999);
        image(brush, (x0 + a2*(f*t - sin(f*t))), (y0 - a*(1-cos(f*t)))%height);
    }
}

void drawLine(float x0, float y0, float b, float a) {
    float y = y0;
    float dy = 0;
    for (float t = 0.; b*t < width; t += 50) {
        // dy = min(1.5, max(-1.5, dy + a*t*t*t*(random(1) - 0.5)));
        dy = dy + a*t*t*t*(random(1) - 0.5);
        y += dy;
        image(brush, (x0 + b*t)%width , y%height);
    }
}

void drawWave(float x0, float y0, float b, float f, float a1, float a2) {
    float f2 = 2*f;
    float f3 = 3*f;
    float f4 = 4*f;
    for (float t = 0.; b*t < width; t += 8) {
        f2 += 0.002*f*(random(1)-0.5);
        f3 += 0.003*f*(random(1)-0.5);
        f4 += 0.004*f*(random(1)-0.5);
        float w = a1*sin(f*b*t) + a2*t*sin(f2*b*t) + a2*a2*t*t*sin(f3*b*t) + a2*a2*a2*t*t*t*sin(f4*b*t);
        image(brush, (x0 + b*t)%width , (y0 + w)%height);
    }
}

void generateMask() {
    mask.loadPixels();
    int r = mask.width/2;
    for (int i = 0; i < mask.width*mask.height; i++) {
        int x = i % mask.width - r;
        int y = i / mask.width - r;
        float rad_diff = float(x*x + y*y)/float(r*r);
        if (rad_diff > 1) {
            mask.pixels[i] = 0;
        } else {
            mask.pixels[i] = max(0, min(160, int(160*(pow(1 - rad_diff, 4)*(1 + 0.5*(random(1) - 0.5))))));
        }
    }
    mask.updatePixels();
}

void generateBrush(int r) {
    generateMask();
    buffer.copy(g, 0, 0, width, height, 0, 0, width, height);

    circle(r, r, r);
    brush.copy(g, 0, 0, 2*r, 2*r, 0, 0, 2*r, 2*r);
    brush.mask(mask);
    image(buffer, 0, 0);
}
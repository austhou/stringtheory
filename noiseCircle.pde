import ddf.minim.analysis.*;
import ddf.minim.*;
//import processing.sound.*;
 
 
float translateJitter = 0;
float transX = 400;
float transY = 400;
float petalMod = 3; //square=1
float temp;

float aMod = PI/4;
float tPeriod;
 
Minim minim;
AudioPlayer jingle;
AudioInput input;
FFT fft;
int size = 512;
float[] samps = new float[size];

float resolution = 10; // how many points in the circle, default 400
float rad = 150;
float x = 1;
float y = 1;
//float prevX;
//float prevY;

float t = 0; // time passed
float tChange = .002; // how quick time flies

float nVal; // noise value
float nInt = 1; // noise intensity
float nAmp = 1; // noise amplitude
float nAmp2 = 1; // noise amplitude

boolean filled = false;

float[] xArr = new float[]{300,500,200,400,600,200,400,600,200,400,600};
float[] yArr = new float[]{400,400,200,200,200,400,400,400,600,600,600};
int ti;
int tn = 2;

void setup() {
  background(0);
  size(800, 800);
  //pg = createGraphics(800, 800);
  noiseDetail(8);
  
  //setup sound
  minim = new Minim(this);
  input = minim.getLineIn();
  fft = new FFT(input.bufferSize(), input.sampleRate());
}

void draw() {
  for(int i = 0; i < size; i++) {
    samps[i] = fft.getBand(i)/50+.001;
  }
  float mean = avmean(samps, size);
  float pitch = wtmean(samps, size);
  float varc = variance(samps, size, mean);
  
  
  if (filled) {
    fill(255,25);
  }
  else {
    fill(0, 55);
  }
  rect(-1,-1,width+1,height+1);
  
  float tx = map(random(varc), 0, .5, 0,200);
  float ty = map(random(varc), 0, .5, 0,200);
  int sx = (int) random(-2,2);
  int sy = (int) random(-2,2);
  
  transX = xArr[ti];
  transY = yArr[ti];
  ti = (ti + 1) % tn;
  
  
  
  fft.forward(input.mix);
  


  if (filled) {
    //noStroke();
    noFill();
    
    stroke(0);
    strokeWeight(1);
  } 
  else {
    noFill();
    stroke(255);
    strokeWeight(6);
  }
  nInt = map(mouseX, 0, width, 5, 0.1); // map mouseX to noise intensity
  nAmp = map(pitch, 0, .5, .6, 0.5); // map mouseY to noise amplitude
  
  nAmp2 = map(pitch, 0, .5, 1.0, 0.5); // map mouseY to noise amplitude
  
   // map mouseX to noise intensity
  //println(nInt);
  if (ti % 2 == 0) {
    translate(transX+100*nAmp+translateJitter*sx*tx,transY+translateJitter*sy*ty);
  }
  else {
    translate(transX-100*nAmp+translateJitter*sx*tx,transY+translateJitter*sy*ty);
  }

  beginShape();
  for (float a=t; a<=4*TWO_PI+t; a+=TWO_PI/resolution) {
    
    tPeriod = map(cos(t*TWO_PI/4), -1,1,5,0.1);
    nInt = tPeriod;
    temp = map(nAmp2, 0,.5, 0.8,1);

    nVal = map(noise(cos(a+aMod)*nInt+1, sin(a+aMod)*nInt+1, t ), 0.0, 1.0, nAmp, 1.0); // map noise value to match the amplitude
    

    x = (cos(a+aMod)*temp + (1-temp)*cos(petalMod*a+aMod)*cos(a+aMod))*rad *nVal;
    y = (sin(a+aMod)*temp + (1-temp)*sin(petalMod*a+aMod)*sin(a+aMod))*rad *nVal;
    
    //parabola
    //x = cos(a+aMod)*temp/((1-temp)*(1+cos(a+aMod)))*rad *nVal;
    //y = sin(a+aMod)*temp/((1-temp)*(1+cos(a+aMod)))*rad *nVal;
    
    //spiral
    //x = cos(a+aMod)*temp*(temp+(1-2*temp)*(a+aMod))*rad *nVal;
    //y = sin(a+aMod)*temp*(temp+(1-2*temp)*(a+aMod))*rad *nVal;

    //    x = map(a, 0,TWO_PI, 0,width);
    //    y = sin(a)*rad *nVal +height/2;

    //    vertex(prevX, prevY);
    vertex(x, y);

    //    line(x,y,x,height);

//    prevX = x;
//    prevY = y;
    
    }
  endShape(CLOSE);

  t += tChange;
  
  petalMod = (petalMod + tChange/3) % 4 + 1; 
}

void mouseClicked() { 
  filled = !filled; // toggle fill by click
}

float avmean(float a[], int n) {
  float sum = 0;
  for (int i = 0; i < n; i++)
    sum += a[i];
  float mean = sum / n;
  return mean;
}

float wtmean(float a[], int n) {
  float sum = 0;
  for (int i = 0; i < n; i++)
    sum += i*a[i];
  float mean = sum / n;
  return mean;
}

float variance(float a[], int n, float mean)
{
    // Compute sum squared 
    // differences with mean.
    float sqDiff = 0;
    for (int i = 0; i < n; i++) 
        sqDiff += (a[i] - mean) * 
                  (a[i] - mean);
    return sqDiff / n;
}

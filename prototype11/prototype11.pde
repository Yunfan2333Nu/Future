/*
  Future
  Version: prototype11
  Author: Yunfan
  Date: 2019.12.28-2019.12.29
  Hardware: leap motion, arduino Romeo
  Software: Processing, Arduino

  6 set of dots mapped to 6 alphabets
  dots' height relate to music or sound from the microphone
  dots' color realte to their x position range from 0 to setWidth 
  when hands or mouse move, a half-tranparent white triangle follows
  data are sent to Arduino each time the status change

*/

// ===============================================
//           SETTINGS & VARIABLES
// ===============================================
// general settings
int setWidth = 1920;  // TODO
int setHeight = 1200;  // TODO
int nRail = 6;
int railWidth = setWidth / nRail;
PImage img_future;
int[] status = {0,0,0,0,0,0};  // status of 6 rails



// sound settings
import processing.sound.*;
AudioIn mic;
Amplitude amp;

// music settings
import ddf.minim.*;
import ddf.minim.analysis.*;

// Music objects
Minim minim;
AudioPlayer[] player;



// moving dots
int num = 500;// The num of points  // TODO
float mts = PI/64;  // max theta speed
float r = 100;  // radius of the circle;
int rdtr = 80;  // rage of the rdt
int rdu = 8;  // radius of circle

PVector v[][] = new PVector[nRail][num];
boolean mv[] = {false,false,false,false,false,false};
boolean mo[] = {true,true,true,true,true,true};
color c[][] = new color[nRail][num];  // color of each points
float theta[][] = new float[nRail][num];  //original angle of each point
float mtheta[][] = new float[nRail][num];  // translate angle of each point
float dtheta[][] = new float[nRail][num];// speed of theta
float easing[][] = new float[nRail][num];  // the velocity towards the center
int rdt[][] = new int[nRail][num];  // make a shuffle of radius

// Color Settings
int R_min=50;
int R_max=100;
int G_min=50;
int G_max=150;
int B_min=150;
int B_max=255;

int[] ColorSets;
int[] BLUE = {R_min,R_max,G_min,G_max,B_min,B_max};
int[] RED = {155,255,100,150,50,100};
int[] PURPLE = {150,200,50,150,150,250};




// *********************************************************
//          middle layer
// *********************************************************
float getDistance(float x1,float y1,float x2,float y2){
  float distance = sqrt((x1-x2)*(x1-x2)+(y1-y2)*(y1-y2));
  return distance;
}

void loadMiddleLayer(){
  ColorSets = PURPLE; //  Test
  
  for(int n=0;n<nRail;n++){
    for(int i = 0; i < num-1; i++)
    {
      c[n][i] = color(random(ColorSets[0],ColorSets[1]),random(ColorSets[2],ColorSets[3]),random(ColorSets[4],ColorSets[5]));  // randomly build color
      v[n][i] = new PVector(random(width),random(height));
      theta[n][i] = round(random(360));
      dtheta[n][i] = random(mts);
      mtheta[n][i] = theta[n][i]/180*PI;
      rdt[n][i] = round(random(-rdtr, rdtr));  // range of rdt
      easing[n][i] = random(0.02,0.2);
    }      
  }
}

void setMiddleLayer(){
  //  float diameter = 
  r = map(amp.analyze(),0,0.1,100,width)*2;
  
  // Set color priginal
  //ColorSets = BLUE; 
  //for(int n=0;n<nRail;n++){
  //  for(int i=0;i<num-1;i++){
  //    c[n][i] = color(random(ColorSets[0],ColorSets[1]),random(ColorSets[2],ColorSets[3]),random(ColorSets[4],ColorSets[5]));  // randomly build color
  //  }    
  //}
  
  // set background color (a rectangle)
  fill(0,0,0,80);  // transparency effect the tail trace
  rect(0,0,width,height);
  
 
  for(int n=0;n<nRail;n++){
    pushMatrix();
    noStroke();    

    if(mv[n]){
      for(int i=0;i<num-1;i++){
        v[n][i].lerp(random(n*railWidth+railWidth/2-300,n*railWidth+railWidth/2+300),900-(sin(mtheta[n][i])+1)*(rdt[n][i]+r),0,easing[n][i]);  // range of x, range of y, 0, easing
  //      fill(c[i]);
        int transparency = 180;
        if(getDistance(v[n][i].x,v[n][i].y,mouseX,mouseY) < 100){
          transparency = 255;
        }
        // two color mode(pink - purple blue)
        // fill(map(v[n][i].x,0,setWidth,255,0),random(ColorSets[2],ColorSets[3]),random(ColorSets[4],ColorSets[5]),transparency);
        
        // three color mode
        if(v[n][i].x < setWidth/2){
          fill(map(v[n][i].x,0,setWidth/2,255,230),map(v[n][i].x,0,setWidth/2,172,121),map(v[n][i].x,0,setWidth/2,100,208),transparency);  
        }
        else{
          fill(map(v[n][i].x,setWidth/2,setWidth,230,75),map(v[n][i].x,setWidth/2,setWidth,121,192),map(v[n][i].x,0,setWidth/2,208,230),transparency);
        }        
        ellipse(v[n][i].x,v[n][i].y,rdu,rdu);
      }    
    }
    if(!mv[n]){
      for(int i=0;i<num-1;i++){
        v[n][i].lerp(n*railWidth+railWidth/2+cos(mtheta[n][i])*rdt[n][i], 900+sin(mtheta[n][i])*rdt[n][i]+random(-100,0),0,easing[n][i]);
        
        // fill(c[i]);
        // fill(map(v[n][i].x,0,1920,255,0),random(ColorSets[2],ColorSets[3]),random(ColorSets[4],ColorSets[5]),80);
        // three color mode
        if(v[n][i].x < setWidth/2){
          fill(map(v[n][i].x,0,setWidth/2,255,230),map(v[n][i].x,0,setWidth/2,172,121),map(v[n][i].x,0,setWidth/2,100,208));  
        }
        else{
          fill(map(v[n][i].x,setWidth/2,setWidth,230,75),map(v[n][i].x,setWidth/2,setWidth,121,192),map(v[n][i].x,0,setWidth/2,208,230));
        }           
        
        ellipse(v[n][i].x,v[n][i].y,rdu,rdu);      
      }
    }
    popMatrix();  
  }
}




// *********************************************************
//          top layer
//              future1.png
// *********************************************************
// load background image "future1.png"
void loadFuture(){
  img_future = loadImage("future1.png");
}

void setTopLayer(){
  image(img_future,0,0);
}





// *********************************************************
//          topmost layer 
//                cursor highlight and light on music node 
// *********************************************************
// if stauts[i] == 1
// give a highlight according to its position
void setTopmostLayer(){
  for(int n=0;n<nRail;n++){
    if(status[n] == 1){
      
      // three color mode
      float posX = n*railWidth+0.5*railWidth;
      if(posX < setWidth/2){
        fill(map(posX,0,setWidth/2,255,230),map(posX,0,setWidth/2,172,121),map(posX,0,setWidth/2,100,208));  
      }
      else{
        fill(map(posX,setWidth/2,setWidth,230,75),map(posX,setWidth/2,setWidth,121,192),map(posX,0,setWidth/2,208,230));
      }      
      
      ellipse(n*railWidth+railWidth*0.5,950,120,150);
    }
  }
}



// *********************************************************
//        Sound Control
// *********************************************************
void loadMic(){
  mic = new AudioIn(this,1);
  mic.start();
  amp = new Amplitude(this);
  amp.input(mic);  
}

void loadMusic(){
  minim = new Minim(this);
  player = new AudioPlayer[6];
  
  for(int i=0;i<nRail;i++){
    player[i] = minim.loadFile("Future"+i+".mp3",1024);
  }
}

void playMusic(){  // according to the array status[nRail]
// how to minimize delay
  for(int i=0;i<status.length;i++){
    
    if(player[i].position() % player[i].length() == 0 ){
      if(status[i] == 1){
        player[i].rewind();
        player[i].play();
      }
      else if(status[i] == 0){
        player[i].pause();
        player[i].rewind();
      }
      else{
        ;
      }
    }

    //if(status[i] == 1){
    //  player[i].loop();
    //}
    //if(status[i] == 0){
    //  player[i].pause();
    //  player[i].rewind();
    //}
  }
  
}

// 10'69"
void playMusic_10(){
  if(status[0] == 1){
    player[0].loop();
    println(0 +" playing");
    mv[0] = true;
  }
  else{
    player[0].pause();
    player[0].rewind();
    println(0 +" stops");
  }
  if(status[1] == 1){
    player[1].loop();
    println(1 +" playing");
    mv[1]=true;
  }
  else{
    player[1].pause();
    player[1].rewind();
    println(1 +" stops");
  }  
  if(status[3] ==1){
    player[3].loop();
    println(3 +" playing");
    mv[3] = true;
  }
  else{
    player[3].pause();
    player[3].rewind();
    println(3 +" stops");
  }  
  if(status[4] == 1){
    player[4].loop();
    println(4 +" playing");
    mv[4]=true;
  }
  else{
    player[4].pause();
    player[4].rewind();
    println(4 +" stops");
  }  
}

// 5'354"
void playMusic_5(){
  if(status[2] == 1){
    player[2].loop();
    println(2 +" playing");
    mv[2]=true;
  }
  else{
    player[2].pause();
    player[2].rewind();
    println(2 +" stops");
  }
}

// 2'672"
void playMusic_2(){
  if(status[5] == 1){
    player[5].loop();
    println(5 +" playing");
    mv[5] = true;
  }
  else{
    player[5].pause();
    player[5].rewind();
    println(5 +" stops");
  }
}



// *********************************************************
//        Mouse Control(test mode)
// *********************************************************
void mousePressed()
{
  //mv[findSeq()] = !mv[findSeq()];  //TODO
  status[findSeq()] = 1 - status[findSeq()];
  if(mv[findSeq()] == true){
    mv[findSeq()] = false;
  }
  // sendDataToArduino();  // TODO
}


int findSeq(){
  int seq = mouseX/(setWidth / nRail);
  if(seq < 0)  seq = 0;
  if(seq > 5)  seq = 5;
  return seq;
}

int findSeq(int positionX){
  int seq = positionX / (setWidth / nRail);
  if(seq < 0)  seq = 0;
  if(seq > 5)  seq = 5;
  return seq;
}

void mousePositionIndicate(){
  fill(128,50);
  //rect(mouseX,0,70,setHeight);
  ellipse(mouseX,mouseY,80,80);
}

// mouse tracing settings
int m_num =300;
float m_mts = PI/64;
float m_r = 60;
int m_rdtr = 40;
int m_rdu = 8;

PVector m_v[] = new PVector[m_num];
color m_c[] = new color[m_num];
float m_theta[] = new float[m_num];
float m_mtheta[] = new float[m_num];
float m_dtheta[] = new float[m_num];
float m_easing[] = new float[m_num];
int m_rdt[] = new int[m_num];

void setMouseTracing(){
  for(int i=0;i<m_num;i++){
    m_c[i] = color(random(128,255),80);
    m_v[i] = new PVector(random(width),random(height));
    m_theta[i] = round(random(360));
    m_dtheta[i] = random(m_mts);
    m_mtheta[i] = m_theta[i]/180*PI;
    m_rdt[i] = round(random(-m_rdtr,m_rdtr));
    m_easing[i] = random(0.02,0.3); 
  }
}

void mouseTracing(){
  // m_r = map(amp.analyze(),0,0.1,100,width);
  
  pushMatrix();
  noStroke();
  
  for(int i=0;i<m_num;i++){
    m_mtheta[i] += m_dtheta[i];
    m_v[i].lerp(mouseX + cos(m_mtheta[i])*(m_rdt[i]+m_r),mouseY + sin(m_mtheta[i])*(m_rdt[i]+m_r),0,m_easing[i]);
    fill(m_c[i]);
    ellipse(m_v[i].x,m_v[i].y,m_rdu,m_rdu);
  }
  
  popMatrix();
}




// ===========================================================
// ========================= Arduino =========================
// ===========================================================
import processing.serial.*;
Serial port;
void setArduino(){
  port = new Serial(this,"COM6",9600);
}
void sendDataToArduino(){
  String s = "";
  for(int i=0;i<6;i++){
    s += "" + status[i];
  }
  port.write(s);
  println(s);
}


// ===========================================================
// ---------------------- leap motion ------------------------
// ===========================================================
import de.voidplus.leapmotion.*;
LeapMotion leap;
void loadLeapMotion(){
  leap = new LeapMotion(this).allowGestures();
}


PVector l_v[] = new PVector[m_num];
color l_c[] = new color[m_num];
float l_theta[] = new float[m_num];
float l_mtheta[] = new float[m_num];
float l_dtheta[] = new float[m_num];
float l_easing[] = new float[m_num];
int l_rdt[] = new int[m_num];

void setLeapTracing(){
  for(int i=0;i<m_num;i++){
    l_c[i] = color(random(128,255),80);
    l_v[i] = new PVector(random(width),random(height));
    l_theta[i] = round(random(360));
    l_dtheta[i] = random(m_mts);
    l_mtheta[i] = m_theta[i]/180*PI;
    l_rdt[i] = round(random(-m_rdtr,m_rdtr));
    l_easing[i] = random(0.02,0.3); 
  }
}

void handTracing(){
  
  pushMatrix();
  noStroke();
  
  for(int i=0;i<m_num;i++){
    l_mtheta[i] += l_dtheta[i];
    l_v[i].lerp(mouseX + cos(l_mtheta[i])*(l_rdt[i]+m_r),mouseY + sin(l_mtheta[i])*(l_rdt[i]+m_r),0,l_easing[i]);
    fill(l_c[i]);
    ellipse(l_v[i].x,l_v[i].y,m_rdu,m_rdu);
  }
  
  popMatrix();
}




void handGestures(){  // modify status[] only, other reaction will based on status[]
  for(Hand hand : leap.getHands()){
    PVector handPosition = hand.getPosition();
    
    // hand position tracing
     fill(128,50);
    //ellipse(handPosition.x,handPosition.y,60,60);
    //rect(handPosition.x,0,100,setHeight);
    //ellipse(handPosition.x,handPosition.y,100,100);
    
    pushMatrix();
    noStroke();
    
    for(int i=0;i<m_num;i++){
      l_mtheta[i] += l_dtheta[i];
      l_v[i].lerp(handPosition.x + cos(l_mtheta[i])*(l_rdt[i]+m_r),handPosition.y + sin(l_mtheta[i])*(l_rdt[i]+m_r),0,l_easing[i]);
      fill(l_c[i]);
      ellipse(l_v[i].x,l_v[i].y,m_rdu,m_rdu);
    }
    
    popMatrix();        
    
    
      
    // test
    println("x: ",handPosition.x,"  y: ",handPosition.y);

    if(handPosition.x > 0 && handPosition.x < setWidth){
      
      // indicate dots
      int seq = findSeq((int)handPosition.x);
     
      // change the status
      if(hand.getGrabStrength() == 1){
        //int seq = findSeq((int)handPosition.x);
        status[seq] = 0;
        mv[seq] = false;
        // sendDataToArduino();  // TODO

      }
      else if(hand.getGrabStrength() == 0){
        //int seq = findSeq((int)handPosition.x);
        status[seq] = 1;     
        //mv[seq] = true;
        // sendDataToArduino();  // TODO
      }
    }   
  }
}



// -------------------------------------------------
//                SET UP
// -------------------------------------------------

void setup()
{
  
  loadFuture();
  
  noCursor();
  
  // Music Sound control
  loadMic();
  loadMusic();
   
  // View control
  colorMode(RGB,255,255,255);
  size(1920,1200);  // TODO

  // middle layer ———— dots
  loadMiddleLayer();
  
  // leap motion
  loadLeapMotion();
  
  setLeapTracing();
  
  // mouse
  setMouseTracing();
  
  // arduino
  // setArduino();  // TODO

  frameRate(60);    
    
}


// -------------------------------------------------
//                    DRAW
// -------------------------------------------------
void draw()
{
  // play the music
  // frameRate = 60
  // loop = 10'690"
  // loop/2 = 5'354"
  // loop/4 = 2'672"
  if(frameCount % 45 == 0){
    //thread("playMusic_2");  // TODO
    playMusic_2();  // TODO
  }  
  if(frameCount % 89 == 0){
    //thread("playMusic_5");  // TODO
    playMusic_5();  // TODO
    playMusic_2();
  }  
  if(frameCount % 178 == 0){
    //thread("playMusic_10");  // TODO
    playMusic_10();  // TODO
    playMusic_5();
    playMusic_2();
  }
  
  //if(frameCount%45==0){
  //  playMusic();
  //}
  
  setMiddleLayer();  
  
  // mouse
  // mousePositionIndicate();
  mouseTracing();
  //handTracing();
  
  handGestures();
  
  setTopLayer();
  
  setTopmostLayer();
    
}

// TODO: check the music, whether they can play correctly or not
// try thread("function") instead if it doesn't work

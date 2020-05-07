import processing.serial.*; 
import processing.sound.*;

//Sound libraries
SoundFile drop;
SoundFile click;


//Arduino Stuff
Serial myPort;

String [] data;

int switchValue = 0;
int potValue = 0;
int ldrValue = 0;

int serialIndex = 2;

// mapping LDR values
float minLDRValue = 100;
float maxLDRValue = 700;

float rotation;
float myoElectricScanner;

//Processing Stuff

//These are all of the images used for HUD
//Default 
PImage l1;
PImage l2;
PImage l3;
PImage dpad;

//Right HUD elements
PImage r1;
PImage r2;
PImage r3;
PImage abpad;

//Active elements
PImage l1press;
PImage l2press;
PImage l3press;
PImage dpadup;
PImage dpaddown;
PImage dpadleft;
PImage dpadright;

//variables to only play sound once
boolean oneL1;
boolean oneL2;
boolean oneL3;

//Various states for button presses
int l1State;
final int l1Up=1;
final int l1Down=2;

int l2State;
final int l2Up=1;
final int l2Down=2;

int l3State;
final int l3Up=1;
final int l3Down=2;

int dpadUpState;
final int dpadUpUp=1;
final int dpadUpDown=2;

int dpadDownState;
final int dpadDownUp=1;
final int dpadDownDown=2;

int dpadLeftState;
final int dpadLeftUp=1;
final int dpadLeftDown=2;

int dpadRightState;
final int dpadRightUp=1;
final int dpadRightDown=2;

void setup(){
  //sound stuff
  drop = new SoundFile(this, "drop.wav");
  click = new SoundFile(this,"click.wav");
  
  //Arduino Stuff
  printArray(Serial.list());
  
  myPort  =  new Serial (this, "COM5",  115200); 
  
  //Processing Stuff
  size(480,360);
  
  //Left side of Controller
  //Button png (not pressed)
  l1 = loadImage("l1_button.png");
  l2 = loadImage("l2_button.png");
  l3 = loadImage("l3_button.png");
  dpad = loadImage("dpad.png");
  
  //Shoulder button pressed
  l1press = loadImage("l1_press.png");
  l2press = loadImage("l2_press.png");
  l3press = loadImage("l3_press.png");
  //dpad pressed
  dpadup = loadImage("dpad_up.png");
  dpaddown = loadImage("dpad_down.png");
  dpadleft = loadImage("dpad_left.png");
  dpadright = loadImage("dpad_right.png");
  
  //Right side of Controller
  r1 = loadImage("r1_button.png");
  r2 = loadImage("r2_button.png");
  r3 = loadImage("r3_button.png");
  abpad = loadImage("abpad.png");
  
  //Set initial states for buttons (all buttons should be "up")
  //dpad states
  dpadUpState=dpadUpUp;
  dpadDownState=dpadDownUp;
  dpadLeftState=dpadLeftUp;
  dpadRightState=dpadRightUp;
  
  //Shoulder button States
  l1State=l1Up;
  l2State=l2Up;
  l3State=l3Up;
}
//Accepts serial feed
void checkSerial() {
  while (myPort.available() > 0) {
    String inBuffer = myPort.readString();  
    
    //print(inBuffer);
    
    // This removes the end-of-line from the string 
    inBuffer = (trim(inBuffer));
    
    // This function will make an array of TWO items, 1st item = switch value, 2nd item = potValue
    data = split(inBuffer, ',');
   
   // we have THREE items — ERROR-CHECK HERE
   if( data.length >= 2 ) {
      switchValue = int(data[0]);           // first index = switch value 
      potValue = int(data[1]);               // second index = pot value
      ldrValue = int(data[2]);               // third index = LDR value
      
      // change the display timer
      rotation = map( potValue, 0, 4095, 0, 11);  
      myoElectricScanner = map(ldrValue, minLDRValue, maxLDRValue, 0, 100);
   }
  }
} 
void draw(){
  background(255);
  drawLayout(); 
}
  
void checkRotation(){
  if (rotation < 5){
    l1State=l1Down;
    if (oneL1==true){
      click.play();
      oneL1=false;
    }
  }
  else if (rotation > 6){
    l2State=l2Down;
    if (oneL2==true){
      click.play();
      oneL2=false;
    }
  }
  else{
    l1State=l1Up;
    l2State=l2Up;
    oneL1=true;
    oneL2=true;
  }
}

void checkMayo(){
  if (myoElectricScanner < 30){
    l3State=l3Down;
    if (oneL3==true){
      click.play();
      oneL3=false;
    }
  }
  else{
    l3State=l3Up;
    oneL3=true;
  }
}
void keyPressed(){
  if (keyCode == UP){
    dpadUpState=dpadUpDown;
    drop.play();
  }
  if (keyCode == LEFT){
    dpadLeftState=dpadLeftDown;
    drop.play();
  }
  if (keyCode == RIGHT){
    dpadRightState=dpadRightDown;
    drop.play();
  }
  if (keyCode == DOWN){
    dpadDownState=dpadDownDown;
    drop.play();
  }    
}

void keyReleased(){
  if (keyCode == UP){
    dpadUpState=dpadUpUp;
  }
  if (keyCode == LEFT){
    dpadLeftState=dpadLeftUp;
  }
  if (keyCode == RIGHT){
    dpadRightState=dpadRightUp;
  }
  if (keyCode == DOWN){
    dpadDownState=dpadDownUp;
  }
}

void drawLayout(){
  //shoulder buttons
  actL1();
  actL2();
  actL3();
  
  //dpad
  actUp();
  actDown();
  actLeft();
  actRight();
  
  checkMayo();
  checkRotation();
  checkSerial();
  
  //right side of controller
  image(r1,415,160,50,50);
  image(r2,415,100,50,50);
  image(r3,380,280,50,50);
  image(abpad,415,220,50,50);
}


// All "act" functions will highlight the button the controller HUD if that specific button is pressed.
void actUp(){
  image(dpad,15,220,50,50);
  if (dpadUpState==dpadUpDown){
    image(dpadup,15,220,50,50);
    
  }
}

void actDown(){
  image(dpad,15,220,50,50);
  if (dpadDownState==dpadDownDown){
    image(dpaddown,15,220,50,50);
  }
}

void actLeft(){
  image(dpad,15,220,50,50);
  if (dpadLeftState==dpadLeftDown){
    image(dpadleft,15,220,50,50);
  }
}

void actRight(){
  image(dpad,15,220,50,50);
  if (dpadRightState==dpadRightDown){
    image(dpadright,15,220,50,50);
  }
}

void actL1(){
  if (l1State==l1Up){
    image(l1,15,160,50,50);
  }
  else if (l1State==l1Down){
    image(l1press,15,160,50,50);
  }
}

void actL2(){
  if (l2State==l2Up){
    image(l2,15,100,50,50);
  }
  else if (l2State==l2Down){
    image(l2press,15,100,50,50);
  }
}

void actL3(){
  if (l3State==l3Up){
    image(l3,50,280,50,50);
  }
  else if (l3State==l3Down){
    image(l3press,50,280,50,50);
  }
}

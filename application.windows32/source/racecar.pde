import java.io.*;
import java.lang.*;


//Fuzzy
float X=800.0f;
float rectX=500.0f;
float rectY=500.0f;
float distancePixel=0;
float velocityPixel=0; 
float steer =0;
float prevrectX=rectX;
//FSM
float fsmCarX = 500.0f;
float fsmCarY = 250.0f;
float distanceFSM = 0;
int state=0;
//input
boolean [] keys=new boolean[128];

void setup()
{
size(1000,1000);
frameRate(60);
}
void draw()
{
    background(255,205,200);
    display();
    println("X: "+X+ " rectX: "+rectX);
    velocityPixel= (prevrectX-rectX)/1000;
    distancePixel= (X-rectX)/1000;
  
    try{rules(distancePixel, velocityPixel);}
    catch(Exception e){}   
    state = statenum(fsmCarX);
    FSM(state);
    prevrectX = rectX;
    move();
}
void keyPressed()
{
  keys[key]=true;
}
void keyReleased()
{
  keys[key]=false;
}
void display()
{
    line(X,0,X,1000);
    rectMode(CENTER);
    fill(224, 22, 157);
    rect(rectX,rectY,50,100);
    rectMode(CENTER);   
    fill(204, 102, 0);
    rect(fsmCarX,fsmCarY,50,100);
}
void move()
{
if(keys['a']||keys['A'])
X-=10;
if(keys['d']||keys['D'])
X+=10;
if(velocityPixel == 0 && steer == 0)
rectX += distancePixel*10;
else
rectX += steer*10;

}
public void rules(float distance, float velocity)throws IOException
{
        
        float dL, dR, dZ, vL, vR, vZ, sL1=0, sL2=0, sL3=0, sR1=0, sR2=0, sR3=0, sZ1=0, sZ2=0, sZ3 = 0;
       
        println("Dp: " +distance);
        println("V:" +velocity);
        distance=Math.round(distance * 1000f) / 1000f;
        velocity=Math.round(velocity * 1000f) / 1000f;        
        
       //Fuzzy sets
        dL = FuzzyTrapezoidL(distance, -0.1, -0.6, -1, -1);
        dR = FuzzyTrapezoidR(distance, 0.1, 0.6, 1, 1);
        dZ=  FuzzyTriangle(distance, -0.2, 0, 0.2);
        vL = FuzzyTrapezoidL(velocity, -0.1, -0.6, -1, -1);
        vR = FuzzyTrapezoidR(velocity, 0.1, 0.6, 1, 1);
        vZ=  FuzzyTriangle(velocity, -0.2, 0, 0.2);
        
        //Rules
      //Left of car + Velocity towardsLeft = No steer
      if(distance <= -0.1 && velocity <= -0.1)
      {
        sZ1 =  Math.min(dL, vL);
      }
      //Left of car + Velocity inLine = Left Steer
      if(distance <= -0.1 && velocity <=0.2 && velocity>=-0.2)
      {
        sL1 = Math.min(dL, vZ);
      }
      //Left of car + Velocity towardsRight = Left Steer
      if(distance <= -0.1 && velocity >= 0.1)
      {
        sL2 = Math.min(dL, vR);
      }
      //OnLine + Velocity towardsLeft = Right Steer
      if(distance >=-0.2 && distance <= 0.2 && velocity <= -0.1)
      {
        sR1 = Math.min(dZ, vL);
      }
      //OnLine + Velocity inLine = No Steer
      if(distance >=-0.2 && distance <= 0.2 && velocity <=0.2 && velocity>=-0.2)
      {
        sZ2 = Math.min(dZ, vZ);
      }
      //OnLine + Velocity towardsRight = Left Steer
      if(distance >=-0.2 && distance <= 0.2 && velocity >=0.1)
      {
        sL3 = Math.min(dZ, vR);
      }
      //Right of car + Velocity towardsLeft = Right Steer
      if(distance >= 0.1 && velocity <=0.1)
      {
        sR2 = Math.min(dR, vL);
      }
      //Right of car + Velocity inLine = Right Steer
      if(distance >= 0.1 && velocity <=0.1)
      {
        sR3 = Math.min(dR, vZ);
      }
      //Right of car + Velocity towardsRight = No Steer
      if(distance >= 0.1 && velocity <=0.1)
      {
        sZ3 = Math.min(dR, vR);
      }
      
      float maxL, maxN, maxR;
      if(sL1 >sL2 && sL1>sL3)
         maxL=sL1;
        else if(sL2>sL1 && sL2>sL3)
         maxL=sL2;
         else
         maxL=sL3;
         
         if(sZ1 > sZ2 && sZ1>sZ3)
         maxN=sZ1;
        else if(sZ2>sZ1 && sZ2>sZ3)
         maxN=sZ2;
         else
         maxN=sZ3;
         
         if(sR1 > sR2 && sR1>sR3)
         maxR=sR1;
        else if(sR2>sR1 && sR2>sR3)
         maxR=sR2;
         else
         maxR=sR3;
      
      steer=defuzz(maxL, maxN, maxR);
      //steer = Math.round(steer * 1000f) / 1000f;  
      println("Distance: " +distance);
      println("Velocity: " +velocity);
      
      println("Steer: " + steer);
}



float FuzzyTriangle(float value, float x0,float x1, float x2)
{
  float result = 0;
  float x = value;
  if(x <= x0 || x>=x2)
  result = 0;
  else if(x == x1)
  result = 1;
  else if((x>x0) && (x<x1))
  result = (x/(x1-x0))-(x0/(x1-x0));
  else
  result = (-x/(x2-x1))+(x2/(x2-x1));
  return result;
}

float FuzzyTrapezoidR(float value, float x0, float x1,float x2, float x3)
{
  float result = 0;
  float x = value;
  if(x <= x0 || x>x3)
  result = 0;
  else if((x>=x1) && (x<=x2))
  result = 1;
  else if((x>x0) && (x<x1))
  result = (x/(x1-x0))-(x0/(x1-x0));
  else
  result = (-x/(x3-x2))+(x3/(x3-x2));
  return result;
}

float FuzzyTrapezoidL(float value, float x0, float x1,float x2, float x3)
{
  float result = 0;
  float x = value;
  if(x >= x0 || x<x3)
  result = 0;
  else if((x<=x1) && (x>=x2))
  result = 1;
  else if((x<x0) && (x>x1))
  result = (x/(x1-x0))-(x0/(x1-x0));
  else
  result = (-x/(x3-x2))+(x3/(x3-x2));
  return result;
}


//Defuzzify
//LS, NS, RS, are equivalent y-axis values for the output

float defuzz(float L, float N, float R)
{
  float result=0;
  float Lm= -1.001;
  float Nm= 1000;
  float Rm= 1.001;
  float Lx, Nx1, Nx2, Rx;
  float arL1;
  float arL2; 
 //float arL3;
  float arN1; 
  float arN2;
  float arN3;  
  float arR1;
  float arR2;
  float cenL1, cenL2, cenN1, cenN2, cenN3, cenR1, cenR2, totArL, totArR, totArN, totArCeL, totArCeN, totArCeR;
  float cL,cR;
  
  if(L==0)
  {
    totArL=0;
    totArCeL = 0;
  }
   else if(L==1)
  {
   totArL= 0.5* (Math.abs(-1 - (-0.001)))* L;
   cL= (-1-1-0.001)/3;
   totArCeL= cL*totArL;
  }
  else
  {
   Lx= (L/Lm) + (-0.001);
   arL1  = areaOfRectangle(-1,Lx, L);
   cenL1 = arxcentroidOfRectangle(arL1, Lx,-1);
   arL2  = areaOfTriangle(Lx,-0.001, L);
   cenL2 = arxcentroidOfTriangle(arL2, Lx, -0.001);
   totArL = arL1+ arL2;
   totArCeL= cenL1+cenL2;
  }  
  
  if(R==0)
  {
   
    totArR=0;
    totArCeR =0;
   
  }
   else if(R==1)
  {
   totArR= 0.5* R * (1-0.001);
   cR= (1+1+0.001)/3;
   totArCeR= cR*totArR;
  }
  else
  {
   Rx= (R/Rm) + 0.001;
   arR1  = areaOfRectangle(Rx, 1, R);
   cenR1 = arxcentroidOfRectangle(arR1, Rx,1);
   arR2  = areaOfTriangle(0.001,Rx, R);
   cenR2 = arxcentroidOfTriangle(arR2, Rx, 0.001);
   totArR = arR1+ arR2;
   totArCeR= cenR1+cenR2;
  }
  
  
  if(N==0)
  {
    totArN=0;
    totArCeN=0;
   }
  else if (N==1)
  {
    arN1= areaOfTriangle(-0.001,0,N); 
    cenN1=arxcentroidOfTriangle(arN1,0,-0.001);
    arN2=areaOfTriangle(0,0.001,N); 
    cenN2=arxcentroidOfTriangle(arN2,0,0.001);  
    totArN=arN1+arN2;
    totArCeN=cenN1+cenN2;
  }
  else
  {
   Nx1= (N/(Nm))+(-0.001);
   Nx2= (N/(-Nm))+0.001;
   arN1 = areaOfTriangle(-0.001, Nx1, N);
   cenN1= arxcentroidOfTriangle(arN1,Nx1,-0.001);
   arN2 = areaOfRectangle(Nx1,Nx2, N);
   cenN2= arxcentroidOfRectangle(arN2, Nx1,Nx2);
   arN3 = areaOfTriangle(Nx2, 0.001, N);
   cenN3= arxcentroidOfTriangle(arN3, Nx2,0.001);
   totArN=arN1+arN2+arN3;
   totArCeN=cenN1+cenN2+cenN3;
   
  }
  
      
  
  float totArea = totArL+totArN+totArR;
  float totCeAr= totArCeL+totArCeN+totArCeR;
  result =totCeAr/totArea;
  return result;
}


float areaOfRectangle(float x0,float x1, float h)
{
  float result=0;
  result= (x1-x0)*h;
  return result;
  
}

float arxcentroidOfRectangle(float ar, float x0,float x1)
{
  float result=0;
  result = ar *((x1+x0)/2);
  return result;
}

float areaOfTriangle(float x0,float x1, float h)
{
  float result = 0;
  result= (x1-x0)*h*0.5;
  return result;
}
float arxcentroidOfTriangle(float ar, float x0,float x1)
{
  float result=0;
  result = ar *((x0+x0+x1)/3);
  return result;
}

int statenum(float carPosX)
{
  distanceFSM = carPosX-X;
  int stateNum=0;
    if( distanceFSM <= -500)
      stateNum= 1;
    else if (distanceFSM > -500 && distanceFSM <=-100)
      stateNum= 2;
    else if (distanceFSM <0 && distanceFSM >-100)
      stateNum= 3;
    else if (distanceFSM == 0)
      stateNum= 4;
    else if (distanceFSM > 0 && distanceFSM <100)
      stateNum= 5;
    else if (distanceFSM >=100 && distanceFSM <500)
      stateNum= 6;
    else if (distanceFSM >= 500)
      stateNum= 7;
  return stateNum;
}
void FSM(int state)
{
  switch(state)
  {
    case 1:
    fsmCarX -= distanceFSM/50;
    break;
    case 2:
    fsmCarX -= distanceFSM/75;
    break;
    case 3:
    fsmCarX -= distanceFSM/100;
    break;
    case 4:
    //fsmCarX += distanceFSM*100;
    break;
    case 5:
    fsmCarX -= distanceFSM/100;
    break;
    case 6:
    fsmCarX -= distanceFSM/75;
    break;
    case 7:
    fsmCarX -= distanceFSM/50;
    break;
    default:
    println("Error");
    break;
  }
}

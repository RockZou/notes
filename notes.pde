import ddf.minim.spi.*;
import ddf.minim.signals.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.ugens.*;
import ddf.minim.effects.*;

Minim minim=new Minim(this);
AudioPlayer music;
AudioPlayer[] beat=new AudioPlayer[5];
int volume;
int k;
int lineTransparency=0;
//all notes fall at a certain speed

int fallSpeed=5, lineHeight=650,difficulty=5;
PImage[] picLane=new PImage[8]; 
PImage[] numbers=new PImage[4];
PImage backGroundImage, backGroundStart, perfectImage;
int[] laneLocation=new int[5];
//the sequence number of the notes array
int[] notePointers=new int[5];
//stack for the ones on display
int[] theStacks= new int[5];
ArrayList<Note> theNotes = new ArrayList<Note>();
//game timer
int timeCount;
int gameState;
int startPoint;
boolean released, pressed, mouseRelease=true;
int[] bottomDisplay=new int[5];
//state of the pressed keys
int[] keyPress=new int[6];
int endTime;
int prePauseState;
int life=100;
int perfect;
int label=1;

void setup()
{ 
  frameRate(60);
  size(400, 720);
  imageLoad();
  musicLoad();
  laneLocation[0]=0;
  for (int i=1;i<5;i++)
    laneLocation[i]=laneLocation[i-1]+80;

  //0 for not even pressed;
  //5 for 
  //1 for pressed not released;
  //2 for pressed but released;

  for (int i=0;i<5;i++)
    keyPress[i]=0;

  //time initialization
  timeCount=0;
  gameState=0;
  released=false;
  startPoint=0;
}

void draw()
{ 
  switch (gameState)
  {
  case 0:
    { 
      startGame();
      break;
    }
  case 1:
    { 
      recordNotes();
      bottomLine();
      break;
    }
  case 2:
    {
      playNotes();
      bottomLine();
      break;
    }
  case 3:
    {
      endGame();
      break;
    }
  case 4:
    {
      textSize(30);
      text("PAUSED",100,350);
      music.pause();
      if (mousePressed)
      {
        music.play();
        gameState=prePauseState;
      }
      break;
    }
  case 5:
    {
      holding();
      break;
    }
  }
}

void startGame()
{
  image(backGroundStart, 0, 0, 400, 720);
  fill(0);
  textSize(12);
  text("Click Here to Start!", 35, 280);
  if (mouseRelease&&mousePressed&&dist(mouseX, mouseY, 110, 280)<80) 
  {
    gameState=5;
    mouseRelease=false;
  }
  else if (mouseRelease&&mousePressed&&dist(mouseX, mouseY, 105, 550)<80) 
  {
    fallSpeed+=5;
    mouseRelease=false;
  }
  else if (mouseRelease&&mousePressed&&dist(mouseX,mouseY,310,155)<100)
  {
    difficulty+=5;
    mouseRelease=false;
  }
  if (fallSpeed>20) fallSpeed=5;
  if (difficulty>15) difficulty=5;
  textSize(20);
  text("Difficulty",250,120);
  text("Speed", 70, 510);
  textSize(30);
  text(fallSpeed/5, 90, 560);
  text(difficulty/5,280,170);
  textSize(10);
  text("click to change", 70, 600);
  text("clikc to change",260,200);
  released=false;
  timeCount=0;
  startPoint=0;
  volume=-50;
  k=0;
  music.setGain(volume);
  music.rewind();
  music.play();
}

//holding

void holding()
{
    if (keyPressed&&key=='p')
    {
      prePauseState=5;
      gameState=4;
    }
  timeCount++;
  imageMode(CENTER);
  if(timeCount<60)
  {
  }
  else if(timeCount<120)
  {
    displayNumber(60,2);
  }
  else if(timeCount<180)
  {
    displayNumber(120,1); 
  }
  else if(timeCount<240)
  {
    displayNumber(180,0);
  }
  /*else if(timeCount<300)
  {
    displayNumber(240,3); 
  }*/
  //***********************
  imageMode(CORNER);
  
  image(backGroundImage,0,0,400,720);
  if (k==5)
  {
  volume+=1;
  k=0;
  }
  else k++;
  music.setGain(volume);
  if (volume==0)
  {
    gameState=1;
    return;
  } 
}

//record the notes

void recordNotes()
{ 
  Note temp;
    if (keyPressed&&key=='p')
    {
      prePauseState=1;
      gameState=4;
    }
  int laneMarker=5;
  timeCount++;
  image(backGroundImage, 0, 0, 400, 720);   

  for (int i=0;i<5;i++)
    if (keyPress[i]==1)
    { 
      beat[i].rewind();
      beat[i].play();
      temp=new Note(timeCount, i);
      theNotes.add(temp);
      keyPress[i]=2;
    }
  for (int i=startPoint;i<theNotes.size();i++)
  { 
    temp=theNotes.get(i);
    temp.preMove();
    temp.preDisplay();
    if (temp.preyPos<0)
      startPoint++;
  }
  if (keyPressed&&key=='q')
  {
    gameState=2;
    endTime=timeCount+height/fallSpeed;
    music.rewind();
    music.play();
    timeCount=0;
    startPoint=0;
    volume=0;
    // if consecutive notes are very close, make them simultaneus  

    for (int i=0;i<theNotes.size()-1;i++)
    { 
      int rec=i;
      Note temp1=theNotes.get(i);
      for (int j=i+1;j<theNotes.size();j++)
      { 
        Note temp2=theNotes.get(j);
        if (temp2.fallTime-temp1.fallTime<5)
        {
          temp2.fallTime=temp1.fallTime;
        }
        else 
        {
          rec=j-1;
          break;
        }
      }

      //skip the ones already set at the same time  

      i=rec;
    }
  }
}

//play the notes

void playNotes()
{ 

  //if the game finished, go to the next state
    if (keyPressed&&key=='p')
    { 
      prePauseState=2;
      gameState=4;
    }
    if (timeCount>endTime)
  {
    timeCount=0;
    endTime=0;
    gameState++;
    return;
  }  

  //start playing the recorded notes

  timeCount++;
  image(backGroundImage, 0, 0, 400, 720);
  for (int i=0;i<theNotes.size();i++)
  { 
    Note temp=theNotes.get(i);
    if (timeCount>=temp.fallTime)
    {

      temp.move();
      temp.display();
      if (temp.finished)
      {
        theNotes.remove(i);
        i--;
      }
    }
    else break;
  }
  if (perfect>0) 
      { 
        imageMode(CENTER);
        image(perfectImage,width/2,height/2,20*perfect,10*perfect);
        imageMode(CORNER);
        perfect--;
      }
  musicDetect();
  //displayLife(life);
}

void endGame()
{
  textSize(20);
  text("Press any key to start over?", 60, 400);
  if (keyPressed)
  {
  while (theNotes.size()>0)
    theNotes.remove(0);
    gameState=0;
  }
}

void gamePaused()
{
  text("Paused",100,400);
  if (mouseRelease==true&&mousePressed&&mouseX>140&&mouseX<220&&mouseY>400&&mouseY<500)
  {
    gameState=prePauseState;
    mouseRelease=false;
  }
}//the target line

void bottomLine()
{
  strokeWeight(20);
  stroke(255, 255, 0, lineTransparency);
  if (lineTransparency<150)
  lineTransparency+=2;
  line(0, 650, 400, 650);
  for (int i=0;i<5;i++)
  {
    if (bottomDisplay[i]>0)
    {

      //when hit, the line gradually changes color
      
      stroke(255, 255-bottomDisplay[i]*25, 0);
      line(laneLocation[i], 650, laneLocation[i]+80, 650);
      bottomDisplay[i]--;
    }
  }
}

//key controls

void keyPressed()
{ 
  keyPress[keyTranslate(key)]=1;
  if (key=='z') 
  {
    save("screenshot"+label+".jpg");
    label++;
  }
  
}

void keyReleased()
{
  keyPress[keyTranslate(key)]=2;
}

int keyTranslate(char c)
{
  if (key==' ')
  return(4);
  else
  if (key==CODED)
  {
    switch (keyCode)
    {
    case LEFT :
      { 
        return(0);
      }
    case UP:
      {
        return(1);
      }
    case RIGHT:
      {
        return(2);
      }
    case DOWN:
      {
        return(3);
      }
    }
  }
  //not any of the above return 5;
  return(5);
}

void mouseReleased()
{
  mouseRelease=true;
}

void imageLoad()
{
  for (int i=0;i<8;i++)
  { 
    int t=i+1;
    picLane[i]=loadImage("bar"+t+".png");
  }
  backGroundImage=loadImage("background.png");
  backGroundStart=loadImage("backGroundStart.png");
  perfectImage=loadImage("perfect.png");
  for(int i=0;i<3;i++)
  {
    int t=i+1;
    numbers[i]=loadImage("number"+t+".png");
  }
}
void musicLoad()
{
  music=minim.loadFile("aperture.wav");
  beat[0]=minim.loadFile("pianoA.wav");
  beat[1]=minim.loadFile("pianoB.wav");
  beat[2]=minim.loadFile("pianoBb.wav");
  beat[3]=minim.loadFile("pianoC.wav");
  beat[4]=minim.loadFile("pianoC#.wav");
}                               

void musicDetect()
{
  for(int i=0;i<5;i++)
    if (keyPress[i]==1)
      {
        beat[i].rewind();
        beat[i].play();
        keyPress[i]=0;
      }
}

//display the numbers in holding

void displayNumber(int x,int i)
{  
  image(numbers[i],width/2,height/2,10*(timeCount-x),10*(timeCount-x));
}

void displayLife(int x)
{
  text("Life left:",10,20);
  strokeWeight(1);
  fill(255,255,0);
  rect(40,10,200,20);
  fill(255,0,0);
  rect(40,10,200*(x/100),20);
  fill(0);
}

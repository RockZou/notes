//the falling note
class Note
{
  //keep track of note's positions in each lane, in mili seconds
  int fallTime;
  int preyPos, yPos, laneNo;
  //whether the key has been hit
  boolean hit=false, finished;

  Note(int x, int y)
  {
    fallTime=x-650/fallSpeed;
    laneNo=y;
    hit=false;
    finished=false;
    preyPos=700;
    yPos=-30;
  }
  void preMove()
  {
    preyPos-=fallSpeed;
  }
  
  void move()
  {    
        if (finished==false) 
        yPos+=fallSpeed;

        //when a key is pressed detect whether hit
        int limit=fallSpeed/5*(50-difficulty);
        if (keyPress[laneNo]==1)
          {
            if (abs(yPos-650)<limit)
            {
            finished=true;
            hit=true;
            bottomDisplay[laneNo]=10;
            if(abs(yPos-650)<10) perfect=30;
            }
          }
        if (yPos>720)
           {
            finished=true;
           }
  }
  
  void preDisplay()
  { 
    image(picLane[laneNo], laneLocation[laneNo], preyPos);
  }

  void display()
  {
    if (hit==false&&finished==false)
      image(picLane[laneNo], laneLocation[laneNo], yPos);
  }
}  

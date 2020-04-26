// Global parameters //<>// //<>// //<>// //<>//

int blockwidth = 48;
int blockheight = 72;

int numcols = 8;
int radius = 0;
int maxtwist = 4;

int yOffset = 0;

int yLength = 20;

Column[] columns = new Column[numcols];


void setup() {
  smooth();
 // size(384, 864);
  size(1500, 864);
  //fullScreen();
  // Parameters go inside the parentheses when the object is constructed.
  for (int i = 0; i < numcols; i = i+1) {
    columns[i] = new Column(i, color(255, 255, 0), color(50, 100, 50), i*blockwidth, (2*numcols-i)*blockwidth, 0, yOffset*blockheight, yLength*blockheight-1);
    println(columns[i].ypos, columns[i].yflipped, columns[i].yend, columns[i].yflippedend);
  }
   noLoop();
}


void draw() {
  for (int i = 0; i < numcols; i = i+1) {
    columns[i].setTwist();
    columns[i].step();
    println(columns[i].ypos, columns[i].yflipped, columns[i].yend, columns[i].yflippedend);
    if (columns[i].ypos < columns[i].yend) {     
      columns[i].leftDisplay();
      columns[i].rightDisplay();
    }
  }
  // noLoop();
}

void keyPressed() {
  if (key == 'q') {
    exit();
  } else if (key == 's') {
    noLoop();
  } else
  loop();
}

void parallelogram(float x, float y, float x1, float y1, float x2, float y2) {
  quad(x, y, x+x1, y+y1, x+x1+x2, y+y1+y2, x+x2, y+y2);
}


// Even though there are multiple objects, we still only need one class. 
// No matter how many cookies we make, only one cookie cutter is needed.
class Column { 
  int index;
  int stepnum = 0;
  color BG, FG;  
  float xpos, xflipped, ypos, yflipped;
  float xend, xflippedend, yend, yflippedend;
  int twist;
  int effectiveTwist;
  boolean Zslash;

  // The Constructor is defined with arguments.
  Column(int tempIndex, color tempBG, color tempFG, float tempXpos, float tempXflipped, float tempYpos, float tempYflipped, float tempYend) { 
    index = tempIndex;  
    BG = tempBG;
    FG = tempFG; 
    xpos = tempXpos;
    xflipped = tempXflipped;
    ypos = 2*tempYpos-tempYflipped-blockheight; //backup so that dummy fill doesn't show and one more for fencepost
    yflipped = tempYpos-blockheight; //start dummy fill one before for fencepost
    yflippedend = tempYend - tempYpos + tempYflipped + blockheight; //reverse backup so that dummy fill doesn't show and one more for fencepost
    yend = tempYend + blockheight; //start dummy fill one (reverse before) for fencepost
    twist = 0;
    effectiveTwist = 0;
    while (ypos < tempYpos-blockheight) {
      Zslash = true;
      step();
      rightDisplay();
      println(index, ypos, yflipped, yend, yflippedend);
      Zslash = false;
      step();
      rightDisplay();
      println(index, ypos, yflipped, yend, yflippedend);
    }
  }



  float threshhold(int twistVal) {
    return 0.5-(0.5/maxtwist)*twistVal;
  }

  int nbhdTwist(int radiusVal) {
    int normTwist =  0;
    for (int i = index - radiusVal; i <= index + radiusVal; i = i+1) {
      normTwist = normTwist + abs(columns[(i % numcols + numcols) % numcols].twist);    // compensate for stupid Java %
    }
    return normTwist*Integer.signum(twist);
  }

  void setTwist() {
    effectiveTwist = nbhdTwist(radius);
    if (random(0, 1)<threshhold(effectiveTwist)) {
      // if (floor(stepnum)/4 % 2 == 0) {  
      Zslash = true;
      twist = twist + 1;
    } else {
      Zslash = false;
      twist = twist - 1;
    }
  }

  void step() {
    ypos = ypos + blockheight;
    //if (ypos > height-blockheight) { // wrap to next set of columns
    //  xpos = xpos + (2*numcols+1)*blockwidth;
    //  ypos = 0;
    //}
    yflipped = yflipped + blockheight;
    //if (yflipped > height-blockheight) {  // wrap to next set of columns
    //  xflipped = xflipped + (2*numcols+1)*blockwidth;
    //  yflipped = 0;
    //}
    yend = yend - blockheight;
    yflippedend = yflippedend - blockheight;
    stepnum = stepnum + 1;
  }


  float Xadjusted(float X, float Y) {
    float adjustedHeight = floor(height/blockheight)*blockheight;
    return X + floor(Y/adjustedHeight) * (2*numcols+1)*blockwidth;
  }

  float Yadjusted(float X, float Y) {
    float adjustedHeight = floor(height/blockheight)*blockheight;
    return Y % adjustedHeight;
  }

  void leftDisplay() {
    float xpos = Xadjusted(this.xpos, this.ypos);
    float ypos = Yadjusted(this.xpos, this.ypos);
    float xflipped = Xadjusted(this.xflipped, this.yflippedend);
    float yflippedend = Yadjusted(this.xflipped, this.yflippedend);
    if ((stepnum + index + ((Zslash) ? 1 : 0)) % 2 == 0) { //cast boolean Zslash to integer
      fill(FG);  
      stroke(BG);
    } else {
      fill(BG);
      stroke(FG);
    }
    strokeWeight(1);
    noFill(); //***temp!
    //  rect(xpos, ypos, blockwidth, blockheight); //outline 
  rect(xflipped-blockwidth, yflippedend-blockheight, blockwidth, blockheight); //flipped skeletonqs
    //noStroke();
    if (Zslash) {
      if ((stepnum + index + ((Zslash) ? 1 : 0)) % 2 == 0) {  //cast boolean Zslash to integer
        fill(FG);  
        stroke(BG);
      } else {
        fill(BG);
        stroke(FG);
      }
      parallelogram(xpos+blockwidth/2, ypos+blockheight/2, blockwidth/2, blockheight/2, 0, blockheight/2); //little 
      parallelogram(xpos+blockwidth/2, ypos, blockwidth/2, blockheight/2, 0, blockheight/2); //little     
      parallelogram(xpos, ypos, blockwidth/2, blockheight/2, 0, blockheight/2); //little
      parallelogram(xpos+blockwidth/2, ypos+blockheight, blockwidth/2, blockheight/2, 0, blockheight/2); //background
      line(xflipped, yflippedend, xflipped-blockwidth, yflippedend-blockheight);
      if ((stepnum + index + ((Zslash) ? 1 : 0)) % 2 == 0) {  //cast boolean Zslash to integer
        fill(BG);  
        stroke(FG);
      } else {
        fill(FG);
        stroke(BG);
      }
      parallelogram(xpos, ypos+blockheight/2, blockwidth/2, blockheight/2, 0, blockheight/2); //little 
      parallelogram(xpos, ypos+blockheight, blockwidth/2, blockheight/2, 0, blockheight/2); //background
    } else {  //Zslash is false
      if ((stepnum + index + ((Zslash) ? 1 : 0)) % 2 == 0) {  //cast boolean Zslash to integer
        fill(FG);  
        stroke(BG);
      } else {
        fill(BG);
        stroke(FG);
      }
      parallelogram(xpos+blockwidth/2, ypos+blockheight/2, blockwidth/2, -blockheight/2, 0, blockheight/2); //little 
      parallelogram(xpos, ypos+blockheight, blockwidth/2, -blockheight/2, 0, blockheight/2); //little 
      parallelogram(xpos+blockwidth/2, ypos+blockheight, blockwidth/2, -blockheight/2, 0, blockheight/2); //little 
      parallelogram(xpos+blockwidth/2, ypos+3*blockheight/2, blockwidth/2, -blockheight/2, 0, blockheight/2); // background 
      parallelogram(xpos, ypos+3*blockheight/2, blockwidth/2, -blockheight/2, 0, blockheight/2); // background
      if ((stepnum + index + ((Zslash) ? 1 : 0)) % 2 == 0) {  //cast boolean Zslash to integer
        fill(BG);  
        stroke(FG);
      } else {
        fill(FG);
        stroke(BG);
      }
      parallelogram(xpos, ypos+blockheight/2, blockwidth/2, -blockheight/2, 0, blockheight/2); //little         
      line(xflipped-blockwidth, yflippedend, xflipped, yflippedend-blockheight);
    }
    noFill();
    // rect(xpos, ypos, blockwidth, blockheight); //outline 
    fill(FG);
    //textSize(24);  
    //textAlign(LEFT, BOTTOM);
    //text(str(twist), xpos, ypos+blockheight);
    //textAlign(RIGHT, BOTTOM);
    //text(str(effectiveTwist), xpos+blockwidth, ypos+blockheight);
  }

  void rightDisplay() {
    float xpos = Xadjusted(this.xpos, this.yend);
    float yend = Yadjusted(this.xpos, this.yend);
    float xflipped = Xadjusted(this.xflipped, this.yflipped);
    float yflipped = Yadjusted(this.xflipped, this.yflipped);
    fill(BG);
    stroke(FG);
    strokeWeight(1);
    rect(xflipped-blockwidth, yflipped, blockwidth, blockheight);
    rect(xpos, yend-blockheight, blockwidth, blockheight);
    strokeWeight(4);
    if (Zslash) {
      line(xflipped, yflipped, xflipped-blockwidth, yflipped+blockheight);
      line(xpos, yend, xpos+blockwidth, yend-blockheight);
    } else {
      line(xflipped-blockwidth, yflipped, xflipped, yflipped+blockheight);
      line(xpos+blockwidth, yend, xpos, yend-blockheight);
    }
  }
}

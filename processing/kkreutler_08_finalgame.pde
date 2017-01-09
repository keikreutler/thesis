import arb.soundcipher.*;
import arb.soundcipher.constants.*;

SoundCipher sound;

Organ organ;
ArrayList organs;
Food food;

float scaleObj, wObj;

char direction;
char[] newDirection;
char[] priorDirection;
char addDirection;
int prevFrameDirection, prevFrameIntersect;

float[] xChange;
float[] yChange;
int lengthOfChangeArray; 
int changePos; // counts positions in the array to add new direction/x and y
int[] organChange; // allows each organ to have a remembered change

color orange, lightOrange, yellow, green0, green1, green2, brown, snakeColor;
color[] snake;
int colorCount;
int snakeHiddenFrame;

Grass[] grass;
int numOfGrass;

PFont font, smallFont, boldFont;
int moves, score;
int[] scores;
int[] sortedScores;
int[] scoreCounts;


int winState;

boolean dead;

FloodWave[] waves;
color blue0, blueW0, blueW1, blue3;
int brokenFrameCount; // frameCount @ which game is broken

char screenMode;

void setup() {
  size(600, 600);

  font = loadFont("Acid-32.vlw");
  smallFont = loadFont("Acid-20.vlw");
  boldFont = loadFont("Acid-Bold-20.vlw");
  sound = new SoundCipher(this);

  orange = color(255, 97, 56);
  lightOrange = color(255, 127, 96);
  yellow = color(255, 255, 157);
  green0 = color(190, 235, 159);
  green1 = color(121, 189, 143);
  green2 = color(0, 163, 136);
  brown = color(108, 75, 63);
  snake = new color[3];
  snake[0] = green0;
  snake[1] = green1;
  snake[2] = green2;

  snakeColor = snake[0];

  smooth();

  scaleObj = 40;
  wObj = width/scaleObj;


  organs = new ArrayList();
  PVector initPos = new PVector(wObj * random(0, scaleObj - scaleObj/2.0), wObj * random(0, scaleObj - scaleObj/2.0));
  for (int i = 0; i < 10; i++) {
    organs.add(new Organ(new PVector(initPos.x - (wObj * i), initPos.y), 'E', 3));
  }

  food = new Food();

  lengthOfChangeArray = 80;
  xChange = new float[lengthOfChangeArray];
  yChange = new float[lengthOfChangeArray];
  changePos = 0;
  xChange[changePos] = width;
  yChange[changePos] = height;

  newDirection = new char[lengthOfChangeArray];
  priorDirection = new char[lengthOfChangeArray];

  newDirection[changePos] = 'E';
  priorDirection[changePos] = 'E';

  winState = 150;
  organChange = new int[winState]; // set to max number of organs, so as to not use an array list but rely on currentSize i counter
  for (int i = 0; i < winState; i++) {
    organChange[i] = 0;
  }


  numOfGrass = 12;
  grass = new Grass[numOfGrass];

  // Group 1, upper left
  grass[0] = new Grass(85, 10.0, 150.0, 110, 40, color(30, 62, 29));
  grass[1] = new Grass(90, 10.0, 150.0, 100, 35, color(30, 62, 29));
  grass[2] = new Grass(70, 10.0, 150.0, 85, 55, color(201, 209, 105));

  // Group 2, middleR
  grass[3] = new Grass(150, 10.0, 150.0, width/2.0 + 90, height/4.0 - 15, color(123, 160, 60));
  grass[4] = new Grass(165, 10.0, 150.0, width/2.0 + 190, height/4.0 - 33, color(123, 160, 60));
  grass[5] = new Grass(200, 10.0, 150.0, width/2.0 + 160, height/4.0 - 60, color(30, 62, 29));
  grass[6] = new Grass(175, 10.0, 150.0, width/2.0 + 130, height/4.0 - 40, color(201, 209, 105));
  grass[7] = new Grass(125, 10.0, 150.0, width/2.0 + 150, height/4.0 + 15, color(123, 160, 60));

  // Group 3, lowL
  grass[8] = new Grass(120, 10.0, 150.0, width/2.0 - 60, height/2.0 + 70, color(123, 160, 60));
  grass[9] = new Grass(130, 10.0, 150.0, width/2.0 - 120, height/2.0 + 60, color(30, 62, 29));
  grass[10] = new Grass(175, 10.0, 150.0, width/2.0 - 90, height/2.0 + 15, color(201, 209, 105));
  grass[11] = new Grass(125, 10.0, 150.0, width/2.0 - 100, height/2.0 + 65, color(123, 160, 60));


  dead = false;
  brokenFrameCount = 0;
  score = 0;
  scores = new int[1];
  scoreCounts = new int[6];

  for (int i = 0; i < 6; i++) {
    scoreCounts[i] = 0;
  }

  blueW0 = color(24, 190, 234);
  blueW1 = color(32, 149, 247);

  waves = new FloodWave[6];

  for (int i = 0; i < 4; i += 3) {
    waves[i] = new FloodWave(0, .15, height/4.0 + (30*i), blueW0);
    waves[i+1] = new FloodWave(0, .25, height/3.0 + (30*(i+1)), blueW1);
    waves[i+2] = new FloodWave(0, .2, height/5.0 + (30*(i+2)), blueW1);
  }
  waves[waves.length-1].wColor = blueW1;


  screenMode = 'S';
}

void draw() {

  switch(screenMode) {
  case 'S':
    background(green1);

    title();

    textAlign(CENTER);
    textFont(smallFont);
    text("Try to eat as much food as possible\n with the least amount of effort.\n\nYour score will be divided by the amount of moves you make in between meals.\nAnd beware, your senses don't work too well hidden in the grass.", width/2.0, height/2.0);
    pressSpace();
    if (keyPressed) {
      if (key == ' ') screenMode = 'G';
    }
    break;  

  case 'G':
    if (organs.size() < winState) {
      
      background(yellow);
      stroke(yellow);
      strokeWeight(2);

      textAlign(RIGHT);
      textFont(font);
      text("Score: "+score, width-10, height-15);
      textAlign(LEFT);
      text("Moves: "+moves, 10, height-15);

      if (broken()) {
        drawWaves();
        if ((dead) && (broken())){
          brokenReset();
          dead = false;
      }  
    } 


      fill(orange);
      food.display();

      if (keyPressed) {
        if (key != ' ') {
          if (frameCount - prevFrameDirection > wObj) {
            // only take prevFrameDirection if key is coded
            moves++;
            // change mouth direction
            changeDirection();
          }
        }
      }

      if (intersect()) intersectAdd();

      followDirection();

      // To make snake visible again after twenty frames
      if (frameCount - snakeHiddenFrame > 20) {
        snakeColor = snake[colorCount];
      }
      fill(snakeColor);
      for (int i = 0; i < organs.size(); i++) {
        Organ organ = (Organ) organs.get(i);
        organ.update();
        organ.display();
      }

      noStroke();  
      for (int i = 0; i < numOfGrass; i++) {
        grass[i].calcWave();
        grass[i].renderWave();
      }

      fill(brown);
      ellipse(width/2.0 - 90, height/2.0 + 190, 110, 10);
      ellipse(100, 125, 60, 6);
      ellipse(width/2.0 + 145, height/4.0 + 135, 160, 10);

      grassIntersect();

      gameOver();

      if(!broken()) {
        if (dead) {
          screenMode = 'L';
          addScore();
        }
      }
    }
    else {
      screenMode = 'W';
      addScore();
    }
    break;


  case 'L':
    background(brown);
    fill(green0);

    title();

    textAlign(CENTER);
    textFont(smallFont);
    text("You couldn't see the lawn for the grass.\n\nYour score: "+score, width/2.0, height/2.0);

    clickToContinue();
    displayScores();

    if (mousePressed) {
      screenMode = 'S';
      reset();
    }
    break;


  case 'W':
    background(lightOrange);
    fill(yellow);

    title();

    textAlign(CENTER);
    textFont(smallFont);
    text("You've traveled far and wide, from one grassy patch to another,\n and managed to eat enough food for the winter.\n(If snakes need to do that.)\n\nYour score: "+score, width/2.0, height/2.0);

    displayScores();
    clickToContinue();

    if (mousePressed) {
      screenMode = 'S';
      reset();
    }
    break;
  }
}

// Snake in the grass title bar
void title() {
  textAlign(CENTER);
  textFont(font);
  fill(green2);
  noStroke();
  rect(0, height/4.0 - 30, width, 40);
  fill(yellow);
  text("SNAKE IN THE GRASS", width/2.0, height/4.0);
}

void clickToContinue() {
  textAlign(CENTER);
  textFont(boldFont);
  fill(yellow);
  if (second() % 2 == 0)  text("Click to continue", width/2.0, height/4.0 + 45);
}

void pressSpace() {
  textAlign(CENTER);
  textFont(boldFont);
  fill(yellow);
  if (second() % 2 == 0)  text("Press SPACE to play", width/2.0, height/4.0 + 45);
}

// List of scores at bottom of W/L screen
void displayScores() {

  textAlign(CENTER);
  textFont(smallFont);

  sortedScores = sort(scores);

  for (int i = 0; i < 6; i++) {
    scoreCounts[i] = 0;
  }
  switch(sortedScores.length) {
  case 1:
    if ((sortedScores[0] > 9) && (sortedScores[0] < 100)) text("1. "+sortedScores[0]+"  ", width/2.0, (3*(height/4.0)) + 25);
    if (sortedScores[0] < 10) text("1. "+sortedScores[0]+"   ", width/2.0, (3*(height/4.0)) + 25);
    if ((sortedScores[0] > 99) && (sortedScores[0] < 1000)) text("1. "+sortedScores[0]+" ", width/2.0, (3*(height/4.0)) + 25);
    if (sortedScores[0] > 999) text("1. "+sortedScores[0], width/2.0, (3*(height/4.0)) + 25);
    break;
  case 2:
    for (int scoreNum = sortedScores.length - 1; scoreNum >= 0; scoreNum--) {
      if ((sortedScores[scoreNum] > 9) && (sortedScores[scoreNum] < 100)) text(scoreCounts[1] + 1 +". "+sortedScores[scoreNum]+"  ", width/2.0, (3*(height/4.0)) + (scoreCounts[1]*25));
      if (sortedScores[scoreNum] < 10) text(scoreCounts[1] + 1 +". "+sortedScores[scoreNum]+"   ", width/2.0, (3*(height/4.0)) + (scoreCounts[1]*25));
      if ((sortedScores[scoreNum] > 99) && (sortedScores[scoreNum] < 1000)) text(scoreCounts[1] + 1 +". "+sortedScores[scoreNum]+" ", width/2.0, (3*(height/4.0)) + (scoreCounts[1]*25));
      if (sortedScores[scoreNum] > 999) text(scoreCounts[1] + 1 +". "+sortedScores[scoreNum], width/2.0, (3*(height/4.0)) + (scoreCounts[1]*25));
      scoreCounts[1] = scoreCounts[1] + 1;
    }
    break;
  case 3:
    for (int scoreNum = sortedScores.length - 1; scoreNum >= 0; scoreNum--) {
      if ((sortedScores[scoreNum] > 9) && (sortedScores[scoreNum] < 100)) text(scoreCounts[2] + 1 +". "+sortedScores[scoreNum]+"  ", width/2.0, (3*(height/4.0)) + (scoreCounts[2]*25));
      if (sortedScores[scoreNum] < 10) text(scoreCounts[2] + 1 +". "+sortedScores[scoreNum]+"   ", width/2.0, (3*(height/4.0)) + (scoreCounts[2]*25));
      if ((sortedScores[scoreNum] > 99) && (sortedScores[scoreNum] < 1000)) text(scoreCounts[2] + 1 +". "+sortedScores[scoreNum]+" ", width/2.0, (3*(height/4.0)) + (scoreCounts[2]*25));
      if (sortedScores[scoreNum] > 999) text(scoreCounts[2] + 1 +". "+sortedScores[scoreNum], width/2.0, (3*(height/4.0)) + (scoreCounts[2]*25));
      scoreCounts[2] = scoreCounts[2] + 1;
    }
    break;
  case 4:
    for (int scoreNum = sortedScores.length - 1; scoreNum >= 0; scoreNum--) {
      if ((sortedScores[scoreNum] > 9) && (sortedScores[scoreNum] < 100)) text(scoreCounts[3] + 1 +". "+sortedScores[scoreNum]+"  ", width/2.0, (3*(height/4.0)) + (scoreCounts[3]*25));
      if (sortedScores[scoreNum] < 10) text(scoreCounts[3] + 1 +". "+sortedScores[scoreNum]+"   ", width/2.0, (3*(height/4.0)) + (scoreCounts[3]*25));
      if ((sortedScores[scoreNum] > 99) && (sortedScores[scoreNum] < 1000)) text(scoreCounts[3] + 1 +". "+sortedScores[scoreNum]+" ", width/2.0, (3*(height/4.0)) + (scoreCounts[3]*25));
      if (sortedScores[scoreNum] > 999) text(scoreCounts[3] + 1 +". "+sortedScores[scoreNum], width/2.0, (3*(height/4.0)) + (scoreCounts[3]*25));
      scoreCounts[3] = scoreCounts[3] + 1;
    }
    break;    
  case 5:
    for (int scoreNum = sortedScores.length - 1; scoreNum >= 0; scoreNum--) {
      if ((sortedScores[scoreNum] > 9) && (sortedScores[scoreNum] < 100)) text(scoreCounts[4] + 1 +". "+sortedScores[scoreNum]+"  ", width/2.0, (3*(height/4.0)) + (scoreCounts[4]*25));
      if (sortedScores[scoreNum] < 10) text(scoreCounts[4] + 1 +". "+sortedScores[scoreNum]+"   ", width/2.0, (3*(height/4.0)) + (scoreCounts[4]*25));
      if ((sortedScores[scoreNum] > 99) && (sortedScores[scoreNum] < 1000)) text(scoreCounts[4] + 1 +". "+sortedScores[scoreNum]+" ", width/2.0, (3*(height/4.0)) + (scoreCounts[4]*25));
      if (sortedScores[scoreNum] > 999) text(scoreCounts[4] + 1 +". "+sortedScores[scoreNum], width/2.0, (3*(height/4.0)) + (scoreCounts[4]*25));
      scoreCounts[4] = scoreCounts[4] + 1;
    }    
    break;
  default:
    for (int scoreNum = sortedScores.length - 1; scoreNum > sortedScores.length - 6; scoreNum--) {
      if ((sortedScores[scoreNum] > 9) && (sortedScores[scoreNum] < 100)) text(scoreCounts[5] + 1 +". "+sortedScores[scoreNum]+"  ", width/2.0, (3*(height/4.0)) + (scoreCounts[5]*25));
      if (sortedScores[scoreNum] < 10) text(scoreCounts[5] + 1 +". "+sortedScores[scoreNum]+"   ", width/2.0, (3*(height/4.0)) + (scoreCounts[5]*25));
      if ((sortedScores[scoreNum] > 99) && (sortedScores[scoreNum] < 1000)) text(scoreCounts[5] + 1 +". "+sortedScores[scoreNum]+" ", width/2.0, (3*(height/4.0)) + (scoreCounts[5]*25));
      if (sortedScores[scoreNum] > 999) text(scoreCounts[5] + 1 +". "+sortedScores[scoreNum], width/2.0, (3*(height/4.0)) + (scoreCounts[5]*25));
      scoreCounts[5] = scoreCounts[5] + 1;
    }
    break;
  }
}

void addScore() {
  if (scores[0] == 0) scores[0] = score;
  else scores = append(scores, score);
}

void sortScores(int testScore) {
}
// Takes key input to change direction of the mouth (the first organ in the array)
void changeDirection() {
  if (key == CODED) {

    prevFrameDirection = frameCount;

    Organ organ = (Organ) organs.get(0);

    if (changePos > lengthOfChangeArray - 1) changePos = 0;

    // Store prior direction at changePos index number
    priorDirection[changePos] = organ.direction;
    // X and Y values at which direction changes
    xChange[changePos] = organ.pos.x;
    yChange[changePos] = organ.pos.y;

    // Change direction with keys... perhaps only if not reverse direction?
    if (keyCode == UP) organ.direction = 'N';
    if (keyCode == DOWN) organ.direction = 'S';
    if (keyCode == RIGHT) organ.direction = 'E';
    if (keyCode == LEFT) organ.direction = 'W';

    newDirection[changePos] = organ.direction;

    changePos++;
  }
}


void followDirection() {


  for (int i = 1; i < organs.size(); i++) {
    Organ organ = (Organ) organs.get(i);

    if (organChange[i] > lengthOfChangeArray - 1) organChange[i] = 0;

    if (priorDirection[organChange[i]] == 'N') {
      switch(newDirection[organChange[i]]) {
      case 'S':
        if (organ.pos.y <= yChange[organChange[i]] + wObj) {
          organ.direction = newDirection[organChange[i]];
          organChange[i] += 1;
        }
        break;
      case 'E':
        if (organ.pos.y <= yChange[organChange[i]]) {
          organ.direction = newDirection[organChange[i]];
          organChange[i] += 1;
        }
        break;
      case 'W':
        if (organ.pos.y <= yChange[organChange[i]]) {
          organ.direction = newDirection[organChange[i]];
          organChange[i] += 1;
        }
        break;
      }
    }

    if (organChange[i] > lengthOfChangeArray - 1) organChange[i] = 0;

    if (priorDirection[organChange[i]] == 'S') {
      switch(newDirection[organChange[i]]) {
      case 'N':
        if (organ.pos.y + wObj >= yChange[organChange[i]]) {
          organ.direction = newDirection[organChange[i]];
          organChange[i] += 1;
        }
        break;
      case 'E':
        if (organ.pos.y >= yChange[organChange[i]]) {
          organ.direction = newDirection[organChange[i]];
          organChange[i] += 1;
        }
        break;
      case 'W':
        if (organ.pos.y >= yChange[organChange[i]]) {
          organ.direction = newDirection[organChange[i]];
          organChange[i] += 1;
        }
        break;
      }
    }

    if (organChange[i] > lengthOfChangeArray - 1) organChange[i] = 0;

    if (priorDirection[organChange[i]] == 'E') {
      switch(newDirection[organChange[i]]) {
      case 'N':
        if (organ.pos.x >= xChange[organChange[i]]) {
          organ.direction = newDirection[organChange[i]];
          organChange[i] += 1;
        }   
        break;
      case 'S':
        if (organ.pos.x >= xChange[organChange[i]]) {
          organ.direction = newDirection[organChange[i]];
          organChange[i] += 1;
        }   
        break;
      case 'W':
        if (organ.pos.x + wObj >= xChange[organChange[i]]) {
          organ.direction = newDirection[organChange[i]];
          organChange[i] += 1;
        }   
        break;
      }
    }

    if (organChange[i] > lengthOfChangeArray - 1) organChange[i] = 0;

    if (priorDirection[organChange[i]] == 'W') {
      switch(newDirection[organChange[i]]) {
      case 'N':
        if (organ.pos.x <= xChange[organChange[i]]) {
          organ.direction = newDirection[organChange[i]];
          organChange[i] += 1;
        }  
        break;
      case 'S':
        if (organ.pos.x <= xChange[organChange[i]]) {
          organ.direction = newDirection[organChange[i]];
          organChange[i] += 1;
        }  

        break;
      case 'E':
        if (organ.pos.x <= xChange[0] + wObj) {
          organ.direction = newDirection[organChange[i]];
          organChange[i] += 1;
        }
        break;
      }
    }
  }
}

void grassIntersect() {

  for (int s = 0; s < numOfGrass; s++) {
    Organ organ = (Organ) organs.get(1);
    if (rectRectIntersect(organ.pos.x, organ.pos.y, organ.pos.x + wObj, organ.pos.y + wObj, 
    grass[s].displayW, grass[s].displayH, grass[s].displayW + grass[s].amplitude, grass[s].displayH + grass[s].h)) {
      grass[s].theta += 1.0;
      snakeColor = yellow;
      sound.playNote(random(80, 100), 100, 1.0);
      snakeHiddenFrame = frameCount;
    }
  }
}

boolean intersect() {
  Organ organ = (Organ) organs.get(0);
  return(rectRectIntersect(organ.pos.x, organ.pos.y, organ.pos.x + wObj, organ.pos.y + wObj, food.pos.x, food.pos.y, food.pos.x + wObj, food.pos.y + wObj));
}




void intersectAdd() {

  if (frameCount - prevFrameIntersect > wObj * 5) {
    sound.playNote(60, 100, 0.5);
    if (moves > 0) score += int(200/moves);
    else score = 250;
    moves = 0;

    int currentSize = organs.size();
    Organ organLast = (Organ) organs.get(currentSize - 1);
    addDirection = organLast.direction;
    for (int i = currentSize; i < currentSize + 7; i++) {
      if (i < winState) {
        organChange[i] = organChange[i-1];
        float addSpeed = organLast.speedValue;
        switch(addDirection) {
        case 'N':
          organs.add(new Organ(new PVector(organLast.pos.x, organLast.pos.y + wObj + (wObj * (i - currentSize))), 'N', addSpeed));
          break;
        case 'S':
          organs.add(new Organ(new PVector(organLast.pos.x, organLast.pos.y - wObj - (wObj * (i - currentSize))), 'S', addSpeed));
          break;
        case 'E':
          organs.add(new Organ(new PVector(organLast.pos.x - wObj - (wObj * (i - currentSize)), organLast.pos.y), 'E', addSpeed));
          break;
        case 'W':
          organs.add(new Organ(new PVector(organLast.pos.x + wObj + (wObj * (i - currentSize)), organLast.pos.y), 'W', addSpeed));
          break;
        }
      }
    }


    food.randomize();
    colorCount++;
    if (colorCount > 2) colorCount = 0;
    snakeColor = snake[colorCount];

    prevFrameIntersect = frameCount;
  }
}



void gameOver() {
  Organ firstOrgan = (Organ) organs.get(0);

  if ((firstOrgan.pos.x < 0) || (firstOrgan.pos.x + wObj > width) || (firstOrgan.pos.y < 0) || (firstOrgan.pos.y + wObj > height)) dead = true;

  for (int i = 3; i < organs.size(); i++) {
    Organ organI = (Organ) organs.get(i);
    if (rectRectIntersect(firstOrgan.pos.x - 10, firstOrgan.pos.y - 10, firstOrgan.pos.x + wObj - 10, firstOrgan.pos.y + wObj - 10, organI.pos.x - 10, organI.pos.y - 10, organI.pos.x + wObj - 10, organI.pos.y + wObj -10)) {
      dead = true;
    }
  }
}


boolean rectRectIntersect(float left, float top, float right, float bottom, 
float otherLeft, float otherTop, float otherRight, float otherBottom) {
  return !(left > otherRight || right < otherLeft || top > otherBottom || bottom < otherTop);
}

boolean broken() {
  Organ organHead = (Organ) organs.get(0);
  Organ organBody = (Organ) organs.get(1);
  return((abs(organHead.pos.x - organBody.pos.x) > wObj * 3) || (abs(organHead.pos.y - organBody.pos.y) > wObj * 3));
}

void drawWaves() {
  for (int i = 0; i < waves.length; i++) {
    waves[i].display();
    waves[i].fillWave();
  }
  waves[waves.length-1].fillLastWave();
}



void brokenReset() {

  snakeColor = snake[0];
  colorCount = 0;


  changePos = 0;

  for (int i = 0; i < xChange.length; i++) {
    xChange[i] = width;
  }

  for (int i = 0; i < yChange.length; i++) {
    yChange[i] = width;
  }

  for (int i = 0; i < newDirection.length; i++) {
    newDirection[i] = 'E';
  }

  for (int i = 0; i < priorDirection.length; i++) {
    priorDirection[i] = 'E';
  }

  for (int i = 0; i < organChange.length; i++) {
    organChange[i] = 0;
  }

  prevFrameDirection = 0;
  prevFrameIntersect = 0;
  snakeHiddenFrame = 0;

  dead = false;
  println("WHY IS IT DEAD");
  PVector resetPos = new PVector(wObj * random(0, scaleObj/2.0), wObj * random(0, scaleObj/2.0));
  for (int i = 1; i < organs.size(); i++) {
    Organ organ = (Organ) organs.get(i);
    organ.pos.x = resetPos.x - (wObj * i);
    organ.pos.y = resetPos.y;
    organ.direction = 'E';
    organ.speedValue = 3;
  }
}

void reset() {

  snakeColor = snake[0];
  colorCount = 0;

  for (int i = organs.size(); i > 0; i--) {
    organs.remove(i-1);
  }

  changePos = 0;

  for (int i = 0; i < xChange.length; i++) {
    xChange[i] = width;
  }

  for (int i = 0; i < yChange.length; i++) {
    yChange[i] = width;
  }

  for (int i = 0; i < newDirection.length; i++) {
    newDirection[i] = 'E';
  }

  for (int i = 0; i < priorDirection.length; i++) {
    priorDirection[i] = 'E';
  }

  for (int i = 0; i < organChange.length; i++) {
    organChange[i] = 0;
  }

  prevFrameDirection = 0;
  prevFrameIntersect = 0;
  snakeHiddenFrame = 0;

  dead = false;

  PVector initPos = new PVector(wObj * random(0, scaleObj/2.0), wObj * random(0, scaleObj/2.0));
  for (int i = 0; i < 10; i++) {
    organs.add(new Organ(new PVector(initPos.x - (wObj * i), initPos.y), 'E', 3));
  }

  score = 0;
  moves = 0;
}

class FloodWave {

  int xspacing;   // How far apart should each horizontal location be spaced
  int w;              // Width of entire wave
  float theta;  // Start angle at 0
  float amplitude;  // Height of wave
  float period;  // How many pixels before the wave repeats
  float dx;  // Value for incrementing X, a function of period and xspacing
  float[] yvalues;
  float angularVelocity;
  float y;
  color wColor;

  FloodWave(float theta, float angularVelocity, float y, color wColor) {
    this.angularVelocity = angularVelocity;
    this.y = y;
    this.theta = theta;
    this.wColor = wColor;

    xspacing = 5;
    //theta = 0.0;
    amplitude = 30.0;
    period = 400.0;
    w = width+16;
    dx = (TWO_PI / period) * xspacing;
    yvalues = new float[w/xspacing];
  }


  void display() {
    this.calcWave();
    this.renderWave();
  }

  void calcWave() {
    // Increment theta (try different values for 'angular velocity' here
    theta += angularVelocity;

    // For every x value, calculate a y value with sine function
    float x = theta;
    for (int i = 0; i < yvalues.length; i++) {
      yvalues[i] = sin(x)*amplitude;
      x+=dx;
    }
  }

  void renderWave() {
    // A simple way to draw the wave with an ellipse at each location
    //  for(int y = 0; y < height; y += 25) {
    for (int x = 0; x < yvalues.length; x++) {
      noStroke();
      fill(wColor);
      ellipseMode(CENTER);
      ellipse(x*xspacing, yvalues[x] + y, 20, 20);
    }
  }

  void fillWave() {

    for (int yPos = 0; yPos < 100; yPos += 10) {
      for (int x = 0; x < yvalues.length; x++) {
        noStroke();
        fill(wColor);
        ellipseMode(CENTER);
        ellipse(x*xspacing, yvalues[x] + y + yPos, 20, 20);
      }
    }
  }

  void fillLastWave() {

    for (int yPos = 0; yPos < height - y + amplitude; yPos += 10) {
      for (int x = 0; x < yvalues.length; x++) {
        noStroke();
        fill(wColor);
        ellipseMode(CENTER);
        ellipse(x*xspacing, yvalues[x] + y + yPos, 20, 20);
      }
    }
  }
}

class Food {

  PVector pos;

  Food() {

    pos = new PVector(wObj * random(5, scaleObj - 5), wObj * random(5, scaleObj - 5));
  }

  void display() {
    rect(pos.x, pos.y, wObj, wObj);
  }
  
  void randomize(){
     pos.x = wObj * random(5, scaleObj - 5);
     pos.y = wObj * random(5, scaleObj - 5);
  }
}

class Grass {


  int yspacing = 3;   // How far apart should each vertical location be spaced
  int h;              // Height of entire wave

  float theta = 0.0;  // Start angle at 0
  float amplitude = 10.0;  // Height of wave
  float period = 150.0;  // How many pixels before the wave repeats
  float dy;  // Value for incrementing Y, a function of period and yspacing
  float[] xvalues;  // Using an array to store width values for the wave

  float displayH;
  float displayW;
  
  color grassColor; 
  
  Grass(int h, float amplitude, float period, float displayW, float displayH, color grassColor) {
    this.h = h;
    this.amplitude = amplitude;
    this.period = period;
    this.displayW = displayW;
    this.displayH = displayH;
    this.grassColor = grassColor;

    yspacing = 3;
    theta = 0.0;
    dy = (TWO_PI / period) * yspacing;
    xvalues = new float[h/yspacing];
  }

  void calcWave() {
    // Increment theta (try different values for 'angular velocity' here
    theta += 0.085;

    // For every x value, calculate a y value with sine function
    float y = theta;
    for (int i = 0; i < xvalues.length; i++) {
      xvalues[i] = sin(y)*amplitude;
      y+=dy;
    }
  }

  void renderWave() {
    // A simple way to draw the wave with an ellipse at each location
    for (int y = 0; y < xvalues.length; y++) {
      fill(grassColor);
      ellipse(displayW + xvalues[y], displayH + y*yspacing, sin(radians(map(y, 0, xvalues.length, 0, 90)))*5, 5);
    }
  }
}

class Organ {

  PVector pos;
  PVector speed;
  float speedValue;

  char direction;

  Organ(PVector pos, char direction, float speedValue) {
    this.pos = pos;
    this.direction = direction;
    this.speedValue = speedValue;
    speed = new PVector(0,0);
  }

  void display() {
    rect(pos.x, pos.y, wObj, wObj);
  }


  void update() {
    switch(direction) {
    case 'N':
      speed.x = 0;
      speed.y = speedValue * -1;
      break;
    case 'S':
      speed.x = 0;
      speed.y = speedValue;
      break;
    case 'E':
      speed.x = speedValue;
      speed.y = 0;
      break;
    case 'W':
      speed.x = speedValue * -1;
      speed.y = 0;
      break;
    }


    pos.x += speed.x;
    pos.y += speed.y;

    //gameOver();

  }


//  void gameOver() {
//    if ((pos.x < 0) || (pos.x + wObj > width) || (pos.y < 0) || (pos.y + wObj > height)) {
//      background(255);
//    }
//  }
}



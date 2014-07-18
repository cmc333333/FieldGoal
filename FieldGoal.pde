//The MIT License (MIT) - See Licence.txt for details

//Copyright (c) 2013 Mick Grierson, Matthew Yee-King, Marco Gillies


import org.jbox2d.util.nonconvex.*;
import org.jbox2d.dynamics.contacts.*;
import org.jbox2d.testbed.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.joints.*;
import org.jbox2d.p5.*;
import org.jbox2d.dynamics.*;

// audio stuff

Maxim maxim;
AudioPlayer kickSound;
AudioPlayer cheerSound;
AudioPlayer jeerSound;

Physics xzPhysics;  //  top-down
Body xzBall;
Physics zyPhysics;  //  side
Body zyBall;

float ballSize = .2;  //  in meters

PImage crateImage;

int score = 0;
boolean kicked = false;
boolean scored = false;

void setup() {
  size(700, 700, P3D);
  frameRate(30);


  crateImage = loadImage("crate.jpeg");
  imageMode(CENTER);

  xzPhysics = new Physics(this, width, height, 0, 0, width*2, height*2,
                          width, height, 14);
  zyPhysics = new Physics(this, width, height, 0, -10, width*2, height*2,
                          width, height, 14);

  xzPhysics.setDensity(10.0);
  zyPhysics.setDensity(10.0);

  // set up the objects
  // Rect parameters are the top left 
  // and bottom right corners
  xzBall = xzPhysics.createRect(width/2 - ballSize*7,
                                height - ballSize*14,
                                width/2 + ballSize*7,
                                height);
  zyBall = zyPhysics.createRect(0,
                                height - ballSize*14,
                                14*ballSize,
                                height);

  maxim = new Maxim(this);

  kickSound = maxim.loadFile("crate2.wav");
  kickSound.speed(0.5);
  kickSound.setLooping(false);

  cheerSound = maxim.loadFile("130326__dianadesim__clapping-and-yelling.wav");
  cheerSound.setLooping(false);

  jeerSound = maxim.loadFile("124996__phmiller42__aww.wav");
  jeerSound.setLooping(false);
}

void draw() {
  background(100); 

  Vec2 xzPos = xzPhysics.worldToScreen(xzBall.getWorldCenter());
  Vec2 zyPos = zyPhysics.worldToScreen(zyBall.getWorldCenter());

  drawGoalPost();
  drawBall(xzPos, zyPos);
  checkReset(xzPos, zyPos);
  checkPoint(xzPos.x, zyPos.y, zyPos.x);

  fill(0);
  textSize(32);
  text("Score: " + score, 20, 50);
}

// when we release the mouse, apply an impulse based 
// on the distance from the droid to the catapult
void mouseClicked()
{
  if (!kicked) {
    float fuzzyX = mouseX + random(-16, 16);
    float fuzzyY = mouseY + random(-10, 10);
    Vec2 click = new Vec2(fuzzyX - width/2, fuzzyY - 590).mul(1.0/14);
    Vec2 xzImpact = xzBall.getWorldCenter().sub(
        new Vec2(-click.x * 0.2, ballSize/2));
    xzBall.applyImpulse(new Vec2(0, 5), xzImpact);

    Vec2 zyImpact = xzBall.getWorldCenter().sub(new Vec2(ballSize/2, -click.y));
    zyBall.applyImpulse(new Vec2(8, 0), zyImpact);
    kicked = true;
    kickSound.cue(0);
    kickSound.play();
  }
}

void drawBall(Vec2 xzPos, Vec2 zyPos)
{
  pushMatrix();
    translate(xzPos.x, height/2 + 14*2.25 - height + zyPos.y, 
              545 - zyPos.x);
    rotateX(radians(zyPhysics.getAngle(zyBall)));
    rotateY(radians(xzPhysics.getAngle(xzBall)));
    beginShape(QUADS);
    texture(crateImage);
    noStroke();

    // +Z "front" face
    vertex(-4, -4,  4, 0, 0);
    vertex( 4, -4,  4, 600, 0);
    vertex( 4,  4,  4, 600, 600);
    vertex(-4,  4,  4, 0, 600);

    // -Z "back" face
    vertex( 4, -4, -4, 0, 0);
    vertex(-4, -4, -4, 600, 0);
    vertex(-4,  4, -4, 600, 600);
    vertex( 4,  4, -4, 0, 600);

    // +Y "bottom" face
    vertex(-4,  4,  4, 0, 0);
    vertex( 4,  4,  4, 600, 0);
    vertex( 4,  4, -4, 600, 600);
    vertex(-4,  4, -4, 0, 600);

    // -Y "top" face
    vertex(-4, -4, -4, 0, 0);
    vertex( 4, -4, -4, 600, 0);
    vertex( 4, -4,  4, 600, 600);
    vertex(-4, -4,  4, 0, 600);

    // +X "right" face
    vertex( 4, -4,  4, 0, 0);
    vertex( 4, -4, -4, 600, 0);
    vertex( 4,  4, -4, 600, 600);
    vertex( 4,  4,  4, 0, 600);

    // -X "left" face
    vertex(-4, -4, -4, 0, 0);
    vertex(-4, -4,  4, 600, 0);
    vertex(-4,  4,  4, 600, 600);
    vertex(-4,  4, -4, 0, 600);
    endShape();
  popMatrix();
}

void drawGoalPost()
{
  pushMatrix();
    translate(width/2, height/2, 100);

    noStroke();
    fill(200);
    rect(-2, -42, 4, 70);  // base
    rect(-30, -46, 60, 4); // crossbar
    rect(-30, -80, 4, 38);  // left
    rect(26, -80, 4, 38);  // right

  popMatrix();
}

void checkReset(Vec2 xzPos, Vec2 zyPos)
{
  if ((zyBall.isSleeping() && zyPos.x > 50) || xzPos.y < .05*width) {
    xzPhysics.removeBody(xzBall);
    zyPhysics.removeBody(zyBall);
    xzBall = xzPhysics.createRect(width/2 - ballSize*7,
                                  height - ballSize*14,
                                  width/2 + ballSize*7,
                                  height);
    zyBall = zyPhysics.createRect(0,
                                  height - ballSize*14,
                                  14*ballSize,
                                  height);
    kicked = false;
    scored = false;
  }
}

void checkPoint(double x, double y, double z)
{
  x = x - width/2;
  y = y - height;
  z = z - (height/2) / tan(PI/6) + 100;

  if (!scored && -26 < x && x < 26 && y < -46 && 0 < z) {
    score += 1;
    scored = true;

    cheerSound.cue(0);
    cheerSound.play();
  } else if (0 < z && !jeerSound.isPlaying()) {
    jeerSound.cue(0);
    jeerSound.play();
  }
}

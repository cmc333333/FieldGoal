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
AudioPlayer crateSound;


Physics xzPhysics;  //  top-down
Body xzBall;
Physics zyPhysics;  //  side
Body zyBall;

int crateSize = 80;
float ballSize = .2;  //  in meters

PImage crateImage;

int score = 0;

void setup() {
  size(700, 700, P3D);
  frameRate(30);


  crateImage = loadImage("crate.jpeg");
  imageMode(CENTER);

  xzPhysics = new Physics(this, width, height, 0, 0, width*2, height*2,
                          width, height, 14);
  zyPhysics = new Physics(this, width, height, 0, -10, width*2, height*2,
                          width, height, 14);
  // this overrides the debug render of the physics engine
  // with the method myCustomRenderer
  // comment out to use the debug renderer 
  // (currently broken in JS)
  //physics.setCustomRenderingMethod(this, "myCustomRenderer");

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

  crateSound = maxim.loadFile("crate2.wav");
  crateSound.setLooping(false);
  crateSound.volume(1);
}

void draw() {
  background(100); 

  Vec2 xzPos = xzPhysics.worldToScreen(xzBall.getWorldCenter());
  Vec2 zyPos = zyPhysics.worldToScreen(zyBall.getWorldCenter());

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


  fill(0);
  text("Score: " + score, 20, 20);
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
  }
}

// when we release the mouse, apply an impulse based 
// on the distance from the droid to the catapult
void mouseClicked()
{
  Vec2 click = new Vec2(mouseX - width/2, mouseY - 590).mul(1.0/14);
  Vec2 xzImpact = xzBall.getWorldCenter().sub(new Vec2(click.x, ballSize/2));
  xzBall.applyImpulse(new Vec2(-click.x, 5), xzImpact);

  Vec2 zyImpact = xzBall.getWorldCenter().sub(new Vec2(ballSize/2, -click.y));
  zyBall.applyImpulse(new Vec2(8, click.y), zyImpact);
}

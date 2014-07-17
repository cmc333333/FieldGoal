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

PImage crateImage;

int score = 0;

void setup() {
  size(1024, 700, P3D);
  frameRate(30);


  crateImage = loadImage("crate.jpeg");
  imageMode(CENTER);

  xzPhysics = new Physics(this, width, 100*20*3, 0, 0, width*2, 100*20*3*2,
                          width, 100*20*3, 100);
  zyPhysics = new Physics(this, 100*20*3, height, 0, -10, 100*20*3*2, height*2,
                          100*20*3, height, 100);
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
  xzBall = xzPhysics.createRect(200, height-crateSize, 200+crateSize, height);
  zyBall = zyPhysics.createRect(400, height-crateSize, 400+crateSize, height);

  maxim = new Maxim(this);

  crateSound = maxim.loadFile("crate2.wav");
  crateSound.setLooping(false);
  crateSound.volume(1);

}

void draw() {
  background(100); 


  // we can call the renderer here if we want 
  // to run both our renderer and the debug renderer
  //myCustomRenderer(physics.getWorld());
  Vec2 xzPos = xzPhysics.worldToScreen(xzBall.getWorldCenter());
  Vec2 zyPos = zyPhysics.worldToScreen(zyBall.getWorldCenter());

  pushMatrix();
  translate(xzPos.x + 200, zyPos.y - 200, xzPos.y - 400);
  image(crateImage, 0, 0, crateSize, crateSize);
  popMatrix();


  fill(0);
  text("Score: " + score, 20, 20);
}

// when we release the mouse, apply an impulse based 
// on the distance from the droid to the catapult
void mouseClicked()
{
  Vec2 xzImpact = xzBall.getWorldCenter().sub(new Vec2(0, crateSize/2));
  xzBall.applyImpulse(new Vec2(0, 30), xzImpact);

  Vec2 zyImpact = xzBall.getWorldCenter().sub(new Vec2(crateSize/2, -crateSize/4));
  zyBall.applyImpulse(new Vec2(10, 0), zyImpact);
}

// this function renders the physics scene.
// this can either be called automatically from the physics
// engine if we enable it as a custom renderer or 
// we can call it from draw
void myCustomRenderer(World world) {
  // get the droids position and rotation from
  // the physics engine and then apply a translate 
  // and rotate to the image using those values
  // (then do the same for the crates)

  /*
  for (int i = 0; i < crates.length; i++)
  {
    Vec2 worldCenter = crates[i].getWorldCenter();
    Vec2 cratePos = physics.worldToScreen(worldCenter);
    float crateAngle = physics.getAngle(crates[i]);
    pushMatrix();
    translate(cratePos.x, cratePos.y, -5 * dist[i]);
    rotate(-crateAngle);
    image(crateImage, 0, 0, crateSize, crateSize);
    popMatrix();
  }
  */

}

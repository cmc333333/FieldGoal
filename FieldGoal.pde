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


Physics physics; // The physics handler: we'll see more of this later

Body [] crates;
boolean [] kicked;
int [] dist;
// the start point of the catapult 
Vec2 startPoint;

int crateSize = 80;
int ballSize = 60;

PImage crateImage, ballImage;

int score = 0;

boolean dragging = false;

void setup() {
  size(1024, 700);
  frameRate(30);


  crateImage = loadImage("crate.jpeg");
  ballImage = loadImage("tux_droid.png");
  imageMode(CENTER);

  //initScene();

  /**
   * Set up a physics world. This takes the following parameters:
   * 
   * parent The PApplet this physics world should use
   * gravX The x component of gravity, in meters/sec^2
   * gravY The y component of gravity, in meters/sec^2
   * screenAABBWidth The world's width, in pixels - should be significantly larger than the area you intend to use
   * screenAABBHeight The world's height, in pixels - should be significantly larger than the area you intend to use
   * borderBoxWidth The containing box's width - should be smaller than the world width, so that no object can escape
   * borderBoxHeight The containing box's height - should be smaller than the world height, so that no object can escape
   * pixelsPerMeter Pixels per physical meter
   */
  physics = new Physics(this, width, height, 0, -10, width*2, height*2, width, height, 100);
  // this overrides the debug render of the physics engine
  // with the method myCustomRenderer
  // comment out to use the debug renderer 
  // (currently broken in JS)
  physics.setCustomRenderingMethod(this, "myCustomRenderer");
  physics.setDensity(10.0);

  // set up the objects
  // Rect parameters are the top left 
  // and bottom right corners
  kicked = new boolean[7];
  dist = new int[7];
  crates = new Body[7];
  crates[0] = physics.createRect(600, height-crateSize, 600+crateSize, height);
  crates[1] = physics.createRect(600, height-2*crateSize, 600+crateSize, height-crateSize);
  crates[2] = physics.createRect(600, height-3*crateSize, 600+crateSize, height-2*crateSize);
  crates[3] = physics.createRect(600+1.5*crateSize, height-crateSize, 600+2.5*crateSize, height);
  crates[4] = physics.createRect(600+1.5*crateSize, height-2*crateSize, 600+2.5*crateSize, height-crateSize);
  crates[5] = physics.createRect(600+1.5*crateSize, height-3*crateSize, 600+2.5*crateSize, height-2*crateSize);
  crates[6] = physics.createRect(600+0.75*crateSize, height-4*crateSize, 600+1.75*crateSize, height-3*crateSize);

  startPoint = new Vec2(200, height-150);
  // this converst from processing screen 
  // coordinates to the coordinates used in the
  // physics engine (10 pixels to a meter by default)
  startPoint = physics.screenToWorld(startPoint);

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

  fill(0);
  text("Score: " + score, 20, 20);
  for (int i = 0; i < crates.length; i++) {
    if (kicked[i] && dist[i] < crateSize) {
      dist[i] += 1;
    }
  }
}

// when we release the mouse, apply an impulse based 
// on the distance from the droid to the catapult
void mouseClicked()
{
  for (int i = 0; i < crates.length; i++) {
    Body crate = crates[i];
    Vec2 pos = physics.worldToScreen(crate.getWorldCenter());
    if (!kicked[i]
        && mouseX >= pos.x - crateSize/2 && mouseX <= pos.x + crateSize/2
        && mouseY >= pos.y - crateSize/2 && mouseY <= pos.y + crateSize/2) {
      Vec2 impulse = crate.getWorldCenter();
      impulse = impulse.sub(physics.screenToWorld(new Vec2(mouseX, mouseY + 10)));
      impulse = impulse.mul(100);
      crate.applyImpulse(impulse, crate.getWorldCenter());

      crateSound.cue(0);
      crateSound.speed(0.5);
      crateSound.play();
      kicked[i] = true;
    }
  }
}

// this function renders the physics scene.
// this can either be called automatically from the physics
// engine if we enable it as a custom renderer or 
// we can call it from draw
void myCustomRenderer(World world) {
  stroke(0);

  Vec2 screenStartPoint = physics.worldToScreen(startPoint);
  strokeWeight(8);
  line(screenStartPoint.x, screenStartPoint.y, screenStartPoint.x, height);

  // get the droids position and rotation from
  // the physics engine and then apply a translate 
  // and rotate to the image using those values
  // (then do the same for the crates)

  for (int i = 0; i < crates.length; i++)
  {
    Vec2 worldCenter = crates[i].getWorldCenter();
    Vec2 cratePos = physics.worldToScreen(worldCenter);
    float crateAngle = physics.getAngle(crates[i]);
    pushMatrix();
    translate(cratePos.x, cratePos.y);
    rotate(-crateAngle);
    image(crateImage, 0, 0, crateSize - dist[i], crateSize - dist[i]);
    popMatrix();
  }

}

import toxi.physics2d.constraints.*;
import toxi.physics2d.behaviors.*;
import toxi.physics2d.*;

import toxi.geom.*;

import java.util.List;

// number of particles for string
int STRING_RES=100;
// number particles for ball
int BALL_RES=60;
// ball size
int BALL_RADIUS=80;

// squared snap distance for mouse selection
float SNAP_DIST = 20 * 20;

VerletPhysics2D physics;
VerletParticle2D selectedParticle;
ArrayList<ParticleString2D> ropes=new ArrayList<ParticleString2D>();
ArrayList<ParticleString2D> groundropes=new ArrayList<ParticleString2D>();


float groundLevel=height*0.95;

void setup() {
  size(1024, 720, P3D);
  initPhysics();
}

void drawRopes() {
  // draw all springs
  stroke(255, 0, 255);
  for (VerletSpring2D s : physics.springs) {
    line(s.a.x, s.a.y, s.b.x, s.b.y);
  }
  // show all particles
  fill(0);
  noStroke();
  for (VerletParticle2D p : physics.particles) {
    ellipse(p.x, p.y, 5, 5);
  }
  // highlight selected particle (if there is one currently)
  if (selectedParticle!=null) {
    fill(255, 0, 255);
    ellipse(selectedParticle.x, selectedParticle.y, 20, 20);
  }
}


void draw() {
  // 1st update
  physics.update();
  // then drawing
  background(224);
  drawRopes();

  ArrayList<ParticleString2D> removeList=new ArrayList<ParticleString2D>();
  for (ParticleString2D rope : ropes) {
    //if more than half of the vertices are lower than the groundLevel, than judge them on the ground
    //and move them from ropes list to groundrope list
    int groundness=0;
    for (VerletParticle2D p : rope.particles) {
      if (p.y>height*0.95) {
        groundness+=1;
      }
    }
    if (groundness>=12) {
      rope.getTail().lock();
      removeList.add(rope);
    }
  }
  //remove ground ropes from the list
  for (ParticleString2D rope : removeList) {
    groundropes.add(rope);
    ropes.remove(rope);
  }
  removeList.clear();

  int i=0;//when the ground ropes are too many, delete them, but only delete at most 6 roeps at one time
  while (groundropes.size()>20 && frameCount%100==0 && i<6) {
    //println(groundropes.size());
    //when there are too many grounropes
    ParticleString2D rope=(ParticleString2D)groundropes.remove(0);
    i+=1;
    for (VerletParticle2D p : rope.particles) {   
      physics.removeParticle(p);
    }
    for (VerletSpring2D s : rope.links) {
      physics.removeSpring(s);
    }
  }

  //float highestY=0;
  //for(ParticleString2D gr:groundropes){
  //  VerletParticle2D tail=gr.getTail();
  //  if(tail.y>highestY){
  //    highestY=tail.y;
  //  }
  //}
  //println(highestY);
  //groundLevel=max(height-highestY*0.95,height*0.85);


  if (ropes.size()<10&&frameCount%50==0) {
    addRope();
    //nextTime=millis()+int(random(2000,4000));
  }
}

void addRope() {
  Vec2D stepDir=new Vec2D(random(-1, 1), random(0.5, 1)).normalizeTo(5);
  ParticleString2D s=new ParticleString2D(physics, new Vec2D(mouseX, 10), stepDir, 25, 1, 0.5);
  ropes.add(s);
  for (VerletParticle2D v : s.particles) {
    physics.addBehavior(new AttractionBehavior2D(v, 5, -3));
  }
}


void mousePressed() {
  //Add a rope
  Vec2D stepDir=new Vec2D(1, 1).normalizeTo(5);
  ParticleString2D s=new ParticleString2D(physics, new Vec2D(mouseX, mouseY), stepDir, 25, 1, 0.5);
  ropes.add(s);
  for (VerletParticle2D v : s.particles) {
    physics.addBehavior(new AttractionBehavior2D(v, 5, -3));
  }
}

void initPhysics() {
  physics=new VerletPhysics2D();
  // set screen bounds as bounds for physics sim
  physics.setWorldBounds(new Rect(0, 0, width, height));
  // add gravity along positive Y axis
  physics.addBehavior(new GravityBehavior2D(new Vec2D(0, 0.1)));
  // compute spacing for string particles
  //float delta=(float)width/(STRING_RES-1);

  //for(int i=0; i<STRING_RES; i++) {
  //  // create particles along X axis
  //  VerletParticle2D p=new VerletParticle2D(i*delta,height/2);
  //  physics.addParticle(p);
  //  // define a repulsion field around each particle
  //  // this is used to push the ball away
  //  physics.addBehavior(new AttractionBehavior2D(p,delta*1,-8));
  //  // connect each particle to its previous neighbour
  //  if (i>0) {
  //    VerletParticle2D q=physics.particles.get(i-1);
  //    VerletSpring2D s=new VerletSpring2D(p,q,delta*0.5,0.1);
  //    physics.addSpring(s);
  //  }
  //}
}
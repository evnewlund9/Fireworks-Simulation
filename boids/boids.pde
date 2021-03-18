//Evan Newlund (newlu004)

PImage bg1;
PImage bg2;
PImage bat;

static int numBoids = 500;
static int numPredators = 0;

Vec2 pos[] = new Vec2[numBoids + 5];
Vec2 vel[] = new Vec2[numBoids + 5];
Vec2 acc[] = new Vec2[numBoids + 5];
int targs[] = new int [5];

float maxSpeed = 40;
float maxPredatorSpeed = 80;
float targetSpeed = 10;
float maxForce = 200;
float radius = 3;
float dt = .1;

float seperationMax = 40;
float attractionMax = 50;
float alignmentMax = 40;
float predatorMax = 150;
float predatorRange = 25;

boolean isWindy = false;
Vec2 windForce = new Vec2(0,400).minus(new Vec2(450,400)).normalized().times(1);
boolean showLight = false;
Vec2 cPos = new Vec2(573, 365);
float cRadius = radius * 47;


void setup(){
  size(1220,925);
  bg1 = loadImage("lightbulboff.jpg");
  bg2 = loadImage("lightbulbon.jpg");
  bat = loadImage("bat.png");
  smooth();
  //Initial boid positions and velocities
  for (int i = 0; i < numBoids; i++){
    pos[i] = new Vec2(200+random(300),200+random(200));
    vel[i] = new Vec2(-1+random(2),-1+random(2));  //TODO: Better random angle
    vel[i].normalize();
    vel[i].mul(maxSpeed);
  }
  
  strokeWeight(2); //Draw thicker lines 
}

void draw(){
  if (showLight) background(bg2);
  else background(bg1);
  noLights();
  noStroke();
  fill(128,128,128);
  for (int i = 0; i < numBoids + numPredators; i++){
    if (i >= numBoids){
        fill(255,0,0);
        image(bat,pos[i].x, pos[i].y);
    }
    else{
      circle(pos[i].x, pos[i].y,radius*2); 
    }
  }
  
   for (int i = 0; i < numBoids + numPredators; i++){
     acc[i] = new Vec2(0,0);
     Vec2 avgPos = new Vec2(0,0);
     Vec2 avgVel = new Vec2(0,0);
     int aCount = 0;
     int vCount = 0;
     for (int j =0; j < numBoids + numPredators; j++){
       float dist = pos[i].minus(pos[j]).length();
       if (dist > 0.01 && dist < seperationMax){ //Seperation Force
         Vec2 seperationForce =  pos[i].minus(pos[j]).normalized();
         if (dist <= radius && i < numBoids && j < numBoids){ //Both i and j are boids
           seperationForce.setToLength(600.0/pow(dist,2));
         }
         else if (dist > radius && i < numBoids && j < numBoids){ 
           seperationForce.setToLength(200.0/pow(dist,2));
         }
         else if (dist < predatorMax && i < numBoids && j >= numBoids){ //j is a predator
           if (dist < radius*2){
             pos[i] = new Vec2(-1, -1);
             vel[i] = new Vec2(0,0);
             acc[i] = new Vec2(0,0);
           }
           seperationForce.setToLength(2000.0/pow(dist,2));
         }
         else if (i >= numBoids){//i is a predator
           seperationForce.setToLength(0);
           if (targs[i - numBoids] != -1 && pos[i].distanceTo(pos[targs[i - numBoids]]) > predatorRange){
             targs[i - numBoids] = -1;
             vel[i] = new Vec2(-1+random(2),-1+random(2)); 
             vel[i].normalize();
             vel[i].mul(10.0);
           }
           if (dist < predatorRange && j < numBoids && (targs[i - numBoids] == -1 || dist < pos[i].distanceTo(pos[targs[i - numBoids]]))){ //j is a boid in range
               targs[i - numBoids] = j;
           }
         }
         acc[i] = acc[i].plus(seperationForce);
       }
       if (dist < attractionMax && dist > 0){ //Sum neighbor positions for Attraction Force
         avgPos.add(pos[j]);
         aCount += 1;
       }
       if (dist < alignmentMax && dist > 0){ //Sum neighbor velocities for Alignment Force
          avgVel.add(vel[j]);
          vCount += 1;
       }
     }
    avgPos.mul(1.0/aCount);
    Vec2 attractionForce;
    if (aCount >= 1 && !showLight){ //Attraction Force
      if (i < numBoids || targs[i - numBoids] == -1){
      attractionForce = avgPos.minus(pos[i]);
      attractionForce.normalize();
      attractionForce.times(6.0);
      attractionForce.clamp(maxForce);
      }
      else{
        attractionForce = pos[targs[i - numBoids]].minus(pos[i]);
        attractionForce.normalize();
        attractionForce.times(20.0);
      }
      acc[i] = acc[i].plus(attractionForce);
    }
    else if (showLight){
      attractionForce = cPos.minus(pos[i]);
      attractionForce.normalize();
      attractionForce.times(75.0);
      acc[i] = acc[i].plus(attractionForce);
    }
    avgVel.mul(1.0/vCount);
    if (vCount >= 1){ //Alignment Force
      if (i < numBoids){
        Vec2 alignmentForce = avgVel.minus(vel[i]);
        alignmentForce.normalize();
        acc[i] = acc[i].plus(alignmentForce.times(2.0));
      }
    }
    Vec2 targetVel = vel[i];
    if (i < numBoids || targs[i - numBoids] == -1){
      targetVel.setToLength(targetSpeed);
      Vec2 goalSpeedForce = targetVel.minus(vel[i]);
      goalSpeedForce.clamp(maxForce);
      acc[i] = acc[i].plus(goalSpeedForce);    
    
    //Wander force
    Vec2 randVec = new Vec2(1-random(2),1-random(2));
    acc[i] = acc[i].plus(randVec.times(10.0)); 
   }
   else{
     targetVel.setToLength(targetSpeed * 2.0);
     Vec2 goalSpeedForce = targetVel.minus(vel[i]);
     goalSpeedForce.clamp(maxForce);
     acc[i] = acc[i].plus(goalSpeedForce);
   }
  }
   for (int i = 0; i < numBoids + numPredators; i++){ //update
    pos[i] = pos[i].plus(vel[i].times(dt));
    if (pos[i].distanceTo(cPos) < (cRadius+radius) && showLight){
      Vec2 normal = pos[i].minus(cPos).normalized();
      pos[i] = cPos.plus(normal.times(cRadius + radius));;
      Vec2 B = projAB(vel[i], normal);
      vel[i] = vel[i].minus((B.times(1.8)));
    }
    if (isWindy){
     acc[i] = acc[i].plus(windForce);
     }
    vel[i] = vel[i].plus(acc[i].times(dt));

    if (vel[i].length() > maxSpeed){
      if (i < numBoids){
        vel[i].clamp(maxSpeed);
      }
      else{
        vel[i].clamp(maxPredatorSpeed);
      }
    }
    
    // Loop the world if agents fall off the edge.
    if (pos[i].x < 0) pos[i].x += width;
    if (pos[i].x > width) pos[i].x -= width;
    if (pos[i].y < 0) pos[i].y += height;
    if (pos[i].y > height) pos[i].y -= height;
  }
 }
 
void keyPressed(){
  if (key == 'l'){
    showLight = true;
  }
  if (key == 'w'){
    isWindy = true;
  }
}

void keyReleased(){
  if (key == 'l'){
    showLight = false;
  }
  if (key == 'w'){
    isWindy = false;
  }
}

void mousePressed(){
  if (numPredators < 5){
    pos[numBoids + numPredators] = new Vec2(mouseX,mouseY);
    vel[numBoids + numPredators] = new Vec2(-1+random(2),-1+random(2));  //TODO: Better random angle
    vel[numBoids + numPredators].normalize();
    vel[numBoids + numPredators].mul(15.0);
    targs[numPredators] = -1;
    
    for (int i =0; i < numBoids + numPredators; i++){
      float dist = pos[numBoids + numPredators].minus(pos[i]).length();
      if (dist <= predatorRange || (targs[numPredators] != -1 && (dist < pos[numBoids + numPredators].minus(pos[targs[numPredators]]).length()))){
        targs[numPredators] = i;
      }
    }
    numPredators++;
  }
}

public Vec2 projAB(Vec2 a, Vec2 b){
  return b.times(a.x*b.x + a.y*b.y);
}

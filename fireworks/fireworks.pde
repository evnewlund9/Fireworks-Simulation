//Evan Newlund (newlu004)

Camera camera;
PImage bg;
ArrayList<Particle> particles;

int maxParticles;
float radius;
float dt = 0.1;
boolean multiColor;
Vec3 gravity;


void setup(){
  size(960,600, P3D);
  camera = new Camera();
  bg = loadImage("bg.jpg");
  particles = new ArrayList<Particle>();
  
  maxParticles = 20000;
  radius = 5.0;
  dt = 0.1;
  multiColor = false;
  gravity = new Vec3 (0, 0.3, 0);
}
  
void draw(){
  background(bg);
  noLights();
  
  camera.Update(1.0/frameRate);

 for(int i = particles.size() - 1; i >= 0; i--){
   Particle p = particles.get(i);
   p.update(dt);
   if (p.life > p.maxLife || p.pos.y > 120){
     particles.remove(i);
   }
   else{
     p.display();
   }
 }
}

void keyPressed(){
  if(key == 'c') multiColor = !multiColor;
  if(key == 'm'){
    for(int i = 0; i < 25; i++){
      explode();
    }
  }
  else camera.HandleKeyPressed();
}

void keyReleased(){camera.HandleKeyReleased();}

void mousePressed(){
  explode();
}

void explode(){
  Vec3 col = new Vec3(random(0,255), random(0,255), random(0,255));
  int size = int(random(1000, 2000));
  print(mouseX);
  print(" ");
  print(mouseY);
  print("\n");
  for (int i = 0; i < size; i++){
    if (particles.size() < maxParticles){
      if (multiColor){
        col = new Vec3(random(0,255), random(0,255), random(0,255));
      }
      addLine(col);
    }
  }
}


void addLine(Vec3 col){
  int size = int(random(5, 10));
  Vec3 mousePos = new Vec3 (0, -500, 0);
  float r = radius * sqrt(random(0,3));
  float theta = 2 * PI * random(0,1);
  Vec3 vel = new Vec3(r * sin(theta), r * cos(theta), random(-0.5, 0.5));
  if (random(0,1) >= 0.8){ 
    vel.add(new Vec3(0,-1.5,0));
  }
  for(int i = 0; i < size; i++){
    int maxLife = int(random(50, 100));
    if (random(0,1) > 8) {maxLife += int(random(10, 50));}
    particles.add(new Particle(mousePos, vel, gravity, col, maxLife));
  }
}

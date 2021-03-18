class Particle{
  
  public Vec3 pos;
  public Vec3 vel;
  public Vec3 acc;
  public Vec3 col;
  public int life, maxLife;
  
  public Particle(Vec3 pos, Vec3 vel, Vec3 acc, Vec3 col, int maxLife){
    this.pos = pos;
    this.vel = vel;
    this.acc = acc;
    this.col = col;
    this.maxLife = maxLife;
    this.life = 0;
  }
  
  public void update(float dt){
    pos.add(vel.times(dt));
    vel.add(acc.times(dt));
    life++;
  }
  
  public void display(){
    int transparency = 0;
    if (maxLife - life <= 5) transparency = int(random(0,1) * (life / 3.0));
    stroke(col.x,col.y,col.z, 255 - life - transparency);
    point(pos.x, pos.y, pos.z);
    
  }
}

program pitfall;

const
    sw=320;
    sh=240;
    fpsec=50;
    floor=110;
    base=210;
    offx=8;
    offy=25;

global
    vineid=0;
    pitid=0;
    crocsid=0;
    harryid=0;

    alive=1;

    level=196;
        // sounds
    struct fx
        death;
        fall;
        hit1;
        hit2;
        jump;
        swing;
        treasure;
    end

    framecount=0;
    soundspeed=256*((fpsec*1000)/50)/1000;

begin

    load_sounds();
    set_fps(fpsec,2);
    load_fpg("pitfall/pitfall.fpg");
    set_mode(sw*1000+sh);

    put(file,3,sw/2,sh/2);//+offy-1);

    write_int(0,0,64,0,&level);

//graph=3;
//region=1;
//ctype=c_scroll;
    size=100;
    x=sw/2;//304/2;
    y=sh/2;//191/2;
//flags=4;
    z=1024;
    //next_level();

    game();

    loop
        if(alive)
            framecount++;
        end
        frame;

    end

    frame;

end


process game()

begin

level=196;

vineid=vine();
trees();
path();
pit();
crocs();
snake();
scorpion();

harryid=harry();
son.y=134;

loop
    frame;
end

end


process vine()


private
x1=sw/2-8;
y1=30+offy;

d=0;
d1=0;


begin
region=1;
draw_z=257;

d=draw(1,60,0,0,x1,y1,x,y);
d1=draw(1,60,0,0,x1,y1,x,y);

loop
if(level%3==0)
x=x1+sin(framecount*2*700)/15;
y=-379+ cos(abs(x1-x)*180)/2;
else
x=x1;y=y1;
end
move_draw(d,60,15,x1,y1,x,y);
move_draw(d1,60,15,x1+1,y1,x+1,y);

frame;

end


end

process crocs()

begin

y=117+offy;
x=sw/2-9;
clone
x-=32;
end
clone
x+=32;
end

graph=32;

loop
if(level&1)
size=0;
else
size=100;
end

if(framecount%120<60)
graph=32;
else
graph=33;
end

frame;
end

end

process rope();

begin
    region=1;

    x=152;
    y=30;
    graph=9;
    size=40;

    loop
        angle=get_angle(father);
        frame;
    end

end


process trees()

begin

    graph=5;
    x=sw/2-8;
    y=82+offy;

    clone
        graph=4;
//        z=-256;
        x=sw/2;
        y=30+offy;
    end

    loop
        frame;
    end

end

process snake();

begin

x=249;
y=144;

loop
graph=34+(framecount&1);
frame;

end

end

process path();

begin

    graph=7;
    x=sw/2;
    y=151;
    //flags=4;

    loop
        frame;
    end

end



process swing()

begin

    graph=2;

end


process dropdeath()

begin
alive=0;
x=father.x;
y=father.y;
graph=father.graph;
flags=father.flags;
father.graph=0;
//signal(father.father,s_sleep_tree);
signal(father,s_kill);
//frame;
define_region(2,x-10,y-10,20,20);
region=2;
//debug;
playsound(fx.death);
//debug;
while(y<150)
y++;
frame(200);

end

harry();

end


process harry()

private
    walk=1;
    yx=3;
    d=0;
    dir=0;
    swinging=0;
    ladder=0;
    above=1;

    topy=109+offy;

    boty=164+offy;
    groundy;
    crocid=0;

begin
    graph=10;

    x=24+offx;
    y=offy+25;
    write_int(0,0,0,0,&x);
    write_int(0,0,16,0,&y);

loop

    crocid=collision(type crocs);

    if(crocid)
        if(crocid.graph==33)
            if(x<crocid.x+5)
                dropdeath();
                return;
            end
        end
    end

    if(x>92 && x< 214 && collision(type pit))
        //debug;
        y++;
        crocid=collision(type crocs);
        y--;

        if(!crocid)
            dropdeath();
            return;
        end
    end

    if(above==0)
        groundy=boty;
    else
        groundy=topy;
    end

    if(swinging)
        x=vineid.x;
        y=vineid.y;
        graph=2;
        if(key(_down))
            swinging=0;
            yx=0;
            y+=4;
            if(flags==0)
                dir=1;
            else
                dir=-1;
            end
            if(key(_left))
                dir=-1;
                flags=1;
            end

            if(key(_right))
                dir=1;
                flags=0;
            end
        end
    end

    if(y==groundy)

        if(key(_space) && yx!=-5)
            yx=-5;
            playsound(fx.jump);

        end

        if(key(_right))
            flags=0;
            dir=1;
            x=x+1;
            if(x%3==0)
                walk=walk+1;
                if(walk==6) walk=1; end
            end

            graph=10+walk;
        end


        if(key(_left))
            flags=1;
            dir=-1;
            x=x-1;

            if(x%3==0)
                walk=walk+1;
                if(walk==6) walk=1; end
            end

            graph=10+walk;

        end

        if(!key(_right) && !key(_left))
            walk=0;
            graph=10;
            dir=0;
        end
    end

    if(y<groundy || yx==-5)
        if(yx<0 && y>vineid.y-10 && y<vineid.y+15
            && x>vineid.x-10 && x<vineid.x+10)
            if(swinging==0)
                swinging=1;
                playsound(fx.swing);
            end
        else
            d++;
            if(d%3==0)
                y+=yx;

                if(alive==1)
                    graph=11;

                    if(yx<8)
                        yx++;
                    end
                end
            end
            x=x+dir;
            if(y>=groundy)
                y=groundy;
                alive=1;
            end

        end

    end
    if(x<16) x=304; level_left(); end
    if(x>304) x=16; level_right(); end

    //end


frame;
end

end

process pit()

private
    oldlevel=0;
    psize=100;
    pdir=0;

begin
   // region=1;
   // ctype=c_scroll;
    x=(sw/2)-8;
    y=119+offy;
    graph=8;
    size=100;

    loop
        if(level!=oldlevel)
            oldlevel=level;
            if(level&1)
                graph=8;
            else
                graph=9;
                size=100;
            end
        end

        if(framecount%130==1)
            if(psize==100)
                pdir=-5;
            else
                pdir=5;
            end
        end

        if(pdir!=0)
            if((pdir<0 && psize>0) || (pdir>0 && psize<100))
                psize+=pdir;
            end
        end

        if(level&1) // pit
            size=psize;
        end

        frame;

    end

end

process scorpion();


begin

x=sw/2;
y=168+offy;

graph=30;

loop;
if(framecount&1 && alive)
    if(x<harryid.x)
        x++;
        flags=0;
    end

    if(x>harryid.x)
        x--;
        flags=1;
    end

    if(harryid.x!=x)
        graph=30+((x/4)&1);
    end
end

frame;

end

end



function load_sounds();

begin

    fx.death=load_wav("pitfall/death.wav",0);
    fx.fall=load_wav("pitfall/fall.wav",0);
    fx.hit1=load_wav("pitfall/hit1.wav",0);
    fx.hit2=load_wav("pitfall/hit2.wav",0);
    fx.jump=load_wav("pitfall/jump.wav",0);
    fx.swing=load_wav("pitfall/swing.wav",0);

end


function playsound(num)

begin

    x=sound(num,256,256);
    change_sound(x,256,soundspeed);

end


function level_right()

private
t;
begin
//write_int(0,0,64,0,&t);
//write_int(0,0,80,0,&level);

t=(level>>7) XOR (level>>5) XOR (level>>4) XOR (level>>3);
level = (level<<1)%256;
level |= (t & 1);

//frame;
//debug;

end

function level_left()

private
t;
begin
write_int(0,0,64,0,&t);
write_int(0,0,80,0,&level);
t=(level>>6) XOR (level >>5) XOR ( level >> 4) XOR level;

//t=(level>>7) XOR (level>>5) XOR (level>>4) XOR (level>>3);
level = (level>>1);
level |= ((t<<7)%256);

//frame;
debug;


end


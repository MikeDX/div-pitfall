program pitfall;

const
    sw=320;
    sh=240;
    fpsec=50;
    floor=110;
    base=210;

global
    vineid=0;
    level=0;

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

    put(file,6,sw/2,sh/2);

//graph=1;

size=10;
x=320;
y=400;

game();

loop
    framecount++;
frame;

end

loop

//size=50+sin(timer[0]*720)/(1000/45);
x=sw/2+cos(timer[0]*720)/(1000/240);

if(size<40)
flags=4;
else
flags=0;
end

frame;

end

end

process game()

begin

level=1;

vineid=vine();
trees();
path();
harry();
pit();

loop
    frame;
end

end


process vine()


private
x1=sw/2-8;
y1=30;

d=0;
d1=0;


begin

draw_z=1024;
//graph=9;

//write_int(0,0,0,0,&x);
//write_int(0,0,16,0,&y);


//x1=320;
//y1=0;

d=draw(1,136,0,0,x1,y1,x,y);
d1=draw(1,136,0,0,x1,y1,x,y);

//graph=2;
//size=100;
//z=-1024;
//rope();
loop

x=x1+sin(framecount*2*700)/15;
y=(-10-sh-x1)+cos(abs(x1-x)*180)/2;
move_draw(d,56,15,x1,y1,x,y);
move_draw(d1,56,15,x1+1,y1,x+1,y);

frame;

end


end

process rope();

begin

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
    y=85;

    clone
        graph=4;
        x=sw/2;
        y=30;
    end

    loop
        frame;
    end

end


process path();

begin

    graph=7;
    x=sw/2;
    y=127;

    loop
        frame;
    end

end



process swing()

begin

graph=2;

end


process harry()
private
walk=1;
yx=0;
d=0;
dir=0;
swinging=0;

topy=111;
boty=200;

begin

x=60;
y=topy;

loop
    if(swinging)
        x=vineid.x;
        y=vineid.y;
        graph=2;
        if(key(_down))
            swinging=0;
            yx=0;
            y+=4;
            dir=0;

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

    if(y==topy)

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

    if(yx<10 && y<topy || yx==-5)
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
                yx++;
                graph=11;
            end
            x=x+dir;
            if(y>topy) y=topy; end

        end

    end
    if(x<16) x=304; level--; end
    if(x>304) x=16; level++; end

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

    x=(sw/2)-8;
    y=120;
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

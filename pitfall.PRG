program pitfall;

const
sw=320;
sh=240;


global
vineid=0;


begin

set_fps(60,2);

load_fpg("pitfall/pitfall.fpg");
set_mode(sw*1000+sh);

put(file,6,sw/2,sh/2);

//graph=1;

size=10;
x=320;
y=400;

vineid=vine();
trees();
path();
harry();


loop

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


process vine()

private
x1=sw/2-8;
y1=30;

d=0;
d1=0;


begin

draw_z=1024;

//write_int(0,0,0,0,&x);
//write_int(0,0,16,0,&y);


//x1=320;
//y1=0;

d=draw(1,136,0,0,x1,y1,x,y);
d1=draw(1,136,0,0,x1,y1,x,y);

//graph=2;
//size=100;
//z=-1024;
loop

x=x1+sin(timer[0]*900)/15;
y=(-10-sh-x1)+cos(abs(x1-x)*180)/2;
move_draw(d,56,15,x1,y1,x,y);
move_draw(d1,56,15,x1+1,y1,x+1,y);

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
    //z=1024;
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

begin

graph=10;

x=60;
y=110;

loop
    if(swinging)
        x=vineid.x;
        y=vineid.y;
        graph=2;
        if(key(_down))
            swinging=0;
            yx=0;
            y+=4;
        end
    end

    if(y==110)

        if(key(_space))
            yx=-5;
         //   y-=6;
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

    if(yx<10 && y<110 || yx==-5)
        if(yx<0 && y>vineid.y-10 && y<vineid.y+10
            && x>vineid.x-5 && x<vineid.x+5)
            swinging=1;
        else
            d++;
            if(d%3==0)
                y+=yx;
                yx++;
                graph=11;
            end
            x=x+dir;
            if(y>110) y=110; end

        end

    end
    if(x<16) x=304; end
    if(x>304) x=16; end

    //end


frame;
end

end

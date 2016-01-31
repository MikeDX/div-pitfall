program pitfall;

const
sw=320;
sh=240;

begin

set_fps(60,2);

load_fpg("pitfall/pitfall.fpg");
set_mode(sw*1000+sh);

put(file,6,sw/2,sh/2);

//graph=1;

size=10;
x=320;
y=400;

vine();
trees();
path();


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

graph=2;
size=100;
z=-1024;
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

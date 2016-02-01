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
    harryid=0;

    alive=1;

    // level data
    tarpit=0;
    shifting=0;
    snake=0;
    wall=0;
    bg=0;
    treasure=0;
    logs=0;
    holes=0;
    vine=0;
    crocs=0;


    level=0;
    bit[8];

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
    write_int(0,0,0,0,&tarpit);
    write_int(0,0,8,0,&shifting);
    write_int(0,0,16,0,&snake);
    write_int(0,0,24,0,&wall);
    write_int(0,0,32,0,&bg);
    write_int(0,0,40,0,&treasure);
    write_int(0,0,48,0,&logs);
    write_int(0,0,56,0,&holes);
    write_int(0,0,64,0,&vine);
    write_int(0,0,72,0,&crocs);

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
    level_update();

    vineid=vineproc();

    // 1 of 4 different tree types
    trees();

    // 1 of 3 paths (solid, ladder, ladder + holes)
    path();

    // pit or quicksand
    pit();

    crocproc();

    // snake or fire
    object();

    // left, right or no wall
    //walls();

    // player-chasing scorpion (or walls)
    scorpion();

harryid=harry();
//son.y=134;
son.y=164+offy;

loop
    frame;
end

end


process vineproc()


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
if(vine)
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

process crocproc()

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
if(!crocs)
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

process object();

begin

x=249;
y=144;

loop
    x=249;
    graph=0;
    flags=0;
    if(snake==1)
        graph=34+(framecount&1);
    end

    if(snake==2)
        size=200;
        graph=16+rand(0,1);
    end

    if(logs>0)
        if(logs<4)
            graph=20-((framecount/4)&1);
            x=offx+6+288-(framecount%288);
        end

    end

    frame;

end

end


process path();

begin

    //graph=7;
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

process death()
private
    t=0;
begin
alive=0;
x=father.x;
y=father.y;
graph=father.graph;
flags=father.flags;

playsound(fx.death);
//debug;
while(t<fpsec*2)
t++;
frame;
end

harryid=harry();
son.y=y-30;
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
//signal(father,s_kill);
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

harryid=harry();

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
    og=0;
    topy=109+offy;

    boty=164+offy;
    groundy;
    crocid=0;

begin
    graph=10;

    x=24+offx;
    y=offy+25;
    //write_int(0,0,0,0,&x);
    //write_int(0,0,16,0,&y);

loop

    crocid=collision(type crocproc);

    if(y>topy)
        above=0;
    else
        above=1;
    end

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
        y+=2;
        crocid=collision(type crocproc);
        y-=2;

        if(!crocid)
            dropdeath();
            return;
        end
    end

    if(above==0)
        groundy=boty;
        if(holes==0)
            og=graph;
            graph=10;
            crocid=collision(type scorpion);
            graph=og;
            if(crocid)
                death();
                return;
            end
        end
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
    if(x<16 || key(_q)) x=304; level_left(); end
    if(x>304 || key(_w)) x=16; level_right(); end

    while(key(_q) || key(_w))
        frame;
    end
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

        if(shifting==0)
            size=100;
        end

    if(tarpit>0)
//        if(level!=oldlevel)
//            oldlevel=level;
//            if(level&1)
            if(tarpit==1)
                graph=8;
            else
                graph=9;
//                size=100;
            end
//        end

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

        if(shifting) // pit
            size=psize;
        end
    else
        graph=0;
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

if(holes==0)
    if(graph==21)
        graph=30;
        x=sw/2;
    end

    y=168+offy;

    if(framecount&1 && alive)
        if(x<harryid.x-5)
            x++;
        end

        if(x>harryid.x+5)
            x--;
        end

        if(x<harryid.x)
            flags=0;
        else
            flags=1;
        end

        if(harryid.x!=x)
            graph=30+((x/4)&1);
        end
    end
else

    graph=21;
    y=159+offy;
    if(bit[7]==1)
        x=280;
    else
        x=20;
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

// pitfall levels LFSR

function level_right()

private
    t;
begin
    t=(level>>7) XOR (level>>5) XOR (level>>4) XOR (level>>3);
    level = (level<<1)%256;
    level |= (t & 1);

    level_update();

end


function level_left()

private
    t;
begin
    t=(level>>6) XOR (level >>5) XOR ( level >> 4) XOR level;

    level = (level>>1);
    level |= ((t<<7)%256);

    level_update();

end


function level_update()

private

begin

    for(x=0;x<8;x++)
        bit[x]=(level>>x)&1;
    end

    tarpit=0;
    shifting=0;
    snake=0;
    wall=0;
    bg=0;
    treasure=0;
    logs=0;
    holes=0;
    vine=0;
    crocs=0;

    // setup level

    switch(7&(level>>3))

        case 0:  // hole with ladder
            holes=1;
            end

        case 1:  // hole with ladder + 2 holes
            holes=3;
            end

        case 2:  // tar pit + vine
            //debug;
            vine=1;
            tarpit=1;
            end

        case 3:  // quicksand with vine
            vine=1;
            tarpit=2;
            end

        case 4:  // croc pit
            crocs=1;
            tarpit=2; // lake
            if(bit[1])  // plus vine if bit 1
                vine=1;
            end

            end

        case 5:  //shifting tar pit + treasure
            tarpit=1;
            shifting=1;
            treasure=(level&3); // one of 4 types
            end

        case 6:  // shifting tarpit + vine
            tarpit=1;
            shifting=1;
            vine=1;
            end

        case 7:  // shifting quicksand
            shifting=1;
            tarpit=2;
            end
    end

    if(crocs==0 && treasure==0)
        x=level&7;
        if(x<6)
            logs=x+1;
        else
            if(x==6)
                snake=2;
            end
            if(x==7)
                snake=1;
            end
        end
    end



end

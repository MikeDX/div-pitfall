/*

########################################

ATARI 2600 PITFALL REMAKE

Made with div games studio in 48 hours

TODO: 
	Eng game when time is 00:00
	

see http://github.com/MikeDX/div-pitfall for license information

(c) 2016 MikeDX

########################################

*/

program pitfall;

const

    sw=320;     // screen width
    sh=240;     // screen height
    fpsec=50;   // target fps
    offx=8;     // screen x offset
    offy=25;    // screen y offset

global

    vineid=0;   // vine id
    harryid=0;  // player id

    alive=1;

    // level data decoded from level number
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

    struct time
        m=20;
        s=0;
    end

    lives=2;

    score=2000;

    level=0;

    // level as binary
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

    load_sounds();
    set_fps(fpsec,2);

    //load_pal("PAL/visibone.PAL");

    load_fpg("pitfall/pitfall.fpg");
    set_mode(sw*1000+sh);
    intro();


    put(file,3,sw/2,sh/2);

    // the virtual screen
    define_region(7,offx,offy,304,192);

    game();

    loop

        if(alive)
            framecount++;
        end
        frame;

    end

end


process game()

private

    firstrun=1;
    nextpal=0;
begin

    vineid=vineproc();

    showtimer();
    showscore();
    showlives();

    // 1 of 4 different tree types
    trees();

    // 1 of 3 paths (solid, ladder, ladder + holes)
    path();
    ladderproc();

    // pit or quicksand
    pit();

    crocproc();

    // snake or fire
    object();

    // player-chasing scorpion (or walls)
    scorpion();

    harryid=harry();
    son.y=134;

loop
    if((key(_enter) && lives<0) || firstrun)
        alive=0;
        level=196;
        time.m=0;
        time.s=0;
        lives=2;
        firstrun=0;
        score=2000;

        signal(harryid,s_kill_tree);
        signal(type death, s_kill_tree);
        signal(type dropdeath, s_kill_tree);

        harryid=harry();
        son.y=134;
        //alive=1;
        framecount=0;
        level_update();

        //lives=2;
        //level=192
        nextpal=timer[0]+100;
    end

    if(lives==-1)
        // roll activision logo / copyright
    end
    frame;
end

end


process showtimer();

private

    om=0;
    os=0;

begin
    y=45;

//    write_int(0,0,8,3,&timer[0]);

loop

    if(om!=time.m || os!=time.s)
        x=113;
        y=18;

        map_put(file,4,60+(time.s%10),x,y);
        map_put(file,4,60+(time.s/10)%10,x-16,y);
        map_put(file,4,70,x-32,y);
        x-=48;

        if(time.m>0)
            map_put(file,4,60+(time.m%10),x,y);
        else
            map_put(file,4,70,x,y);
        end

        map_put(file,4,60+(time.m/10)%10,x-16,y);

        om=time.m;
        os=time.s;
    end


    if(framecount%50==49)
        time.s--;

        if(time.s<0)
            time.s=59;
            time.m--;
        end

        while(framecount%fpsec==fpsec-1)
            frame;
        end

     end

    frame;
end


end


process showscore();

private
    oldscore=999;
    len=0;
    string strscore="";
begin

  //  write_int(0,0,0,0,&score);
  //  write_int(0,40,0,0,&len);
    loop

        if(score!=oldscore)
            oldscore=score;
            strscore=itoa(score);
            len=strlen(strscore);
            x=113;
            y=5;
            while(len>0)
                map_put(file,4,60+(oldscore%10),x,y);
                //,0,100,4);
                oldscore=oldscore/10;
                x-=16;
                len--;
            end
            map_put(file,4,73,x,y);
            map_put(file,4,73,x-16,y);


            oldscore=score;
        end

        frame;

    end


end



process showlives();

begin

    x=36;
    y=45;
    z=-256;

    loop

        graph=71+(2-lives);

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
    //region=1;
    draw_z=257;

    d=draw(1,60,0,0,x1,y1,x,y);
    d1=draw(1,60,0,0,x1,y1,x,y);

    loop

    if(vine)
        x=x1+sin(framecount*2*700)/15;
        y=-373+cos(abs(x1-x)*180)/2;
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
    z=-21;
    clone
        x-=32;
    end

    if(x==(sw/2-9))
        clone
            x+=32;
        end
    end

    //write_int(0,x,y+16,4,&x);

    graph=32;

    loop
        if(!crocs)
            size=0;
        else
            size=100;

            if(framecount%200<100)
                graph=32;
            else
                graph=33;
            end
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

private
oldlevel;

begin
    x=sw/2;
    y=81+offy;

    clone
        graph=4;
        y=30+offy;
    end

    loop
        if(level!=oldlevel)
            if(graph!=4)
                graph=50+((level>>6)&3);
                oldlevel=level;
            end
        end

        frame;
    end

end

process object();

private

    logid=0;
    fc=0;
    logbits[3];
    lcount=0;
    oldlevel=0;

begin

    x=249;
    y=144;
    z-=30;
    region=7;

    clone
        logid=1;
    end

    if(logid==0)
        clone
            logid=2;
        end
    end

    loop

        if(level!=oldlevel)
            lcount=310;
            oldlevel=level;
        end

        x=249;
        y=144;
        graph=0;
        flags=0;

        if(logid==0)
            if(treasure)
                flags=0;

                switch(level&3)

                    case 0: // money bag
                        graph=44;
                    end

                    case 1: // silver bar
                        graph=47+rand(0,alive);
                    end

                    case 2: // gold bar
                        graph=45+rand(0,alive);
                    end

                    case 3: // diaond ring
                        graph=49;
                    end

                end
            end

            if(snake==1) // cobra
                graph=34+(framecount&1);
            end

            if(snake==2) // fire
                graph=16+rand(0,alive);
            end
        end

        if(logs>0)
            graph=20;

            if(logs<5)
                logbits[0]=1;
                logbits[1]=bit[0];
                logbits[2]=bit[1];

                if(logbits[logid])
                    graph=20-((framecount/4)&1);

                    fc=(lcount+365)-32*logid;

                    x=offx+6+288-(fc%310);
                    y=144+(x%16<3);
                else
                    graph=0;
                end
            else
                graph=0;

                if(logs==5)
                    x-=8;
                end

                if(bit[0] || logid==0)
                    graph=20;

                    if(logid==2)
                        x+=64;
                    end

                    if(logid==1)
                        x=55;
                    end

                end
            end
        end

        if(alive)
            lcount++;
        end

        frame;

    end

end


process path();

begin

    x=sw/2;
    y=151;
    z=256;

    loop
        graph=40+holes;
        frame;
    end

end

process ladderproc()

begin

    x=sw/2;
    y=149;
    graph=18;
    z=-10;

    clone
        graph=39;
        x=sw/2-8;
        y=155;
        z=256;
    end

    if(graph==18)
        clone
            graph=37;
            y=175;
            x=sw/2-8;
            z=256;
        end
    end

    if(graph==18)
        clone
            graph=38;
            y=154;
            x=100;
            z=256;
        end
    end

    if(graph==18)
        clone
            graph=38;
            y=154;
            x=204;
            z=256;
        end
    end


    loop
        size=0;

        if(holes==3)
            size=100;
        else
            if(holes==1 && (graph == 39 || graph == 37))
                size=100;
            end
        end

        if(graph==18)
            size=100;
        end

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

    frame(fps*200);

    lives--;
    if(lives>=0)
        harryid=harry();

        // put scorpion in his place
        if(holes==0)

            t=get_id(type scorpion);
            t.x=sw/2;
        end

        if(y>160)
            son.y=y-25;
            define_region(2,18,167,26,32);
        else
            son.y=y-60;
            define_region(2,24,80,35,95);
        end

        harryid.region=2;

    else
    // keep harry on screen when game over
        loop
            frame;
        end
    end

end



process dropdeath()

begin
    alive=0;
    x=father.x;
    y=father.y;
    graph=father.graph;
    flags=father.flags;
    father.graph=0;
    z=-21;

    define_region(2,x-10,y-10,20,20);
    region=2;
    playsound(fx.death);

    while(y<160)
        y++;
        frame;
    end

    frame(fps*25);

    lives--;
    if(lives>=0)
        harryid=harry();
    end
    define_region(2,24,80,35,95);
    harryid.region=2;

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
    lastspace=0;
    vinebox=0;

begin
    graph=10;

    x=24+offx;
    y=offy+25;

//    write_int(0,0,0,0,&x);
//    write_int(0,0,8,0,&y);
//    write_int(0,0,16,0,&groundy);

    z=-40;

    if(lives==2)
        while(!key(_left) && !key(_right) && !key(_space))
            frame;
        end
        alive=1;
    end

    //timer[0]=0;

    //vinebox = draw(3,255,7,7,0,0,vineid.x,vineid.y);
loop
    if(holes==0)
        z=-40;
    else
        z=0;
    end

   // crocid=collision(type crocproc);

    if(y>topy)
        above=0;
    else
        above=1;
    end

    if(above==0)
        groundy=boty;

        if(holes==0)
            og=graph;
            y-=3;
            graph=10;
        end

        crocid=collision(type scorpion);

        if(holes==0)
            y+=3;
            graph=og;
        end
        //crocid=collision(type scorpion);

        if(crocid)
            if(holes==0) // hit a scorpion
                death();
                return;
            else
                // hit a wall
                playsound(fx.hit1);
                if(flags==0)
                    if(crocid.x>x)
                        x-=3;
                        if(dir!=0)
                            dir=-1;
                            flags=1;
                        end
                    end
                else
                    if(crocid.x<x)
                        x+=3;
                        if(dir!=0)
                            dir=1;
                            flags=0;
                        end
                    end
                end
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
        end

    end

    if(y==groundy)
        region=0;
        if(key(_space) && yx!=-4 && !lastspace)
            yx=-4;
            playsound(fx.jump);
            lastspace=1;
        end
        if(!key(_space))
            lastspace=0;
        end

        if(key(_right))
            flags=0;
            dir=1;
            if(yx>0)
                x=x+1;

                if(x%3==0)
                    walk=walk+1;

                    if(walk==6)
                        walk=1;
                    end

                end

                graph=10+walk;

            end
        end


        if(key(_left))
            flags=1;
            dir=-1;
            if(yx>0)
                x=x-1;

                if(x%3==0)
                    walk=walk+1;
                    if(walk==6)
                        walk=1;
                    end
                end

                graph=10+walk;
            end

        end

        if(!key(_right) && !key(_left))
            walk=0;
            graph=10;
            dir=0;
        end
    end

    og=graph;
    graph=10;

    if(y==topy && x>92 && x< 214 && collision(type pit))
        y+=2;
        crocid=collision(type crocproc);
        y-=2;
        if(crocid)
            if(crocid.graph==33 && x<crocid.x+2)
                dropdeath();
                return;
            end
        else
            dropdeath();
            return;
        end
    end

    graph=og;
    //move_draw(vinebox,255,7,vineid.x-10,vineid.y-20,vineid.x+10,vineid.y+20);

    if(y<groundy || yx<5)
    //!collision(type ladderproc))
       // if(vine==1)

            if(yx<0 && y>vineid.y-20 && y<vineid.y+20
                && x>vineid.x-10 && x<vineid.x+10)

                if(swinging==0)
                    swinging=1;
                    playsound(fx.swing);
                end
         //   end

        else
            d++;
            if(d%3==0)
                y+=yx;

                if(alive==1 || y>groundy-32)
                    //if(
                    graph=11;
                    if(alive==1)
                        if(yx<8)
                            yx++;
                        else

                        end
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

    if(logs==0 && treasure==0)

        og=graph;
        y-=2;
        crocid=collision(type object);
        y+=2;
        graph=og;

    else
        crocid=collision(type object);
    end

    if(crocid)
        if(treasure)
            score+=(treasure+2)*1000;
            treasure=0;
            crocid.graph=0;
            playsound(fx.treasure);
        else
            if(swinging==0)
                if(crocid.graph==19 || crocid.graph==20)
                    graph=22;

                    if(score>0)
                        score--;
                    end

                    playsound(fx.hit1);
                else
                    death();
                    return;
                end
            end
        end
    end



    if(holes>0 && y==topy || y==boty)
        og=graph;
        graph=10;
        crocid=collision(type ladderproc);
        graph=og;
        if(crocid)
            if ( (crocid.graph==39 || crocid.graph==37 || crocid.graph==18) )

                repeat

                if(y<boty && key(_down))
                    graph=36;
                    x=152;
                    y++;
                end

                if(y!=topy && swinging==0 && collision(type object))
                    if(score>0)
                        score--;
                    end
                    //debug;
                    playsound(fx.hit1);
                    y+=2;
                end

                if(y>topy && key(_up))
                    if(y>topy+15)
                        graph=36;
                        x=152;
                        y--;
                    end

                    if(y<topy+16)
                        if(key(_left) || key(_right))
                            y=topy;
                            yx=-4;

                            if(key(_left))
                                dir=-1;
                            else
                                dir=1;
                            end
                        end
                    end

                end

                if(y>topy && y<boty && graph!=11)
                    graph=36;
                    flags=((y/8)&1);
                end

                if(y!=topy && y!=boty)
                    frame;
                end
                until(y==topy || y==boty);
            end

            if(y==topy && yx>=0)

                if(x>crocid.x-(5+4*(crocid.graph==38)) && x<crocid.x+5+4*(crocid.graph==38))

                    graph=10;
                    groundy=boty;
                    playsound(fx.fall);
                    if(score>100)
                        score-=100;
                    else
                        score=0;
                    end


                    while(y<boty)
                        y++;
                        if(y>groundy-16)
                            graph=11;
                        end

                        frame;

                        //region=0;

                    end

                 end
             end
        end
    end

    if(x<18 || key(_q)) x=295; level_left(1+(3*(above==0))); end

    if(x>295 || key(_w)) x=18; level_right(1+(3*(above==0))); end


    while((key(_q) || key(_w)))
        frame;
    end

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
    z=-20;
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

        if(framecount%150==1)
            if(psize==100)
                pdir=-5;
            else
                pdir=5;
            end
        end

        if(pdir!=0 && alive)
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

private
oldlevel;

begin

x=sw/2;
y=168+offy;

graph=30;

loop;
    if(level!=oldlevel)
        x=sw/2;
        oldlevel=level;
    end

/*
    if(alive==0 && harryid!=0)
        if(harryid.y<y-10 && x<sw/2)
            x=sw/2;
        end

    end
*/
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

    // not a scorpion, a wall! ls


    graph=21;
    y=158+offy;

    if(bit[7]==1)
        x=273;
    else
        x=35;
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
    fx.treasure=load_wav("pitfall/treasure.wav",0);

end


process playsound(num)

private

psound=0;
begin
    //write_int(0,0,0,0,&psound);

    if(is_playing_sound(psound))
        stop_sound(psound);
    end

    psound=sound(num,256,256);
    change_sound(psound,256,soundspeed);

end

// pitfall levels LFSR

function level_right(count)

private
    t;
begin
    while(count>0)
        t=(level>>7) XOR (level>>5) XOR (level>>4) XOR (level>>3);
        level = (level<<1)%256;
        level |= (t & 1);
        count--;
    end

    level_update();
    scrolloff(1);

end


function level_left(count)

private
    t;
begin
    while(count>0)
        t=(level>>6) XOR (level >>5) XOR ( level >> 4) XOR level;

        level = (level>>1);
        level |= ((t<<7)%256);
        count--;
    end

    level_update();
    scrolloff(-1);

end

process scrolloff(dir)

private

scroll_map=0;

begin

return;

scroll_map=new_map(304,191,152,95,1);

screen_copy(file,0,23,0,0,320,240);

map_put(file,scroll_map,23,152,95);

graph=scroll_map;

x=sw/2;
y=sh/2;
size=100;
z=-50;
//graph=23;
//debug;
define_region(3,offx,0,304,sh);
region=3;
flags=4;
//debug;

while(!out_region(id,3))
y+=dir*8;
size-=4;
//y+=2;
frame;
end
//debug;
unload_map(scroll_map);

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
            treasure=1; // one of 4 types
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

function intro()

begin

    graph=1;

    x=160;
    y=120;

    timer[0]=0;

    while(timer[0]<200)
        frame;
    end

    fade_off();
    while(fading)
        frame;
    end
    fade_on();

end


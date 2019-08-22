%% STIMULUS PRESENTATION FOR BASELINE BLOCKS DURING EEG CAPING
curText = ['<color=ffffff>In this experiment, you will hear either the word'...
    '<color=ffff00><b>"Beer"<b> <color=ffffff>or the word <color=ffff00><b>"Pier.'...
    '"<b> <color=ffffff>\n\n'...
    'If you hear "beer," click the box labelled "beer."\nIf you hear "pier,"'...
    'click the box labelled "pier."\n\nIf you are unsure, '...
    'make your best guess.\n\n'...
    'This is the first part of the experiment while the experimenter'...
    'is putting electrodes on your head'...
    'There is only one block in this part'...
    '<b>Press "spacebar" to begin.<b>'];
%curText = 'In this experiment, you will hear either the word "BEER" or the word "PIER" \n\n\n\n If you hear "BEER", click the box labelled "BEER". \n\n If you hear "PIER" click the box labelled "PIER". \n\n If you are unsure, make your best guess.\n\n\n\n Every once in a while, you can take a break \n\n and we will show you a short cartoon with the same sounds in the background. \n\n You just need to watch the cartoon and relax and ignore the sounds. \n\n\n\n Press SPACEBAR to begin';
DrawFormattedText2(curText,'win',win,'sx',100,'sy',400,'xalign','left','yalign','top','wrapat',59);
%DrawFormattedText(win, curText, 'center', 'center', white);
Screen('Flip',win);
oldtype = ShowCursor(0);
KbWait([],2);

repNumber = 2; %%the baseline block should be repeated 4 times
baselineTN = 25*repNumber;

presentation = [];
for i = 1:repNumber
    A = randperm(25);
    presentation=[presentation, A];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% BASELINE BLOCKS  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for j=1:baselineTN %change the trial number
    %Flip Screen to be Beer Pier blocks
    [scrX,scrY] = RectCenter(winRect);
    rect1 = CenterRectOnPoint([0 0 500 500],scrX-325,scrY);
    rect2 = CenterRectOnPoint([0 0 500 500],scrX+325,scrY);   
    Screen('FillRect', win, [135 206 250], rect1);
    Screen('FillRect', win, [135 206 250], rect2);
    curText='Beer                                                     Pier';
    DrawFormattedText(win,curText,'center','center',[0 0 0]);
    Screen('Flip',win);

    signal=BPCWmaster_baseline.Stimuli{presentation(j),7};

    BPCWresp(j,1:6)=BPCWmaster_baseline.Stimuli(presentation(j),1:6);

    signaltwo=[signal,signal]';

    PsychPortAudio('FillBuffer', pamaster, signaltwo);
    t1 = PsychPortAudio('Start', pamaster, 1, 0, 1);
    PsychPortAudio('Stop', pamaster , 1, 1);

    %get user response
    [clicks,x,y,whichButton]=GetClicks(win,0);
    while ~((((x>=scrX-575)&&(x<=scrX-75))&&((y>=scrY-250)&&(y<=scrY+250)))||(((x>=scrX+75)&&(x<=scrX+575))&&((y>=scrY-250)&&(y<=scrY+250))))
        [clicks,x,y,whichButton]=GetClicks(win,0);
    end
    %record user response (in correct location)
    if (((x>=scrX-575)&&(x<=scrX-75))&&((y>=scrY-250)&&(y<=scrY+250))) %clicked "beer"
        BPCWresp{j,7}='beer'; 
        %LOOK LATER

        %Flip Screen to be Beer Pier blocks
        [scrX,scrY] = RectCenter(winRect);
        rect1 = CenterRectOnPoint([0 0 500 500],scrX-325,scrY);
        rect2 = CenterRectOnPoint([0 0 500 500],scrX+325,scrY);
        Screen('FillRect', win, [255 255 204], rect1);
        Screen('FillRect', win, [135 206 250], rect2);
        curText='Beer                                                     Pier';
        DrawFormattedText(win,curText,'center','center',[0 0 0]);
        Screen('Flip',win);

        WaitSecs(1);

    else %clicked "pier"
        BPCWresp{j,7}='pier';
        %LOOK LATER

        %Flip Screen to be Beer Pier blocks
        [scrX,scrY] = RectCenter(winRect);
        rect1 = CenterRectOnPoint([0 0 500 500],scrX-325,scrY);
        rect2 = CenterRectOnPoint([0 0 500 500],scrX+325,scrY);
        Screen('FillRect', win, [135 206 250], rect1);
        Screen('FillRect', win, [255 255 204], rect2);
        curText='Beer                                                     Pier';
        DrawFormattedText(win,curText,'center','center',[0 0 0]);
        Screen('Flip',win);

        WaitSecs(1);
    end
end
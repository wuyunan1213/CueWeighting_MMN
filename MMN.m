%BeerPier script
%
%   FILE NAME       : Beer vs Pier VOT and F0 test
%   DESCRIPTION     : This is a
%
%RETURNED ITEMS
%
%   XXX_BPCW_date   : *.mat and *.csv containing sID, statistical
%                     categories, and subject responses in noise and quiet.
%
%(C)This script was written by Charles Wu with help of Tim Noland.
% Holt Lab
%    Last Edit 08/16/2019
%

%% INITIALIZATION
close all;
clear all; %#ok<CLALL>
clc;

cd('C:\Users\Lab User\Desktop\Experiments\Charles\EEG')

fprintf('Beginning BP behavioral pilot protocol.\n\n')

% Step One: Connect to and properly initialize RME sound card
fprintf('Entablishing connection to sound card...\n')

Devices=PsychPortAudio('GetDevices');
if isempty(Devices)
    error ('There are no devices available using the selected host APIs.');
else
    q=1;
    while ~strcmp(Devices(q).DeviceName,'ASIO MADIface USB') && q <= length(Devices)
        q=q+1;
    end
end

fs = Devices(q).DefaultSampleRate;
fprintf('\nDefault sampling rate is %.1f\n', fs)

playDev = Devices(q).DeviceIndex;
stimchanList = [1,2,14];
pamaster = PsychPortAudio('Open',playDev,1,4,fs,3,[],[],[12,13,14]);

% Step Two: Yippee, we're online. Now, we establish the subject's ID number
% and load in Master List and Response templates.
fprintf('\nPlease follow the prompt in the pop-up window.\n\n')

subj = '007'; %char(inputdlg('Please enter the subject ID number:','Subject ID'));

fprintf('Loading sound files. This may take a moment...')
load('BPmaster_baseline.mat');
A = load('BPmaster_canonical.mat');
load('BPmaster_reverse.mat');
load('BPmaster_test.mat');
load('BPresp.mat');
fprintf('Done.\n')

%Step Three: Launch PsychToolbox; display instructions
screens = Screen('Screens');
screenNumber = max(screens);
black = BlackIndex(screenNumber);
white = WhiteIndex(screenNumber);
grey = white / 2;
Screen('Preference','DefaultFontSize',40);
Screen('Preference','VisualDebugLevel',1);
Screen('Preference', 'TextAntiAliasing', 2);
Screen('Preference', 'TextRenderer', 1);
Screen('Preference','SyncTestSettings', 0.002);
%%auditory
[win,winRect] = Screen('OpenWindow',screenNumber,black);
[width,height] = Screen('WindowSize',screenNumber);
Screen('TextFont', win, 'Helvetica');
Screen('BlendFunction', win, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

responseKeyIdx = KbName('space');
enabledkeys = RestrictKeysForKbCheck(responseKeyIdx);

%%%step four, present the baseline block first. This is done while the
%%%participant is being capped. Only one block


%% STIMULUS PRESENTATION FOR BASELINE BLOCKS DURING EEG CAPING
curText = '<color=ffffff>In this experiment, you will hear either the word'...
    '<color=ffff00><b>"Beer"<b> <color=ffffff>or the word <color=ffff00><b>"Pier.'...
    '"<b> <color=ffffff>\n\n'...
    'If you hear "beer," click the box labelled "beer."\nIf you hear "pier,"'...
    'click the box labelled "pier."\n\nIf you are unsure, '...
    'make your best guess.\n\n'...
    'This is the first part of the experiment while the experimenter'...
    'is putting electrodes on your head'...
    'There is only one block in this part'...
    '<b>Press "spacebar" to begin.<b>';
%curText = 'In this experiment, you will hear either the word "BEER" or the word "PIER" \n\n\n\n If you hear "BEER", click the box labelled "BEER". \n\n If you hear "PIER" click the box labelled "PIER". \n\n If you are unsure, make your best guess.\n\n\n\n Every once in a while, you can take a break \n\n and we will show you a short cartoon with the same sounds in the background. \n\n You just need to watch the cartoon and relax and ignore the sounds. \n\n\n\n Press SPACEBAR to begin';
DrawFormattedText2(curText,'win',win,'sx',100,'sy',400,'xalign','left','yalign','top','wrapat',59);
%DrawFormattedText(win, curText, 'center', 'center', white);
Screen('Flip',win);
oldtype = ShowCursor(0);
KbWait([],2);

repNumber = 4;
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


Screen('TextFont', win, 'Helvetica');
Screen('BlendFunction', win, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

responseKeyIdx = KbName('space');
enabledkeys = RestrictKeysForKbCheck(responseKeyIdx);

curText = '<color=ffffff>Now we are ready to start the second part.'...
    'You will be doing the same thing as what you did in the first part.'...
    'There will be 26 blocks. At the end of each block, you will watch a'...
    'short video to take a break.\n\n You will hear the same sounds'...
    'embedded in the videos but you don ignore the sounds embedded'...
    'in the video\n\n<b>Press "spacebar" to begin.<b>';
DrawFormattedText2(curText,'win',win,'sx',100,'sy',400,'xalign','left','yalign','top','wrapat',59);
%DrawFormattedText(win, curText, 'center', 'center', white);
Screen('Flip',win);
oldtype = ShowCursor(0);
KbWait([],2);
%Step Five: Play the canonical and reverse blocks with the MMN block at the
%end
blockNumber = 2; %%change the block number, which should always be even
trialNumber = 2;
trig_len = 441; %10ms of trigger length

presentation = [];
for i=1:blockNumber
    A=randperm(12);
    B=randperm(12);
    C=randperm(12);
    presentation=[presentation;A(1:12),B(1:12),C(1:12)];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%% STIMULUS PRESENTATION FOR CANONICAL AND REVERSE  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i=1:blockNumber %%change the block number
    curText = [sprintf('Beginning block %d of %d.',i,blockNumber) '\n\nPress "spacebar" to continue.'];
    DrawFormattedText(win,curText,'center','center',[255 255 255]);
    Screen('Flip',win);
    KbWait([],2);
    %%%Training block(canonical/reverse)
    for j=1:trialNumber %change the trial number

        %Flip Screen to be Beer Pier blocks
        [scrX,scrY] = RectCenter(winRect);
        rect1 = CenterRectOnPoint([0 0 500 500],scrX-325,scrY);
        rect2 = CenterRectOnPoint([0 0 500 500],scrX+325,scrY);   
        Screen('FillRect', win, [135 206 250], rect1);
        Screen('FillRect', win, [135 206 250], rect2);
        curText='Beer                                                     Pier';
        DrawFormattedText(win,curText,'center','center',[0 0 0]);
        Screen('Flip',win);
        
        %%%%CHANGE THIS WHOLE CHUNK BASED ON THE NEW STIMULI SHEET
        %Play sound...include noise or not
        repIndex = baselineTN+(i-1)*trialNumber+j;
        
        if i <= blockNumber/2 %%present the canonical blocks first
            stim=BPCWmaster_can.Stimuli(presentation(i,j),1:8);
            %%%canonical exposure category 'b':111
            %%%canonical exposure category 'p':112
            %%%canonical test1: 121
            %%%canonical test2: 122
            
            %%%reverse exposure category 'b':211
            %%%reverse exposure category 'p':212
            %%%reverse test1: 221
            %%%reverse test2: 222
            %%%separate the 4 different trigger conditions:
            trig = zeros(length(stim{8}),1);
            if (stim{7} == 'exposure' && stim{2} < 15)
                trig(find(stim{8}>.005,1):(find(stim{8}>.005,1)+trig_len-1))...
                = trignum2scalar(111)*ones(trig_len,1);
            
            elseif (stim{7} == 'exposure' && stim{2} > 15)
                trig(find(stim{8}>.005,1):(find(stim{8}>.005,1)+trig_len-1))...
                = trignum2scalar(112)*ones(trig_len,1);
            
            elseif (stim{7} == 'test' && stim{2} < 15)
                trig(find(stim{8}>.005,1):(find(stim{8}>.005,1)+trig_len-1))...
                = trignum2scalar(121)*ones(trig_len,1);
            
            elseif (stim{7} == 'test' && stim{2} > 15)
                trig(find(stim{8}>.005,1):(find(stim{8}>.005,1)+trig_len-1))...
                = trignum2scalar(122)*ones(trig_len,1);
            end
        
            BPCWresp(repIndex,1:7)=stim(1:7);%%%fill the stim info
            
        else %%%%then the reverse blocks
            stim=BPCWmaster_rev.Stimuli{presentation(i,j),7};
            trig = zeros(length(stim{8}),1);
            %%4 different trigger conditions
            if (stim{7} == 'exposure' && stim{2} < 15)
                trig(find(stim{8}>.005,1):(find(stim{8}>.005,1)+trig_len-1))...
                = trignum2scalar(211)*ones(trig_len,1);
            
            elseif (stim{7} == 'exposure' && stim{2} > 15)
                trig(find(stim{8}>.005,1):(find(stim{8}>.005,1)+trig_len-1))...
                = trignum2scalar(212)*ones(trig_len,1);
            
            elseif (stim{7} == 'test' && stim{2} < 15)
                trig(find(stim{8}>.005,1):(find(stim{8}>.005,1)+trig_len-1))...
                = trignum2scalar(221)*ones(trig_len,1);
            
            elseif (stim{7} == 'test' && stim{2} > 15)
                trig(find(stim{8}>.005,1):(find(stim{8}>.005,1)+trig_len-1))...
                = trignum2scalar(222)*ones(trig_len,1);
            end
           
            BPCWresp(repIndex,1:7)=stim(1:7);%%%fill the stim info

        end
       
        %%%concatenate all 3 channels of signals
        signalthree=[stim{8},stim{8},trig]';
        
        PsychPortAudio('FillBuffer', pamaster, signalthree);
        t1 = PsychPortAudio('Start', pamaster, 1, 0, 1);
        PsychPortAudio('Stop', pamaster , 1, 1);

        %get user response
        [clicks,x,y,whichButton]=GetClicks(win,0);
        while ~((((x>=scrX-575)&&(x<=scrX-75))&&((y>=scrY-250)&&(y<=scrY+250)))||(((x>=scrX+75)&&(x<=scrX+575))&&((y>=scrY-250)&&(y<=scrY+250))))
            [clicks,x,y,whichButton]=GetClicks(win,0);
        end
        %record user response (in correct location)
        if (((x>=scrX-575)&&(x<=scrX-75))&&((y>=scrY-250)&&(y<=scrY+250))) %clicked "beer"
            BPCWresp{repIndex,8}='beer'; 
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
            BPCWresp{repIndex,8}='pier';
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
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% MMN BLOCK WITH  SILENT MOVIES  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    















%%%%%%%%%UNDONE!!!! 
    %%%first create 1s silent period
    silence = zeros(fs,1);
    %%%Then create our counterbalancing conditions such that in odd blocks,
    %%%we have b as standard, p as deviant and in even blocks, we have the
    %%%opposite
    %%%we do this by loading different scripts depending on the block
    %%%number
    
    if (mod(i, 2) ~= 0) %%load different
        v = [1,1,1,2];
        last = [1,1,2];
        standard = BPCWmaster_test.Stimuli{1,8};
    else
        v = [1,2,2,2];
        last = [1,2,2];
        standard = BPCWmaster_test.Stimuli{2,8}; 
    end
    
    %%start 'building' our speech sequence and store in vector 'build'
    %%and store the trigger vector in 'trigger_build'
    build = [];
    trigger_build = [];
    for b = 1:6
        pos = v(randperm(numel(v)));
        pos_end = last(randperm(numel(last)));     

        ISI_length = 700; %%%ISI should not be jittered!!
        ISI = int16(ISI_length/1000*44100);

        if (mod(b, 2) ~= 0) %%all the blocks of 3 standard stimuli in odd numbers
            Block = [zeros(ISI,1);standard;...
                     zeros(ISI,1);standard;...
                     zeros(ISI,1);standard];
            %%%MMN test1: 221
            %%%MMN test2: 222
            trig = zeros(length(standard),1);
            trig(find(standard>.005,1):(find(standard>.005,1)+trig_len-1))...
            = trignum2scalar(????)*ones(trig_len,1);
        
            trig_Block = [zeros(ISI,1);trig;...
             zeros(ISI,1);trig;...
             zeros(ISI,1);trig];
        %%%%THE TRIGGER NUMBER BELOW IS A LITTLE TRICKY
        %%%%THINK OF A GOOD WAY TO DEAL WITH THIS
        elseif (mod(b, 2) == 0) && (b<6) %% randomize standard+deviant blocks in <6 even numbers
            s1 = BPCWmaster_test.Stimuli{pos(1),7}; s2 = BPCWmaster_test.Stimuli{pos(2),7};
            s3 = BPCWmaster_test.Stimuli{pos(3),7}; s4 = BPCWmaster_test.Stimuli{pos(4),7};
            
            t1 = 50+pos(1); t2 = 50+pos(2); t3 = 50+pos(3); t4 = 50+pos(4);
            Block = [zeros(ISI,1); s1;...
                     zeros(ISI,1); s2;...
                     zeros(ISI,1); s3;...
                     zeros(ISI,1); s4];
                 
            trig1 = zeros(length(s1),1);
            trig1(find(s1>.005,1):(find(s1>.005,1)+trig_len-1))...
            = trignum2scalar(t1)*ones(trig_len,1);
        
            trig2 = zeros(length(s2),1);
            trig2(find(s2>.005,1):(find(s2>.005,1)+trig_len-1))...
            = trignum2scalar(t2)*ones(trig_len,1);
        
            trig3 = zeros(length(s3),1);
            trig3(find(s3>.005,1):(find(s3>.005,1)+trig_len-1))...
            = trignum2scalar(t3)*ones(trig_len,1);
        
            trig4 = zeros(length(s4),1);
            trig4(find(s4>.005,1):(find(s4>.005,1)+trig_len-1))...
            = trignum2scalar(t4)*ones(trig_len,1);
        
            trig_Block = [zeros(ISI,1);trig1;...
             zeros(ISI,1);trig2;...
             zeros(ISI,1);trig3;
             zeros(ISI,1);trig4];
         

        elseif (b==6) %%randomize the last block
            s1 = BPCWmaster_test.Stimuli{pos_end(1),7};
            s2 = BPCWmaster_test.Stimuli{pos_end(2),7};
            s3 = BPCWmaster_test.Stimuli{pos_end(3),7};
            
            Block = [zeros(ISI,1); s1;...
                     zeros(ISI,1); s2;...
                     zeros(ISI,1); s3];
                 
            t1 = 50+pos_end(1); t2 = 50+pos_end(2); t3 = 50+pos_end(3);
                 
            trig1 = zeros(length(s1),1);
            trig1(find(s1>.005,1):find(s1>.005,1)+trig_len-1)...
            = trignum2scalar(t1)*ones(trig_len,1);
        
            trig2 = zeros(length(s2),1);
            trig2(find(s2>.005,1):find(s2>.005,1)+trig_len-1)...
            = trignum2scalar(t2)*ones(trig_len,1);
        
            trig3 = zeros(length(s3),1);
            trig3(find(s3>.005,1):find(s3>.005,1)+trig_len-1)...
            = trignum2scalar(t3)*ones(trig_len,1);
        
            trig_Block = [zeros(ISI,1);trig1;...
            zeros(ISI,1);trig2;...
            zeros(ISI,1);trig3];
        end

        build = [build; Block];
        trigger_build = [trigger_build; trig_Block];

    end

    signal = [silence; build; silence];
    trigger_MMN = [silence; trigger_build; silence];
    
    % Select screen for display of movie:
    moviename = ['C:\Users\Lab User\Desktop\Experiments\Charles\EEG\Movies\Movie_', int2str(i),'.MP4' ];
    screenid = max(Screen('Screens'));
    % Open 'windowrect' sized window on screen, with black [0] background color:
    screen=max(Screen('Screens'));
    % Open movie file:
    movie = Screen('OpenMovie', win, moviename, [], [], 2);

    % Start playback engine:
    Screen('PlayMovie', movie, 1);
    rect1=SetRect(400,400,1000,900);

    signalthree=[signal,signal, trigger_MMN]';
    PsychPortAudio('FillBuffer', pamaster, signalthree);
    t1 = PsychPortAudio('Start', pamaster, 1, 0, 0);

    % Playback loop: Runs until end of movie or ke   ypress:
    while(1)
        % Wait for next movie frame, retrieve texture handle to it
        tex = Screen('GetMovieImage', win, movie);

        % Valid texture returned? A negative value means end of movie reached:
        if tex<=0
            % We're done, break out of loop:
            break;
        end

        % Draw the new texture immediately to screen:
        Screen('DrawTexture', win, tex, [], rect1);

        % Update display:
        Screen('Flip', win);

        % Release texture:
        Screen('Close', tex);
    end

    PsychPortAudio('Stop', pamaster , 1, 1);


    % Stop playback:
    Screen('PlayMovie', movie, 0);
    % Close movie:
    Screen('CloseMovie', movie);
end

%% CLOSEOUT
% Close PTB Screen
Screen('CloseAll');

% Save subject response file. As of 01.14.2019, the data saves as BOTH a
% *.mat and *.csv file for extra security. Also, there's a if/else
% statement that will warn the experimenter if an issue with the *.csv save
% process occurs, lest it tells you everything saved properly.

fnamemat = ['C:\Users\Lab User\Desktop\Experiments\Charles\EEG\Results\' subj '_BP_' datestr(datetime('now'),'yyyymmdd') '.mat'];
save(fnamemat,'BPCWresp')

sIDcell=cell(length(BPCWresp),1);
sIDcell(:)={subj};
BPCWresp=cell2table([sIDcell,BPCWresp]);
fnamecsv = ['C:\Users\Lab User\Desktop\Experiments\Charles\EEG\Results\' subj '_BP_' datestr(datetime('now'),'yyyymmdd') '.csv'];
BPCWresp.Properties.VariableNames={'sID','Sound','VOT','F0','VOTlevel','F0level','StimulusType','Response'};
writetable(BPCWresp,fnamecsv);

% Disconnect RME
fprintf('Disconnecting PsychPortAudio...\n')
PsychPortAudio('Close')
fprintf('PsychPortAudio successfully disconnected. Goodbye!\n')

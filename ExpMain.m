% function ExpMain
% Paradigm code for cross-situational word learning paradigm, similar to
% Yurovsky & Frank (in press).
% 2014/2/13: Present 2 pictures at a time, and after clicking on one, put a
% box around it.
% 2014/2/20: Most of the training and testing code done
% further thoughts: some secondary task to keep subjects engaged. e.g. have
% arrows during ISI, or, move box from one to another
% 2014/6/5: Stroop task integrated
clear;clc
rng('shuffle');
% %% get the subject code and write a matlab file
subjectCode = input('Please enter the subject ID: ','s');
cd data
fx =dir('*.mat');
for i=1:length(fx)
    if strcmp(fx(i).name(1:end-4),subjectCode)
        subjectCode = [subjectCode '_new'];
    end
end
cd ..
num_example = 8; % second half of the pictures are beep things
presentation_times = 6;

% read in all the images
picdir ='pic_use/';
cd(picdir);
sd = dir('*.bmp');
sd =sd(1:2*num_example);
sd =sd(randperm(2*num_example));
[a,b,c]=size(imread(sd(1).name));
% then the sounds
cd ../words
sdi = dir('*.wav');
for i=1:num_example
    W(i).name = sdi(i).name;
    [W(i).wav,Fs] =wavread(W(i).name);
end
W=W(randperm(num_example));
cd ..

train_list = MakeTrainMat(num_example,presentation_times);

scale = 0.6;
a = a*scale;
b = b*scale;
box_size = 10;

% three-column matrix: picture on left, picture on right, and the sound
% end of presentation matrix
% Fs = 44100;      % Samples per second, already defined
t=0:1/Fs:0.3; f= 440;
beepwav=sin(2*pi.*f.*t); % generate the beep sound
% begin the experiment
[wPtr,rect]=Screen('OpenWindow',0); % Open the screen
Screen('TextSize', wPtr, 25);
Screen('TextFont', wPtr, 'Arabic Typesetting');
leftRect  = [rect(3)/2-b-box_size,rect(4)/2-a/2,rect(3)/2-box_size,rect(4)/2+a/2];
rightRect = [rect(3)/2+box_size,rect(4)/2-a/2,rect(3)/2+b+box_size,rect(4)/2+a/2];
centerRect =[rect(3)/2-b/2,rect(4)/2-a/2,rect(3)/2+b/2,rect(4)/2+a/2];

% ShowCursor('Arrow');
HideCursor();
PresentText(wPtr,'Thank you for participating in our study! Press Space to start.');
PresentText(wPtr,'When you are ready to start the study, press Space.');
Trial_Length = 3;
% training phase
for i=1:size(train_list,1)
    starttime = GetSecs();
    picture = [picdir sd(train_list(i,1)).name];
    % bad structure; images should be read into memory before the start of the experiment
    faceData = imread(picture);
    faceData1 = imresize(faceData, scale);
    faceTexture1 = Screen('MakeTexture',wPtr,im2uint8(faceData1));
    if train_list(i,3) == 1
        Screen('DrawTexture',wPtr,faceTexture1,[],leftRect);
    else
        Screen('DrawTexture',wPtr,faceTexture1,[],rightRect);
    end
    picture = [picdir sd(train_list(i,2)).name];
    faceData = imread(picture);
    faceData2 = imresize(faceData, scale);
    faceTexture2 = Screen('MakeTexture',wPtr,im2uint8(faceData2));
    if train_list(i,3) == 1
        Screen('DrawTexture',wPtr,faceTexture2,[],rightRect);
    else
        Screen('DrawTexture',wPtr,faceTexture2,[],leftRect);
    end
    Screen('Flip',wPtr);
    if train_list(i,1)<num_example+1
        PlaySound(W(train_list(i,1)).wav,Fs,wPtr);
    else
        PlaySound(beepwav,Fs,wPtr);
    end
end
PresentText(wPtr,'Great! Now, do you know which objects greeble labels with beeps. Press Space to continue.');
% % % test phase
test_res1 = zeros(2*num_example,3);
test_res2 = zeros(2*num_example,3);

list =1:2*num_example;
test_seq1 = list(randperm(length(list)));
% first, test the ones that occured with beeps
for i=1:2*num_example
    starttime = GetSecs();
    picture = [picdir sd(test_seq1(i)).name];
    str = 'Did this occur with a beep?';
    [res, secs] = PresentPicText(wPtr,centerRect,picture,str,{'y','n'});
    test_res1(i,1) = res;
    test_res1(i,2) = secs-starttime;
end
PresentText(wPtr,'Next, do you know what the objects are called? Press Space to continue.');
% test part 2
% randomization: how to test?
% for every word, 3 times, 1 with true referent, 1 with a foil, 1 with a
% beep object
test_seq2 = TestMat(num_example,3);
for i=1:3*num_example
    starttime = GetSecs();
    picture = [picdir sd(test_seq2(i,2)).name];
    str = ['Is this ' W(test_seq2(i,1)).name(1:end-4) '?'];
    [res, secs] = PresentPicTextSound(wPtr,centerRect,picture,str,{'y','n'},W(test_seq2(i,1)).wav,Fs);
    test_res2(i,1) = res;
    test_res2(i,2) = secs-starttime;
end
PresentText(wPtr,'You are done! Press Space to exit.');
% % % % end of test phase
fclose('all');
clear Screen;
clc
save(['data/' subjectCode '.mat']);

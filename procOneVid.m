%%
%this function will convert and save one video into a series of images sync'ed by filename
%specifically, by finding portions of video where hand drops below certain
%threshold
function res = procOneVid(fileData, incr)
    [status,message,messageid] = mkdir(fileData.writeImgDir);
%     if(length(message) > 0)
%         disp(strcat('Already processed ',baseFileName));
%         return;
%     end
    %read video file obj
    latchBound = ones(10,1);%hard code latch boundaries to minimize jitter - this is # of frames to ignore transition
    latchBound = 20 * latchBound;
    latchBound(6:8,1) = 10;
    videoFileReader = vision.VideoFileReader(fileData.readFileName);
    %need the file reader to get the audio too.
    tmpVidObj = VideoReader(fileData.readFileName);
    %frameRate = tmpVidObj.FrameRate;
    numFramesInVid = tmpVidObj.NumberOfFrames;
    clearvars tmpVidObj;

    frame = 0;
    %need to latch around hand entering/leaving screen bound (190+ y val)
    isInBoundRgn = 0;
    isMakingLetter = 0;
    ltrLtchVal = 0;
    latchCount = 0;
    numFramesToProc = numFramesInVid-frame;
    index = 0;
    ltrLatch = zeros(numFramesToProc, 1);
    clipThresh = zeros(numFramesToProc, 1);
    curLtr = 0;
    frameNum = 0;
    fh = figure;
    while index < numFramesToProc      
        % get the next frame
        [videoFrame]      = step(videoFileReader);
        %find region of lightgray to white pixels in videoFrame - assume
        %this is hand
        bw = (mean(videoFrame(1:200,20:150),3) > .5);
        stats = regionprops('table',bw,'Centroid',...
        'MajorAxisLength','MinorAxisLength');
        centers = stats.Centroid;
        imshow(bw);
        %when between 190 and 200, hand leaving/entering screen
        maxCtrY = max(centers(:,2));
        hardCodeResOff = checkFileAndFrameOff(incr,index);      %check if should ignore latch
        if(~hardCodeResOff)         %if hardCodeResoff then ignore hand position
            if (maxCtrY > 190)   %y > 190 means hand is close to bottom of screen, which is letter transition bounds.
                %entering bounds
                if(isInBoundRgn ~= 1)
                    isInBoundRgn = 1;
                    isMakingLetter = mod((isMakingLetter + 1) ,2);
                    if(isMakingLetter == 0)
                        isMakingLetter = 1;
                    end               
                %staying in bounds
                else

                end
            else
                %was in bounds - leaving bounds
                if(isInBoundRgn == 1)
                    isInBoundRgn = 0;
                    %was making letter, leaving screen, letter finished
                    if(isMakingLetter == 1)
                        isMakingLetter = 0;                                       
                    end
                end

            end
        end
        latchCount = latchCount + 1;
        %custom handling of certain frame bounds
        %incr == 3 is first file (1 and 2 are . and .. )
        hardCodeRes = checkFileAndFrameOn(incr, index);         %check if should turn on latch
%         if(((incr == 3) && ((index == 1780) ||(index == 1970)||(index == 2140) || (index==2665))) ...    %hand modified start locations for alphabet_2, will need more for other alphabets too.
%                 || ((isMakingLetter == 1) && (latchCount > 20)))
        if(hardCodeRes || ((isMakingLetter == 1) && (latchCount > latchBound(incr,1))))
            ltrLtchVal = mod(ltrLtchVal + 1,2);
            frameNum = 0;
            curLtr = curLtr + ltrLtchVal;
            latchCount = 0;
        end
        
        if(ltrLtchVal == 1)
            prefix = '';
            if(frameNum<1000)
                prefix = strcat(prefix,'0');
            end   
            if(frameNum<100)
                prefix = strcat(prefix,'0');
            end   
            if(frameNum<10)
                prefix = strcat(prefix,'0');
            end  

            outAlphaDir = strcat(fileData.writeBaseFileName); 
            [status,message,messageid] = mkdir(outAlphaDir);
            curLtrFileName = strcat(fileData.baseFileName,'_',char(curLtr + 'a' -1)); 
            outFileDir = strcat(outAlphaDir,'\',curLtrFileName); 
            [status,message,messageid] = mkdir(outFileDir);
            outFilename = strcat(outFileDir,'\',curLtrFileName,'_',strcat(prefix,num2str(frameNum)),fileData.writeImgNameExt);   %,'_',strcat(prefix,num2str(index)),fileData.writeImgNameExt));
            %imshow(bw);
            set(fh,'Name',strcat('idx:',num2str(index),'frm:',num2str(frameNum), 'ltr:',char(curLtr + 'a' -1)));
            %disp (outFilename);            
            imwrite(rgb2gray(videoFrame),outFilename);
        end
        index = index + 1;
        frameNum = frameNum + 1;
        %means(index) = mean(mean(mean(videoFrame)));
        clipThresh(index) = isMakingLetter;
        ltrLatch(index) = ltrLtchVal;
        %disp(index);
    end
    xAxis = [1:numFramesToProc];
    plot(xAxis,clipThresh,xAxis,ltrLatch);
    % Clean up
    release(videoFileReader);
    
    disp(strcat('Finished processing ',fileData.baseFileName));
    res = 0;
end

%returns true if hardcoded bound of letter - used to turn bound on if
%missed
%fileIdx is which alphabet
function res = checkFileAndFrameOn(fileIdx, frame)
    res = (((fileIdx == 3) && ((frame == 1780) || (frame == 1970)||(frame == 2140) || (frame==2665))) ...   %hand modified start locations for alphabet_2, will need more for other alphabets too.
        || ((fileIdx == 4) && ((frame == 273) || (frame == 435)|| (frame == 691)|| (frame == 1235)|| (frame == 2127))) ...
        || ((fileIdx == 5) && ((frame == 1467)|| (frame == 1625)|| (frame == 1959))) ...
        || ((fileIdx == 6) && ((frame == 260)|| (frame == -2))) ... %((frame == 205) || (frame == 431) || (frame == -2))) ...
        || ((fileIdx == 7) && ((frame == -1)|| (frame == -2))) ...
        || ((fileIdx == 8) && ((frame == 2145)|| (frame == -2))) ...
    );   

end
%returns true if should ignore latch change due to large hand motions -
%used to turn bound off if erroneously generated
function res = checkFileAndFrameOff(fileIdx, frame)
    res = (((fileIdx == 5) && (((frame >= 944) && (frame <= 946)) || ((frame >= 1051) && (frame <= 1056)) || ((frame >= 1138) && (frame <= 1144)) || ((frame >= 1903) && (frame <= 1907)))) ...
        || ((fileIdx == 8) && (((frame >= 1550) && (frame <= 1560)) || ((frame >= 2235) && (frame <= 2240)) || (frame == -2))) ...
    );   

end
clear;
close all;
clc;

%set to 1 to debug
debug=0;
ltrsList = {'CVEL_17022419/','CVEL_17022410/','CVEL_17022419/','CVEL_17022319/','CVEL_17022311/','CVEL_17022211/','CVEL_17022119/'};

%this will blur and possibly resample images - use to limit file io
%directory in baseDir where synth letters reside
for ltrIdx = 1:size(ltrsList,2)
    %ltrsDir = 'CVEL_17022419/';
    ltrsDir = ltrsList{ltrIdx};
    %flags : idx 1 == perform blur or not; idx 2 == perform resample or not
    flags = [1; 1];
    %blur kernel size over images - avg weighting of "clean" imgs to produce
    %blur - each value is a frame to be used - blur over 3 frames is [1;1;1];
    blrkrnl = [1;1;1];
    %num images to resample to - should be no smaller than 16
    numImgs = 16;

    %process test/train data residing here
    baseDir = 'D:/dart5-1_cs4496/dart/apps/gestureIK/frames/';
    %find all letter folders within this folder
    inputDir = strcat(baseDir, ltrsDir);
    outBaseName = strcat('blur_F',num2str(numImgs),'_',ltrsDir);
    outputDir = strcat(baseDir,outBaseName);        

    blrkrnl = blrkrnl./sum(blrkrnl);

    %build cell array of names of all letter directories within inputDir 
    tmpDirRes = dir(inputDir);
    letterDirs = {tmpDirRes([tmpDirRes.isdir]).name};
    letterDirs(1:2) = []; %ignore . and ..

    if(debug==1)
        disp('Debugging');
        %debugging - only 100 letters, no parallel toolbox
        iters = size(letterDirs,2);
        %make destination directories
        for dirIdx = 1:100
            ltrDir = char(letterDirs(1,dirIdx));
            outDir = strcat(outputDir,ltrDir);
            mkdir(outDir);
        end

        for dirIdx = 1:100
            ltrDir = char(letterDirs(1,dirIdx));
            inDir = strcat(inputDir,ltrDir);
            outDir = strcat(outputDir,ltrDir);
            %mkdir(outDir);
            BlurAndRsmplImgWithKernel(inDir, outDir, blrkrnl, numImgs, flags);    
            disp(dirIdx);
        end
    else
        %not debugging
        iters = size(letterDirs,2);
        %make destination directories
        for dirIdx = 1:iters
            ltrDir = char(letterDirs(1,dirIdx));
            outDir = strcat(outputDir,ltrDir);
            mkdir(outDir);
        end
        delete(gcp('nocreate'));
        %12 logical cores on my laptop, set core configuration via parallel
        %computing toolkit "manage cluster profiles"
        parpool(12);
        parfor dirIdx = 1:iters
            ltrDir = char(letterDirs(1,dirIdx));
            inDir = strcat(inputDir,ltrDir);
            outDir = strcat(outputDir,ltrDir);
            %mkdir(outDir);
            BlurAndRsmplImgWithKernel(inDir, outDir, blrkrnl, numImgs, flags);    
            fprintf('Finished with %i\n',dirIdx);
        end
    end
    fprintf('\nDone with %s\n\n',ltrsDir);
end

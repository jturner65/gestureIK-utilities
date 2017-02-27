clear;
close all;
clc;
%this will blur images
%directory in baseDir where synth letters reside
ltrsDir = 'CVEL_17022419/';
%set to be less than 1 to not resample
numImgs = 16;
%process test/train data
baseDir = 'D:/dart5-1_cs4496/dart/apps/gestureIK/frames/';
%find all letter folders within this folder - relative to location of this script
inputDir = strcat(baseDir, ltrsDir);
outBlurDir = strcat(baseDir,'blur_',ltrsDir);   

%blur kernel size over images - avg weighting of "clean" imgs to produce
%blur - each value is a frame to be used - blur over 3 frames is 
blrkrnl = [1;1;1];
blrkrnl = blrkrnl./sum(blrkrnl);

%build cell array of names of all letter directories within inputDir 
tmpDirRes = dir(inputDir);
letterDirs = {tmpDirRes([tmpDirRes.isdir]).name};
letterDirs(1:2) = []; %ignore . and ..

%make destination directories
for dirIdx = 1:size(letterDirs,2)
    ltrDir = char(letterDirs(1,dirIdx));
    outBlurDir = strcat(outBlurDir,ltrDir);
    mkdir(outBlurDir);
end

%for every letter directory, process every letter
iters = size(letterDirs,2);
delete(gcp('nocreate'));
%12 threads on my laptop
parpool(12);
parfor dirIdx = 1:iters
%for dirIdx = 1:size(letterDirs,2)
    ltrDir = char(letterDirs(1,dirIdx));
    inDir = strcat(inputDir,ltrDir);
    outDir = strcat(outBlurDir,ltrDir);
    %mkdir(outDir);
    BlurImgWithKernel(inDir, outDir, blrkrnl);
    disp(dirIdx);
end

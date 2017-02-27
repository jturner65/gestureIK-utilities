clear;
close all;
clc;
%this will blur 
%directory in baseDir where synth letters reside
ltrsDir = 'CVEL_17022419/';
numImgs = 16;
%process test/train data
baseDir = 'D:/dart5-1_cs4496/dart/apps/gestureIK/frames/';
%find all letter folders within this folder 
inputDir = strcat(baseDir, ltrsDir);
outRsmplDir = strcat(baseDir,'resamp_',ltrsDir);

%build cell array of names of all letter directories within inputDir 
tmpDirRes = dir(inputDir);
letterDirs = {tmpDirRes([tmpDirRes.isdir]).name};
letterDirs(1:2) = []; %ignore . and ..

%make destination directories
for dirIdx = 1:100 %size(letterDirs,2)
    ltrDir = char(letterDirs(1,dirIdx));
    outRSDir = strcat(outRsmplDir,ltrDir);
    mkdir(outRSDir);
end

%for every letter directory, process every letter
% iters = size(letterDirs,2);
% delete(gcp('nocreate'));
% %12 threads on my laptop
% parpool(12);
% parfor dirIdx = 1:100 %iters
for dirIdx = 1:100 %size(letterDirs,2)
    ltrDir = char(letterDirs(1,dirIdx));
    inDir = strcat(inputDir,ltrDir);
    outRSDir = strcat(outRsmplDir,ltrDir);
    %mkdir(outDir);
    ResampleFrameRate(inDir, outRSDir, numImgs);
    disp(dirIdx);
end

clear;
close all;
clc;

%process validation data    
%separate valdiation vids by source of videos
baseDir = 'john/';
%find all letter folders within this folder - relative to location of this script
inputDir = strcat(baseDir,'outLetters/letters/alphabets/');
%for blocks on faces
outBlkHeadDir = strcat(baseDir,'outLetters/letters_block/alphabets/');
%for blocks on hands
outBlkHandDir = strcat(baseDir,'outLetters/letters_blockHands/alphabets/');
%to deblur the hand motion
outDblrDir = strcat(baseDir,'outLetters/letters_deblur/alphabets/');


% Create a cascade detector object.
faceDetector = vision.CascadeObjectDetector();      %can detect mouths too
% to be increased to make sure we only get 1 face (defaults to 4)
faceDetector.MergeThreshold = 10;
%color of face block, 0==black, 1==white - hand should always be white
blockClr = 1;

%for blocks on faces
%outputDir = strcat(baseDir,'outLetters/letters_block/alphabets/');
%for blocks on hands
%outputDir = strcat(baseDir,'outLetters/letters_blockHands/alphabets/');
%blur kernel size over images - avg weighting of "clean" imgs to produce
%blur
dblrkrnl = [1;2;8;2;1];
blrkrnl = [1;1;1];
dblrkrnl = dblrkrnl./sum(dblrkrnl);
blrkrnl = blrkrnl./sum(blrkrnl);

%build cell array of names of all letter directories within inputDir 
tmpDirRes = dir(inputDir);
letterDirs = {tmpDirRes([tmpDirRes.isdir]).name};
letterDirs(1:2) = []; %ignore . and ..

%for every letter directory, process every letter
iters = size(letterDirs,2);
% delete(gcp('nocreate'));
% parpool(12);
% parfor dirIdx = 1:iters
for dirIdx = 1:size(letterDirs,2)
    ltrDir = char(letterDirs(1,dirIdx));
    inDir = strcat(inputDir,ltrDir);
    %cover faces in all images in letterDirs(1,dirIdx) with white block
    %outDir = strcat(outBlkHeadDir,ltrDir);
    %mkdir(outDir);
    %CoverFaceWithBlock(faceDetector, inDir, outDir, blockClr);   
    %cover hand with white block
    %outDir = strcat(outBlkHandDir,ltrDir);
    %mkdir(outDir);
    %CoverHandWithBlock(inDir, outDir);  
    %deblur hand motion
    outDir = strcat(outDblrDir,ltrDir);
    mkdir(outDir);
    %RemoveBlur(inDir, outDir);
    RemoveBlurImgKern(inDir, outDir, dblrkrnl);
end
%build ValidateDataIndexFile_valid16.txt file with directory names in
%output dir
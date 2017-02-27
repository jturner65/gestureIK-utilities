clear;
close all;
clc;
%%%
%this file will preprocess the videos of handwaving to be images in directories based on filename
%base file name comes from iterating loop - will have ext, want to remove it
%% Process videos into images
userDir = 'john/';
inVidFileDir = strcat(userDir,'avis_60fps/');
outPngFileDir = strcat(userDir,'outLetters_60fps/');

tmpDirRes = dir(inVidFileDir);
%only non-directories
vidNamesList = {tmpDirRes(~[tmpDirRes.isdir]).name}';
iters = size(vidNamesList,1);
incr = 1;%incr == 1 is alphabet2 vid, etc.
%only need parallel proc for many files - overhead is expensive for fewer
%than 20 or thereabouts
if(iters < 20)
%     for incr = 4:iters
%         if(vidList(incr).isdir == 1) 
%             continue;
%         end
        baseFileName = vidNamesList{incr};
        disp(strcat('Starting processing :',baseFileName));
        fileData = fileDataStruct(baseFileName,inVidFileDir, outPngFileDir);
        procOneVid(fileData, incr);
%     end;
else
    delete(gcp('nocreate'));
    parpool(12);
    parfor incr = 1:iters
        baseFileName = vidNamesList(incr);
        %procOneVid(baseFileName,inVidFileDir, incr);  
        fileData = fileDataStruct(baseFileName,inVidFileDir, outPngFileDir);
        procOneVid(fileData, incr);

    end;
end;

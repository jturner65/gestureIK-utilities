clear;
close all;
clc;
%this will build an average image of all images within a specified
%directory

%%
% User enterable quantities
%
%whether or not debugging
debug = 0;
%process data residing here
baseDir = 'D:/dart5-1_cs4496/dart/apps/gestureIK/frames/';
%baseDir = 'John/';
%make avg image of all imgs in the clip directories in this dir
%ltrsDirList = {'CVEL_17022419/','CVEL_17022410/','CVEL_17022419/','CVEL_17022319/','CVEL_17022311/','CVEL_17022211/','CVEL_17022119/'};
%ltrsDirList = {'blur_F16_CVEL_17022419/','blur_F16_CVEL_17022410/','blur_F16_CVEL_17022419/','blur_F16_CVEL_17022319/','blur_F16_CVEL_17022311/','blur_F16_CVEL_17022211/','blur_F16_CVEL_17022119/'};
ltrsDir = 'blur_F16_CVEL_17022419/';

%img dims
imgH = 200;
imgW = 200;

%%

%find all letter folders within this folder
inputDir = strcat(baseDir, ltrsDir);

%build cell array of names of all letter directories within inputDir 
tmpDirRes = dir(inputDir);
letterDirs = {tmpDirRes([tmpDirRes.isdir]).name};
letterDirs(1:2) = []; %ignore . and ..
clear tmpDirRes;

numDirs = size(letterDirs,2);

if ((debug== 1) || (numDirs < 100))
    disp('Debugging');
    %only 10 letters if debugging
    
    totImg = zeros(imgH,imgW);
    totNumImgs = 0;
    for dirIdx = 1:numDirs
        ltrDir = char(letterDirs(1,dirIdx));
        inDir = strcat(inputDir,ltrDir);
        %calculates avg for all images within ltrDir
        [sumImg, numCalcImgs] = funcMakeAvgImg(inDir, imgW, imgH);
        totImg = totImg + sumImg;
        totNumImgs = totNumImgs + numCalcImgs;
        if (debug == 1)
            imshow(sumImg);
            %fprintf('Finished with %i giving %i images\n',dirIdx, numCalcImgs);
        end
        fprintf('Finished with %i giving %i images\n',dirIdx, numCalcImgs);
    end
    finalImg = totImg / totNumImgs;
    imshow(finalImg);
    imgBaseName = strcat('avgImage_',strrep(ltrsDir,'/','_'),'.png'); 
    imgOutFileName = strcat(inputDir,imgBaseName);
    imwrite(finalImg,imgOutFileName);   

    fprintf('\nDone with %s\n\n',ltrsDir);    
    
else
    %not debug, use multithreading
    numDirsPerThd = round(numDirs / 12);
    tmpMat = cell(1,12*numDirsPerThd);
    tmpMat(1,1:size(letterDirs,2)) = letterDirs(1,1:end);
    tmpMat = reshape(tmpMat,12,numDirsPerThd);
    %initialize par pool
    delete(gcp('nocreate'));
    %12 logical cores on my laptop, set core configuration via parallel
    %computing toolkit "manage cluster profiles"
    parpool(12);
    parfor dirListRow = 1:12        
        inDirList = tmpMat(dirListRow,:);        
        funcAvgImgsInDirs(inDirList,inputDir,dirListRow,imgW, imgH);
    end
end


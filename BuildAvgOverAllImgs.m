clear;
close all;
clc;

%whether or not debugging
debug = 1;
%this will make an average image of all the flow images within a specified dir
ltrsDir = 'flowOrig/';
%process test/train data residing here
baseDir = 'John/';
%find all letter folders within this folder
inputDir = strcat(baseDir, ltrsDir);

%build cell array of names of all letter directories within inputDir 
tmpDirRes = dir(inputDir);
letterDirs = {tmpDirRes([tmpDirRes.isdir]).name};
letterDirs(1:2) = []; %ignore . and ..

if (debug== 1)
    %only 10 letters if debugging
    iters = 10;
else
    iters = size(letterDirs,2);
end
%make destination directories
for dirIdx = 1:iters
    ltrDir = char(letterDirs(1,dirIdx));
    outDir = strcat(outputDir,ltrDir);
    mkdir(outDir);
end

if(debug==1)
    disp('Debugging');
    for dirIdx = 1:iters
        ltrDir = char(letterDirs(1,dirIdx));
        inDir = strcat(inputDir,ltrDir);
        outDir = strcat(outputDir,ltrDir);
        %mkdir(outDir);
        BlurAndRsmplImgWithKernel(inDir, outDir, blrkrnl, numImgs, flags);    
        disp(dirIdx);
    end
else
    %not debugging
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
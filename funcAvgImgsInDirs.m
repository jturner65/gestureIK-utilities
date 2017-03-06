%iterate through list of directories, building sum of all images found
%save sum as matrix along with count of images used to build
%use this function within multi-thread call
function funcAvgImgsInDirs(letterDirs, baseDir, thIdx, imgW, imgH)

    iters = size(letterDirs,2);
    totImg = zeros(imgH,imgW);
    totNumImgs = 0;
    for dirIdx = 1:iters
        if(size(letterDirs{dirIdx},1) == 0)
            fprintf('Skipping empty entry %i for thread %i\n',dirIdx, thIdx);
            continue;
        end
        ltrDir = char(letterDirs(1,dirIdx));
        inDir = strcat(baseDir,ltrDir);
        %calculates avg for all images within ltrDir
        [sumImg, numCalcImgs] = funcMakeAvgImg(inDir, imgW, imgH);
        totImg = totImg + sumImg;
        totNumImgs = totNumImgs + numCalcImgs;
    end
    %save totImg, totNumImgs as matlab variables
    outBaseName = strcat('avgImgVals_th_',num2str(thIdx),'.mat');
    outFileName = strcat(baseDir,outBaseName);
    save(outFileName, 'totImg', 'totNumImgs');    
    
end
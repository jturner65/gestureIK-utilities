%iterate through all images in inDir and return # of images and sum image

function [sumImg, numCalcImgs] = funcMakeAvgImg(inDir, imgW, imgH)
    %source of images : inDir
    %dest of blocked images : outDir
    imgFileNames = dir(inDir);    
    imgFileNames(1:2) = [];%ignore . and ..
    
    numCalcImgs = size(imgFileNames,1);  

    sumImg = zeros(imgH,imgW);
    %receives deblurred images
    %dblrImgsMat = zeros(numPxls,size(imgFileNames,1));
    %read in all images
    for imgIdx = 1:numCalcImgs   %for each image  
        imgBaseName = imgFileNames(imgIdx,1).name;
        %disp(imgBaseName);
        imgFileName = strcat(inDir,'/',imgBaseName);
        try
            tmpImg = im2double(imread(imgFileName));  
            sumImg = sumImg + tmpImg;
            %disp(strcat('image named : ',imgFileName, ' read successfully'));
        catch ME
            disp(strcat('error with image name : ',imgFileName));
            continue;
        end         
    end 

end
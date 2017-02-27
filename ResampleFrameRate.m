%%
%this function will resample a list of images in a directory to give a
%specified number of output images
function ResampleFrameRate(inDir, outDir, numResImgs)
    %source of images : inDir
    %dest of blocked images : outDir
    imgFileNames = dir(inDir);    
    imgFileNames(1:2) = [];%ignore . and ..
        
    numPxls = 40000;%200*200;
    numCalcImgs = size(imgFileNames,1);

    imgsMat = zeros(numPxls,numCalcImgs);
    %receives deblurred images
    %dblrImgsMat = zeros(numPxls,size(imgFileNames,1));
    %read in all images
    for imgIdx = 1:size(imgFileNames,1)   %for each image  
        imgBaseName = imgFileNames(imgIdx,1).name;
        %disp(imgBaseName);
        imgFileName = strcat(inDir,'/',imgBaseName);
        try
            tmpImg = im2double(imread(imgFileName));  
            %imgsMat(:,imgIdx+2) = reshape(tmpImg,numPxls,1); 
            imgsMat(:,imgIdx) = reshape(tmpImg,numPxls,1); 
            %disp(strcat('image named : ',imgFileName, ' read successfully'));
        catch ME
            disp(strcat('error with image name : ',imgFileName));
            continue;
        end         
    end
    %resample imgsMat so that # cols == numResImgs
    numImgs = size(imgsMat,2);
    x = (1:numImgs)';
    xi = linspace(1,numImgs,numResImgs)';
    %resImgsMat = interp1(x',imgsMat',xi','spline')';
    resImgsMat = interp1(x',imgsMat',xi', 'nearest')';

    locDots = strfind(imgFileNames(1,1).name, '.')
    imgRootName = imgFileNames(1,1).name(1:locDots(1));
    for imgIdx = 1:size(resImgsMat,2)
        rSmpImg = reshape(resImgsMat(:,imgIdx), 200,200);
        %imshow(rSmpImg);
        imgBaseName = strcat(imgRootName,buildZPrefix(imgIdx),'.png') % imgFileNames(imgIdx,1).name; <-- can't do this because interpolation might make more images than originally in clip
        imgOutFileName = strcat(outDir,'/',imgBaseName);
        imwrite(rSmpImg,imgOutFileName);   
    end

end

%%
%this function will blur and/or resample an image based on the values of its neighbor's
%images, using the passed kernel - assumed to be centered kernel (prepend
%or append 0's
% flags : idx 0 == do blur or not; idx 1 == do resample or not 
function BlurAndRsmplImgWithKernel(inDir, outDir, krnl, numSmpls, flags)
    %set up directory for result images
    %mkdir(outDir);
    %source of images : inDir
    %dest of blocked images : outDir
    imgFileNames = dir(inDir);    
    imgFileNames(1:2) = [];%ignore . and ..
    
    outImgPrfx = '';
    
    numPxls = 40000;%200*200;
    numCalcImgs = size(imgFileNames,1);  
    if(flags(1))
        krnlSz = size(krnl,1);
        bndSz = floor(krnlSz/2);

        %square per-pxl kernel
        krnlMatTmp = eye(numCalcImgs+(2*bndSz),numCalcImgs+(2*bndSz)) * (krnl(bndSz+1));
        %build diag dominant krnl mat
        for i = 1:numCalcImgs+bndSz
            for k = 1:bndSz
                matIdx = i + (bndSz +1 - k);
                krnlMatTmp(matIdx,i) = krnl(k);
                krnlMatTmp(i,matIdx) = krnl(k);
            end
        end
        krnlMat = krnlMatTmp(bndSz+1:end-bndSz,bndSz+1:end-bndSz);
        for i = 1:bndSz
            val = sum(krnl( (bndSz +1+i):end));
            krnlMat(i,i) = krnlMat(i,i) + val;
            krnlMat(end-i+1,end-i+1) = krnlMat(end-i+1,end-i+1) + val;
        end
    end
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
    if(flags(1))
        blrImgsMat = (krnlMat * imgsMat')'; %b = Ax : blurring images
        outImgPrfx = 'blr_';
    else
        blrImgsMat = imgsMat;
    end
    %if resampling (numSmpls > 1) then resample blurred images
    if(flags(2))
        %resample imgsMat so that # cols == numResImgs
        numImgs = size(blrImgsMat,2);
        x = (1:numImgs)';
        xi = linspace(1,numImgs,numSmpls)';
        resImgsMat = interp1(x',blrImgsMat',xi','spline')';
        %resImgsMat = interp1(x',imgsMat',xi', 'nearest')';
        blrImgsMat = resImgsMat;
        outImgPrfx = strcat(outImgPrfx,'F',num2str(numSmpls),'_');
    end
    %find base name of imgs to use as new image names - need to do this in
    %case making more images than originally had
    %locDots = strfind(imgFileNames(1,1).name, '.');
    locULines = strfind(imgFileNames(1,1).name, '_');
    imgRootName = strcat(imgFileNames(1,1).name(1:locULines(3)),outImgPrfx);
    for imgIdx = 1:size(blrImgsMat,2)
        blrImg = reshape(blrImgsMat(:,imgIdx), 200,200);
        %imshow(blrImg);
        imgBaseName = strcat(imgRootName,funcBuildZPrefix(imgIdx-1),'.png'); % imgFileNames(imgIdx,1).name; <-- can't do this because interpolation might make more images than originally in clip
        imgOutFileName = strcat(outDir,'/',imgBaseName);
        imwrite(blrImg,imgOutFileName);   
    end

end


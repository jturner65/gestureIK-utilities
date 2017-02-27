%%
%this function will blur an image based on the values of its neighbor's
%images, using the passed kernel - assumed to be centered kernel (prepend
%or append 0's for 
function BlurImgWithKernel(inDir, outDir, krnl)
    %set up directory for result images
    %mkdir(outDir);
    %source of images : inDir
    %dest of blocked images : outDir
    imgFileNames = dir(inDir);    
    imgFileNames(1:2) = [];%ignore . and ..
    
    krnlSz = size(krnl,1);
    bndSz = floor(krnlSz/2);
    
    numPxls = 40000;%200*200;
    numCalcImgs = size(imgFileNames,1);
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
    
    blrImgsMat = (krnlMat * imgsMat')'; %b = Ax - blurring images

    for imgIdx = 1:size(blrImgsMat,2)
        blrImg = reshape(blrImgsMat(:,imgIdx), 200,200);
        %imshow([reshape(imgsMat(:,imgIdx), 200,200), blrImg ]);
        imgBaseName = imgFileNames(imgIdx,1).name;
        %add 'blur' to image name
        %uLocs = strfind(imgBaseName,'_');  %use uLocs(end)
        %outNameStr = strcat(imgBaseName(1:uLocs(end)),'blur',imgBaseName(uLocs(end):end));        
        %imgOutFileName = strcat(outDir,'/',outNameStr);
        imgOutFileName = strcat(outDir,'/',imgBaseName);
        imwrite(blrImg,imgOutFileName);   
    end

end

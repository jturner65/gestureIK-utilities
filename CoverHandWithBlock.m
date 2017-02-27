%%
%this function will make a rectangular white "hand" block centered where
%the hand is thought to be in an image
function CoverHandWithBlock(inDir, outDir)
    mkdir(outDir);
    %source of images : inDir
    %dest of blocked images : outDir
    imgFileNames = dir(inDir);    
    imgFileNames(1:2) = [];%ignore . and ..
    for imgIdx = 1:size(imgFileNames,1)   %for each image  
        imgBaseName = imgFileNames(imgIdx,1).name;
        %disp(imgBaseName);
        imgFileName = strcat(inDir,'/',imgBaseName);
        try
            image1 = im2single(imread(imgFileName));  
            disp(strcat('image named : ',imgFileName, ' read successfully'));
        catch ME
            disp(strcat('error with image name : ',imgFileName));
            continue;
        end 
        %find hand here
        %[newImage, bbox] = findFaceAndMod(faceDetector, image1, bbox, faceBlockClr);
        %imshow(newImage);
        %save newImage to outDir/imgFileNames with name modified to include
        %"obsFace_"
        uLocs = strfind(imgBaseName,'_');  %use uLocs(end)
        outNameStr = strcat(imgBaseName(1:uLocs(end)),'blockHand',imgBaseName(uLocs(end):end));
        imgOutFileName = strcat(outDir,'/',outNameStr);
        imwrite(newImage,imgOutFileName);
        
    end
end
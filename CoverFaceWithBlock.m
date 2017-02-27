%iterate through all images within input dir, block the face, and save to
%output dir
%pass face detector to only instantiate 1 time
function CoverFaceWithBlock(faceDetector, inDir, outDir, faceBlockClr)
    %set default box location/dimensions - this is for a 200x200 image
    dfltBox = [129,37,51,51];
    bbox = dfltBox;
    mkdir(outDir);
    %source of images : inDir
    %dest of blocked images : outDir
    imgFileNames = dir(inDir);    
    imgFileNames(1:2) = [];%ignore . and ..
    for imgIdx = 1:size(imgFileNames,1)   %for each image     
        imgBaseName = imgFileNames(imgIdx,1).name;
        disp(imgBaseName);
        imgFileName = strcat(inDir,'/',imgBaseName);
        try
            image1 = im2single(imread(imgFileName));  
            disp(strcat('image named : ',imgFileName, ' read successfully'));
        catch ME
            disp(strcat('error with image name : ',imgFileName));
            continue;
        end 
        [newImage, bbox] = findFaceAndMod(faceDetector, image1, bbox, faceBlockClr);
        %imshow(newImage);
        %save newImage to outDir/imgFileNames with name modified to include
        %"obsFace_"
        uLocs = strfind(imgBaseName,'_');  %use uLocs(end)
        outNameStr = strcat(imgBaseName(1:uLocs(end)),'occlFace',imgBaseName(uLocs(end):end));
        imgOutFileName = strcat(outDir,'/',outNameStr);
        imwrite(newImage,imgOutFileName);
    end
end
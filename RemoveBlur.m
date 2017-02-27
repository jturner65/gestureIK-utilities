%%
%this function attempts to remove blur in image caps using built in matlab functions
function RemoveBlur(inDir, outDir)
    
    dampAr = .2;%example used .1
    %set up directory for result images
    mkdir(outDir);
    PSF = fspecial('gaussian',7,10);
    %source of images : inDir
    %dest of blocked images : outDir
    imgFileNames = dir(inDir);    
    imgFileNames(1:2) = [];%ignore . and ..
    
    imgBaseName = imgFileNames(1,1).name;
    %disp(imgBaseName);
    imgFileName = strcat(inDir,'/',imgBaseName);
    try
        tmpImg = im2double(imread(imgFileName));  
        disp(strcat('Initial Read : image named : ',imgFileName, ' read successfully'));
    catch ME
        disp(strcat('Initial Read : error with image name : ',imgFileName));
    end     
    %from example code for deconvBlind
    WT = zeros(size(tmpImg));
    WT(5:end-4,5:end-4) = 1;
    INITPSF = ones(size(PSF));
    %figure;
    for imgIdx = 1:size(imgFileNames,1)   %for each image  
        imgBaseName = imgFileNames(imgIdx,1).name;
        %disp(imgBaseName);
        imgFileName = strcat(inDir,'/',imgBaseName);
        try
            image1 = im2double(imread(imgFileName));  
            disp(strcat('image named : ',imgFileName, ' read successfully'));
        catch ME
            disp(strcat('error with image name : ',imgFileName));
            continue;
        end 
        %remove/reduce ringing
        image1 = edgetaper(image1,PSF); 
        %deblur image here - blind deconvolution
        %[newImage P] = deconvblind(image1,INITPSF,20,dampAr,WT);
        %deblur image here - Lucy-Richardson method
        newImage = deconvlucy(image1,PSF,20, dampAr);%,WT);
        %deblur image here - blind deconvolution
        %[newImage P] = deconvblind(image1,INITPSF,20,dampAr,WT);
        %deblur image here - blind deconvolution
        %[newImage P] = deconvblind(image1,INITPSF,20,dampAr,WT);
        %subplot(1,2, 1);
        %imshow(image1);
        imshow([image1 newImage]);
%         subplot(1, 2, 2);
%         imshow(newImage);
        %save newImage to outDir/imgFileNames with name modified to include
        %"obsFace_"
        uLocs = strfind(imgBaseName,'_');  %use uLocs(end)
        outNameStr = strcat(imgBaseName(1:uLocs(end)),'deblur',imgBaseName(uLocs(end):end));
        imgOutFileName = strcat(outDir,'/',outNameStr);
        %imwrite(newImage,imgOutFileName);
        
    end
end
% PSF  = fspecial('gaussian',13,1);
% OTF  = psf2otf(PSF,[31 31]); % PSF --> OTF
% PSF2 = otf2psf(OTF,size(PSF)); % OTF --> PSF2
% subplot(1,2,1); surf(abs(OTF)); title('|OTF|');
% axis square; axis tight
% subplot(1,2,2); surf(PSF2); title('Corresponding PSF');
% axis square; axis tight
% I = checkerboard(8);
% PSF = fspecial('gaussian',7,10);
% V = .0001;
% BlurredNoisy = imnoise(imfilter(I,PSF),'gaussian',0,V);
% WT = zeros(size(I));
% WT(5:end-4,5:end-4) = 1;
% J1 = deconvlucy(BlurredNoisy,PSF);
% J2 = deconvlucy(BlurredNoisy,PSF,20,sqrt(V));
% J3 = deconvlucy(BlurredNoisy,PSF,20,sqrt(V),WT);
% 
% subplot(221);imshow(BlurredNoisy);
% title('A = Blurred and Noisy');
% subplot(222);imshow(J1);
% title('deconvlucy(A,PSF)');
% subplot(223);imshow(J2);
% title('deconvlucy(A,PSF,NI,DP)');
% subplot(224);imshow(J3);
% title('deconvlucy(A,PSF,NI,DP,WT)');

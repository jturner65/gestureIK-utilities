%%
%this function attemps to remove blur in image caps by inverting the blurring process.
%assuming the blur is caused by a weighted mixture of images over a sequence of frames, this  
%function builds a system of equations Ax = b where A is weighting and b is blurred images, and 
%solves for x
function RemoveBlurImgKern(inDir, outDir, krnl, debug)
    %set up directory for result images
    mkdir(outDir);
    %source of images : inDir
    %dest of blocked images : outDir
    imgFileNames = dir(inDir);    
    imgFileNames(1:2) = [];%ignore . and ..
    
    krnlSz = size(krnl,1);
    bndSz = floor(krnlSz/2);
    
    numPxls = 200*200;
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
    
    dblrImgsMat =(krnlMat\imgsMat')'; %x = A\b
    %threshold here?
    dblrImgsMat2 = max(imgsMat,dblrImgsMat);
    dblrMatToUse = dblrImgsMat2;

    zMat = zeros(size(reshape(dblrMatToUse(:,imgIdx), 200,200)));
    ctr = [100,100];
    %find centers
    for imgIdx = 1:size(dblrMatToUse,2)
        dlbrImg = reshape(dblrMatToUse(:,imgIdx), 200,200);
        if(imgIdx == 1 )
            diffImg = dlbrImg;
        else     
            diffImg = max(dlbrImg - reshape(dblrMatToUse(:,imgIdx-1), 200,200),zMat);
        end
        %dlbrImg(dlbrImg>.8) = 1; 
        %bw = (mean(diffImg(1:200,20:150),3) > .5);
        bw = (mean(diffImg(:,:),3) > .5);
        stats = regionprops('table',bw,'Centroid','MajorAxisLength','MinorAxisLength');
        if(~isempty(stats.Centroid))
            if(size(stats.Centroid,1) > 1)
                ctr = [mean(stats.Centroid(:,1)) , mean(stats.Centroid(:,2))];
            else 
                ctr = stats.Centroid;
            end
        end
        ctr = max(ctr,0);
        ctr = min(ctr,190);        

        yHighVal = ctr(2)+10;
        if(yHighVal > 200)
            yHighVal = 200;
        end
        diffImg(ctr(2)-10:yHighVal,ctr(1)-10:ctr(1)+10) = 1;
        %replace with rectangle
%         if(imgIdx == 94)
%             disp('stop');
%         end
        imshow([reshape(imgsMat(:,imgIdx), 200,200), dlbrImg ,diffImg]);
        %imshow([reshape(imgsMat(:,imgIdx), 200,200), dlbrImg ]);
        imgBaseName = imgFileNames(imgIdx,1).name;
        uLocs = strfind(imgBaseName,'_');  %use uLocs(end)
        outNameStr = strcat(imgBaseName(1:uLocs(end)),'deblur',imgBaseName(uLocs(end):end));
        imgOutFileName = strcat(outDir,'/',outNameStr);
        imwrite(dlbrImg,imgOutFileName);  
    end

end

function velVec = calcVel(smthDat,ctrRes)
    %calc velocity
    velVec = zeros(size(ctrRes,1),2);
    velVec(2:end,:) = smthDat(2:end,1:2) - smthDat(1:end-1,1:2);
    %resultant data - save as CSV
end

function plotCtr(smthDat, ctrRes)
    %x and y data
    x = (1:size(ctrRes,1))
    subplot(2,1,1)
    y = ctrRes(:,1)';
    yy1 = smthDat(:,1);
    plot(x,y,'b.',x,yy1,'r-')
    %set(gca,'YLim',[-1.5 3.5])
    legend('Original data x','Smoothed data x using ''rloess''',...
           'Location','NW')

    subplot(2,1,2)
    y = ctrRes(:,2);
    yy2 = smthDat(:,2);
    plot(x,y,'b.',x,yy2,'r-')
    %set(gca,'YLim',[-1.5 3.5])
    legend('Original data y','Smoothed data y using ''rloess''',...
           'Location','NW')


end

%return info pertaining to file locations in a single struct
function res = fileDataStruct(fileName, inVidFileDir, outputDir)
    tmp = strsplit(fileName,'_');   %remove extra crap
    baseFileName = tmp(1,1);       
    imgFileExt = '.png';

    fld0 = 'readFileName';          val0 = strcat(inVidFileDir,fileName);       %read the original base video files 
    fld1 = 'writeBaseFileName';     val1 = strcat(outputDir,'letters\',baseFileName);
    fld2 = 'writeImgNameExt';       val2 = imgFileExt;
    fld3 = 'writeImgDir';           val3 = strcat(outputDir,'imgs\',baseFileName);
    fld4 = 'baseFileName';           val4 = baseFileName;
    res = struct(fld0,val0,fld1,val1,fld2,val2,fld3,val3,fld4,val4);
     
end
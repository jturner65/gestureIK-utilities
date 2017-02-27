%finds face in video frame and blocks it out.  uses bboxOld if can't find
%blockClr should be either 0 or 1 (black or white)
function [imgFrame,bbox] = findFaceAndMod(faceDetector, imgFrame, bboxOld, blockClr)
    bbox = step(faceDetector, imgFrame);   
    %handle if face is occluded
    if(size(bbox,1) == 0)       %if no bbox, use old bbox
        bbox = bboxOld;
    else 
        bbox(1,2) = bbox(1,2) - 10;
    end
    bboxPoints = bbox2points(bbox(1, :));
    %bboxPolygon = reshape(bboxPoints', 1, []);
    %adds bounding box in frame
    %imgFrame = insertShape(imgFrame, 'Polygon', bboxPolygon, 'LineWidth', 2);
    imgFrame((bboxPoints(2,2):bboxPoints(3,2)),(bboxPoints(1,1):bboxPoints(2,1)),:) = blockClr;
end
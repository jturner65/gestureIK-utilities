clear;
close all;
clc;
%% Detect a Face
% Use vision.CascadeObjectDetector to detect the location of a face in a video frame. The
% cascade object detector uses the Viola-Jones detection algorithm and a
% trained classification model for detection.

%% This Version runs on vids
% Read a video frame and run the face detector.
userDir = 'john/';
folderName = 'avis_60fps/';
%color of face block, 0==black, 1==white
blockClr = 1;
% range of 2 - 7
vidNum = 3;

fileName = strcat(userDir,folderName,'alphabet',num2str(vidNum),'_filterCrop.avi');
out_fileName = strcat(userDir,folderName,'bbox_alphabet',num2str(vidNum),'_filterCrop.avi');
videoFileReader = vision.VideoFileReader(fileName, 'AudioOutputPort',false);  
videoFileWriter = vision.VideoFileWriter (out_fileName,'AudioInputPort',false,'FrameRate',videoFileReader.info.VideoFrameRate);
%videoFileWriter.VideoCompressor='MJPEG Compressor';
videoFileWriter.VideoCompressor='DV Video Encoder';
% Create a cascade detector object.
faceDetector = vision.CascadeObjectDetector();      %can detect mouths too
% to be increased to make sure we only get 1 face (defaults to 4)
faceDetector.MergeThreshold = 10;

%default bbox
deflt_bbox = [129,37,51,51];
%first frame detection
videoFrame      = step(videoFileReader);
bbox            = step(faceDetector, videoFrame);
if(size(bbox,1) == 0)       %if no bbox, use old bbox
    bbox = deflt_bbox;
else 
    bbox(1,2) = bbox(1,2) - 10;
end

bbox(1,2) = bbox(1,2) - 10;
bboxPoints = bbox2points(bbox(1, :));
bboxPolygon = reshape(bboxPoints', 1, []);

% Create a video player object for displaying video frames.
videoPlayer  = vision.VideoPlayer('Position',...
    [100 100 [size(videoFrame, 2)+100, size(videoFrame, 1)]+100]);

while ~isDone(videoFileReader)
    % get the next frame
    videoFrame    = step(videoFileReader);
    [videoFrame, bbox] = findFaceAndMod(faceDetector, videoFrame, bbox, blockClr);
    %save frame without points
    step(videoFileWriter, videoFrame);
    % Display the annotated video frame using the video player object
    step(videoPlayer, videoFrame);
end

% Clean up
release(videoFileReader);
release(videoFileWriter);
release(videoPlayer);


%% Lane Detection Test
% Author: Sankalprajan P
% Affiliation: KPIT Technologies Ltd.
%% SETUP
% Connect to ROS master
clear all;
rosshutdown;
gazeboIp = '10.30.47.132';    % Obtained from the command terminal >> hostname -I
rosinit(gazeboIp);
% Create ROS subscribers and publishers
imgSub = rossubscriber('/camera/rgb/image_raw');
receive(imgSub,10); % Wait to receive first message
%[velPub,velMsg] = rospublisher('/mobile_base/commands/velocity');
% Create video player for visualization
vidPlayer = vision.DeployableVideoPlayer;
% Load control parameters
% params = controlParamsGazebo;
% Deciding ROI points by plotting it on image
%% LOOP
while(1) 
%% SENSE
% Grab images
img = readImage(imgSub.LatestMessage);
%% PROCESS
% Object detection algorithm
% resizeScale = 0.5;
% [centerX,centerY,circleSize] = detectCircle(img,resizeScale);
% Object tracking algorithm
% [v,w] = trackCircle(centerX,circleSize,size(img,2),params);
% hsvimg = rgb2hsv(img); Convert to HSV from RGB
[h,w] = size(img); % Obtain size of Image
% [r c] = ginput(10);
r = [0 w w 0]; % Specifying for ROI % Will change accordingly to the camera frame parameters
c = [h h (h*0.66) (h*0.66)]; % Specifying for ROI % Will change accordingly to the camera frame parameters
% gaussimg = imgaussfilt3(img);
%% CONTROL
% Package ROS message and send to the robot
% velMsg.Linear.X = v;
% velMsg.Angular.Z = w;
% send(velPub,velMsg);
% Define Thresholds for masking Yellow Color
% Define thresholds for Hue
channel1MinY = 130;
channel1MaxY = 255;
% Define thresholds for Saturation
channel2MinY = 130;
channel2MaxY = 255;
% Define thresholds for Value
channel3MinY = 0;
channel3MaxY = 130;
% Create mask based on chosen histogram thresholds
yellowimg = ((img(:,:,1)>=channel1MinY)|(img(:,:,1)<=channel1MaxY))& ...
    (img(:,:,2)>=channel2MinY)&(img(:,:,2)<=channel2MaxY)&...
    (img(:,:,3)>=channel3MinY)&(img(:,:,3)<=channel3MaxY);
% Define Thresholds for masking White Color
% Define thresholds for Hue
channel1MinW = 200;
channel1MaxW = 255;
% Define thresholds for Saturation
channel2MinW = 200;
channel2MaxW = 255;
% Define thresholds for Value
channel3MinW = 200;
channel3MaxW = 255;
% Create mask based on chosen histogram thresholds
whiteimg = ((img(:,:,1)>=channel1MinW)|(img(:,:,1)<=channel1MaxW))&...
    (img(:,:,2)>=channel2MinW)&(img(:,:,2)<=channel2MaxW)& ...
    (img(:,:,3)>=channel3MinW)&(img(:,:,3)<=channel3MaxW);
% Edge Detetction by using Canny
edgewhiteimg = edge(whiteimg, 'canny', 0.2);
edgeyellowimg = edge(yellowimg, 'canny', 0.2);
% Neglecting closed edges in smaller areas
edgewhiteimg = bwareaopen(edgewhiteimg,15);
edgeyellowimg = bwareaopen(edgeyellowimg,15);
% Extracting Region of Interest from Yellow Edge Frame
roiyellowimg = roipoly(edgeyellowimg, r, c);
[R , C] = size(roiyellowimg);
for i = 1:R
    for j = 1:C
        if roiyellowimg(i,j) == 1
            frameroiyellow(i,j) = edgeyellowimg(i,j);
        else
            frameroiyellow(i,j) = 0;
        end
    end
end
% Extracting Region of Interest from White Edge Frame
roiywhiteimg = roipoly(edgewhiteimg, r, c);
[R , C] = size(roiywhiteimg);
for i = 1:R
    for j = 1:C
        if roiywhiteimg(i,j) == 1
            frameroiwhite(i,j) = edgewhiteimg(i,j);
        else
            frameroiwhite(i,j) = 0;
        end
    end
end
% Applying Hough Tansform to get straight lines from Image
% Applying Hough Transform to White and Yellow Frames
[H_Y,theta_Y,rho_Y] = hough(frameroiyellow);
[H_W,theta_W,rho_W] = hough(frameroiwhite);
% Extracting Hough Peaks from Hough Transform of frames
P_Y = houghpeaks(H_Y,2);
P_W = houghpeaks(H_W,2);
%% VISUALIZE
% Annotate image and update the video player
% img = insertShape(img,'Circle',[centerX centerY circleSize/2],'LineWidth',2);
step(vidPlayer,img);
end
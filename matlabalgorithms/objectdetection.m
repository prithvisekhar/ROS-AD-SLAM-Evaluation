%% Object Detection Example: Gazebo
% Copyright 2017 The MathWorks, Inc.

%% SETUP
% Connect to ROS master
rosshutdown;
rosinit('Inspiron5548');
% Create ROS subscribers and publishers
imgSub = rossubscriber('/camera/rgb/image_raw');
receive(imgSub,10); % Wait to receive first message
[velPub,velMsg] = rospublisher('cmd_vel');
% Create video player for visualization
vidPlayer = vision.DeployableVideoPlayer;

%% LOOP
while(1) 
    %% SENSE
    % Grab images
    img = readImage(imgSub.LatestMessage);
    
    %% PROCESS
    % Object detection algorithm
    resizeScale = 0.5;
    [centerX,centerY,circleSize] = detectCircle(img,resizeScale);
    % Object tracking algorithm
    [v,w] = trackCircle(centerX,circleSize,size(img,2),params);
    
    %% CONTROL
    % Package ROS message and send to the robot
    velMsg.Linear.X = v;
    velMsg.Angular.Z = w;
    send(velPub,velMsg);
    
    %% VISUALIZE
    % Annotate image and update the video player
    img = insertShape(img,'Circle',[centerX centerY circleSize/2],'LineWidth',2);
    step(vidPlayer,img);
        
end
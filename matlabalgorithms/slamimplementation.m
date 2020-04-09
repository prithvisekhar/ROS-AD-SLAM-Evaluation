rosinit('10.30.87.48');
scanSub = rossubscriber('/kbot/laser/scan');
lidar = lidarScan(receive(scanSub));


% Convert 2D scan to 3D point cloud and perform obstacle segmenting using Euclidean distance clustering
ptCloud = pointCloud([lidar.Cartesian zeros(size(lidar.Cartesian,1),1)]);
minDist = 0.25;
[labels,numClusters] = pcsegdist(ptCloud,minDist);

% Get first scan
lidar1 = lidarScan(receive(scanSub));

% Move robot
velMsg.Linear.X = 0.1;
velMsg.Angular.Z = 0.25;
send(velPub,velMsg);
pause(1);
velMsg.Linear.X = 0;
velMsg.Angular.Z = 0;
send(velPub,velMsg);

% Get second scan
lidar2 = lidarScan(receive(scanSub));

% Perform sc                                                                                                                                                                                                                                                                                                      an matching
relPoseScan = matchScans(lidar2,lidar1)

% Define the LidarSLAM object
maxRange = 2;     % meters
resolution = 25;  % cells per meter
slam = robotics.LidarSLAM(resolution,maxRange);
slam.LoopClosureThreshold = 350;
slam.LoopClosureSearchRadius = 5;

% Build and optimize the pose graph
numIters = numel(scansSampled);
for idx = 1:numIters
  addScan(slam,scansSampled(idx));
end

% Export the final results as an Occupancy Grid
[slamScans, slamPoses] = scansAndPoses(slam);
map = buildMap(slamScans, slamPoses, resolution, maxRange);
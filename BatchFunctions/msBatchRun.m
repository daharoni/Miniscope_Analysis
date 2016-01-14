%% Generates the initial ms.mat files for all data folders
msBatchGenerateMS(pwd);

%% Select fluorescnece thesh for good frames
msBatchSelectFluorThresh(pwd);

%% Allows user to select ROIs for each data folder
msBatchSelectROIs(pwd)

%% Run alignment across all data and ROIs

%for miniscope data try scaling everything to min max range
tic
msBatchAlignmentFFT(pwd);
toc
%% Calculate mean frames
downsample = 1;
msBatchMeanFrame(pwd,downsample);

%% Manually inspect and select best alignment
msBatchSelectAlignment(pwd);

%% Segment Sessions
msBatchSegment(pwd);

%% Calculate Segment relationships
calcCorr = false;
calcDist = true;
calcOverlap = true;
msBatchCalcSegRelations(pwd,calcCorr, calcDist, calcOverlap);

%% Clean Segments
corrThresh = [];
distThresh = 7;
overlapThresh = .8;
msBatchCleanSegments(pwd,corrThresh,distThresh,overlapThresh);

%% Calculate Segment relationships
calcCorr = true;
calcDist = true;
calcOverlap = true;
msBatchCalcSegRelations(pwd,calcCorr, calcDist, calcOverlap);

%% Calculate segment centroids
msBatchSegmentCentroids(pwd);

%% Extract dF/F
msBatchExtractdFFTraces(pwd);

%% Align across sessions
msBatchAlignBetweenSessions(pwd);

%% Count segments in common field
msBatchSegmentsInField(pwd);

%% Match segments across sessions
distThresh = 5;
msBatchMatchSegmentsBetweenSessions(pwd, distThresh);


%% BEHAV STUFF

%% Generate behav.m
msBatchGenerateBehav(pwd);

%% Select ROI and HSV for tracking
msBatchSelectPropsForTracking(pwd);

%% Extract position
trackLength = 200;%cm
msBatchExtractBehavior(pwd, trackLength);

%% Calculate spatial firing rate
speedThresh = 5;%cm
binSize = 5;%cm
msBatchLinearSFR(pwd, speedThresh, binSize)

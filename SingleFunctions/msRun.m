%% Generates the initial ms data struct for data set contained in current folder
ms = msGenerateVideoObj(pwd,'msCam');

% Newer versions of the Miniscope system do not require Column Correction. 
% If this is the case for you still run msColumn Correction() then run the two lines of code below it.
ms = msColumnCorrection(ms,5);  
% ms.columnCorrection(:) = 0;
% ms.columnCorrectionOffset = 0;

ms = msFluorFrameProps(ms);

%% Select fluorescence thresh for good frames
% The output of msSelectFluorThresh(), ms.goodFrames, is not implemented. 
% Therefore the threshold selected has no effect on the rest of the analysis. 
% msSelectFluorThresh() does generate a potentially interesting plot of  
% fluorescence changes across recording sessions. 
ms = msSelectFluorThresh(ms);

%% Allows user to select ROIs for each data folder
ms = msSelectROIs(ms);
%% Run alignment across all ROIs
plotting = true;
tic
ms = msAlignmentFFT(ms,plotting);
toc
%% Calculate mean frames
downsample = 5;
ms = msMeanFrame(ms,downsample);

%% Manually inspect and select best alignment
ms = msSelectAlignment(ms);

%% Segment Sessions
plotting = true;
ms = msFindBrightSpots(ms,30,[],.03,0.02,plotting);
ms = msAutoSegment2(ms,[],[60 700],5,.90,plotting);

%% Calculate Segment relationships
calcCorr = false;
calcDist = true;
calcOverlap = true;
ms = msCalcSegmentRelations(ms, calcCorr, calcDist, calcOverlap);

%% Clean Segments
corrThresh = [];
distThresh = 7;
overlapThresh = .8;
ms = msCleanSegments(ms,corrThresh,distThresh,overlapThresh);

%% Calculate Segment relationships
calcCorr = false;
calcDist = true;
calcOverlap = true;
ms = msCalcSegmentRelations(ms, calcCorr, calcDist, calcOverlap);

%% Calculate segment centroids
ms = msSegmentCentroids(ms);

%% Extract dF/F
ms = msExtractdFFTraces(ms);
ms = msCleandFFTraces(ms);
ms = msExtractFiring(ms);

%% Align across sessions
% ms = msAlignBetweenSessions(msRef,ms);

%% Count segments in common field
% msBatchSegmentsInField(pwd);

%% Match segments across sessions
% distThresh = 5;
% msBatchMatchSegmentsBetweenSessions(pwd, distThresh);


%% BEHAV STUFF

%% Generate behav.m
behav = msGenerateVideoObj(pwd,'behavCam');

%% Select ROI and HSV for tracking
behav = msSelectPropsForTracking(behav); 

%% Extract position
trackLength = 200;%cm
behav = msExtractBehavoir(behav, trackLength); 

function vidObj = msFindBrightSpots(vidObj,stepSize, frameLimits,dFFTresh, backgroundTresh)
%MSFINDBRIGHTSPOTS Summary of this function goes here
%   Detailed explanation goes here


if isempty(frameLimits)
    frameLimits = [1 vidObj.numFrames];
end

count = 0;

%smoothing kernal
hSmall = fspecial('average', 3);
hLarge = fspecial('average', 60);

red = cat(3, ones(vidObj.alignedHeight,vidObj.alignedWidth), ...
    zeros(vidObj.alignedHeight,vidObj.alignedWidth), ...
    zeros(vidObj.alignedHeight,vidObj.alignedWidth));

green = cat(3, zeros(vidObj.alignedHeight,vidObj.alignedWidth), ...
    ones(vidObj.alignedHeight,vidObj.alignedWidth), ...
    zeros(vidObj.alignedHeight,vidObj.alignedWidth));

% kernal used for eroding and dilating
se = strel('diamond',10);
se2 = strel('diamond',2);
%location where segments are stored

frame = nan(vidObj.alignedHeight,vidObj.alignedWidth,stepSize);
vidObj.brightSpots = zeros(vidObj.alignedHeight,vidObj.alignedWidth);
vidObj.brightSpotTiming = sparse(vidObj.alignedHeight*vidObj.alignedWidth,0);

for startFrameNum=frameLimits(1):stepSize:min([frameLimits(2) vidObj.numFrames-stepSize])
   
    %loads needed frames centered around the current frame being
    %displayed
    count = 0;
    for frameNum = startFrameNum:(startFrameNum+stepSize)
        count = count+1;
        frame(:,:,count) =filter2(hSmall,msReadFrame(vidObj,frameNum,true,true,true));
    end
    frameMax = max(frame,[],3);
    frameBase = filter2(hLarge,frameMax);
    f = figure(1);
    clf
    hold off
    bw = zeros(size(frameMax));
    bw((frameMax-frameBase >= backgroundTresh) & (frameMax >dFFTresh)) = 1;
    bw = imerode(bw,se2);
    %         bw = imdilate(bw,se2);
    
    bwProps = regionprops(logical(bw), frameMax, 'Area', 'BoundingBox', 'Image', 'PixelIdxList','Centroid','WeightedCentroid');
    for propNum = 1:length(bwProps)
        centroid = floor(bwProps(propNum).WeightedCentroid);        
        if (bwProps(propNum).Area < 500 && bwProps(propNum).Area >=20)
            vidObj.brightSpots(centroid(2),centroid(1)) = vidObj.brightSpots(centroid(2),centroid(1)) + 1;
            vidObj.brightSpotTiming(centroid(2)+(centroid(1)-1)*vidObj.alignedHeight,...
                vidObj.brightSpots(centroid(2),centroid(1))) = frameNum;
        end
    end      
    subplot_tight(1,2,1,0.05*[1 1])
    pcolor(frameMax)
    caxis([-0.05 .3]) %sets visial dF/F range    
    colormap gray
    freezeColors
    shading flat
    hold on
    %overlay outline of segmentations
    h3 = imshow(green);
    set(h3, 'AlphaData', bw);
    title(['Frame: ' num2str(frameNum) '/' num2str(vidObj.numFrames)]);
    subplot_tight(1,2,2,0.05*[1 1])
    pcolor(vidObj.brightSpots)
    daspect([1 1 1])
    shading flat
    colormap jet
    freezeColors
end


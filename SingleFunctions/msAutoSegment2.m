function vidObj = msAutoSegment2(vidObj, frameLimits, cellAreaLimits, downSamp,corrCoefThreshDefault,plotting)
%MSAUTOSEGMENT2 An serial iterative algorithm for identifying the boundries
%of active neurons.
%   vidObj = The Miniscope data structure which contains location of video
%   files, bright spot information, and preprocessing corrections
%   frameLimits= Should just pass in an empty array '[]'. This variable
%   doesn't do anything anymore
%   cellAreaLimits = [minArea maxArea]. min and max pixel area for a region
%   to be considered a possible neuron
%   downSamp = down sample factor. This algorithm loads all video data into
%   RAM. Make sure the waveform shape of dF/F activity is not lost. We down
%   sample by a factor of 5 when imaging GCaMP6F at 30FPS.
%   corrCoefThreshDefault = Minimum threshold for surrounding pixels to be
%   grouped in to the ROI on each iteration


if isempty(frameLimits)
    frameLimits = [1 vidObj.numFrames];
end
    
%smoothing kernal
hSmall = fspecial('average', 5);
hLarge = fspecial('average', 60);

%Used for plotting (Generally plotting should be commented out)
green = cat(3, zeros(vidObj.alignedHeight(vidObj.selectedAlignment),vidObj.alignedWidth(vidObj.selectedAlignment)), ...
    ones(vidObj.alignedHeight(vidObj.selectedAlignment),vidObj.alignedWidth(vidObj.selectedAlignment)), ...
    zeros(vidObj.alignedHeight(vidObj.selectedAlignment),vidObj.alignedWidth(vidObj.selectedAlignment)));
green(:,:,1) = 10*vidObj.brightSpots/max(vidObj.brightSpots(:));
ttt = green(:,:,1)==0;
green(:,:,2) = ttt;
%--------------------------------------------------------------------------

%corrWindow holds the the data/info of the current section of video
%being analyzed

%The values below are the length of half of the side of a square.
window.size =  20; %The window size to run pixel correlations on
time.size = 20; %The size of the window of bright spot timings to use
seg.initialSize = 2; %initial size of pixel box to include in pixel group G_px
%--------------------------------------------------------------------------

% kernal used for eroding and dilating
se = strel('diamond',10);
se2 = strel('diamond',4);

%location where segments are stored
if ~isfield(vidObj,'segments')
    vidObj.segments = [];
    vidObj.segMat = zeros(vidObj.alignedHeight(vidObj.selectedAlignment),vidObj.alignedWidth(vidObj.selectedAlignment));
    vidObj.segementOutline = zeros(vidObj.alignedHeight(vidObj.selectedAlignment),vidObj.alignedWidth(vidObj.selectedAlignment));
end

%allocation of memory
numFramesDown = length(1:downSamp:vidObj.numFrames);
data = uint8(nan(vidObj.alignedHeight(vidObj.selectedAlignment),vidObj.alignedWidth(vidObj.selectedAlignment),numFramesDown));
count = 0;
brightSpots = vidObj.brightSpots;
brightSpots = filter2(ones(3,3),brightSpots);
initialNumSpots = sum(brightSpots(:));

if ~isempty(vidObj.segments) %if vidObjs already has segments present
    brightSpots(sum(vidObj.segments,3)>0) = 0;
end

%Loads down sampled video into memory and calculates dF/F max projection
for frameNum=1:downSamp:vidObj.numFrames
    count = count +1;
     if (mod(frameNum,1+100*downSamp)==0)
            display(['Reading video into memory. ' num2str(frameNum/vidObj.numFrames*100) '% done'])
     end
    data(:,:,count) = msReadFrame(vidObj,frameNum,true,true,false); %loads dF/F frame
end
frameMax = squeeze(max(data,[],3));
data = reshape(data,[],numFramesDown);
%--------------------------------------------------------------------------

% lowpass filter pixel dF/F to remove some noise
[bFilt,aFilt] = butter(2,  1/((30/downSamp)/2), 'low');
for i=1:vidObj.alignedHeight
    tempData = double(data((1:vidObj.alignedWidth(vidObj.selectedAlignment))+vidObj.alignedWidth(vidObj.selectedAlignment)*(i-1),:)');
    tempData = filtfilt(bFilt,aFilt,tempData);
    data((1:vidObj.alignedWidth(vidObj.selectedAlignment))+vidObj.alignedWidth(vidObj.selectedAlignment)*(i-1),:) = uint8(tempData');
end
%--------------------------


[numCounts,index] = max(brightSpots(:));
f = figure(1);

%While loop will run through the pixel location with the highest number of
%bright spots detected until there are only pixels with counts less than brightSpotsStopAmount
brightSpotsStopAmount = 2; %Counts few than 5 are generally due to noise and slow down the segmentation algorithm
while (sum(brightSpots(:)) > 1) && (numCounts>=brightSpotsStopAmount)
    
    %centroid is the pixel location with the current highest count of
    %bright spots
    centroid(1) = mod(index,vidObj.alignedHeight(vidObj.selectedAlignment));
    centroid(2) = floor(index/vidObj.alignedHeight(vidObj.selectedAlignment))+1;
    
    %window holds the information for the iterative correlation algorithm
    %below. Used to select only the near by pixels in 'data' to run correlation on
    window.mask = zeros(vidObj.alignedHeight(vidObj.selectedAlignment),vidObj.alignedWidth(vidObj.selectedAlignment));
    window.width = uint16(max([1 centroid(2)-window.size]):min([vidObj.alignedWidth(vidObj.selectedAlignment) centroid(2)+window.size]));
    window.height = uint16(max([1 centroid(1)-window.size]):min([vidObj.alignedHeight(vidObj.selectedAlignment) centroid(1)+window.size]));
        
    % Plotting stuff. Uncomment if you want to see what is going on
    if plotting == true    
        subplot_tight(4,4,[1 2 3 5 6 7 9 10 11],[1 1]*.05);

        pcolor(double(frameMax))
        colormap gray;
        daspect([1 1 1])
        shading flat
        freezeColors

        hold on
        hhh = imshow(green);
        set(hhh,'AlphaData',(vidObj.segementOutline)|(vidObj.brightSpots>=2));
        rectangle('Position',[centroid(2)-window.size,centroid(1)-window.size,window.size*2,window.size*2]);
        hold off
        drawnow

        if ~isempty(vidObj.segments)
            title(['Current Count: ' num2str(numCounts) ' | Counts left: ' num2str(sum(brightSpots(:))/sum(initialNumSpots)*100) '% | Number of Segments: ' num2str(size(vidObj.segments,3))])
        end
    end
    %center of window. if statements handle if the window is overlapping
    %the edge of the frame
    if (window.width(1) == 1)
        window.centerMaskW = length(window.width) - window.size;
    else
        window.centerMaskW = window.size;
    end
    if (window.height(1) == 1)
        window.centerMaskH = length(window.height) - window.size;
    else
        window.centerMaskH = window.size;
    end
    %----------------------------------------------------------------------
    
    %window.mask and window.maskVect are masks containing 1's for pixels to run correlation on
    window.mask(window.height, window.width) = 1;
    window.maskVect = window.mask(:);
    
    %'time' is used to select the relevant frames for the following
    %correlation. We want to run correlation only around frames where there
    %was activity (i.e. dF/F bright spots).
    time.mask = zeros(vidObj.alignedHeight(vidObj.selectedAlignment),vidObj.alignedWidth(vidObj.selectedAlignment));
    time.width = uint16(max([1 centroid(2)-time.size]):min([vidObj.alignedWidth(vidObj.selectedAlignment) centroid(2)+time.size]));
    time.height = uint16(max([1 centroid(1)-time.size]):min([vidObj.alignedHeight(vidObj.selectedAlignment) centroid(1)+time.size]));
    time.mask(time.height, time.width) = 1;
    time.maskVect = time.mask(:);
    %----------------------------------------------------------------------
    
    %timesInWindow holds all the frame numbers of when bright spots occured
    %in time.mask
    timeWindow = zeros(1,numFramesDown);
    timesInWindow = vidObj.brightSpotTiming(time.maskVect==1,:);
    timesInWindow = timesInWindow(:);
    timesInWindow = timesInWindow(timesInWindow~=0);
    %----------------------------------------------------------------------
    
    for i=1:length(timesInWindow) %% need to add framerate and window width adjustments
        temp = timesInWindow(i)/downSamp;
        timeWindow(max([1 round(temp-30/downSamp)]):min([numFramesDown round(temp+150/downSamp)])) = 1; %number are time window size around event
    end
    
    %seg.mask holds the ROI of the current segment being detected
    seg.mask = zeros(vidObj.alignedHeight(vidObj.selectedAlignment),vidObj.alignedWidth(vidObj.selectedAlignment));
    seg.width = uint16(max([1 centroid(2)-seg.initialSize]):min([vidObj.alignedWidth(vidObj.selectedAlignment) centroid(2)+seg.initialSize]));
    seg.height = uint16(max([1 centroid(1)-seg.initialSize]):min([vidObj.alignedHeight(vidObj.selectedAlignment) centroid(1)+seg.initialSize]));
    
    seg.mask(seg.height,seg.width) = 1;
    seg.maskVect = seg.mask(:);
    %----------------------------------------------------------------------
    
    kill = 0; %used in case interative algorithm get stuck
    attempts = 0;
    previousMaskSum = 0; %prevoious size of ROI
    corrCoefThresh = corrCoefThreshDefault;
    
    %Used to approx. dF/F. F ~= meanFrame
    meanFrameWindow = vidObj.meanFrame{vidObj.selectedAlignment}(window.maskVect==1);
    meanFrameWindow = repmat(meanFrameWindow,1,sum(timeWindow));
    %----------------------------------------------------------------------
    
    %Start of iterative algorithm
    while (kill == 0)
        attempts = attempts +1;
        
        %Calculate mean dF/F of all pixels currently in ROI
        seg.mean = mean(double(data(seg.maskVect==1,timeWindow==1))./repmat(vidObj.meanFrame{vidObj.selectedAlignment}(seg.maskVect==1),1,sum(timeWindow)),1);       
        %Calculate approx individual dF/F of surrounding pixels
        temp3 = double(data(window.maskVect==1,timeWindow==1))./meanFrameWindow;
        %------------------------------------------------------------------
        
        %dF/dt
%         seg.mean = diff(seg.mean);
%         temp3 = diff(temp3,1,2);
        %-----
        
        %Calculate correlation of current segment dF/F with individual
        %surrounding pixels
        xCorrCoef2 = corr(double(temp3'),seg.mean');
        xCorrCoef = reshape(xCorrCoef2,length(window.height),length(window.width));
        %------------------------------------------------------------------
        
        %Surrounding pixels with high correlation coefficients get grouped
        %into the segment
        seg.mask(window.height,window.width) = ((seg.mask(window.height,window.width) == 1) | (xCorrCoef > corrCoefThresh));
        
        seg.mask = imdilate(seg.mask,se);
        seg.mask = imerode(seg.mask,se);
        %------------------------------------------------------------------
        
        %Making sure the pixel group we are keeping is the one containing
        %the initial group
        regionStats = regionprops(logical(seg.mask), 'Area', 'BoundingBox', 'Image', 'PixelIdxList');
        c = 0;
        maskSum = 0;
        for j=1:length(regionStats)
            if (sum(regionStats(j).PixelIdxList == index) >0)
                c = c +1 ;
                seg.mask(:,:) = 0;
                seg.mask(regionStats(j).BoundingBox(2)-.5+(1:regionStats(j).BoundingBox(4)), ...
                    regionStats(j).BoundingBox(1)-.5+(1:regionStats(j).BoundingBox(3))) = regionStats(j).Image*1;
                maskSum = regionStats(j).Area;%sum(sum(seg.mask));
                break;
            end                    
        end
        if (c == 0)
            kill = 1;
            attempts = inf;
            display('Segment moved too far away');
        end
        %------------------------------------------------------------------
        
        % Plotting stuff. Uncomment if you want to see what is going on.
        if plotting == true
        subplot_tight(4,4,[4],[1 1]*.05);                
        pcolor(xCorrCoef);
        colormap jet
        title('CorrCoef')
        shading flat
        caxis([0 1])
        daspect([1 1 1])
        set(gca,'xTick',[])
        set(gca,'yTick',[])
        freezeColors

        subplot_tight(4,4,12,[1 1]*.05);  
        pcolor(seg.mask(window.height,window.width)*1)
        colormap jet
        set(gca,'xTick',[])
        set(gca,'yTick',[])
        freezeColors
        title(['Final Mask | NumPixels:' num2str(maskSum)])
        shading flat
        daspect([1 1 1])
        subplot_tight(4,4,[13 14 15 16],[1 1]*.05);  
                ttt = find(xCorrCoef2<corrCoefThresh);
%                 length(ttt)
                ttt = ttt(ceil(length(ttt)*rand(ceil(length(ttt)/100),1)));
                if (~isempty(ttt))
                    plot(((1:size(temp3,2))*downSamp/30)',temp3(ttt,:)'-1,'r');
                    hold on 
                end
                ttt = find(xCorrCoef2>=corrCoefThresh);
                ttt = ttt(ceil(length(ttt)*rand(ceil(length(ttt)/30),1)));
                if (~isempty(ttt))
                    plot(((1:size(temp3,2))*downSamp/30)',temp3(ttt,:)'-1,'g');
                end
                plot(((1:size(temp3,2))*downSamp/30)',seg.mean-1,'k','linewidth',2);
                hold off
%                 axis([-corrWindow.frameLength corrWindow.frameLength -.1 .3])
                title('Pixel intensity')
                xlabel('time (s)');
                ylabel('dF/F');
                ylim([-0.1 .5])
                xlim([0 size(temp3,2)*downSamp/30])
        drawnow
        end
    % Checks to see if segment stopped growing or too many iterations have passed
        if (maskSum > cellAreaLimits(2))
            attempts = inf;
            kill = 1;
        end

        if (maskSum == previousMaskSum)
            kill = 1;
            if (maskSum < cellAreaLimits(1))
                attempts = inf;

            end
        end
        previousMaskSum = maskSum;
        seg.maskVect = seg.mask(:);
        if (attempts >30)
            attempts = inf;
            kill=1;
        end
        
    end
    % Adds final segment ROI to vidObj.segment
    brightSpots(seg.maskVect == 1) = 0;
    seg.mask = imdilate(seg.mask,se);
    seg.mask = imerode(seg.mask,se);
    if (attempts <=30)
        if isempty(vidObj.segments)
            vidObj.segments(:,:,1) = seg.mask;
        else
            vidObj.segments(:,:,end+1) = seg.mask;
        end
        vidObj.segementOutline = vidObj.segementOutline + bwperim(seg.mask);
        vidObj.segMat(vidObj.segments(:,:,end)==1) = vidObj.segMat(vidObj.segments(:,:,end)==1) +1;
    else
        display('Could not find bounds')
    end
    [numCounts,index] = max(brightSpots(:));
end
               
vidObj.segments = uint8(vidObj.segments); %added 10_8_2014 to decrease memory size
vidObj.cellAreaLimits = cellAreaLimits;
vidObj.numSegments = size(vidObj.segments,3);

end


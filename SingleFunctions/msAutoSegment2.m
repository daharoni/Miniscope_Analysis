function vidObj = msAutoSegment2(vidObj, frameLimits, cellAreaLimits, downSamp,corrCoefThreshDefault)
%MSAUTOSEGMENT Summary of this function goes here
%   Detailed explanation goes here

cVideo = 0;
if isempty(frameLimits)
    frameLimits = [1 vidObj.numFrames];
end

% Added in for making video
%--------------------------
    
count = 0;
%these settings can be changed.
% brightnessThreshDefault = 0.85;%0.9;
% corrCoefThreshDefault = 0.9;%0.86;

%smoothing kernal
hSmall = fspecial('average', 5);
hLarge = fspecial('average', 60);

green = cat(3, zeros(vidObj.alignedHeight,vidObj.alignedWidth), ...
    ones(vidObj.alignedHeight,vidObj.alignedWidth), ...
    zeros(vidObj.alignedHeight,vidObj.alignedWidth));
green(:,:,1) = 10*vidObj.brightSpots/max(vidObj.brightSpots(:));
ttt = green(:,:,1)==0;
green(:,:,2) = ttt;

%corrWindow holds the the data/info of the current section of video
%being analyzed
window.size =  20;
time.size = 20;
seg.initialSize = 2;

% kernal used for eroding and dilating
se = strel('diamond',10);
se2 = strel('diamond',4);
%location where segments are stored
if ~isfield(vidObj,'segments')
    vidObj.segments = [];
    vidObj.segMat = zeros(vidObj.alignedHeight,vidObj.alignedWidth);
    vidObj.segementOutline = zeros(vidObj.alignedHeight,vidObj.alignedWidth);
end
%allocation of memory

numFramesDown = length(1:downSamp:vidObj.numFrames);
data = uint8(nan(vidObj.alignedHeight,vidObj.alignedWidth,numFramesDown));
count = 0;
brightSpots = vidObj.brightSpots;
brightSpots = filter2(ones(3,3),brightSpots);
initialNumSpots = sum(brightSpots(:));
if ~isempty(vidObj.segments)
    brightSpots(sum(vidObj.segments,3)>0) = 0;
end
for frameNum=1:downSamp:vidObj.numFrames
    count = count +1;
     if (mod(frameNum,1+100*downSamp)==0)
            display(['Reading video into memory. ' num2str(frameNum/vidObj.numFrames*100) '% done'])
     end
    data(:,:,count) = msReadFrame(vidObj,frameNum,true,true,false);
end
frameMax = squeeze(max(data,[],3));
data = reshape(data,[],numFramesDown);

% lowpass filter pixel dF/F
[bFilt,aFilt] = butter(2,  1/((30/downSamp)/2), 'low');
for i=1:vidObj.alignedHeight
    tempData = double(data((1:vidObj.alignedWidth)+vidObj.alignedWidth*(i-1),:)');
    tempData = filtfilt(bFilt,aFilt,tempData);
    data((1:vidObj.alignedWidth)+vidObj.alignedWidth*(i-1),:) = uint8(tempData');
end
%--------------------------

[numCounts,index] = max(brightSpots(:));
f = figure(1);
while (sum(brightSpots(:)) > 1) && (numCounts>=5)

    centroid(1) = mod(index,vidObj.alignedHeight);
    centroid(2) = floor(index/vidObj.alignedHeight)+1;
    
    window.mask = zeros(vidObj.alignedHeight,vidObj.alignedWidth);
    window.width = uint16(max([1 centroid(2)-window.size]):min([vidObj.alignedWidth centroid(2)+window.size]));
    window.height = uint16(max([1 centroid(1)-window.size]):min([vidObj.alignedHeight centroid(1)+window.size]));
        
    subplot_tight(4,4,[1 2 3 5 6 7 9 10 11],[1 1]*.05);

%     h =imshow((frameMax),[50 150]);
pcolor(double(frameMax))
    colormap gray;
    daspect([1 1 1])
    shading flat
    freezeColors
% drawnow
%     hold on
    
%     h = imshow(vidObj.brightSpots,[0 10]);
%     drawnow
%     set(h,'AlphaData',vidObj.brightSpots~=0);
%     drawnow
%     daspect([1 1 1])
%     shading flat
    hold on
    hhh = imshow(green);
%     drawnow
    set(hhh,'AlphaData',(vidObj.segementOutline)|(vidObj.brightSpots>=2));
%     drawnow
%     plot(centroid(2),centroid(1),'ro','markersize',30)
    rectangle('Position',[centroid(2)-window.size,centroid(1)-window.size,window.size*2,window.size*2]);
    hold off
    drawnow
    if ~isempty(vidObj.segments)
        title(['Current Count: ' num2str(numCounts) ' | Counts left: ' num2str(sum(brightSpots(:))/sum(initialNumSpots)*100) '% | Number of Segments: ' num2str(size(vidObj.segments,3))])
%     title(['Number of Segments: ' num2str(size(vidObj.segments,3))])
    end
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
    window.mask(window.height, window.width) = 1;
    window.maskVect = window.mask(:);
    
    time.mask = zeros(vidObj.alignedHeight,vidObj.alignedWidth);
    time.width = uint16(max([1 centroid(2)-time.size]):min([vidObj.alignedWidth centroid(2)+time.size]));
    time.height = uint16(max([1 centroid(1)-time.size]):min([vidObj.alignedHeight centroid(1)+time.size]));
    time.mask(time.height, time.width) = 1;
    time.maskVect = time.mask(:);
    
    timeWindow = zeros(1,numFramesDown);
    timesInWindow = vidObj.brightSpotTiming(time.maskVect==1,:);
    timesInWindow = timesInWindow(:);
    timesInWindow = timesInWindow(timesInWindow~=0);
    for i=1:length(timesInWindow) %% need to add framerate and window width adjustments
        temp = timesInWindow(i)/downSamp;
        timeWindow(max([1 round(temp-30/downSamp)]):min([numFramesDown round(temp+150/downSamp)])) = 1; %number are time window size around event
%         [i sum(timeWindow)]
    end
%     waitforbuttonpress
    seg.mask = zeros(vidObj.alignedHeight,vidObj.alignedWidth);
    seg.width = uint16(max([1 centroid(2)-seg.initialSize]):min([vidObj.alignedWidth centroid(2)+seg.initialSize]));
    seg.height = uint16(max([1 centroid(1)-seg.initialSize]):min([vidObj.alignedHeight centroid(1)+seg.initialSize]));

    seg.mask(seg.height,seg.width) = 1;
    seg.maskVect = seg.mask(:);
%     pcolor(seg.mask)
%     shading flat
    kill = 0;
    attempts = 0;
    previousMaskSum = 0;
    corrCoefThresh = corrCoefThreshDefault;
%     brightnessThresh = brightnessThreshDefault;
    
    meanFrameWindow = vidObj.meanFrame{vidObj.selectedAlignment}(window.maskVect==1);
    meanFrameWindow = repmat(meanFrameWindow,1,sum(timeWindow));
    while (kill == 0)
        attempts = attempts +1;
        seg.mean = mean(double(data(seg.maskVect==1,timeWindow==1))./repmat(vidObj.meanFrame{vidObj.selectedAlignment}(seg.maskVect==1),1,sum(timeWindow)),1);       
        temp3 = double(data(window.maskVect==1,timeWindow==1))./meanFrameWindow;
        
        %dF/dt
%         seg.mean = diff(seg.mean);
%         temp3 = diff(temp3,1,2);
        %-----
        xCorrCoef2 = corr(double(temp3'),seg.mean');
        xCorrCoef = reshape(xCorrCoef2,length(window.height),length(window.width));

        seg.mask(window.height,window.width) = ((seg.mask(window.height,window.width) == 1) | (xCorrCoef > corrCoefThresh));
        
        seg.mask = imdilate(seg.mask,se);
        seg.mask = imerode(seg.mask,se);
    
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
        
        cVideo = cVideo+1;
        filename = ['video/frame' num2str(cVideo) '.jpg'];
        
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
%         subplot_tight(4,4,[8],[1 1]*.05);  
%         pcolor((xCorrCoef > corrCoefThresh)*1);
%         colormap jet
%         freezeColors
%         title(['CorrCoef Mask'])
%         shading flat
%         daspect([1 1 1])
%                 subplot_tight(4,4,[12],[1 1]*.05);  
%                 pcolor(brightnessMask*1);
%                 colormap jet
%                 freezeColors
%                 title(['Brightness Mask | Thresh:' num2str(brightnessThresh)])
%                 shading flat
%                 daspect([1 1 1])
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
        % Added in for making video
%             saveas(f,filename);
        %----------------------------------
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
               

%     frameNum = frameNum + stepSize;
%     corrWindow.frame(:,:,1:end-stepSize) = corrWindow.frame(:,:,(stepSize+1):end);
%     corrWindow.frame(1,1,(end-stepSize):end) = nan;
%     curserW = [];
%     
    
    
% end
vidObj.segments = uint8(vidObj.segments); %added 10_8_2014 to decrease memory size
vidObj.cellAreaLimits = cellAreaLimits;
vidObj.numSegments = size(vidObj.segments,3);

%Added for making video

%----------------------
end


function vidObj = msAutoSegment(vidObj,stepSize, frameLimits, cellAreaLimits, fps, dFFTresh, backgroundTresh)
%MSAUTOSEGMENT Summary of this function goes here
%   Detailed explanation goes here


if isempty(frameLimits)
    frameLimits = [1 vidObj.numFrames];
end

count = 0;
%these settings can be changed.
brightnessThreshDefault = 0.85;%0.9;
corrCoefThreshDefault = 0.97;%0.86;

%smoothing kernal
hSmall = fspecial('average', 5);
hLarge = fspecial('average', 60);

red = cat(3, ones(vidObj.alignedHeight(vidObj.selectedAlignment),vidObj.alignedWidth(vidObj.selectedAlignment)), ...
    zeros(vidObj.alignedHeight(vidObj.selectedAlignment),vidObj.alignedWidth(vidObj.selectedAlignment)), ...
    zeros(vidObj.alignedHeight(vidObj.selectedAlignment),vidObj.alignedWidth(vidObj.selectedAlignment)));

green = cat(3, zeros(vidObj.alignedHeight(vidObj.selectedAlignment),vidObj.alignedWidth(vidObj.selectedAlignment)), ...
    ones(vidObj.alignedHeight(vidObj.selectedAlignment),vidObj.alignedWidth(vidObj.selectedAlignment)), ...
    zeros(vidObj.alignedHeight(vidObj.selectedAlignment),vidObj.alignedWidth(vidObj.selectedAlignment)));

%corrWindow holds the the data/info of the current section of video
%being analyzed
corrWindow.frameLength = ceil(5*fps);
corrWindow.size =  30;
seg.initialSize = 2;

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
corrWindow.frame = (nan(vidObj.alignedHeight(vidObj.selectedAlignment),vidObj.alignedWidth(vidObj.selectedAlignment),corrWindow.frameLength*2+1));
frameNum = max([frameLimits(1) stepSize corrWindow.frameLength+1]);


while (frameNum < min([frameLimits(2) (vidObj.numFrames-(stepSize + corrWindow.frameLength))]))
    beginingFrameNum = frameNum - corrWindow.frameLength;
    endingFrameNum = frameNum+corrWindow.frameLength;
    
    %loads needed frames centered around the current frame being
    %displayed
    for loadFrameNum = beginingFrameNum:endingFrameNum
        if (isnan(corrWindow.frame(1,1,loadFrameNum-beginingFrameNum+1)))
            %                 loadFrameNum
            corrWindow.frame(:,:,loadFrameNum-beginingFrameNum+1) =filter2(hSmall,msReadFrame(vidObj,loadFrameNum,true,true,true));
        end
    end
    frame = max(corrWindow.frame(:,:,ceil(end/2+(-stepSize:stepSize)/2)),[],3);
    frameBase = filter2(hLarge,frame);
    f = figure(1)
    clf
    hold off
    bw = zeros(size(frame));
    bw((frame./frameBase >= backgroundTresh) & (frame >dFFTresh)) = 1;
    bw = imerode(bw,se2);
    %         bw = imdilate(bw,se2);
    
    bwProps = regionprops(logical(bw), frame, 'Area', 'BoundingBox', 'Image', 'PixelIdxList','Centroid','WeightedCentroid');
    subplot_tight(4,4,[1 2 3 5 6 7 9 10 11],[1 1]*.05);
    pcolor(frame)
    caxis([-0.05 .3]) %sets visial dF/F range
    
    colormap gray
    shading flat
    hold on
    %overlay outline of segmentations
    h = imshow(red);
    set(h, 'AlphaData', vidObj.segementOutline);
    hold on
    h3 = imshow(green);
    set(h3, 'AlphaData', bw);
    freezeColors
    
    if ~isempty(vidObj.segments)
        title(['Frame: ' num2str(frameNum) '/' num2str(vidObj.numFrames) ' | Number of ROIs: ' num2str(size(vidObj.segments,3))]);
    else
        title(['Frame: ' num2str(frameNum) '/' num2str(vidObj.numFrames)]);
    end
    
    for propNum = 1:length(bwProps)
%         bwProps(propNum).Centroid = floor(bwProps(propNum).Centroid);
        bwProps(propNum).Centroid = floor(bwProps(propNum).WeightedCentroid);

        alreadySegmented = 0;
        if (vidObj.segMat(bwProps(propNum).Centroid(2),bwProps(propNum).Centroid(1)) ~=0)
            alreadySegmented = 1;
        end
        
        %---------added for inscopix data
%         if (sqrt((bwProps(propNum).Centroid(2)-vidObj.alignedHeight(vidObj.selectedAlignment)/2)^2+ (bwProps(propNum).Centroid(1)-vidObj.alignedWidth(vidObj.selectedAlignment)/2)^2) > 240)
%             alreadySegmented = 1;
%         end
        %--------------------------------
        if (bwProps(propNum).Area < 500 && bwProps(propNum).Area >=20 && alreadySegmented == 0)
            figure(1)
            set(h, 'AlphaData', vidObj.segementOutline)
            if ~isempty(vidObj.segments)
                title(['Frame: ' num2str(frameNum) '/' num2str(vidObj.numFrames) ' | Number of ROIs: ' num2str(size(vidObj.segments,3))]);
            end
            
            
            %grab a single input from mouse/keyboard
            %             [curserW, curserH, curserB] = ginput(1);
            %             curserW = char(curserW);
            %             curserH = char(curserH);
            
            corrWindow.mask = zeros(vidObj.alignedWidth(vidObj.selectedAlignment),vidObj.alignedHeight(vidObj.selectedAlignment));
            corrWindow.width = uint16(max([1 bwProps(propNum).Centroid(1)-corrWindow.size]):min([vidObj.alignedWidth(vidObj.selectedAlignment) bwProps(propNum).Centroid(1)+corrWindow.size]));
            corrWindow.height = uint16(max([1 bwProps(propNum).Centroid(2)-corrWindow.size]):min([vidObj.alignedHeight(vidObj.selectedAlignment) bwProps(propNum).Centroid(2)+corrWindow.size]));
            corrWindow.centerW = bwProps(propNum).Centroid(1);
            corrWindow.centerH = bwProps(propNum).Centroid(2);
            
            subplot_tight(4,4,[1 2 3 5 6 7 9 10 11],[1 1]*.05);
            plot(corrWindow.centerW,corrWindow.centerH,'bo','markersize',40)
            
            if (corrWindow.width(1) == 1)
                corrWindow.centerMaskW = length(corrWindow.width) - corrWindow.size;
            else
                corrWindow.centerMaskW = corrWindow.size;
            end
            if (corrWindow.height(1) == 1)
                corrWindow.centerMaskH = length(corrWindow.height) - corrWindow.size;
            else
                corrWindow.centerMaskH = corrWindow.size;
            end
            corrWindow.mask(corrWindow.width, corrWindow.height) = 1;
            corrWindow.mask = corrWindow.mask';
            corrWindow.maskVect = corrWindow.mask(:);
            
            seg.mask = zeros(vidObj.alignedWidth(vidObj.selectedAlignment),vidObj.alignedHeight(vidObj.selectedAlignment));
            seg.width = uint16(max([1 bwProps(propNum).Centroid(1)-seg.initialSize]):min([vidObj.alignedWidth(vidObj.selectedAlignment) bwProps(propNum).Centroid(1)+seg.initialSize]));
            seg.height = uint16(max([1 bwProps(propNum).Centroid(2)-seg.initialSize]):min([vidObj.alignedHeight(vidObj.selectedAlignment) bwProps(propNum).Centroid(2)+seg.initialSize]));
            
            seg.mask(seg.width,seg.height) = 1;
            seg.mask = seg.mask';
            seg.maskVect = seg.mask(:);
            
            clickIdx = vidObj.alignedHeight(vidObj.selectedAlignment)*(bwProps(propNum).Centroid(1)-1)+ bwProps(propNum).Centroid(2);
            
            kill = 0;
            attempts = 0;
            previousMaskSum = 0;
            corrCoefThresh = corrCoefThreshDefault;
            brightnessThresh = brightnessThreshDefault;
            while (kill == 0)
                attempts = attempts +1;
                temp2 = reshape(corrWindow.frame,[],size(corrWindow.frame,3));
                seg.mean = mean(temp2(seg.maskVect==1,:),1);
                
                temp3 = temp2(corrWindow.maskVect==1,:);
                xCorrCoef2 = corr(double(temp3'),seg.mean');
                xCorrCoef = reshape(xCorrCoef2,length(corrWindow.height),length(corrWindow.width));
                
                brightness = mean(max(temp2(seg.maskVect==1,:),[],2));
                brightnessMask = (max(corrWindow.frame(corrWindow.height,corrWindow.width,:),[],3)) >= brightnessThresh*brightness;
                %                 brightness = mean(max(temp2(seg.maskVect==1,:),[],2));
                %                 brightnessMask = (max(temp(corrWindow.height,corrWindow.width,:),[],3)) >= brightnessThresh*brightness;
                seg.mask(corrWindow.height,corrWindow.width) = ((seg.mask(corrWindow.height,corrWindow.width) == 1) | (xCorrCoef > corrCoefThresh)) & brightnessMask;
               
%                 seg.mask(brightnessMask == 0) = 0;
                
                %                 seg.mask = imerode(seg.mask,se);
                %                 seg.mask = imdilate(seg.mask,se);
                
                
                seg.mask = imdilate(seg.mask,se);
                seg.mask = imerode(seg.mask,se);
                
                
                regionStats = regionprops(logical(seg.mask), 'Area', 'BoundingBox', 'Image', 'PixelIdxList');
                c = 0;
                maskSum = 0;
                for j=1:length(regionStats)
                    if (sum(regionStats(j).PixelIdxList == clickIdx) >0)
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
                %                     [regionStats(j).Area maskSum]
                f = figure(1)
                subplot_tight(4,4,[4],[1 1]*.05);                
                pcolor(xCorrCoef);
                colormap jet
                title('CorrCoef')
                shading flat
                caxis([0 1])
                daspect([1 1 1])
                freezeColors
                subplot_tight(4,4,[8],[1 1]*.05);  
                pcolor((xCorrCoef > corrCoefThresh)*1);
                colormap jet
                freezeColors
                title(['CorrCoef Mask | Thresh:' num2str(corrCoefThresh)])
                shading flat
                daspect([1 1 1])
                subplot_tight(4,4,[12],[1 1]*.05);  
                pcolor(brightnessMask*1);
                colormap jet
                freezeColors
                title(['Brightness Mask | Thresh:' num2str(brightnessThresh)])
                shading flat
                daspect([1 1 1])
                subplot_tight(4,4,[16],[1 1]*.05);  
                pcolor(seg.mask(corrWindow.height,corrWindow.width)*1)
                colormap jet
                freezeColors
                title(['vidObj.segmentsation Mask | NumPixels:' num2str(maskSum)])
                shading flat
                daspect([1 1 1])
                subplot_tight(4,4,[13 14 15],[1 1]*.05);  
                
                plot(-corrWindow.frameLength:corrWindow.frameLength,temp3(1:20:end,:)','r');
                hold on
                plot(-corrWindow.frameLength:corrWindow.frameLength,seg.mean,'k','linewidth',2);
                hold off
                axis([-corrWindow.frameLength corrWindow.frameLength -.1 .3])
                title('Pixel intensity')
                xlabel('frame');
                ylabel('dF/F');
                drawnow
%                 count = count+1;
%                 filename = ['video/frame' num2str(count) '.jpg'];
%                 saveas(f,filename);
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
            
            
        end
    end
    frameNum = frameNum + stepSize;
    corrWindow.frame(:,:,1:end-stepSize) = corrWindow.frame(:,:,(stepSize+1):end);
    corrWindow.frame(1,1,(end-stepSize):end) = nan;
    curserW = [];
    
    
    
end
vidObj.segments = uint8(vidObj.segments); %added 10_8_2014 to decrease memory size
vidObj.cellAreaLimits = cellAreaLimits;
vidObj.numSegments = size(vidObj.segments,3);
end


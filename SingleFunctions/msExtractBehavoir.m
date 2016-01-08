function behav = msExtractBehavoir(behav, trackLength)
%MSEXTRACTBEHAVOIR Summary of this function goes here
%   Detailed explanation goes here
    ROI = uint16([behav.ROI(1) behav.ROI(1)+behav.ROI(3) behav.ROI(2) behav.ROI(2)+behav.ROI(4)]);
%% Removes background
% takes the median of each pixel from 100 frames spread out across the video
    numFramesUsed = 100;
    if behav.numFrames >  numFramesUsed
        backgroundFrames = ceil(linspace(1,behav.numFrames,numFramesUsed));
    else
        backgroundFrames = linspace(1,behav.numFrames,behav.numFrames);
    end
    
    frame = uint8(zeros(behav.height,behav.width,3,length(backgroundFrames)));
    for index=1:length(backgroundFrames)
        if (mod(index,10)==0)
            display(['Reading in video for background subtraction. ' num2str(index/length(backgroundFrames)*100) '% done'])
        end
        frame(:,:,:,index) = uint8(msReadFrame(behav,backgroundFrames(index),false,false,false));
    end
    frame = frame(ROI(3):ROI(4),ROI(1):ROI(2),:,:);
    background = median(frame,4);
    figure(2)
    imshow(background,'InitialMagnification','fit')
    title('Background. Make sure the mouse does not show up')
%%
    position = nan(behav.numFrames, 2);
    for frameNum=1:behav.numFrames
        frame = double(msReadFrame(behav,frameNum,false,false,false))/255;
        frame = frame(ROI(3):ROI(4),ROI(1):ROI(2),:);
        
        backgroundIndex = ones(size(frame(:,:,1)));
        for i=1:3
            backgroundIndex = backgroundIndex & (frame(:,:,i) < (.1+double(background(:,:,i))/255) & frame(:,:,i) > (-.1+double(background(:,:,i))/255));
        end
        backgroundIndex = repmat(backgroundIndex,1,1,3);
        frame(backgroundIndex) = 0;
%         frame = frame(:,:,1)./sum(frame(:,:,[2 3]),3);
        bw = hsvThreshold(frame,behav.hsvLevel);
        
%         bw = imerode(bw,se);
%         bw = imdilate(bw,se);
        
%         frame= im2bw(frame,threshold);
%         frame = bw;
%         hold off
        
%         figure(1)
%         imshow(bw)
%         drawnow
        props = regionprops(bw,'Area','Centroid');
        area = 0;
        index = 0;
        for i=1:length(props)
            if (props(i).Area > area)
                area = props(i).Area;
                index  = i;
            end
        end
        if index ~=0        
            position(frameNum,[1 2]) = props(index).Centroid;
        end
        if (mod(frameNum,200)==0)
            display(['Calculating animal position. ' num2str(frameNum/behav.numFrames*100) '% done'])
            figure(2)
            imshow(background)
            hold on
            plot(position(:,1),position(:,2),'r')
            hold off
            daspect([1 1 1])
            drawnow
        end
%         hold on
%         plot(position(frameNum,1),position(frameNum,2),'r.')
        
    end
    position = position*trackLength/behav.ROI(3);
    
    time = behav.time(~isnan(position(:,1)));
    position = position(~isnan(position(:,1)),:);
    position = interp1(time,position,behav.time);
    dt = median(diff(behav.time/1000)); 
    position = smoothts(position','b',ceil(1/dt))';
    behav.position = position;
    
    dx = [0; diff(position(:,1))];
    dy = [0; diff(position(:,2))];

    behav.speed = sqrt((dx).^2+(dy).^2)/dt;
    behav.speed = smoothts(behav.speed','b',ceil(1/dt));
    behav.dt = dt;
    behav.trackLength = trackLength;
    
end



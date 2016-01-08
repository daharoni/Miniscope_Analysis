function vidObj = msAlignment(vidObj)
%MSALIGNMENT Aligns frames from a single experiment. Aligns using the
%middle frame as reference. 
%First click and drag to select ROI.
%Algorithm runs in a parfor loop to speed up alignment

    hShift = nan(vidObj.numFrames,size(vidObj.alignmentROI,2));
    wShift = nan(vidObj.numFrames,size(vidObj.alignmentROI,2));
    [optimizer, metric]  = imregconfig('monomodal');%'monomodal');
%     optimizer.GradientMagnitudeTolerance =.5e-4;
%     optimizer.MinimumStepLength = .5e-5;
%     optimizer.MaximumStepLength = 12e-2;
%     optimizer.RelaxationFactor = .7;
    
    %filter templates for preprocessing alignment frames
    hLarge = fspecial('average', 80);
    hSmall = fspecial('average', 2);
    
    %displays reference frame so an ROI can be selected
    for ROINum = 1:size(vidObj.alignmentROI,2)
        refFrameNumber = ceil(vidObj.numFrames/2);
        refFrame = msReadFrame(vidObj,refFrameNumber,true,false,false);

        rect = vidObj.alignmentROI(:,ROINum);
        ROI = uint16([rect(1) rect(1)+rect(3) rect(2) rect(2)+rect(4)]);
        refFrame = (filter2(hSmall,refFrame) - filter2(hLarge, refFrame));
        refFrame = refFrame(ROI(3):ROI(4),ROI(1):ROI(2));

        %runs through data, calculating shifts in height and width
        parfor frameNum=1:vidObj.numFrames
            frame = msReadFrame(vidObj,frameNum,true,false,false);
            frame = (filter2(hSmall,frame) - filter2(hLarge, frame));
            frame = frame(ROI(3):ROI(4),ROI(1):ROI(2));
    %         frame = frame - refFrameMin;
    %         frame = (frame-refMin)/refMax;
    %         frame = (frame-min(min(frame)))/max(max(frame-min(min(frame))));

            aligned = imregister(frame,refFrame,'translation',optimizer, metric);
            hShift(frameNum) = sum(sum(aligned(1:50,:),2)==0) - sum(sum(aligned(end-49:end,:),2)==0);
            wShift(frameNum) = sum(sum(aligned(:,1:50),1)==0) - sum(sum(aligned(:,end-49:end),1)==0);  

            if (mod(frameNum,200)==0)
                display(['Calculating shift between frames. ' num2str(frameNum/vidObj.numFrames*100) '%'])    
            end

        end
        vidObj.hShift(:,ROINum) = hShift;
        vidObj.wShift(:,ROINum) = wShift;
        vidObj.alignedHeight(ROINum) = vidObj.height - (max(vidObj.hShift(:,ROINum))-min(vidObj.hShift(:,ROINum))+1);
        vidObj.alignedWidth(ROINum) = vidObj.width - (max(vidObj.wShift(:,ROINum))-min(vidObj.wShift(:,ROINum))+1);
    end
end


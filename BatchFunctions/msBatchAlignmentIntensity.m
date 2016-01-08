function msBatchAlignmentIntensity(dirName)
%MSBATCHALIGNMENT Summary of this function goes here
%   Detailed explanation goes here

    %--------- Alignment parameters ----
    [optimizer, metric]  = imregconfig('monomodal');%'monomodal');
    %filter templates for preprocessing alignment frames
    hLarge = fspecial('average', 80);
    hSmall = fspecial('average', 2);
    %-----------------------------------
    
    dataFolders = msBatchFindDataFolders(dirName,[]);
    for folderNum = 1:length(dataFolders)
        currentFolder = dataFolders{folderNum};
        temp = load([currentFolder '\ms.mat']);
        ms = temp.ms;
        % ---------------- Actual alignment code ----------------------
        if (~isfield(ms,'hShift')) %does not have alignment already done
            for ROINum = 1:size(ms.alignmentROI,2)
                display(['Working on alginment ' num2str(ROINum) '/' num2str(size(ms.alignmentROI,2)) ' for ' currentFolder]);
                hShift = nan(ms.numFrames,1);
                wShift = nan(ms.numFrames,1);
                rect = ms.alignmentROI(:,ROINum);
                ROI = uint16([rect(1) rect(1)+rect(3) rect(2) rect(2)+rect(4)]);
                refFrameNumber = ceil(ms.numFrames/2);
                refFrame = msReadFrame(ms,refFrameNumber,true,false,false);
                refFrame = (filter2(hSmall,refFrame) - filter2(hLarge, refFrame));
                refFrame = refFrame(ROI(3):ROI(4),ROI(1):ROI(2));
    %             pcolor(refFrame);
    %             shading flat
    %             daspect([1 1 1])
    %             title('ROI of alignment frame');
    %             drawnow;

                %runs through data, calculating shifts in height and width
                parfor frameNum=1:ms.numFrames

                    frame = msReadFrame(ms,frameNum,true,false,false);
                    frame = (filter2(hSmall,frame) - filter2(hLarge, frame));
                    frame = frame(ROI(3):ROI(4),ROI(1):ROI(2));

                    aligned = imregister(frame,refFrame,'translation',optimizer, metric);
                    hShift(frameNum) = sum(sum(aligned(1:50,:),2)==0) - sum(sum(aligned(end-49:end,:),2)==0);
                    wShift(frameNum) = sum(sum(aligned(:,1:50),1)==0) - sum(sum(aligned(:,end-49:end),1)==0);  

                    if (mod(frameNum,1000)==0)
                        display(['Calculating shift between frames. ' num2str(frameNum/ms.numFrames*100) '%'])    
                    end
                end
                ms.hShift(:,ROINum) = hShift;
                ms.wShift(:,ROINum) = wShift;
                ms.alignedHeight(ROINum) = ms.height - (max(hShift)-min(hShift)+1);
                ms.alignedWidth(ROINum) = ms.width - (max(wShift)-min(wShift)+1);
            end
            save([currentFolder '\ms.mat'],'ms','-v7.3');
        end
    end

end


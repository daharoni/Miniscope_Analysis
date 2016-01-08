function msBatchSegmentsInField(dirName)
%MSBATCHSEGMENTSINFIELD Summary of this function goes here
%   Detailed explanation goes here

    dataFolders = msBatchFindDataFolders(dirName,[]);
    
    refFolderNum = ceil(length(dataFolders)/2);
    currentFolder = dataFolders{refFolderNum};
    temp = load([currentFolder '\ms.mat']);
    msRef = temp.ms;
    refMeanFrame = msRef.meanFrame{msRef.selectedAlignment};
    display(['Reference session: ' num2str(refFolderNum)]);
    
    overlapMask = ones(size(refMeanFrame));
    overlapImage = zeros(size(refMeanFrame));
    
    for folderNum = 1:length(dataFolders)
        currentFolder = dataFolders{folderNum};
        temp = load([currentFolder '\ms.mat']);
        ms = temp.ms;
        if(isfield(ms,'tform'))
            temp1 = imwarp(ones(size(ms.meanFrame{ms.selectedAlignment})),ms.tform,'OutputView', imref2d(size(refMeanFrame)));
            overlapMask = overlapMask&temp1;
            overlapImage = overlapImage+temp1;
           
        else
            display([currentFolder ' is missing tform.']);
        end
        
    end
    for folderNum = 1:length(dataFolders)
        currentFolder = dataFolders{folderNum};
        temp = load([currentFolder '\ms.mat']);
        ms = temp.ms;
        if(isfield(ms,'tform'))
            display(['Finding segments in common field for ' currentFolder])
            segTemp1 = round(transformPointsForward(ms.tform,ms.segCentroid));
            ms.segInField = [];
            for segNum=1:ms.numSegments
                if (segTemp1(segNum,1) < 1 || segTemp1(segNum,2) < 1 || segTemp1(segNum,1) > size(overlapMask,2) || segTemp1(segNum,2) > size(overlapMask,1))
                    ms.segInField(segNum) = 0;
                else
                    ms.segInField(segNum) = overlapMask(segTemp1(segNum,2),segTemp1(segNum,1));
                end
            end
            save([currentFolder '\ms.mat'],'ms','-v7.3');
        end
    end
    figure(104)
    clf
    pcolor(overlapImage)
    shading flat
    colorbar
   
end


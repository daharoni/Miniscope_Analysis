function msBatchSegment(dirName)
%MSBATCHSEGMENT Summary of this function goes here
%   Detailed explanation goes here

    dataFolders = msBatchFindDataFolders(dirName,[]);
    for folderNum = 1:length(dataFolders)
        currentFolder = dataFolders{folderNum};
        temp = load([currentFolder '\ms.mat']);
        ms = temp.ms;
        
        % Do this stuff till I write a new msSegment
%         ms2 = ms;
%         ms2.meanFrame = ms2.meanFrame{1};
%         ms2.hShift = ms2.hShift(:,ms2.selectedAlignment);
%         ms2.wShift = ms2.wShift(:,ms2.selectedAlignment);
%         ms2.alignedHeight = ms2.alignedHeight(ms2.selectedAlignment);
%         ms2.alignedWidth = ms2.alignedWidth(ms2.selectedAlignment);
%         ms2.selectedAlignment = 1;
        % ------------------------------------------
        
        if (isfield(ms,'hShift'))
            display(['Segmenting ' currentFolder]);
            
%             ms = msAutoSegment(ms,30,[],[80 600], 30,.05,1.5); %old
%             alignment
            ms = msFindBrightSpots(ms,30,[],.03,0.02);
            save([currentFolder '\ms.mat'],'ms','-v7.3');
            ms = msAutoSegment2(ms,[],[60 700],5,.90);

%             ms.segments = ms2.segments;
%             ms.cellAreaLimits = ms2.cellAreaLimits;
%             ms.numSegments = ms2.numSegments;
%             ms.segementOutline = ms2.segementOutline;
            save([currentFolder '\ms.mat'],'ms','-v7.3');
        else
            display([currentFolder 'is missing alignment']);
        end
end


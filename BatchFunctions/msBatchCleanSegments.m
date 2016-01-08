function msBatchCleanSegments(dirName,corrThresh,distThresh,overlapThresh)
%MSBATCHCELANSEGMENTS Summary of this function goes here
%   Detailed explanation goes here

    dataFolders = msBatchFindDataFolders(dirName,[]);
    for folderNum = 1:length(dataFolders)
        currentFolder = dataFolders{folderNum};
        temp = load([currentFolder '\ms.mat']);
        ms = temp.ms;
        if(isfield(ms,'segDist'))
            display(['Cleaning segments for ' currentFolder])
            ms = msCleanSegments(ms,corrThresh,distThresh,overlapThresh);
            save([currentFolder '\ms.mat'],'ms','-v7.3');
        else
            display([currentFolder 'is missing segment relations']);
        end
    end
end


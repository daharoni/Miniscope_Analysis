function msBatchSegmentCentroids( dirName )
%MSBATCHSEGMENTCENTROIDS Summary of this function goes here
%   Detailed explanation goes here

    dataFolders = msBatchFindDataFolders(dirName,[]);
    for folderNum = 1:length(dataFolders)
        currentFolder = dataFolders{folderNum};
        temp = load([currentFolder '\ms.mat']);
        ms = temp.ms;
        if(isfield(ms,'segments'))
            display(['Finding segment centers for ' currentFolder]);
            ms = msSegmentCentroids(ms);
            save([currentFolder '\ms.mat'],'ms','-v7.3');
        else
            display([currentFolder ' is missing segments.']);
        end
        
    end

end


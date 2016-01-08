function msBatchExtractdFFTraces(dirName)
%MSBATCHEXTRACTDFFTRACES Summary of this function goes here
%   Detailed explanation goes here

    dataFolders = msBatchFindDataFolders(dirName,[]);
    for folderNum = 1:length(dataFolders)
        currentFolder = dataFolders{folderNum};
        temp = load([currentFolder '\ms.mat']);
        ms = temp.ms;
        if(isfield(ms,'segments'))
            display(['Extracting segments for ' currentFolder]);
            if ~isfield(ms,'time')
                ms.time = linspace(0,ms.numFrames/30*1000,ms.numFrames);
            end
            ms = msExtractdFFTraces(ms);
            ms = msCleandFFTraces(ms);
            ms = msExtractFiring(ms);
            save([currentFolder '\ms.mat'],'ms','-v7.3');
        else
            display([currentFolder ' is missing segments.']);
        end
    end
        
end


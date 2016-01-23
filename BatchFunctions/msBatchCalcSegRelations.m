function msBatchCalcSegRelations(dirName,calcCorr, calcDist, calcOverlap)
%MSBATCHSEGRELATIONS Summary of this function goes here
%   Detailed explanation goes here

    dataFolders = msBatchFindDataFolders(dirName,[]);
    parfor folderNum = 1:length(dataFolders)
        currentFolder = dataFolders{folderNum};
        temp = load([currentFolder '\ms.mat']);
        ms = temp.ms;
        if (isfield(ms,'segments'))
            display(['Calculating segment relations for' currentFolder]);
            ms = msCalcSegmentRelations(ms, calcCorr, calcDist, calcOverlap);
            parsave([currentFolder '\ms.mat'],ms);
        else
            display([currentFolder 'is missing segments']);
        end
    end
end


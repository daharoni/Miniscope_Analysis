function dataFolders = msBatchFindDataFolders(dirName, dataFolders)
%MSBATCHFINDDATAFOLDERS Summary of this function goes here
%   Detailed explanation goes here
    if isempty(dirName) 
        dirName = pwd;
    end
    if isempty(dataFolders)
        dataFolders = cell(0);
    end
    dirData = dir(dirName);
    dirIndex = [dirData.isdir];
    fileList = {dirData(~dirIndex).name};
    subDirs = {dirData(dirIndex).name};
    validIndex = ~ismember(subDirs,{'.','..'});
                    
    if(sum(validIndex) == 0)
       if (sum(ismember(fileList,'msCam1.avi')) >0)
        dataFolders{end+1} = dirName;
       end
        
    end
    
    for iDir = find(validIndex)                  
        nextDir = fullfile(dirName,subDirs{iDir});  
%         fileList = [fileList; msBatchSelectROIs(nextDir)];  
         dataFolders = msBatchFindDataFolders(nextDir, dataFolders);
    end

end


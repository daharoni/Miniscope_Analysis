function msBatchLinearSFR(dirName, speedThresh, binSize)
%MSBATCHLINEARSFR Summary of this function goes here
%   Detailed explanation goes here
    dataFolders = msBatchFindBehavFolders(dirName,[]);
    for folderNum = 1:length(dataFolders)
        currentFolder = dataFolders{folderNum};
        dirData = dir(currentFolder);
        dirIndex = [dirData.isdir];
        fileList = {dirData(~dirIndex).name};       
        if ((sum(ismember(fileList,'behav.mat')) == 1) && (sum(ismember(fileList,'ms.mat')) == 1))   
            temp = load([currentFolder '\behav.mat']);
            behav = temp.behav;
            temp = load([currentFolder '\ms.mat']);
            ms = temp.ms;
            
            ms = msLineatSFR(ms, behav, speedThresh, binSize);
            save([currentFolder '\ms.mat'],'ms','-v7.3');
        else
            display([currentFolder ' is missing mat file(s).']);
        end
    end

end


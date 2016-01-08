function msBatchGenerateBehav(dirName)
%MSBATCHGENERATEBEHAV Summary of this function goes here
%   Detailed explanation goes here
    dataFolders = msBatchFindBehavFolders(dirName,[]);
    figureNum = 0;
    for folderNum = 1:length(dataFolders)
        currentFolder = dataFolders{folderNum};
        dirData = dir(currentFolder);
        dirIndex = [dirData.isdir];
        fileList = {dirData(~dirIndex).name};
        figureNum = figureNum+1;

        
        if (sum(ismember(fileList,'behav.mat')) == 0)
           %Generate ms data structure 
           display(['Generating ms.mat and calculating good frames and correcting DAC for ' currentFolder]);
           behav = msGenerateVideoObj(currentFolder,'behavCam');   
            
           
           save([currentFolder '\behav.mat'],'behav','-v7.3')
        end   
    end
end


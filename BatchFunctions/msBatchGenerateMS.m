function msBatchGenerateMS(dirName)
%MSBATCHGENERATEMS Summary of this function goes here
%   Detailed explanation goes here
    dataFolders = msBatchFindDataFolders(dirName,[]);
    figureNum = 0;
    parfor folderNum = 1:length(dataFolders)
        currentFolder = dataFolders{folderNum};
        dirData = dir(currentFolder);
        dirIndex = [dirData.isdir];
        fileList = {dirData(~dirIndex).name};
%        figureNum = figureNum+1;
%        figure(figureNum)
        
        if (sum(ismember(fileList,'ms.mat')) == 0)
           %Generate ms data structure 
           display(['Generating ms.mat and calculating good frames and correcting DAC for ' currentFolder]);
           ms = msGenerateVideoObj(currentFolder,'msCam');         
%            ms = msGoodFrames(ms,30);
           ms = msColumnCorrection(ms,5);
           ms = msFluorFrameProps(ms);
%            title(currentFolder)
           
%           save([currentFolder '\ms.mat'],'ms','-v7.3')
			parsave([currentFolder '\ms.mat'],ms)
        end   
    end
end


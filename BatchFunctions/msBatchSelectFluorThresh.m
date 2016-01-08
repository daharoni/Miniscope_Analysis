function  msBatchSelectFluorThresh(dirName)
%MSBATCHSELECTFLUORTHRESH Summary of this function goes here
%   Detailed explanation goes here

 
    dataFolders = msBatchFindDataFolders(dirName,[]);
    for folderNum = 1:length(dataFolders)
        currentFolder = dataFolders{folderNum};
        dirData = dir(currentFolder);
        dirIndex = [dirData.isdir];
        fileList = {dirData(~dirIndex).name};       
        if (sum(ismember(fileList,'ms.mat')) == 1)
            temp = load([currentFolder '\ms.mat']);
            ms = temp.ms;
            if (isfield(ms,'meanFluorescence')) %does not have alignment already done
                display(['Working on ' currentFolder]);
                ms = msSelectFluorThresh(ms);       
                save([currentFolder '\ms.mat'],'ms','-v7.3');
            else
                display([currnetFolder ' is missing FluorFrameProps.']);
            end
        else
            display([currentFolder ' is missing ms.mat.']);
        end
end


function msBatchSelectROIs( dirName )
%MSBATCHSELECTROIS Summary of this function goes here

   dataFolders = msBatchFindDataFolders(dirName,[]);
   for folderNum = 1:length(dataFolders)
        currentFolder = dataFolders{folderNum};
        dirData = dir(currentFolder);
        dirIndex = [dirData.isdir];
        fileList = {dirData(~dirIndex).name};       
        if (sum(ismember(fileList,'ms.mat')) == 1)     
            temp = load([currentFolder '\ms.mat']);
            ms = temp.ms;
            figure(100)
            clf 
            title([currentFolder ' | ROI']);
            hold on
            ms = msSelectROIs(ms);
            save([currentFolder '\ms.mat'],'ms','-v7.3')
        else
            display([currentFolder ' is missing ms.mat.']);
        end
   end
end


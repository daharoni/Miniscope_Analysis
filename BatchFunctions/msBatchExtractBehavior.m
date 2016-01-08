function  msBatchExtractBehavior( dirName, trackLength)
%MSBATCHEXTRACTBEHAVIOR Summary of this function goes here
%   Detailed explanation goes here
   dataFolders = msBatchFindBehavFolders(dirName,[]);
   for folderNum = 1:length(dataFolders)
        currentFolder = dataFolders{folderNum};
        dirData = dir(currentFolder);
        dirIndex = [dirData.isdir];
        fileList = {dirData(~dirIndex).name};       
        if (sum(ismember(fileList,'behav.mat')) == 1)     
            temp = load([currentFolder '\behav.mat']);
            behav = temp.behav;
            
            behav = msExtractBehavoir(behav, trackLength);   
           
            save([currentFolder '\behav.mat'],'behav','-v7.3')
        end
   end

end



% combine data for the control and advanced meditators:
% concatenate data for the subjects in a big matrix
tic
biPolarFlag = 0; 
removeIndividualUniqueBadTrials = 0; 
removeVisualInspectedElecs =0;

loadFolderpath = getFolderName(biPolarFlag,removeIndividualUniqueBadTrials,removeVisualInspectedElecs);
% load(loadFilepath);

% folderSourceSring = 'D:\Projects\MeditationProjects\MeditationProject2\data\savedData\subjectWiseDataMaster\subjectWiseUnipolarBadTrialIndElec';
folderSourceSring  = loadFolderpath;
subjectNameGrouped = getOnlyMatchedSubjects;

if biPolarFlag==1
    dataString = 'BipolarPowerDataAllElecs_' ;
else
    dataString = 'PowerDataAllElecs_' ;
end
    
% dataString = 'PowerDataAllElecs_';
% varStringToCat = 'powerValBL';

powerValStCombinedAdvanced = [];

% 12 different protocols
% 251 power values
% for 64 electrodes

for groupIndex=1:size(subjectNameGrouped,2)    
    for subIndex=1:length(subjectNameGrouped)
        subjectName = subjectNameGrouped{subIndex,groupIndex};
       
        fileNameToLoad = fullfile(folderSourceSring,[dataString subjectName,'.mat']);
        load(fileNameToLoad);
        disp(subjectName);
        
        switch groupIndex
            case 1
                powerValStCombinedAdvanced(subIndex,:,:,:) = powerValST;

                checkData = squeeze(powerValST(2,:,:));
                powerValBlCombinedAdvanced(subIndex,:,:,:) = powerValBL;
            case 2
                powerValStCombinedControl(subIndex,:,:,:) = powerValST;
                powerValBlCombinedControl(subIndex,:,:,:) = powerValBL;
        end        
    end    
end

if biPolarFlag==1
    saveFileString = 'BiPolarGroupedPowerDataPulledAcrossSubjects.mat';
else
    saveFileString = 'UnipolarGroupedPowerDataPulledAcrossSubjects.mat';
end

save(fullfile(folderSourceSring,saveFileString),'powerValStCombinedAdvanced','powerValBlCombinedAdvanced','powerValStCombinedControl','powerValBlCombinedControl');

%% disp run Log: 
elapsedTime = toc;
disp('All the data saved successfully and');
disp(['It took'  string(elapsedTime) ' to run the function']);


%% Associated functions

function loadFilepath= getFolderName(biPolarFlag,removeIndividualUniqueBadTrials,removeVisualInspectedElecs)
sdParams.folderSourceString = 'D:\Projects\MeditationProjects\MeditationProject2';

saveDataDeafultStr ='subjectWise';

if biPolarFlag
    saveDataDeafultStr = [saveDataDeafultStr 'Bipolar'];
else
    saveDataDeafultStr = [saveDataDeafultStr 'Unipolar'];
end

if removeIndividualUniqueBadTrials
    saveFolderName = [saveDataDeafultStr 'BadTrialIndElec'];
else
    saveFolderName = [saveDataDeafultStr 'BadTrialComElec'];
end

if removeVisualInspectedElecs
    saveFolderName = [saveFolderName 'VisualInspRemoved'];
end

loadFilepath = fullfile(sdParams.folderSourceString,'data','savedData','subjectWiseDataMaster',saveFolderName);
end

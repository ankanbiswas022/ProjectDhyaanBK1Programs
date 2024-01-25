% run script for calling the 'saveIndividualSubjectDataMeditation' function
clear; close all
tic
removeProblamaticIndices=1;
% get the demographic information
[allSubjectNameList,expDateList] = getDemographicDetails('BK1');
% get good subjectList
[goodSubjectList, meditatorList, controlList] = getGoodSubjectsBK1;
% get The indices
allIndices = 1:length(goodSubjectList);
if removeProblamaticIndices
    problamaticIndices = find(ismember(goodSubjectList,[{'053DR'}])); % this index need to be extracted separately
else
    problamaticIndices = [];
end
saveTheseIndices  = setdiff(allIndices,problamaticIndices);

% saveDataFlags
sdParams.badTrialNameStr = '_wo_v8';
sdParams.badElectrodeRejectionFlag = 2; % 1: saves all the electrodes, 2: rejects individual protocolwise 3: rejects common across all protocols
sdParams.logTransformFlag = 0;    % saves log Transformed PSD if 'on'
sdParams.saveDataFlag = 1;        % if 1, saves the data
sdParams.eegElectrodeList = 1:64; % eeg electrodeList
sdParams.freqRange = [0 200];     % FreqVals to save the data
sdParams.biPolarFlag = 0;         % unipolar/bipolar
sdParams.removeIndividualUniqueBadTrials = 0;
sdParams.removeDeclaredBadElecs = 1;
sdParams.saveDataFlagProtocolwise = 1;

% save file location
sdParams.folderSourceString = 'D:\Projects\ProjectDhyaan\BK1';
saveDataDeafultStr ='subjectWise';

if sdParams.biPolarFlag
    saveDataDeafultStr = [saveDataDeafultStr 'Bipolar'];
    saveFileNameDeafultStr = ['_bipolar_stRange_250_1250' sdParams.badTrialNameStr '.mat'] ;
else
    saveDataDeafultStr = [saveDataDeafultStr 'Unipolar'];
    saveFileNameDeafultStr = ['_unipolar_stRange_250_1250' sdParams.badTrialNameStr '.mat'] ;
end

if sdParams.removeIndividualUniqueBadTrials
    saveFolderName = [saveDataDeafultStr 'BadTrialIndElec'];
else %default foldername
    saveFolderName = [saveDataDeafultStr 'BadTrialComElec'];
end

if sdParams.removeDeclaredBadElecs
    saveFolderName = [saveFolderName 'DeclaredBadElecRemoved'];
else
    saveFolderName = [saveFolderName 'DeclareedBadElecRemoved'];
end

sdParams.saveDataFolder = fullfile(sdParams.folderSourceString,'data','savedData',saveFolderName);

% if the saveData folder does not exist make it:
if ~isfolder(sdParams.saveDataFolder)
    disp('Making the saveData folder');
    mkdir(sdParams.saveDataFolder);
end

%% display the parameters and check for it:
disp(sdParams);
reply = input('Have you checked all the flags? Y/N [Y]: ', 's');
if isempty(reply)
    reply = 'N';
end

if reply=='Y'
    sdParams.checked = 1;
    for i=70%:length(saveTheseIndices)
        subjectName = goodSubjectList{saveTheseIndices(i)};
        disp(['Saving Data for the subject ' subjectName]);
        expDate = expDateList{strcmp(subjectName,allSubjectNameList)};
        if sdParams.biPolarFlag==1
            fileName = ['BipolarPowerDataAllElecs_' subjectName '.mat'];
        else
            fileName = ['PowerDataAllElecs_' subjectName '.mat'];
        end
        sdParams.saveFileName = fullfile(sdParams.saveDataFolder,fileName);
        sdParams.saveFileNameProtocolWise = [subjectName saveFileNameDeafultStr];
        % if ~exist(sdParams.saveFileName,'file')
        saveIndividualSubjectDataMeditation(subjectName,expDate,sdParams);
        % end

    end
    sdParams.elapsedTime = toc;
    disp('All the data saved successfully');
    disp(['It took'  string(sdParams.elapsedTime) ' to run the function']);
    save(sdParams.saveFileName,'sdParams',"-append");
else
    disp("Please check the input parameters carefully before proceeding!");
end

% Issues for the following subjects:-
% i = 12; 053DR:EO1 is not saved (fixed)
% i = 70; 099SP: (M2 data is for 358 trials) (fixed)

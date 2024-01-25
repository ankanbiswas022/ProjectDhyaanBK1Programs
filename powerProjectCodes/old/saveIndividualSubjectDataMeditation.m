function saveIndividualSubjectDataMeditation(subjectName,expDate,sdParams)
% This function saves the power data for the given subject
%
% Input:
%
% Required: 'subjectName' and 'exprimentDate'
%            loads the extracted data for the given subject
% Optional: Assumes default value s if not provided
%             'folderSourceString','allElectrodeList','badTrialNameStr','badElectrodeRejectionFlag',
%             'logTransformFlag','freqRange','saveDataFlag' and
%             'saveFileName'
%
% Protocols Details:
%   15 minute M1 and M2 protocols were segmented into three 5 minute sub-segments consisting with 120
%   trials each sub-segments sharing the same badElectrodes and bad-trials
%
% Extra notes for segmenting M1/M2 protocols:
%        Segmentation of M1/M2 protocol could be done in two ways, one is by
%        looping through the original 8 protocols and having additional three
%        loops for three different sub-segments.
%        Or, by incorporating the sub-segments in the original protocols
%        list and changing the trial index accordingly. Importantly, while loading,
%        we need to load the original data file for M1/M2.
%        Here, we are taking the second approach.
%
% Other Assignments:
%   NaN values are assigned to the power values of the bad electrodes
%
% Output (saved) data format
%   12*251*64 (protocol x frequencies x electrodes) for individual subject
%
% Uses two local sub-functions
%   'getAllBadElecs' combines all types of bad electrodes
%   'getData' gets the power data
%-----------------------------------------------------------------------------------------
% Updates on 28/03/23:
% Remove the remove the bad trials (from individual electrodes)
% adding flag remove bad trils from individual electrodes!

% Updates 11/09/23:
% First optimize the code to unify the loop

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Getting input paramters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
folderSourceString              = sdParams.folderSourceString;
saveDataFolder                  = sdParams.saveDataFolder;
saveFileName                    = sdParams.saveFileName;

badTrialNameStr                 = sdParams.badTrialNameStr;
badElectrodeRejectionFlag       = sdParams.badElectrodeRejectionFlag ; % 1: saves all the electrodes, 2: rejects individual protocolwise 3: rejects common across all protocols
logTransformFlag                = sdParams.logTransformFlag; % saves log Transformed PSD if 'on'
saveDataFlag                    = sdParams.saveDataFlag; % if 1, saves the data
% eegElectrodeList              = sdParams.eegElectrodeList;
freqRange                       = sdParams.freqRange;
biPolarFlag                     = sdParams.biPolarFlag;
removeDeclaredBadElecs          = sdParams.removeDeclaredBadElecs;
removeIndividualUniqueBadTrials = sdParams.removeIndividualUniqueBadTrials;
saveDataFlagProtocolwise        = sdParams.saveDataFlagProtocolwise;
saveFileNameProtocolWise        = sdParams.saveFileNameProtocolWise;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Check Input %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin < 2; error('Needs Subject Name and experimetent Date'); end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Default variables %%%%%%%%%%%%%%%%%%%%%%%%%%
if ~exist('folderSourceString','var');              folderSourceString=[];              end
if ~exist('allElectrodeList','var');                allElectrodeList = 1:64;            end
if ~exist('badTrialNameStr','var');                 badTrialNameStr='_v5';              end
if ~exist('badElectrodeRejectionFlag','var');       badElectrodeRejectionFlag=2;        end
if ~exist('logTransformFlag','var');                logTransformFlag = 0;               end
if ~exist('freqRange','var');                       freqRange = [0 250];                end
if ~exist('saveDataFlag','var');                    saveDataFlag = 0;                   end
if ~exist('saveFileName','var');                    saveFileName=[];                    end
if ~exist('biPolarFlag','var');                     biPolarFlag=0;                      end
if ~exist('removeIndividualUniqueBadTrials','var'); removeIndividualUniqueBadTrials=0;  end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization %%%%%%%%%%%%%%%%%%%%%%%%%%%%
gridType = 'EEG';

% We have total 8 protocols. M1 and M2 is segmented to create M1a,M1b,M1c
% and M2a,M2b,M2c respectively.
segmentNameList = [{'EO1'} {'EC1'} {'G1'} {'M1a'} {'M1b'} {'M1c'} {'G2'} {'EO2'} {'EC2'} {'M2a'} {'M2b'} {'M2c'}];
numSegments = length(segmentNameList);

%% -----------------------------------------------Getting the bad eectrodes across trials -------------------------------------------------------------
badTrialsList = cell(1,numSegments);
badElecList = cell(1,numSegments);
badElectrodes.badImpedanceElecs = [];
badElectrodes.noisyElecs = [];
badElectrodes.flatPSDElecs = [];

if removeDeclaredBadElecs
    % declared bad elecs remains same across the protocols
    declaredBadElecs  =  getDeclaredBadElecs(0.35)';
else
    declaredBadElecs = [];
end


for s=1:numSegments
    segmentName=segmentNameList{s};

    % for sub-segments M1a,M1b,M1c loads the same badTrial file as M1/M2
    if contains(segmentName,'M1')
        segmentName='M1';
    elseif contains(segmentName,'M2')
        segmentName='M2';
    end
    badFileName = fullfile(folderSourceString,'data',subjectName,gridType,expDate,segmentName,'segmentedData',['badTrials' badTrialNameStr '.mat']);
    if exist(badFileName,'file')
        x = load(badFileName);
        % temp saving bad trials and bad elecs per protocol
        allBadTrialsList{s} = x.allBadTrials; %1.1c: getting badtrials unique to the electrode
        badTrialsList{s} = x.badTrials;
        x.badElecs.declaredBadElecs = declaredBadElecs;
        badElecList{s}   = x.badElecs;

        badElectrodes.badImpedanceElecs = cat(1,badElectrodes.badImpedanceElecs,x.badElecs.badImpedanceElecs);
        badElectrodes.noisyElecs = cat(1,badElectrodes.noisyElecs,x.badElecs.noisyElecs);
        badElectrodes.flatPSDElecs = cat(1,badElectrodes.flatPSDElecs,x.badElecs.flatPSDElecs);
    else
        badTrialsList{s} = [];
        badElecList{s}   = [];
    end
end

% common bad elecs across all the protocols
badElectrodes.badImpedanceElecs = unique(badElectrodes.badImpedanceElecs);
badElectrodes.noisyElecs = unique(badElectrodes.noisyElecs);
badElectrodes.flatPSDElecs = unique(badElectrodes.flatPSDElecs);
badElectrodes.declaredBadElecs = declaredBadElecs;


%% -----------------------------------------------Getting the data------------------------------------------------------------------------------------
% get data across protocols:
timeRangeStrings = {'BL','ST'};
numTimeRange = length(timeRangeStrings);

timeRangeS = {[-1 0],[0.25 1.25]}; % baseLine and stimulus timePeriods
trialIndexesForSubSegments = {(1:120),(121:240),(241:360)};

meanPSDVals = cell(1,numSegments);
tfPower = cell(1,numSegments);
freqVals = cell(1,numSegments);
numGoodElectrodesList = zeros(1,numSegments);
numGoodTrialsAllProtocols = [];
erpBL = [];
erpST = [];
erpCombined = [];

segmentIndex=1; % default segment
for p=1:numSegments
    for t=1:numTimeRange
        timeRange = timeRangeS{t};
        segmentName = segmentNameList{p};
        trialIndexes = trialIndexesForSubSegments{segmentIndex};

        % for sub-segments M1a,M1b,M1c, we use the same protocol, M1/M2
        if contains(segmentName,'M')
            contains(segmentName,'M1')
            if contains(segmentName,'M1')
                segmentName = 'M1';
            elseif contains(segmentName,'M2')
                segmentName = 'M2';
            end
        end

        if badElectrodeRejectionFlag==1
            electrodeList = allElectrodeList;
        elseif badElectrodeRejectionFlag==2
            electrodeList = setdiff(allElectrodeList,getAllBadElecs(badElecList{p}));
        elseif badElectrodeRejectionFlag==3
            electrodeList = setdiff(allElectrodeList,getAllBadElecs(badElectrodes));
        end

        numGoodElectrodesList(p) = length(electrodeList);
        badElecIndexThisProtocol = getAllBadElecs(badElecList{p});

        % uses local sub-function 'getData' for getting the power data
        if ~isempty(electrodeList)
            disp(['Extracting data of ''' segmentNameList{p} ''' segment, for the ''' timeRangeStrings{t} ''' period']);
            disp(['for trials- ' num2str(trialIndexes(1)) ':' num2str(trialIndexes(end))]);

            % getting the mean data across trials
            [meanPSDVals{p},freqVals,numGoodTrials,timeVals,tfPower,timeValsTF{t},freqValsTF,erp{p}] = getData(subjectName,expDate,segmentName,folderSourceString,gridType,allElectrodeList,freqRange,timeRange,trialIndexes,logTransformFlag,biPolarFlag,removeIndividualUniqueBadTrials,allBadTrialsList{p},badTrialsList{p});

            % assigning the bad electrodes as NaN
            meanPSDVals{p}(badElecIndexThisProtocol,:) = NaN;
            % saving Tfs and erp
            tfPower(badElecIndexThisProtocol,:,:) = NaN;
            erp{p}(badElecIndexThisProtocol,:)    = NaN;
            % saving bad Elecs and trials
            numGoodTrialsAllProtocols(p,:) = numGoodTrials;
            numGoodElecThisProtocol        = length(setdiff(1:64,badElecIndexThisProtocol));
            numGoodElecsAllProtocols(p,:)  = numGoodElecThisProtocol;
            badElecListAllProtocols{p}     = badElecIndexThisProtocol;
        end

        % stores the power data in different variables for the 'BL' and 'ST' period
        if t==1
            blPowerVsFreqTopo = meanPSDVals{p};
            powerValBL(p,:,:) = blPowerVsFreqTopo;
            tfPowerBL         = tfPower;
            timeValsTFBL = timeValsTF{t};
            erpTopoBl = erp{p};
            erpBL(p,:,:) = erpTopoBl;
        else
            stPowerVsFreqTopo = meanPSDVals{p};
            powerValST(p,:,:) = stPowerVsFreqTopo;
            tfPowerST         = tfPower;
            timeValsTFST = timeValsTF{t};
            erpStTopoSt = erp{p};
            erpST(p,:,:) = erpStTopoSt;
            % Avg across both the condition: ST and BL
            powerValCombinedTopo    = (blPowerVsFreqTopo+stPowerVsFreqTopo)/2;
            powerValCombined(p,:,:) = powerValCombinedTopo;
            tfPowerCombined         = (tfPowerBL+tfPowerST)/2;
            erpCombinedTopo = (erpTopoBl+erpStTopoSt)/2;
            erpCombined(p,:,:) = erpCombinedTopo;
        end
    end

    % meanPower
    % conditions for M segments
    % changing 'medSegmentIndex' to select the particular trial-block
    if contains(segmentName,'M') && segmentIndex<5
        segmentIndex = segmentIndex+1;
        if segmentIndex == 4 % switch back to the default value
            segmentIndex = 1;
        end
    end

    if saveDataFlagProtocolwise % save data for the current subject
        disp(['Saving the Power data for ' subjectName ' for ' segmentNameList{p}]);
        dirName = fullfile(saveDataFolder,segmentNameList{p});
        if ~exist(dirName, 'dir')
            mkdir(dirName);
        end
        fileNameToSave = fullfile(saveDataFolder,segmentNameList{p},saveFileNameProtocolWise);
        save(fileNameToSave,'blPowerVsFreqTopo','stPowerVsFreqTopo','freqVals',"timeVals","numGoodTrials","tfPowerBL","tfPowerST","numGoodElecThisProtocol","powerValCombinedTopo","tfPowerCombined","erpTopoBl","erpStTopoSt","erpCombinedTopo","timeValsTFBL","timeValsTFST","segmentNameList");
    end
end

if saveDataFlag % save data for the current subject
    disp(['Saving the Power data for ' subjectName]);
    save(saveFileName,'powerValBL','powerValST','powerValCombined','freqVals',"timeVals",'numGoodTrialsAllProtocols',"numGoodElecsAllProtocols","badElecListAllProtocols","erpBL","erpST","erpCombined","segmentNameList");
end
end % the main function end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%% Sub-functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function allBadElecs = getAllBadElecs(badElectrodes)
if ~isempty(badElectrodes.declaredBadElecs)
    allBadElecs = union([badElectrodes.badImpedanceElecs; badElectrodes.noisyElecs; badElectrodes.flatPSDElecs],badElectrodes.declaredBadElecs);
else
    allBadElecs = [badElectrodes.badImpedanceElecs; badElectrodes.noisyElecs; badElectrodes.flatPSDElecs];
end
end

function [meanPSDVals,freqVals,numGoodTrials,timeVals,meanTfPower,timeValsTF,freqValsTF,erp] = getData(subjectName,expDate,protocolName,folderSourceString,gridType,electrodeList,freqRange,timeRange,trialIndexS,logTransformFlag,biPolarFlag,removeIndividualUniqueBadTrials,allBadTrialsListElecWise,badTrialsList)
% get the mean PSD values for each individual subjects

if biPolarFlag==1
    capType=  'actiCap64_UOL';
    bipolarLocs = load(fullfile("D:\Programs\ProgramsMAP\Montages\Layouts\"+capType+"\bipChInfo"+capType));
    numElectrodes = length(bipolarLocs.bipolarLocs);
    electrodeList = 1:numElectrodes;
else
    numElectrodes = length(electrodeList);
end

tapers = [1 1];

folderExtract = fullfile(folderSourceString,'data',subjectName,gridType,expDate,protocolName,'extractedData');
folderSegment = fullfile(folderSourceString,'data',subjectName,gridType,expDate,protocolName,'segmentedData');

if ~exist(folderExtract,'file')
    disp([folderExtract ' does not exist']);
    psd = []; freqVals=[];
else
    t = load(fullfile(folderSegment,'LFP','lfpInfo.mat'));
    timeVals = t.timeVals;
    Fs = round(1/(timeVals(2)-timeVals(1)));
    goodTimePos = find(timeVals>=timeRange(1),1) + (1:round(Fs*diff(timeRange)));

    % Sets up multitaper
    params.tapers   = tapers;
    params.pad      = -1;
    params.Fs       = Fs;
    params.fpass    = freqRange;
    params.trialave = 0;

    % parameters for TF
    winSize         = 0.25;
    winStep         = 0.025; % 4Hz resolution
    movingwin       = [winSize winStep];

    for i=1:numElectrodes
        if biPolarFlag==1
            analogElecs = bipolarLocs.bipolarLocs(electrodeList(i),:);
            % load the .mat lfp file for the two electrode
            % rejection can happen at this level itself,
            e1 = load(fullfile(folderSegment,'LFP',['elec' num2str(analogElecs(1)) '.mat']));
            e2 = load(fullfile(folderSegment,'LFP',['elec' num2str(analogElecs(2)) '.mat']));

            % substract and put this in the e
            e.analogData = e1.analogData-e2.analogData; %updated e for the bipolar
        else
            e = load(fullfile(folderSegment,'LFP',['elec' num2str(electrodeList(i)) '.mat']));
        end
        if contains(protocolName,'M') && size(e.analogData,1)<max(trialIndexS)
            % additional constarain when trialNum is less than the
            trialIndexS = trialIndexS(1):size(e.analogData,1);
        end
        [psdTMP(i,:,:),freqVals] = mtspectrumc(e.analogData(trialIndexS,goodTimePos)',params); %#ok<AGROW>
        [tfPowerTMP(i,:,:,:),timeValsTF0,freqValsTF] = mtspecgramc(e.analogData(:,goodTimePos)',movingwin,params); % for all the trials
        timeValsTF = timeValsTF0 + timeRange(1);
        erpTMP(i,:,:) = e.analogData(trialIndexS,goodTimePos);
    end

    if logTransformFlag
        psd     = log10(psdTMP);
        tfPower = log10(tfPowerTMP);
    else
        psd     = psdTMP; % passing raw PSD to the main function
        tfPower = tfPowerTMP;
    end

    % removes bad trials, assigns Nans to the bad electrodes and
    % transforms the data to have the following format: protocol x frequencies x electrodes
    if removeIndividualUniqueBadTrials
        if biPolarFlag
            badTrialsFirstElec = allBadTrialsListElecWise{analogElecs(1)};
            badTrialsSecondElec = allBadTrialsListElecWise{analogElecs(2)};
            commonBadTrials = union(badTrialsFirstElec,badTrialsSecondElec);
        else
            commonBadTrials = allBadTrialsListElecWise{i};
        end
        meanPSDVals   = mean(psd(:,:,setdiff(1:size(psd,3),commonBadTrials)),3); % dont remove the bad trials as it has already been removed.
        numGoodTrials = length(setdiff(1:size(psd,3),badTrialsList));
        meanTfPower   = mean(tfPower(:,:,:,setdiff(1:size(tfPower,4),commonBadTrials)),4);
    else
        meanPSDVals   = mean(psd(:,:,setdiff(1:size(psd,3),badTrialsList)),3);
        numGoodTrials = length(setdiff(1:size(psd,3),badTrialsList));
        meanTfPower   = mean(tfPower(:,:,setdiff(1:size(tfPower,4),badTrialsList)),4);
        erpTMP        = squeeze(mean(erpTMP(:,setdiff(1:size(erpTMP,2),badTrialsList),:),2));
        meanErp       = mean(erpTMP,2);
        erp           = erpTMP-meanErp;
    end
end
end
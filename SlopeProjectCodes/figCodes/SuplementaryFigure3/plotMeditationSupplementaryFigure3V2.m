% optimized code 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Fixed choices %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clf
clear
comparisonStr = 'paired';

if strcmp(comparisonStr,'paired')
    pairedSubjectNameList = getPairedSubjectsBK1;
    subjectNameLists{1} = pairedSubjectNameList(:,1);
    subjectNameLists{2} = pairedSubjectNameList(:,2);
    pairedDataFlag      = 1;
else
    [~, meditatorList, controlList] = getGoodSubjectsBK1;
    subjectNameLists{1} = meditatorList;
    subjectNameLists{2} = controlList;
    pairedDataFlag      = 0;
end

badEyeCondition = 'ep';
badTrialVersion = 'v8';
badElectrodeRejectionFlag = 1;

stRange = [0.25 1.25]; % hard coded for now

axisRangeList{1} = [0 100];
axisRangeList{2} = [-2.5 2.5];
axisRangeList{3} = [-1.5 1.5];

cutoffList = [3 30]; useMedianFlag = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Get Data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot the relationship between
% 1. Meditation-induced gamma (M1-EO1) vs stimulus-induced gamma(G1_ST-G1_BL)
% 2. Meditation-induced gamma (M2-G2(bl)) vs stimulus-induced gamma(M2(st)-M2(bl))

protocolNames  = [{'M1'}       {'M1'}         {'M2'}    {'G1'}     {'M2'}   ];
refChoices     = [{'none'}     {'EO1'}        {'G2'}    {'G1'}     {'M2'}   ] ;
analysisChoice = [{'combined'},{'combined'},  {'bl'},   {'st'},    {'st'}   ];
freqRangeList  = {[30 80],      [30 80]       [30 80]   [24 34]    [24 34]  };
groupPosList   = [   2             2             2         1           1     ];
compareIndexesList   = {[2 4] [3 5]};

numProtocol = length(protocolNames);
for i=1:numProtocol
    groupPos               = groupPosList(i);
    freqRangeListTmp{1}    = freqRangeList{i};

    [~,powerDataToReturn,goodSubjectNameListsToReturn] = displayPowerDataAllSubjects(subjectNameLists,protocolNames{i},analysisChoice{i},refChoices{i},badEyeCondition,badTrialVersion,badElectrodeRejectionFlag,stRange,freqRangeListTmp,axisRangeList,cutoffList,useMedianFlag,[],pairedDataFlag,0);
    logPowerData{i}     = powerDataToReturn{groupPos,1};
    goodSubjectNames{i} = goodSubjectNameListsToReturn(groupPos,:);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Create Figures %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get figure handles
hf0=getPlotHandles(1,2,[0.1 0.6 0.8 0.3],0.05,0.05);
hf1=getPlotHandles(2,2,[0.1 0.1 0.8 0.4],0.05,0.05);


%%%%%%%%%%%%%%%%%%%%%%%%%%% Correlations %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
colorNames(1,:)  = [0.8 0 0.8];
colorNames(2,:)  = [0.25 0.41 0.88];

for i=1:length(compareIndexesList)
    compareIndexes = compareIndexesList{i};
    for pos=1:2 % 1 for meditators, 2 for controls
        data1 = logPowerData{compareIndexes(1)}{pos};
        subjects1 = goodSubjectNames{compareIndexes(1)}{pos};
        data2 = logPowerData{compareIndexes(2)}{pos};
        subjects2 = goodSubjectNames{compareIndexes(2)}{pos};
        getCorrelation(data1,subjects1,data2,subjects2,hf0(1,i),colorNames(pos,:));
        hold(hf0(1,i),'on');
    end
end
xlabel(hf0(1,1),'Meditation-induced gamma (M1-EO1)');
ylabel(hf0(1,1),'Stimulus-induced gamma (G1(St-Bl))');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% vs Hours of Meditation

% Meditation Induced gamma (M1-EO1) vs #hours of Meditation (2a)
practiceHoursData = load('BK1PracticeHours.mat');
ppos=2; %1- M1 raw % 2- M1-EO1
data1     = cell2mat(practiceHoursData.practiceHours(2:end,2));
data1     = data1/max(data1); % normalized Meditation data
subjects1 = practiceHoursData.practiceHours(2:end,1);
data2     = logPowerData{ppos}{1};
subjects2 = goodSubjectNames{ppos}{1};
getCorrelation(data1,subjects1,data2,subjects2,hf1(1,1),colorNames(1,:));
xlabel(hf1(1,1),'Hours of Meditation (Hrs)');
ylabel(hf1(1,1),'Meditation Induced Gamma (dB)');


% Stimulus Induced gamma (M1-EO1) vs #hours of Meditation (2a)
practiceHoursData = load('BK1PracticeHours.mat');
ppos=3; %1- M1 raw; 2- M1-EO1; 3- G1(st)-G1(bl)
data1     = cell2mat(practiceHoursData.practiceHours(2:end,2));
data1     = data1/max(data1); % normalized Meditation data
subjects1 = practiceHoursData.practiceHours(2:end,1);
data2     = logPowerData{ppos}{1};
subjects2 = goodSubjectNames{ppos}{1};
getCorrelation(data1,subjects1,data2,subjects2,hf1(1,2),colorNames(1,:));
xlabel(hf1(1,2),'Hours of Meditation (Hrs)');
ylabel(hf1(1,2),'Stimulus Induced Gamma (dB)');

% Vs Age

% Meditation Induced gamma (M1-EO1) vs Age
practiceHoursData = load('BK1PracticeHours.mat');
ppos=2; %1- M1 raw % 2- M1-EO1
[subjects1,~,~,data1] = getDemographicDetails('BK1');
data2     = logPowerData{ppos}{1};
subjects2 = goodSubjectNames{ppos}{1};
getCorrelation(data1,subjects1,data2,subjects2,hf1(2,1),colorNames(1,:));
xlabel(hf1(2,1),'Age (Yrs)');
ylabel(hf1(2,1),'Meditation Induced Gamma (dB)');

% Meditation Induced gamma (M1-EO1) vs Age
practiceHoursData = load('BK1PracticeHours.mat');
ppos=3; %1- M1 raw; 2- M1-EO1; 3- G1(st)-G1(bl)
[subjects1,~,~,data1] = getDemographicDetails('BK1');
data2     = logPowerData{ppos}{1};
subjects2 = goodSubjectNames{ppos}{1};
getCorrelation(data1,subjects1,data2,subjects2,hf1(2,2),colorNames(1,:));
xlabel(hf1(2,2),'Age (Yrs)');
ylabel(hf1(2,2),'Stimulus Induced Gamma (dB)');


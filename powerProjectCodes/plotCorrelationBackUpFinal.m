% Plots Supplementary Figure 3 for the BK1 Project
% Shows Correlations for stimulus-induced and meditation-induced gamma with many different measures

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Fixed choices %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clf
clear
comparisonStr = 'paired';
fontSize = 16;

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
analysisChoice = [{'combined'} {'combined'}   {'bl'}    {'st'}     {'st'}   ];
freqRangeList  = {[30 80],      [30 80]       [30 80]   [24 34]    [24 34]  };
groupPosList   = [   1             1             1         1          1     ];

compareIndexesList   = {[2 4] [3 5]};

numProtocol      = length(protocolNames);
logPowerData     = cell(1,numProtocol);
goodSubjectNames = cell(1,numProtocol);
for i=1:numProtocol
    groupPos               = groupPosList(i);
    freqRangeListTmp{1}    = freqRangeList{i};

    [~,powerDataToReturn,goodSubjectNameListsToReturn] = displayPowerDataAllSubjects(subjectNameLists,protocolNames{i},analysisChoice{i},refChoices{i},badEyeCondition,badTrialVersion,badElectrodeRejectionFlag,stRange,freqRangeListTmp,axisRangeList,cutoffList,useMedianFlag,[],pairedDataFlag,0);
    logPowerData{1,i}     = powerDataToReturn{groupPos,1};
    goodSubjectNames{1,i} = goodSubjectNameListsToReturn(groupPos,:);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Create Figures %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get figure handles
hf0=getPlotHandles(1,2,[0.1 0.1 0.8 0.8],0.06,0.05);
% hf1=getPlotHandles(2,2,[0.1 0.1 0.8 0.4],0.05,0.08);

colorNames(1,:)  = [0.8 0 0.8];
colorNames(2,:)  = [0.25 0.41 0.88];

%% %%%%%%%%%%%%%%%%%%%%%%%%%%% Stimulus Induced vs Meditation-Induced %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i=1:length(compareIndexesList)
    compareIndexes = compareIndexesList{i};
    r=[];p=[];N=[]; xData=[]; yData=[];
    for pPos=1:2 % 1 for meditators, 2 for controls
        data1 = logPowerData{compareIndexes(1)}{pPos};
        subjects1 = goodSubjectNames{compareIndexes(1)}{pPos};
        data2 = logPowerData{compareIndexes(2)}{pPos};
        subjects2 = goodSubjectNames{compareIndexes(2)}{pPos};
        [r(pPos),p(pPos),N(pPos)]=getCorrelation(data1,subjects1,data2,subjects2,hf0(1,i),colorNames(pPos,:));
        xData=[xData data1];
        yData=[yData data2];
    end
    % set the text position
    yshift=0;
    for pPos=1:2
        xPos=min(xData(:))+5; yPos=max(yData(:))-yshift;
        text(xPos,yPos,['r =' num2str(round(r(pPos),2)) ', p =' num2str(round(p(pPos),2)) ', N =' num2str(N(pPos))],'Color',colorNames(pPos,:),'parent',hf0(1,i),'FontSize',14);
        if i==1
            yshift=0.3;
        else
            yshift=0.2;
        end
    end

end
xlabel(hf0(1,1),'Meditation-induced gamma (M1-EO1)','FontSize',fontSize);
ylabel(hf0(1,1),'Stimulus-induced gamma (G1(St-Bl))','FontSize',fontSize);

xlabel(hf0(1,2),'Meditation-induced gamma (M2(Bl)-G2(Bl))','FontSize',fontSize);
ylabel(hf0(1,2),'Stimulus-induced gamma (M2(St-Bl))','FontSize',fontSize);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% %% Meditation Induced gamma (M1-EO1) vs Age
% pPosList=[2 4]; %
% [subjects1,~,~,data1] = getDemographicDetails('BK1');
% for pPos=1:length(pPosList)
%     for gPos=1:2
%         data2     = logPowerData{pPosList(pPos)}{gPos};
%         subjects2 = goodSubjectNames{pPosList(pPos)}{gPos};
%         getCorrelation(data1,subjects1,data2,subjects2,hf1(1,pPos),colorNames(gPos,:));
%     end
% end
% xlabel(hf1(1,1),'Age (Yrs)');
% ylabel(hf1(1,1),'Meditation-induced Gamma (dB)');
% 
% xlabel(hf1(1,2),'Age (Yrs)');
% ylabel(hf1(1,2),'Stimulus-induced Gamma (dB)');
% 
% 
% %% Meditation Induced gamma (M1-EO1) vs #hours of Meditation (2a)
% practiceHoursData = load('BK1PracticeHours.mat');
% data1     = cell2mat(practiceHoursData.practiceHours(2:end,2));
% subjects1 = practiceHoursData.practiceHours(2:end,1);
% for pPos=1:length(pPosList)
%     for gPos=1 % For Meditators
%         data2     = logPowerData{pPosList(pPos)}{gPos};
%         subjects2 = goodSubjectNames{pPosList(pPos)}{gPos};
%         getCorrelation(data1,subjects1,data2,subjects2,hf1(2,pPos),colorNames(gPos,:));
%     end
% end
% xlabel(hf1(2,1),'Hours of Meditation (Hrs)');
% ylabel(hf1(2,1),'Meditation-induced Gamma (dB)');
% 
% xlabel(hf1(2,2),'Hours of Meditation (Hrs)');
% ylabel(hf1(2,2),'Stimulus-induced Gamma (dB)');

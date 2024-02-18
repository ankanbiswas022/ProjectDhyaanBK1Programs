
clear
close all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initial variables %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure1 = figure('WindowState','maximized','Color',[1 1 1]);
hTopo = getPlotHandles(1,3,[0.1 0.1 0.8 0.8],0.05,0.06);

fontsize       = 12;
comparisonStr  = 'paired';
protocolNames  = [{'EO1'}  {'EC1'}  {'M1'} ];
refChoices     = [{'none'} {'none'} {'none'} ] ;
analysisChoice = {'combined','combined','combined','combined'};

groupNames      = {'Med','Con'};
badEyeCondition = 'ep';
badTrialVersion = 'v8';
badElectrodeRejectionFlag = 1;

stRange = [0.25 1.25]; % hard coded for now

freqRangeList{1} = [8 13];  % alpha
freqRangeList{2} = [30 80]; % spontaneous gamma range

% axisRangeList{1}    = [5 200];     axisRangeName{1} = 'Freq Lims (Hz)';
% axisRangeList{2}{1} = [-2 1];      axisRangeName{2} = 'YLims';
% axisRangeList{2}{2} = [-2.5 0.5];
axisRangeList{3}    = [-4 4];  axisRangeName{3} = 'cLims (topo)';

styleTopo = 'both'; %if 'both', both contur and color, if 'map', no contour lines
colormap('jet');

useMedianFlag = 0;
cutoffList    = [3 30];

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Get Data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
hPSDPlots = [];
groupPos  = [1,2]; % Occipital
freqPos   = 2;     % Slow gamma

numGroups     = length(groupPos);
numProtocols  = length(protocolNames);
logPSDDataTMP = cell(numGroups,numProtocols);
logPowerTMP   = cell(numGroups,numProtocols);
goodSubjectNameListsTMP = cell(1,numProtocols);

% get the data
for i=1:numProtocols
    [psdDataTMP,powerDataTMP,goodSubjectNameListsTMP{i},topoplotDataTMP,freqVals] = displayPowerDataAllSubjects(subjectNameLists,protocolNames{i},analysisChoice{i},refChoices{i},badEyeCondition,badTrialVersion,badElectrodeRejectionFlag,stRange,freqRangeList,axisRangeList,cutoffList,useMedianFlag,hPSDPlots,pairedDataFlag,0);
    for g=1:numGroups
        logPSDDataTMP{g,i}   = psdDataTMP{g};
        logPowerTMP{g,i}     = powerDataTMP{g,freqPos};
    end
    logTopoDataTMP{i,1}  = topoplotDataTMP(:,freqPos);
end

logPSDData  = logPSDDataTMP;
logPower    = logPowerTMP;
logTopoData = logTopoDataTMP;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% loading Montage for the topoplot
capType = 'actiCap64_UOL';
gridType = 'EEG';
x = load([capType 'Labels.mat']); montageLabels = x.montageLabels(:,2);
x = load([capType '.mat']); montageChanlocs = x.chanlocs;
% axisRangeList{3} = [-1.5 1.5]; axisRangeName{3} = 'cLims (topo)';
cLimsTopo = axisRangeList{3};
styleTopo = 'both'; %if 'both', both contur and color, if 'map', no contour lines
colormap('jet');

%%%%%%%%%%%%%%%%%%%%% Reshape the data for topoplot %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
comparisonData = [];
for i=1:numProtocols
    for s=1:2
        data = logTopoData{i,1}{s};
        comparisonData(s,:) = data;
    end
    % difference of the data
    data = -diff(squeeze(comparisonData(:,:)));
    axes(hTopo(i));
    topoplot(10*data,montageChanlocs,'electrodes','on','maplimits',cLimsTopo,'plotrad',0.6,'headrad',0.6,'style',styleTopo);
%     title({protocolNames{i};['(' groupNames{1} '-' groupNames{2}  ')']} ,'fontsize',14);
    title(protocolNames{i},'fontsize',20);
    subtitle(['(' groupNames{1} '-' groupNames{2} ')'],'fontsize',20);
    if i==2
        ach=colorbar;
        ach.Location       ='southoutside';
        ach.Position       =  [0.4106    0.1866    0.1781    0.0404];  ach.FontWeight = 'bold'; ach.FontSize  =10;
        ach.Label.String   = 'Change in Power (dB)';
        ach.Label.FontSize = 14;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Meditation Figure 2
% Shows spontaneous gamma for EO1(combined), EC1(combined) and G1(Baseline)
% ---------------------------------------------------------------------------------------

clf
clear
plotTopoFlag = 1;
plotSlopeFlag = 1;
displayInsetFlag = 1;
displaySignificanceFlag =0; %for slope topoplot

fontsize = 12;
comparisonStr  = 'paired';
protocolNames  = [{'EO1'}  {'EC1'}  {'M1'} {'M1'}];
refChoices     = [{'none'} {'none'} {'none'} {'EO1'}] ;
analysisChoice = {'combined','combined','combined','combined'};

groupNames = {'Meditators','Controls'};
% colorList = [rgb('RoyalBlue');rgb('DarkCyan')];
colorList = [[ 0.2539    0.4102    0.8789];[0    0.5430    0.5430]];

badEyeCondition = 'ep';
badTrialVersion = 'v8';
badElectrodeRejectionFlag = 1;

stRange = [0.25 1.25]; % hard coded for now

freqRangeList{1} = [8 13];  % alpha
freqRangeList{2} = [30 80]; % spontaneous gamma range

axisRangeList{1} = [5 198];     axisRangeName{1} = 'Freq Lims (Hz)';
axisRangeList{2} = [-2.5 1.2];  axisRangeName{2} = 'YLims';
axisRangeList{3} = [-1.5 1.5]; axisRangeName{3} = 'cLims (topo)';

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Make Plots %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

hAllPlots = getPlotHandles(3,4,[0.1 0.12 0.85 0.8],0.04,0.05);
hTopo     = hAllPlots(:,end);

hTopoSlope = hAllPlots(3,1:3);

annotation('textbox',[.12 .72 .1 .2], 'String','Occipital','EdgeColor','none','FontWeight','bold','FontSize',20,'Rotation',90,'Color',colorList(1,:));
annotation('textbox',[.12 .40 .12 .2], 'String','Fronto-Central','EdgeColor','none','FontWeight','bold','FontSize',20,'Rotation',90,'Color',colorList(2,:));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Get Data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
groupPos = [1,2]; % Occipital
freqPos  = 2; % Slow gamma

numGroups = length(groupPos);
numProtocols = length(protocolNames);
logPSDDataTMP = cell(numGroups,numProtocols);
logPowerTMP = cell(numGroups,numProtocols);
goodSubjectNameListsTMP = cell(1,numProtocols);


if numProtocols==1
    [psdDataToReturn,powerDataToReturn,goodSubjectNameListsToReturn,topoplotDataToReturn,freqVals] = displayPowerDataAllSubjects(subjectNameLists,protocolNames{1},analysisChoice,refChoices{1},badEyeCondition,badTrialVersion,badElectrodeRejectionFlag,stRange,freqRangeList,axisRangeList,cutoffList,useMedianFlag,hAllPlots,pairedDataFlag,0);
    logPSDData = psdDataToReturn{groupPos};
    logPower = powerDataToReturn{groupPos,freqPos};
    goodSubjectsSlope = goodSubjectNameListsToReturn;

else % either combine or just get the data
    % Combine
    for i=1:numProtocols
        [psdDataTMP,powerDataTMP,goodSubjectNameListsTMP{i},topoplotDataTMP,freqVals] = displayPowerDataAllSubjects(subjectNameLists,protocolNames{i},analysisChoice{i},refChoices{i},badEyeCondition,badTrialVersion,badElectrodeRejectionFlag,stRange,freqRangeList,axisRangeList,cutoffList,useMedianFlag,hAllPlots,pairedDataFlag,0);
        for g=1:numGroups
            logPSDDataTMP{g,i}   = psdDataTMP{g};
            logPowerTMP{g,i}     = powerDataTMP{g,freqPos};
        end
        logTopoDataTMP{i,1}  = topoplotDataTMP(:,freqPos);
    end

    logPSDData = logPSDDataTMP;
    logPower = logPowerTMP;
    logTopoData = logTopoDataTMP;
end

%%%%%%%%%%%%%%%%%%%%%%%% Plot topoplots slope %%%%%%%%%%%%%%%%%%%%%%%%%

% loading Montage for the topoplot
capType = 'actiCap64_UOL';
gridType = 'EEG';
x = load([capType 'Labels.mat']); montageLabels = x.montageLabels(:,2);
x = load([capType '.mat']); montageChanlocs = x.chanlocs;

for i=1:3
    for j=1:2
        goodSubjectsSlope{i}{j} = goodSubjectNameListsTMP{i}{1,j};
    end
end

if plotSlopeFlag
    analysisChoiceSlope = analysisChoice{1};
    plotFigure1TopoMed(goodSubjectsSlope,montageChanlocs, badEyeCondition,badTrialVersion, analysisChoiceSlope, badElectrodeRejectionFlag,cutoffList(2),useMedianFlag,displaySignificanceFlag,hTopoSlope);
end

% change the axis for hTopoSlope inside

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Plot Psd %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
displaySettings.fontSizeLarge = 10;
displaySettings.tickLengthMedium = [0.025 0];
displaySettings.xscaleLogFlag = 1;
% displaySettings.colorNames(1,:) = [1 0 0];

% Cyan and Blue (CMYK)
displaySettings.colorNames(1,:) = [ 0.5000         0    0.5000];
displaySettings.colorNames(2,:) = [  0.2539    0.4102    0.8789];

% RGB Color scheme
% displaySettings.colorNames(1,:) = [ 1 0 0];
% displaySettings.colorNames(2,:) = [ 0 1 0];

titleStr{1} = 'Meditators';
titleStr{2} = 'Controls';

freqLims = axisRangeList{1};
yLimsPSD = axisRangeList{2};
cLimsTopo = axisRangeList{3};

numProtocolsToShow = 3;
for g=1:length(groupPos)
    for i=1:numProtocols
        %%%%%%%%%%%%%%%%%%%%%%%%%%%% Plot topoplots %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if i==4 % if M1 with respect to EO1 baseline
            if plotTopoFlag
                for s=1:3 %  meditators  and control
                    if s==3
                        data = -diff(squeeze(comparisonData(:,:)));
                        axes(hTopo(s));
                        topoplot(data,montageChanlocs,'electrodes','on','maplimits',cLimsTopo,'plotrad',0.6,'headrad',0.6);
                    else
                        axes(hTopo(s));
                        title(groupNames{s});
                        data = logTopoData{i,1}{s};                                                                                                                                                   data = logTopoData{i}{s};
                        comparisonData(s,:) = data;
                        topoplot(data,montageChanlocs,'electrodes','on','maplimits',cLimsTopo,'plotrad',0.6,'headrad',0.6);
                        if i==2 && s==1
                            ach=colorbar;
                            ach.Location='southoutside';
                            ach.Position =  [ach.Position(1) ach.Position(2)-0.05 ach.Position(3) ach.Position(4)];
                            ach.Label.String = '\Delta Power (dB)';
                        end

                    end
                    if s==1
                        [electrodeGroupList,groupNameList] = getElectrodeGroups(gridType,capType);
                        numGroups = length(electrodeGroupList);
                        for n=1:numGroups
                            showElecIDs = electrodeGroupList{n};
                            topoplot_murty([],montageChanlocs,'electrodes','on','style','blank','drawaxis','off','nosedir','+X','emarkercolors',x,'plotchans',showElecIDs,'plotrad',0.65,'headrad',0.6,'emarker',{'.',colorList(n,:),14,1},'plotrad',0.6,'headrad',0.6);
                        end
                    end
                end
            end
        else
            %%%%%%%%%%%%%%%% Plot PSD %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            hPSD = hAllPlots(g,i);
            hPos =  get(hPSD,'Position');
            displayAndcompareData(hPSD,logPSDData{g,i},freqVals,displaySettings,yLimsPSD,1,useMedianFlag,~pairedDataFlag);

            %%%%%%%%%%% Add -- lines from EO1 %%%%%%%%%%%%%%%
            if i==3  % M1 protocol
                p=1; % EO1
                showOnlyLineFlag = 1;
                lineStyle = '--';
                displayAndcompareData(hPSD,logPSDData{g,p},freqVals,displaySettings,yLimsPSD,0,useMedianFlag,~pairedDataFlag,showOnlyLineFlag,lineStyle);
            end

            % Add lines in PSD plots
            if ~strcmp(refChoices{1},'none')
                line([0 freqVals(end)],[0 0],'color','k','parent',hPSD);
            end

            % add vertical lines to show the ranges
            %             xline([freqRangeList{freqPos}(1)  freqRangeList{freqPos}(2)],'--k','LineWidth',2)
            %             xline([84  190],'--m','LineWidth',2);

            xlim(hPSD,freqLims);
            set(hPSD,'XScale','log');
            set(hPSD,'xtick',[2 10 50 100 200],'xticklabel',[2 10 50 100 200],'XMinorTick','off');

            %%%%%%%%%%%%%%%%%%%%%%%%%%% Violin Plot %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if displayInsetFlag
                hInset = axes('position', [hPos(1)+0.02 hPos(2)+0.032   0.0544    0.0727]);
                displaySettings.plotAxes = hInset;
                if ~useMedianFlag
                    displaySettings.parametricTest = 1;
                else
                    displaySettings.parametricTest = 0;
                end

                if g==2 &&  i==1
                    displaySettings.showYTicks=1;
                    displaySettings.showXTicks=1;
                    ylabel(hInset,'Power','FontSize',10);
                else
                    displaySettings.showYTicks=0;
                    displaySettings.showXTicks=0;

                end
                displaySettings.setYLim=[-1 2.3];
                displaySettings.commonYLim = 1;
                displaySettings.xPositionText =0.8;
                ax=displayViolinPlot(logPower{g,i},[{displaySettings.colorNames(1,:)} {displaySettings.colorNames(2,:)}],1,1,1,pairedDataFlag,displaySettings);
            end
        end
    end
end

% Add labels:
xlabel(hAllPlots(2,1),'Frequency(Hz)','FontWeight','bold','FontSize',15);
ylabel(hAllPlots(2,1),'Power (log_{10}(\muV^2))','FontWeight','bold','FontSize',15);
% xlabel(hAllPlots(2,1),'Frequency(Hz)','FontWeight','bold','FontSize',18);
% ylabel(hAllPlots(2,1),'Power (log_{10}(\muV^2))','FontWeight','bold','FontSize',18);

title(hAllPlots(1,1),'EO1','FontWeight','bold','FontSize',18);
title(hAllPlots(1,2),'EC1','FontWeight','bold','FontSize',18);
title(hAllPlots(1,3),'M1','FontWeight','bold','FontSize',18);

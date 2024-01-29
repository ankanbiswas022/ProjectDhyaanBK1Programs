% Meditation Figure 2
% Shows spontaneous gamma for M1 (during Meditation)
% ---------------------------------------------------------------------------------------
clf
clear

figure(1);
fontsize = 12;
comparisonStr = 'paired';

protocolNames = {'M1'};
refChoices    = {'none'};
analysisChoice = {'combined'};

badEyeCondition = 'ep';
badTrialVersion = 'v8';
badElectrodeRejectionFlag = 1;

stRange = [0.25 1.25]; % hard coded for now

freqRangeList{1} = [8 13];  % alpha
freqRangeList{2} = [25 40]; % modified slow-Gamma range
freqRangeList{3} = [41 65]; % modified fast-Gamma range

axisRangeList{1} = [0 100];    axisRangeName{1} = 'Freq Lims (Hz)';
axisRangeList{2} = [-2.5 2.5]; axisRangeName{2} = 'YLims';
axisRangeList{3} = [-1.5 1.5]; axisRangeName{3} = 'cLims (topo)';

cutoffList = [3 30];
useMedianFlag = 0;

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
clf
hPSD = getPlotHandles(1,2,[0.1 0.7 0.8 0.25],0.05);
HViolin = getPlotHandles(3,2,[0.1 0.08 0.8 0.55],0.05,0.03);

% Label the plots
title(hAllPlots(1,1),'Occipital','FontWeight','bold','FontSize',18);
title(hAllPlots(1,2),'Fronto-Central','FontWeight','bold','FontSize',18);
title(hAllPlots(1,3),'G1','FontWeight','bold','FontSize',18);
annotation('textbox',[.12 .65 .1 .2], 'String','Occipital','EdgeColor','none','FontWeight','bold','FontSize',18,'Rotation',90);
annotation('textbox',[.12 .18 .1 .2], 'String','Fronto-Central','EdgeColor','none','FontWeight','bold','FontSize',18,'Rotation',90);

xlabel(hAllPlots(2,1),'Frequency(Hz)','FontWeight','bold','FontSize',15);
ylabel(hAllPlots(2,1),'Power (log_{10}(\muV^2))','FontWeight','bold','FontSize',15);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Get Data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
groupPos = [1,2]; % Occipital
freqPos  = 2; % Slow gamma

numGroups = length(groupPos);
numProtocols = length(protocolNames);
logPSDDataTMP = cell(numGroups,numProtocols);
logPowerTMP = cell(numGroups,numProtocols);
goodSubjectNameListsTMP = cell(numGroups,numProtocols);


if numProtocols==1
    [psdDataToReturn,powerDataToReturn,goodSubjectNameListsToReturn,topoplotDataToReturn,freqVals] = displayPowerDataAllSubjects(subjectNameLists,protocolNames{1},analysisChoice,refChoices{1},badEyeCondition,badTrialVersion,badElectrodeRejectionFlag,stRange,freqRangeList,axisRangeList,cutoffList,useMedianFlag,hAllPlots,pairedDataFlag,0);
    logPSDData = psdDataToReturn{groupPos};
    logPower = powerDataToReturn{groupPos,freqPos};

else % either combine or just get the data
    % Combine
    for i=1:numProtocols
        [psdDataTMP,powerDataTMP,goodSubjectNameListsTMP{i},topoplotDataTMP,freqVals] = displayPowerDataAllSubjects(subjectNameLists,protocolNames{i},analysisChoice{i},refChoices{i},badEyeCondition,badTrialVersion,badElectrodeRejectionFlag,stRange,freqRangeList,axisRangeList,cutoffList,useMedianFlag,hAllPlots,pairedDataFlag,0);
        for g=1:numGroups
            logPSDDataTMP{g,i} = psdDataTMP{g};
            logPowerTMP{g,i}   = powerDataTMP{g,freqPos};
        end
    end
    logPSDData = logPSDDataTMP;
    logPower = logPowerTMP;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Plot Psd %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

displaySettings.fontSizeLarge = 10;
displaySettings.tickLengthMedium = [0.025 0];
displaySettings.colorNames(1,:) = [1 0 0];
displaySettings.colorNames(2,:) = [0 1 0];
titleStr{1} = 'Meditators';
titleStr{2} = 'Controls';

freqLims = axisRangeList{1};
yLimsPSD = axisRangeList{2};
cLimsTopo = axisRangeList{3};

for g=1:length(groupPos)
    for i=1:numProtocols
        hPSD = hAllPlots(g,i);
        displayAndcompareData(hPSD,logPSDData{g,i},freqVals,displaySettings,yLimsPSD,1,useMedianFlag,~pairedDataFlag);
        xlim(hPSD,freqLims);

        % Add lines in PSD plots
        for k=1:2
            line([freqRangeList{freqPos}(k) freqRangeList{freqPos}(k)],yLimsPSD,'LineStyle','--','LineWidth',2,'color','k','parent',hPSD);
        end

        if ~strcmp(refChoices{1},'none')
            line([0 freqVals(end)],[0 0],'color','k','parent',hPSD);
        end

        yticks(hPSD,yLimsPSD(1):1:yLimsPSD(end));

        if g==2 && i==1
            legend('','Meditators','','Controls','FontWeight','bold','FontSize',12);
            legend('boxoff')
            text(75,1.2,'p<0.05','Color','k','FontSize',fontsize+3,'FontWeight','bold');
            text(75,0.8,'p<0.01','Color','c','FontSize',fontsize+3,'FontWeight','bold');
        end
    end
end

% common change across figure!
set(findobj(gcf,'type','axes'),'box','off'...
    ,'fontsize',fontsize...
    ,'FontWeight','Bold'...
    ,'TickDir','out'...
    ,'TickLength',[0.02 0.02]...
    ,'linewidth',1.2...
    ,'xcolor',[0 0 0]...
    ,'ycolor',[0 0 0]...
    );
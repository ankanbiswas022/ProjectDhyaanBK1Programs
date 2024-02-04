% Meditation Figure 2
% Shows spontaneous gamma for EO1(combined), EC1(combined) and G1(Baseline)
% ---------------------------------------------------------------------------------------
clf
clear

% figure(2);
fontsize = 12;
comparisonStr = 'paired';
% % protocolNames = {'G2'}; refChoices = {'none'};
colormap jet

combineDataAcrossCommonProtocols = 0;

protocolNames  = [{'M2'}  {'M2'}  {'M2'} {'M1'} {'G2'}];
refChoices     = [{'none'} {'none'} {'M2'}  {'none'} {'none'}] ;
analysisChoice = {'bl','st','st','combined','bl'};

groupNames = {'Meditators','Controls'};
colorList  = [rgb('RoyalBlue');rgb('DarkCyan')];

combineDataAcrossCommonProtocols = 0;
plotTopoFlag = 1;

% combIndex      = {[1,4],[2,5],[3,6]};
% protocolNames  = [{'EO1'}  {'EC1'}  {'G1'} {'EO2'}  {'EC2'}  {'G2'}];
% refChoices     = [{'none'} {'none'} {'none'} {'none'}  {'none'}  {'none'}] ;
% analysisChoice = {'combined','combined','bl','combined','combined','bl'};

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

hAllPlots = getPlotHandles(2,4,[0.1 0.1 0.85 0.8],0.05);
hTopo     = hAllPlots(:,end);



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
        logTopoDataTMP{i,1}  = topoplotDataTMP(:,freqPos);
    end
    logPSDData  = logPSDDataTMP;
    logPower    = logPowerTMP;
    logTopoData = logTopoDataTMP;
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

% loading Montage for the topoplot
capType = 'actiCap64_UOL';
gridType = 'EEG';
x = load([capType 'Labels.mat']); montageLabels = x.montageLabels(:,2);
x = load([capType '.mat']); montageChanlocs = x.chanlocs;

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
            text(75,1.2,'p<0.05','Color','c','FontSize',fontsize+3,'FontWeight','bold');
            text(75,0.8,'p<0.01','Color','k','FontSize',fontsize+3,'FontWeight','bold');
        end

        %%%%%%%%%%%%%%%%%% Plot topoplot %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if i==3
            if plotTopoFlag
                for s=1:2 %  meditators  and control
                    axes(hTopo(s));
                    title(groupNames{s});
                    data = logTopoData{i,1}{s};                                                                                                                                                   data = logTopoData{i}{s};
                    topoplot(data,montageChanlocs,'electrodes','on','maplimits',cLimsTopo,'plotrad',0.6,'headrad',0.6);
                    if i==2 && s==1
                        ach=colorbar;
                        ach.Location='southoutside';
                        ach.Position =  [ach.Position(1) ach.Position(2)-0.05 ach.Position(3) ach.Position(4)];
                        ach.Label.String = '\Delta Power (dB)';
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
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    end
end

% Label the plots
title(hAllPlots(1,1),'M2 (Spontaneous)','FontWeight','bold','FontSize',18);
title(hAllPlots(1,2),'M2 (Stimulus)','FontWeight','bold','FontSize',18);

% common change across figure!
set(gcf,'color','w');
set(findobj(gcf,'type','axes'),'box','off'...
    ,'fontsize',fontsize...
    ,'FontWeight','Bold'...
    ,'TickDir','out'...
    ,'TickLength',[0.02 0.02]...
    ,'linewidth',1.2...
    ,'xcolor',[0 0 0]...
    ,'ycolor',[0 0 0]...
    );
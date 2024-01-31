% Meditation Figure 2
% Shows spontaneous gamma for EO1(combined), EC1(combined) and G1(Baseline)
% ---------------------------------------------------------------------------------------

clf
clear


plotTopoFlag = 1;
displayInsetFlag=0;

figure('units','normalized','WindowState','maximized','InvertHardcopy','on');
colormap jet

fontsize = 12;
comparisonStr  = 'paired';
protocolNames  = [{'EO1'}  {'EC1'}  {'M1'} {'M1'}];
refChoices     = [{'none'} {'none'} {'none'} {'EO1'}] ;
analysisChoice = {'combined','combined','combined','combined'};
groupNames = {'Meditators','Controls'};
colorList = [rgb('RoyalBlue');rgb('DarkCyan')];

combineDataAcrossCommonProtocols = 0;

badEyeCondition = 'ep';
badTrialVersion = 'v8';
badElectrodeRejectionFlag = 1;

stRange = [0.25 1.25]; % hard coded for now

freqRangeList{1} = [8 13];  % alpha
freqRangeList{2} = [30 80]; % modified slow-Gamma range
% freqRangeList{3} = [41 65]; % modified fast-Gamma range

axisRangeList{1} = [0 90];     axisRangeName{1} = 'Freq Lims (Hz)';
axisRangeList{2} = [-2. 2.5];  axisRangeName{2} = 'YLims';
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

hAllPlots = getPlotHandles(2,4,[0.1 0.12 0.85 0.8],0.05);
hTopo     = hAllPlots(:,end);

% Label the plots
% title(hAllPlots(1,1),'EO1','FontWeight','bold','FontSize',18);
% title(hAllPlots(1,2),'EC1','FontWeight','bold','FontSize',18);
% title(hAllPlots(1,3),'M1','FontWeight','bold','FontSize',18);

annotation('textbox',[.12 .60 .1 .2], 'String','Occipital','EdgeColor','none','FontWeight','bold','FontSize',20,'Rotation',90,'Color',colorList(1,:));
annotation('textbox',[.12 .18 .12 .2], 'String','Fronto-Central','EdgeColor','none','FontWeight','bold','FontSize',20,'Rotation',90,'Color',colorList(2,:));

% xlabel(hAllPlots(2,1),'Frequency(Hz)','FontWeight','bold','FontSize',18);
% ylabel(hAllPlots(2,1),'Power (log_{10}(\muV^2))','FontWeight','bold','FontSize',18);

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
            logPSDDataTMP{g,i}   = psdDataTMP{g};
            logPowerTMP{g,i}     = powerDataTMP{g,freqPos};
        end
        logTopoDataTMP{i,1}  = topoplotDataTMP(:,freqPos);
    end
    logPSDData = logPSDDataTMP;
    logPower = logPowerTMP;
    logTopoData = logTopoDataTMP;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Plot Psd %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
displaySettings.fontSizeLarge = 10;
displaySettings.tickLengthMedium = [0.025 0];
% displaySettings.colorNames(1,:) = [1 0 0];

% Cyan and Blue (CMYK)

% displaySettings.colorNames(1,:) = [ 0.5000         0    0.5000];
% displaySettings.colorNames(2,:) = [  0.2539    0.4102    0.8789];

% RGB Color scheme
displaySettings.colorNames(1,:) = [ 1 0 0];
displaySettings.colorNames(2,:) = [ 0 1 0];

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

numProtocolsToShow = 3;
% although we are getting the data for the four protocols, we are showing for the first three protocols!

for g=1:length(groupPos)
    for i=1:numProtocols
        %%%%%%%%%%%%%%%%%%%%%%%%%%%% Plot topoplots %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if i==4 % if M1 with respect to EO1 baseline
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

        else
            %%%%%%%%%%%%%%%% Plot PSD %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            hPSD = hAllPlots(g,i);
            hPos =  get(hPSD,'Position');

            % handaxes1 = axes('position', [0.35 0.8 0.15 0.1]);
            displayAndcompareData(hPSD,logPSDData{g,i},freqVals,displaySettings,yLimsPSD,1,useMedianFlag,~pairedDataFlag);
            xlim(hPSD,freqLims);

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

            %         if i==3 && g==1
            %             legend('','Meditators','','Controls','FontWeight','bold','FontSize',12);
            %             legend('boxoff')
            %             text(75,1.2,'p<0.05','Color','c','FontSize',fontsize+3,'FontWeight','bold');
            %             text(75,0.8,'p<0.01','Color','k','FontSize',fontsize+3,'FontWeight','bold');
            %         end

            % put the xtick and yticklabels
            if i==1
                yticks(hPSD,-2:1:yLimsPSD(end));
                yticklabels(hPSD,-2:1:yLimsPSD(end));
            else
                yticks(hPSD,yLimsPSD(1):2:yLimsPSD(end));
                yticklabels(hPSD,[]);
            end

            if  g==2
                xticks(hPSD,freqLims(1):20:freqLims(2));
                xticklabels(hPSD,freqLims(1):20:freqLims(2));
            else
                xticks(hPSD,freqLims(1):20:freqLims(2));
                xticklabels(hPSD,[]);
            end

            %         for k=1:2
            %             gk=line([freqRangeList{freqPos}(k) freqRangeList{freqPos}(k)],yLimsPSD,'LineStyle','--','LineWidth',2,'color','k','parent',hPSD);
            %             xline(freqRangeList{freqPos}(1) freqRangeList{freqPos}(2),'LineStyle','--','LineWidth',2,'color','k','parent';hPSD);
            xline([freqRangeList{freqPos}(1)  freqRangeList{freqPos}(2)],'--k','LineWidth',2);
            % end

            %%%%%%%%%%%%%%%%%%%%%%%%%%% Violin Plot %%%%%%%%%%%
            % hInset = axes('position', [hPos(1)+0.25 hPos(2)+0.11 0.15 0.12]);
            if displayInsetFlag

                %             hInset = axes('position', [hPos(1)+0.178 hPos(2)+0.2 0.07 0.16]);
                hInset = axes('position', [hPos(1)+0.13 hPos(2)+0.2 0.07 0.16]);
                displaySettings.plotAxes = hInset;
                if ~useMedianFlag
                    displaySettings.parametricTest = 1;
                else
                    displaySettings.parametricTest = 0;
                end

                if g==2 &&  i==1
                    displaySettings.showYTicks=1;
                    displaySettings.showXTicks=1;
                    ylabel(hInset,'Power (log_{10}(\muV^2))','FontSize',10);
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



xlabel(hAllPlots(2,1),'Frequency(Hz)','FontWeight','bold','FontSize',15);
ylabel(hAllPlots(2,1),'Power (log_{10}(\muV^2))','FontWeight','bold','FontSize',15);

title(hAllPlots(1,1),'EO1','FontWeight','bold','FontSize',18);
title(hAllPlots(1,2),'EC1','FontWeight','bold','FontSize',18);
title(hAllPlots(1,3),'M1','FontWeight','bold','FontSize',18);

% common change across figure!
set(gcf,'color','w');
set(findobj(gcf,'type','axes'),'box','off'...
    ,'FontWeight','Bold'...
    ,'TickDir','out'...
    ,'TickLength',[0.02 0.02]...
    ,'linewidth',1.2...
    ,'xcolor',[0 0 0]...
    ,'ycolor',[0 0 0]...
    );
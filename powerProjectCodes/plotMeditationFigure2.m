% Meditation Figure 2
% Shows spontaneous gamma for EO1(combined), EC1(combined) and G1(Baseline)
% ---------------------------------------------------------------------------------------

% clf
clear
figure()
plotTopoFlag = 1;
plotSlopeFlag = 1;
freqSlopeRange = [104 190];
displayInsetFlag = 1;
customColorMapFag =1;
displaySignificanceFlag = 0; % for slope topoplot
styleTopo = 'both'; %if 'both', both contur and color, if 'map', no contour lines
colormap('jet');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% colorList = [rgb('RoyalBlue');rgb('DarkCyan')];
% colorList = [[ 0.2539    0.4102    0.8789]; [0    0.5430    0.5430]];

colorList = [rgb('Aqua');rgb('Orange')];
% colorList = [[ 0.2539    0.4102    0.8789]; [0    0.5430    0.5430]];

if customColorMapFag
    % Cyan and Blue (CMYK)
%     displaySettings.colorNames(1,:)     = [0.7 0 0.7];
    displaySettings.colorNames(1,:)     = [0.7 0 0.7];
    displaySettings.colorNames(2,:)     = [0 0.7 0.7];
    displaySettings.colorNames(3,:) = [ 0.5000    0      0.5000];
    displaySettings.colorNames(4,:) = [ 0.2539    0.4102    0.8789];
else
    % RGB Color scheme
    displaySettings.colorNames(1,:) = [ 1 0 0];
    displaySettings.colorNames(2,:) = [ 0 1 0];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fontsize = 12;
comparisonStr  = 'paired';
protocolNames  = [{'EO1'}  {'EC1'}  {'M1'} {'M1'}];
refChoices     = [{'none'} {'none'} {'none'} {'EO1'}] ;
analysisChoice = {'combined','combined','combined','combined'};

groupNames = {'Meditators','Controls'};

badEyeCondition = 'ep';
badTrialVersion = 'v8';
badElectrodeRejectionFlag = 1;

stRange = [0.25 1.25]; % hard coded for now

freqRangeList{1} = [8 13];  % alpha
freqRangeList{2} = [30 80]; % spontaneous gamma range

axisRangeList{1} = [5 200];     axisRangeName{1} = 'Freq Lims (Hz)';
axisRangeList{2}{1} = [-2 1];  axisRangeName{2} = 'YLims';
axisRangeList{2}{2} = [-2.5 0.5];
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

hPSDPlots = getPlotHandles(2,3,[0.08 0.38 0.7 0.53],0.02,0.04);
hTopo = getPlotHandles(3,1,[0.83 0.1 0.11 0.82],0.01,0.06);
hTopoSlope0 = getPlotHandles(1,6,[0.07 0.08 0.7 0.15],0.01);

for iTopo = 1:3
    hTopoSlope(iTopo) = hTopoSlope0(2*(iTopo)-1);
    hBarSlope(iTopo) = hTopoSlope0(2*iTopo);
end
% hAllPlots = getPlotHandles(3,4,[0.1 0.12 0.85 0.8],0.04,0.05);
% hTopo     = hAllPlots(:,end);
% hTopoSlope = hAllPlots(3,1:3);

% annotation('textbox',[.12 .72 .1 .2], 'String','Occipital','EdgeColor','none','FontWeight','bold','FontSize',20,'Rotation',90,'Color',colorList(1,:));
% annotation('textbox',[.12 .40 .12 .2], 'String','Fronto-Central','EdgeColor','none','FontWeight','bold','FontSize',20,'Rotation',90,'Color',colorList(2,:));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Get Data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
groupPos = [1,2]; % Occipital
freqPos  = 2; % Slow gamma

numGroups = length(groupPos);
numProtocols = length(protocolNames);
logPSDDataTMP = cell(numGroups,numProtocols);
logPowerTMP = cell(numGroups,numProtocols);
goodSubjectNameListsTMP = cell(1,numProtocols);


if numProtocols==1
    [psdDataToReturn,powerDataToReturn,goodSubjectNameListsToReturn,topoplotDataToReturn,freqVals] = displayPowerDataAllSubjects(subjectNameLists,protocolNames{1},analysisChoice,refChoices{1},badEyeCondition,badTrialVersion,badElectrodeRejectionFlag,stRange,freqRangeList,axisRangeList,cutoffList,useMedianFlag,hPSDPlots,pairedDataFlag,0);
    logPSDData = psdDataToReturn{groupPos};
    logPower = powerDataToReturn{groupPos,freqPos};
    goodSubjectsSlope = goodSubjectNameListsToReturn;

else % either combine or just get the data
    % Combine
    for i=1:numProtocols
        [psdDataTMP,powerDataTMP,goodSubjectNameListsTMP{i},topoplotDataTMP,freqVals] = displayPowerDataAllSubjects(subjectNameLists,protocolNames{i},analysisChoice{i},refChoices{i},badEyeCondition,badTrialVersion,badElectrodeRejectionFlag,stRange,freqRangeList,axisRangeList,cutoffList,useMedianFlag,hPSDPlots,pairedDataFlag,0);
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
    plotFigure2SlopeTopoandBarMed(goodSubjectsSlope,montageChanlocs, badEyeCondition,badTrialVersion, analysisChoiceSlope, badElectrodeRejectionFlag,cutoffList,useMedianFlag,displaySignificanceFlag,hTopoSlope,hBarSlope)
    %plotFigure1TopoMed(goodSubjectsSlope,montageChanlocs, badEyeCondition,badTrialVersion, analysisChoiceSlope, badElectrodeRejectionFlag,cutoffList(2),useMedianFlag,displaySignificanceFlag,hTopoSlope);
end

% change the axis for hTopoSlope inside

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Plot Psd %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
displaySettings.fontSizeLarge = 10;
displaySettings.tickLengthMedium = [0.025 0];
displaySettings.xscaleLogFlag = 1;
% displaySettings.colorNames(1,:) = [1 0 0];

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
                        topoplot(data,montageChanlocs,'electrodes','on','maplimits',cLimsTopo,'plotrad',0.6,'headrad',0.6,'style',styleTopo);
                        title([groupNames{1} '-' groupNames{2}] ,'fontsize',12);
                        ach=colorbar;
                        ach.Location='southoutside';
                        ach.Position =  [0.83  0.07 0.12 0.02];  ach.FontWeight = 'bold'; ach.FontSize  =10;
                        ach.Label.String = '\Delta Power (dB)';
                        ach.Label.FontSize = 10;
                    else
                        axes(hTopo(s));
                        title(groupNames{s},'fontsize',12,'Color', displaySettings.colorNames(s,:),'fontweight','bold');
                        data = logTopoData{i,1}{s};                                                                                                                                                   data = logTopoData{i}{s};
                        comparisonData(s,:) = data;
                        topoplot(data,montageChanlocs,'electrodes','on','maplimits',cLimsTopo,'plotrad',0.6,'headrad',0.6,'style',styleTopo);

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
            hPSD = hPSDPlots(g,i);%hAllPlots(g,i);
            hPos =  get(hPSD,'Position');
            displayAndcompareData(hPSD,logPSDData{g,i},freqVals,displaySettings,yLimsPSD{g},1,useMedianFlag,~pairedDataFlag);


            %%%% Add slope lines
            if g==2
                freqSlope1 = freqSlopeRange(1)+1;
                freqSlope2 = freqSlopeRange(2)+1;
                for iSub = 1:2
                    data0{iSub} = nanmean(logPSDData{g,i}{iSub},1);
                    aFit=fit(log10(freqVals(freqSlope1:freqSlope2))',data0{iSub}(freqSlope1:freqSlope2)','poly1');
                    hold on;
                    plot(hPSD,freqVals(freqSlope1:freqSlope2),aFit.p2+aFit.p1.*log10(freqVals(freqSlope1:freqSlope2)),'--k','lineWidth',2.5);
                end
            end
            %%%%%%%%%%% Add -- lines from EO1 %%%%%%%%%%%%%%%
            if i==3  % M1 protocol
                p=1; % EO1
                showOnlyLineFlag = 1;
                lineStyle = '--';
                displaySettings2 = displaySettings;
                displaySettings2.colorNames  = [1 0.4 0.4; 0.4 1 0.4];
                displayAndcompareData(hPSD,logPSDData{g,p},freqVals,displaySettings2,yLimsPSD{g},0,useMedianFlag,~pairedDataFlag,showOnlyLineFlag,lineStyle);
            end

            % Add lines in PSD plots
            if ~strcmp(refChoices{1},'none')
                line([0 freqVals(end)],[0 0],'color','k','parent',hPSD);
            end

            % add vertical lines to show the ranges
            %             xline([freqRangeList{freqPos}(1)  freqRangeList{freqPos}(2)],'--k','LineWidth',2)
            %             xline([84  190],'--m','LineWidth',2);

            xlim(hPSD,freqLims);
            ylim(hPSD,yLimsPSD{g});
            set(hPSD,'XScale','log');

            if g==1
                if i==1;     legend(titleStr{1},'',titleStr{2});         end
                title(hPSD,protocolNames{i},'FontSize',15);
                set(hPSD,'xtick',[10 50 100 200],'xticklabel',[], 'LineWidth',1,'XMinorTick','off','Ticklength',[0.02 0.02],'FontWeight','bold');
            else
                set(hPSD,'xtick',[10 50 100 200],'xticklabel',[10 50 100 200], 'LineWidth',1,'XMinorTick','off','Ticklength',[0.02 0.02],'FontWeight','bold');
                xlabel(hPSD,'Frequency (Hz)','Fontsize',12,'FontWeight','bold');
            end

            if i==1
                ylabel(hPSD,'Power (log_{10}(\muV^2))','Fontsize',12,'FontWeight','bold');
                set(hPSD,'YTick',[-2 -1 0 1]);

            else
                set(hPSD,'YTickLabel',[],'YTick',[-2 -1 0 1]);
            end
            box off;
            %%%%%%%%%%%%%%%%%%%%%%%%%%% Violin Plot %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if displayInsetFlag
                hInset = axes('position', [hPos(1)+0.02 hPos(2)+0.032   0.0544    0.081]);
                displaySettings.plotAxes = hInset;
                if ~useMedianFlag
                    displaySettings.parametricTest = 1;
                else
                    displaySettings.parametricTest = 0;
                end


                displaySettings.showYTicks=1;
                displaySettings.showXTicks=1;
                ylabel(hInset,'Power','FontSize',10);

                displaySettings.setYLim=[-1 2.3];
                displaySettings.commonYLim = 1;
                displaySettings.xPositionText =0.8;
                displaySettings.textFontSize = 10;
                displaySettings.yPositionLine=0.3;
                ax=displayViolinPlot(logPower{g,i},[{displaySettings.colorNames(1,:)} {displaySettings.colorNames(2,:)}],1,1,1,pairedDataFlag,displaySettings);
                set(ax,'FontWeight','bold');
            end
        end
    end
end

% Add labels:
% xlabel(hAllPlots(2,1),'Frequency(Hz)','FontWeight','bold','FontSize',12);
% ylabel(hAllPlots(2,1),'Power (log_{10}(\muV^2))','FontWeight','bold','FontSize',12);
% title(hAllPlots(1,1),'EO1','FontWeight','bold','FontSize',15);
% title(hAllPlots(1,2),'EC1','FontWeight','bold','FontSize',15);
% title(hAllPlots(1,3),'M1','FontWeight','bold','FontSize',15);

if customColorMapFag
    % red-white-blue
    mycolormap = customcolormap(linspace(0,1,11), {'#68011d','#b5172f','#d75f4e','#f7a580','#fedbc9','#f5f9f3','#d5e2f0','#93c5dc','#4295c1','#2265ad','#062e61'});
    colormap(mycolormap);
end
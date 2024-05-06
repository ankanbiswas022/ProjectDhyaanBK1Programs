% Meditation Figure 2
% Shows spontaneous gamma for EO1(combined), EC1(combined) and G1(Baseline)
% ---------------------------------------------------------------------------------------

clf
clear
saveFlag = 0;
plotTopoFlag = 1;
plotSlopeFlag = 1;
freqSlopeRange = [104 190];
displayInsetFlag = 1;
customColorMapFag = 1;
displaySignificanceFlag = 0; % for slope topoplot
styleTopo = 'both'; %if 'both', both contur and color, if 'map', no contour lines
colormap('jet');

boxColor = [0.8 0.6 0.2];

fontsize = 12;

% updated font sizes
labelFontSize = 16;
titleFontSize = 20;
annotationFontSize = 24;


comparisonStr  = 'paired';
protocolNames  = [{'EO1'}  {'EC1'}  {'M1'} {'M1'}];
refChoices     = [{'none'} {'none'} {'none'} {'EO1'}] ;
analysisChoice = {'combined','combined','combined','combined'};

groupNames = {'Meditators','Controls'};
% colorList = [rgb('RoyalBlue');rgb('DarkCyan')];
% colorList = [[ 0.2539    0.4102    0.8789];[0    0.5430    0.5430]];

badEyeCondition = 'ep';
badTrialVersion = 'v8';
badElectrodeRejectionFlag = 1;

stRange = [0.25 1.25]; % hard coded for now

freqRangeList{1} = [8 13];  % alpha
freqRangeList{2} = [30 80]; % spontaneous gamma range

axisRangeList{1} = [5 200];     axisRangeName{1} = 'Freq Lims (Hz)';
axisRangeList{2}{1} = [-2 1];  axisRangeName{2} = 'YLims';
axisRangeList{2}{2} = [-2.5 0.5];
axisRangeList{3} = [-2 2]; axisRangeName{3} = 'cLims (topo)';

useMedianFlag = 0;
cutoffList    = [3 25];

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

hPSDPlots = getPlotHandles(2,3,[0.08 0.46 0.72 0.49],0.03,0.04);
hTopo = getPlotHandles(3,1,[0.82 0.11 0.15 0.8],0.01,0.07);
% hTopoSlope = getPlotHandles(1,3,[0.08 0.088 0.63 0.23],0.1625);
% hBarSlope = getPlotHandles(1,3,[0.21 0.053 0.61 0.23],0.175);

hTopoSlope = getPlotHandles(1,3,[0.07 0.09 0.61 0.23],0.157);
hBarSlope = getPlotHandles(1,3,[0.213 0.053 0.59 0.23],0.165);
% hTopoSlope0 = getPlotHandles(1,6,[0.05 0.08 0.72 0.21],0.04);
%
% for iTopo = 1:3
%     hTopoSlope(iTopo) = hTopoSlope0(2*(iTopo)-1);
%     hBarSlope(iTopo) = hTopoSlope0(2*iTopo);
% end
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


%%%%%%%%%%%%%%%%%%% colors %%%%%%%%%%%%%%%%%%%%%%%%%%
% Cyan and Blue (CMYK)

colorList = [rgb('Aqua');rgb('Orange')];

if customColorMapFag
    %     displaySettings.colorNames(1,:) = [ 0.5000         0    0.5000];
    displaySettings.colorNames(1,:)    = [0.8 0 0.8];
    displaySettings.colorNames(2,:)     = [0.25 0.41 0.88];
    displaySettings.colorNames(3,:)     = rgb('Purple');
    displaySettings.colorNames(4,:)     = rgb('Blue');
    displaySettings.colorNames(5,:)     = [0.8 0 0.8];
    displaySettings.colorNames(6,:)     = [0.25 0.41 0.88];
else
    % RGB Color scheme
    displaySettings.colorNames(1,:) = [ 1 0 0];
    displaySettings.colorNames(2,:) = [ 0 0 1];
    displaySettings.colorNames(3,:) = rgb('Brown');
    displaySettings.colorNames(4,:) = rgb('DarkGreen');

    displaySettings.colorNames(5,:) = [ 1 0 0];
    displaySettings.colorNames(6,:) = [ 0 0 1];
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
    plotFigure2SlopeTopoandBarMed(goodSubjectsSlope,montageChanlocs, badEyeCondition,badTrialVersion, analysisChoiceSlope, badElectrodeRejectionFlag,cutoffList,useMedianFlag,displaySignificanceFlag,hTopoSlope,hBarSlope,displaySettings.colorNames)
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
                        title([groupNames{1} '-' groupNames{2}] ,'fontsize',18);
                        ach=colorbar;
                        ach.Location='southoutside';
                        ach.Position =  [0.836  0.07 0.12 0.02];  ach.FontWeight = 'bold'; ach.FontSize  =12;
                        ach.Label.String = 'Change in Power (dB)';
                        ach.Label.FontSize = 14;
                    else
                        axes(hTopo(s));
                        title(groupNames{s},'fontsize',20,'Color', displaySettings.colorNames(s,:),'fontweight','bold');
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
                    plot(hPSD,freqVals(freqSlope1:freqSlope2),aFit.p2+aFit.p1.*log10(freqVals(freqSlope1:freqSlope2)),':k','lineWidth',4);
                end
            end
            %%%%%%%%%%% Add -- lines from EO1 %%%%%%%%%%%%%%%
            if i==3  % M1 protocol
                p=1; % EO1
                showOnlyLineFlag = 1;
                lineStyle = '--';
                displaySettings2 = displaySettings;
                displaySettings2.colorNames  = [displaySettings.colorNames(3,:) ; displaySettings.colorNames(4,:)];
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
                %if i==1;     legend(titleStr{1},'',titleStr{2});         end
                title(hPSD,protocolNames{i},'FontSize',20);
                set(hPSD,'xtick',[10 50 100 200],'xticklabel',[], 'LineWidth',1,'XMinorTick','on','Ticklength',[0.02 0.02],'FontWeight','bold','Fontsize',labelFontSize);
            else
                set(hPSD,'xtick',[10 50 100 200],'xticklabel',[10 50 100 200], 'LineWidth',1,'XMinorTick','on','Ticklength',[0.02 0.02],'FontWeight','bold','Fontsize',labelFontSize);
                xlabel(hPSD,'Frequency (Hz)','Fontsize',labelFontSize,'FontWeight','bold');
            end

            if i==1
                if g==2 
               yl= ylabel(hPSD,'Power (log_{10}(\muV^2))','Fontsize',labelFontSize,'FontWeight','bold');
                yl.Position(2) = 1;
                end 
               set(hPSD,'YTick',[-2 -1 0 1]);

            else
                set(hPSD,'YTickLabel',[],'YTick',[-2 -1 0 1]);
            end

            makeShadedRegion(hPSD,freqRangeList{2},yLimsPSD{g},[rgb('Cyan')],0.15);
            box off;
            %%%%%%%%%%%%%%%%%%%%%%%%%%% Violin Plot %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if displayInsetFlag
                hInset = axes('position', [hPos(1)+0.029 hPos(2)+0.032   0.0544    0.079]);
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
                displaySettings.yPositionLine=0.15;
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

annotation('textbox',[0.111875 0.728827238335435 0.1 0.2], 'String','Occipital','EdgeColor','none','FontWeight','bold','FontSize',20,'Rotation',90,'Color',colorList(1,:));
annotation('textbox',[0.111875 0.420176544766709 0.12 0.2], 'String','Fronto-Temporal','EdgeColor','none','FontWeight','bold','FontSize',20,'Rotation',90,'Color',colorList(2,:));





set(gcf,'color','w');
set(findobj(gcf,'type','axes'),'box','off'...
    ,'FontWeight','Bold'...
    ,'TickDir','out'...
    ,'TickLength',[0.02 0.02]...
    ,'linewidth',1.3...
    ,'xcolor',[0 0 0]...
    ,'ycolor',[0 0 0]...
    );

finalPlotsSaveFolder ='D:\Projects\ProjectDhyaan\BK1\ProjectDhyaanBK1Programs\powerProjectCodes\savedFigures';

if saveFlag
    figure1.Color = [1 1 1];
    savefig(figure1,fullfile(finalPlotsSaveFolder,'MeditationFigure4.fig'));
    print(figure1,fullfile(finalPlotsSaveFolder,'MeditationFigure4'),'-dsvg','-r600');
    print(figure1,fullfile(finalPlotsSaveFolder,'MeditationFigure4'),'-dtiff','-r600');
end
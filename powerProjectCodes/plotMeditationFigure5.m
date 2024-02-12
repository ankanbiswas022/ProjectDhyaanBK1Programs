% Meditation Figure 2
% Shows spontaneous gamma for EO1(combined), EC1(combined) and G1(Baseline)
% ---------------------------------------------------------------------------------------

clear
saveFlag = 1;

figure1 = figure('WindowState','maximized','Color',[1 1 1]);
colormap(jet);
displayInsetFlag = 1;

labelFontSize = 16;
titleFontSize = 20;
annotationFontSize = 24;

fontsize = 12;
comparisonStr = 'paired';
customColorMapFag =1;
showLegend = 0;
colormap jet

protocolNames  = [{'M2'}    {'M2'}    {'M2'}  {'M1'}     {'G2'}     {'M2'}  ];
refChoices     = [{'none'}  {'none'}  {'M2'}  {'none'}   {'none'}   {'G2'} ] ;
analysisChoice = [{'bl'      ,'st',    'st',  'combined',  'bl'}   {'bl'} ];

groupNames = {'Meditators','Controls'};
% colorList  = [rgb('RoyalBlue');rgb('DarkCyan')];
colorList = [rgb('Aqua');rgb('Orange')];

plotTopoFlag = 1;

badEyeCondition = 'ep';
badTrialVersion = 'v8';
badElectrodeRejectionFlag = 1;

stRange = [0.25 1.25]; % hard coded for now

freqRangeList{1} = [8 13];  % alpha
freqRangeList{2} = [24 34]; % modified slow-Gamma range
freqRangeList{3} = [30  80]; % modified fast-Gamma range
% freqRangeList{3} = [41 65]; % modified fast-Gamma range

axisRangeList{1} = [5 80];    axisRangeName{1} = 'Freq Lims (Hz)';
axisRangeList{2} = [-2 1]; axisRangeName{2} = 'YLims';
axisRangeList{3} = [-2 2]; axisRangeName{3} = 'cLims (topo)';
axisRangeList{4} = [-2.5 2]; axisRangeName{3} = 'YLims';

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

hrawPSD = getPlotHandles(2,2,[0.14 0.12 0.38 0.8],0.02,0.05);
hdeltaPSD = getPlotHandles(2,1,[0.58 0.12 0.18 0.8],0.05);
hAllPlots = [hrawPSD hdeltaPSD];
hTopo     = getPlotHandles(4,1,[0.85 0.12 0.1 0.8],0.05,0.06);

annotation('textbox',[.14 .65 .1 .2], 'String','Occipital','EdgeColor','none','FontWeight','bold','FontSize',annotationFontSize,'Rotation',90,'Color',colorList(1,:));
annotation('textbox',[.14 .18 .1 .2], 'String','Fronto-Temporal','EdgeColor','none','FontWeight','bold','FontSize',annotationFontSize,'Rotation',90,'Color',colorList(2,:));

xlabel(hAllPlots(2,1),'Frequency(Hz)','FontWeight','bold','FontSize',labelFontSize);
ylabel(hAllPlots(2,1),'Power (log_{10}(\muV^2))','FontWeight','bold','FontSize',labelFontSize);

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
        if i==6
            flag;
        end
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

displaySettings.fontSizeLarge = 14;
displaySettings.tickLengthMedium = [0.025 0];

% Cyan and Blue (CMYK)
if customColorMapFag
    %     displaySettings.colorNames(1,:) = [ 0.5000         0    0.5000];
    displaySettings.colorNames(1,:) = [ 0.5000         0    0.5000];
    displaySettings.colorNames(2,:) = [ 0.2539    0.4102    0.8789];
else
    % RGB Color scheme
    displaySettings.colorNames(1,:) = [ 1 0 0];
    displaySettings.colorNames(2,:) = [ 0 1 0];
end

titleStr{1} = 'Meditators';
titleStr{2} = 'Controls';

freqLims = axisRangeList{1};
yLimsPSD = axisRangeList{2};
cLimsTopo = axisRangeList{3};
ylimDeltaPower = axisRangeList{4};

% loading Montage for the topoplot
capType = 'actiCap64_UOL';
gridType = 'EEG';
x = load([capType 'Labels.mat']); montageLabels = x.montageLabels(:,2);
x = load([capType '.mat']); montageChanlocs = x.chanlocs;

for g=1:length(groupPos)
    for i=1:numProtocols

        %%%%%%%%%%%%%% Add M1(BL-combined line) or G2 (st) for comparision %%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%% to the M2-Bl (1st Panel) and  M2 St (Second Panel) (st) for comparision %%%%%%%%%%%%%%%%%%%
        if i>3
            switch i
                case 4 % M1 combined
                    p=4; % EO1
                    hPSD = hAllPlots(g,1);
                    showOnlyLineFlag = 1;
                    lineStyle = '--';
                    displayAndcompareData(hPSD,logPSDData{g,p},freqVals,displaySettings,yLimsPSD,0,useMedianFlag,~pairedDataFlag,showOnlyLineFlag,lineStyle);
                case 5 % G2(st)
                    p=5;
                    hPSD = hAllPlots(g,2);
                    showOnlyLineFlag = 1;
                    lineStyle = '--';
                    displayAndcompareData(hPSD,logPSDData{g,p},freqVals,displaySettings,yLimsPSD,0,useMedianFlag,~pairedDataFlag,showOnlyLineFlag,lineStyle);
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        else
            hPSD = hAllPlots(g,i);
            xticklabels(hPSD,'auto');
            yticklabels(hPSD,'auto');
            hPos =  get(hPSD,'Position');
            hold(hPSD,'on');

            if i==1
                makeShadedRegion(hPSD,freqRangeList{3},[-2 2],[rgb('Cyan')],0.1);
            else
                makeShadedRegion(hPSD,freqRangeList{2},[-2.49 2],[rgb('MistyRose')],1);
            end

            if i==3
                displayAndcompareData(hPSD,logPSDData{g,i},freqVals,displaySettings,ylimDeltaPower,1,useMedianFlag,~pairedDataFlag);
            else
                displayAndcompareData(hPSD,logPSDData{g,i},freqVals,displaySettings,yLimsPSD,1,useMedianFlag,~pairedDataFlag);
            end

            xlim(hPSD,freqLims);
            set(hPSD,'FontSize',14);

            if ~strcmp(refChoices{i},'none')
                line([0 freqVals(end)],[0 0],'color','k','parent',hPSD);
            end

            if i==3
                yticks(hPSD,yLimsPSD(1):1:2);
            else
                yticks(hPSD,yLimsPSD(1):1:yLimsPSD(end));
            end
            

            if showLegend
                if g==2 && i==1
                    legend('','Meditators','','Controls','FontWeight','bold','FontSize',12);
                    legend('boxoff')
                    text(75,1.2,'p<0.05','Color','c','FontSize',fontsize+3,'FontWeight','bold');
                    text(75,0.8,'p<0.01','Color','k','FontSize',fontsize+3,'FontWeight','bold');
                end
            end



        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%% Plot topoplot %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
iList=[3 6];
for i=iList
    if plotTopoFlag
        if i==6
            axesTopolot = 3;
        else
            axesTopolot = 1;
        end
        for s=1:2 %  meditators  and control
            axes(hTopo(axesTopolot));
            title(groupNames{s},'FontWeight','bold','FontSize',titleFontSize,'Color',displaySettings.colorNames(s,:));
            data = logTopoData{i,1}{s};                                                                                                                                                   data = logTopoData{i}{s};
            topoplot(data,montageChanlocs,'electrodes','on','maplimits',cLimsTopo,'plotrad',0.6,'headrad',0.6);

            if i==6 && s==2
                ach=colorbar;
                ach.Location='southoutside';
                ach.Position =  [ach.Position(1)-0.02 ach.Position(2)-0.08 ach.Position(3)+0.04 ach.Position(4)];
                ach.Label.String = 'Change in power (dB)';
                ach.Label.FontWeight = "bold";
                ach.Label.FontSize = 14;
                ach.Label.Color = [0 0 0];
                ach.FontSize = 16;
            end

            %                         showElecIDs = 1:64; % show all electrodes
            %                         topoplot_murty([],montageChanlocs,'electrodes','on','style','blank','drawaxis','off','nosedir','+X','emarkercolors',x,'plotchans',showElecIDs,'plotrad',0.65,'headrad',0.6,'emarker',{'.',[0 0 0],8,1},'plotrad',0.6,'headrad',0.6);
            axesTopolot=axesTopolot+1;
        end

    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%% Plot Violin PLots %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if displayInsetFlag
    for g=1:length(groupPos)
        for i=1:3
            hPSD = hAllPlots(g,i);
            hPos =  get(hPSD,'Position');
            hInset = axes('position', [hPos(1)+0.120 hPos(2)+0.26  0.0563    0.1114]);
            displaySettings.plotAxes = hInset;
            if ~useMedianFlag
                displaySettings.parametricTest = 1;
            else
                displaySettings.parametricTest = 0;
            end

            if g==2 &&  i==1
                displaySettings.showYTicks=1;
                displaySettings.showXTicks=1;
                ylabel(hInset,'Power','FontSize',12);
            end

            %             displaySettings.setYLim=[-1 2.3];
            displaySettings.commonYLim = 1;
            displaySettings.xPositionText =0.8;
            displaySettings.yPositionLine=0.05;
            if i==3
                displaySettings.commonYLim = 1;
                
                if g==2
                    displaySettings.setYLim=[-1 2];
                     ax=displayViolinPlot(logPower{g,i},[{displaySettings.colorNames(1,:)} {displaySettings.colorNames(2,:)}],1,1,1,pairedDataFlag,displaySettings);
                     yticks(ax,-1:1:2);
                else
                    displaySettings.setYLim=[-1.5 3.5];
                    ax=displayViolinPlot(logPower{g,i},[{displaySettings.colorNames(1,:)} {displaySettings.colorNames(2,:)}],1,1,1,pairedDataFlag,displaySettings);
                    yticks(ax,-1:2:3);
                end
               
            else
                if g==2
                    displaySettings.setYLim=[-0.3 1.8];
                else % g==1
                    displaySettings.yPositionLine=-0.08;
                    displaySettings.setYLim=[-0.3 1.2];
                end
                ax=displayViolinPlot(logPower{g,i},[{displaySettings.colorNames(1,:)} {displaySettings.colorNames(2,:)}],1,1,1,pairedDataFlag,displaySettings);
            end

        end
    end
end

%%%%%%%%%%%%%%%%%% Plot Violin PLots End %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%% Label plot  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
numRowPSD=2;
numColumnPSD =3;
titlePSDArrays = {'M2 (Spontaneous)','M2 (Stimulus)','Change in Power'};

for i=1:numRowPSD
    for j=1:numColumnPSD
        if j==1 % first column
            ylabel(hAllPlots(i,j),'Power (log_{10}(\muV^2))','FontWeight','bold','FontSize',labelFontSize);
        elseif j==3
            ylabel(hAllPlots(i,j),'Change in Power (dB)','FontWeight','bold','FontSize',labelFontSize);
        end
        if i==2
            xlabel(hAllPlots(i,j),'Frequency(Hz)','FontWeight','bold','FontSize',labelFontSize);
        end
        if i==1  % first row
            xticklabels(hAllPlots(i,j),[]);
            title(hAllPlots(i,j),titlePSDArrays{j},'FontWeight','bold','FontSize',titleFontSize);
        end
        if j==2
            yticklabels(hAllPlots(i,j),[]);
        end
    end
end
%%%%%%%%%%%%%%%%%% Label plot end  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

annotation(gcf,'textbox',[0.1725    0.8827    0.0738    0.0381],'Color',[0.768627450980392 0.0862745098039216 0.941176470588235],...
    'String',{'Meditators'},...
    'LineStyle','none',...
    'FontWeight','bold',...
    'FontSize',14,...
    'FitBoxToText','off');

annotation(gcf,'textbox',[   0.1733    0.8486    0.0986    0.0394],'Color',[0.250980392156863 0.411764705882353 0.87843137254902],...
    'String','Controls',...
    'LineStyle','none',...
    'FontWeight','bold',...
    'FontSize',14,...
    'FitBoxToText','off');
annotation(gcf,'textbox',[    0.1620    0.8158    0.0986    0.0394],'Color',[0.501960784313725 0 0.501960784313725],...
    'String','-- Med (M1)',...
    'LineStyle','none',...
    'FontWeight','bold',...
    'FontSize',14,...
    'FitBoxToText','off');

annotation(gcf,'textbox',[  0.1606    0.7844    0.0975    0.0381],'Color',[0 0 1], ...
    'String','-- Con (M1)',...
    'LineStyle','none',...
    'FontWeight','bold',...
    'FontSize',14,...
    'FitBoxToText','off');


%%%%%%%%%%%%%%%%%%%%%%%%%%%For 2nd plot
annotation(gcf,'textbox',[ 0.3712    0.8890    0.0738    0.0381],'Color',[0.768627450980392 0.0862745098039216 0.941176470588235],...
    'String',{'Meditators'},...
    'LineStyle','none',...
    'FontWeight','bold',...
    'FontSize',14,...
    'FitBoxToText','off');

annotation(gcf,'textbox',[   0.3713    0.8575    0.0737    0.0381],'Color',[0.250980392156863 0.411764705882353 0.87843137254902],...
    'String','Controls',...
    'LineStyle','none',...
    'FontWeight','bold',...
    'FontSize',14,...
    'FitBoxToText','off');
annotation(gcf,'textbox',[    0.3595    0.8184    0.1124    0.0394],'Color',[0.501960784313725 0 0.501960784313725],...
    'String','-- Med (G2-st)',...
    'LineStyle','none',...
    'FontWeight','bold',...
    'FontSize',14,...
    'FitBoxToText','off');

annotation(gcf,'textbox',[   0.3594    0.7856    0.0975    0.0381],'Color',[0 0 1], ...
    'String','-- Con G2-st)',...
    'LineStyle','none',...
    'FontWeight','bold',...
    'FontSize',14,...
    'FitBoxToText','off');



%---------------------------------------------------
annotation(gcf,'textbox',[ 0.9575    0.5965    0.2669    0.3342],'String',{'Stim-Induced','       (M2)'}','Rotation',90,'FontWeight','bold','FontSize',annotationFontSize,'FitBoxToText','off',...
    'EdgeColor','none');

% Create textbox
annotation(gcf,'textbox',[0.9581    0.1866    0.2669    0.3342],'String',{'Spontaneous','    (M2-G2)'},'Rotation',90,'FontWeight','bold','FontSize',annotationFontSize,'FitBoxToText','off',...
    'EdgeColor','none');


%---------------------------------------------------

% if customColorMapFag
%     mycolormap = customcolormap([0 .25 .5 .75 1], {'#9d0142','#f66e45','#ffffbb','#65c0ae','#5e4f9f'});
%     colormap(mycolormap);
% end

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

finalPlotsSaveFolder ='D:\Projects\ProjectDhyaan\BK1\ProjectDhyaanBK1Programs\powerProjectCodes\savedFigures';
if saveFlag
    figure1.Color = [1 1 1];
    savefig(figure1,fullfile(finalPlotsSaveFolder,'MeditationFigure4.fig'));
    print(figure1,fullfile(finalPlotsSaveFolder,'MeditationFigure4'),'-dsvg','-r600');
    print(figure1,fullfile(finalPlotsSaveFolder,'MeditationFigure4'),'-dtiff','-r600');
end


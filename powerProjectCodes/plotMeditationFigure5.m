% Meditation Figure 2
% Shows spontaneous gamma for EO1(combined), EC1(combined) and G1(Baseline)
% ---------------------------------------------------------------------------------------
% clf
clear

figure1 = figure('WindowState','maximized','Color',[1 1 1]);
colormap(jet);
displayInsetFlag = 1;

fontsize = 12;
comparisonStr = 'paired';
customColorMapFag =1;
showLegend = 0;
colormap jet

protocolNames  = [{'M2'}  {'M2'}  {'M2'} {'M1'} {'G2'}];
refChoices     = [{'none'} {'none'} {'M2'}  {'none'} {'none'}] ;
analysisChoice = {'bl'      ,'st',   'st','combined','bl'};

groupNames = {'Meditators','Controls'};
colorList  = [rgb('RoyalBlue');rgb('DarkCyan')];

plotTopoFlag = 1;

badEyeCondition = 'ep';
badTrialVersion = 'v8';
badElectrodeRejectionFlag = 1;

stRange = [0.25 1.25]; % hard coded for now

freqRangeList{1} = [8 13];  % alpha
freqRangeList{2} = [20 40]; % modified slow-Gamma range
freqRangeList{3} = [41 65]; % modified fast-Gamma range

axisRangeList{1} = [5 80];    axisRangeName{1} = 'Freq Lims (Hz)';
axisRangeList{2} = [-2.5 3]; axisRangeName{2} = 'YLims';
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

hrawPSD = getPlotHandles(2,2,[0.14 0.12 0.36 0.8],0.02,0.05);
hdeltaPSD = getPlotHandles(2,1,[0.60 0.12 0.18 0.8],0.05);
hAllPlots = [hrawPSD hdeltaPSD];
hTopo     = getPlotHandles(4,1,[0.85 0.12 0.1 0.8],0.05,0.06);

annotation('textbox',[.14 .65 .1 .2], 'String','Occipital','EdgeColor','none','FontWeight','bold','FontSize',20,'Rotation',90);
annotation('textbox',[.14 .18 .1 .2], 'String','Fronto-Central','EdgeColor','none','FontWeight','bold','FontSize',20,'Rotation',90);

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
            rectangle('Position',[24,-2.4,16,5],'FaceColor',[  0.85    1.0000    1.0000],'EdgeColor','none','LineWidth',0.001,'Parent',hPSD);

            displayAndcompareData(hPSD,logPSDData{g,i},freqVals,displaySettings,yLimsPSD,1,useMedianFlag,~pairedDataFlag);
            xlim(hPSD,freqLims);

            if ~strcmp(refChoices{i},'none')
                line([0 freqVals(end)],[0 0],'color','k','parent',hPSD);
            end

            yticks(hPSD,yLimsPSD(1):1:yLimsPSD(end));

            if showLegend
                if g==2 && i==1
                    legend('','Meditators','','Controls','FontWeight','bold','FontSize',12);
                    legend('boxoff')
                    text(75,1.2,'p<0.05','Color','c','FontSize',fontsize+3,'FontWeight','bold');
                    text(75,0.8,'p<0.01','Color','k','FontSize',fontsize+3,'FontWeight','bold');
                end
            end


            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            %%%%%%%%%%%%%%%%%% Plot topoplot %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if i==1 || i==3
                if plotTopoFlag
                    if i==1
                        axesTopolot = 1;
                    else
                        axesTopolot = 3;
                    end
                    for s=1:2 %  meditators  and control
                        axes(hTopo(axesTopolot));
                        title(groupNames{s});
                        data = logTopoData{i,1}{s};                                                                                                                                                   data = logTopoData{i}{s};
                        topoplot(data,montageChanlocs,'electrodes','on','maplimits',cLimsTopo,'plotrad',0.6,'headrad',0.6);
                        if i==2 && s==1
                            ach=colorbar;
                            ach.Location='southoutside';
                            ach.Position =  [ach.Position(1) ach.Position(2)-0.05 ach.Position(3) ach.Position(4)];
                            ach.Label.String = '\Delta Power (dB)';
                        end

                        %                         showElecIDs = 1:64; % show all electrodes
                        %                         topoplot_murty([],montageChanlocs,'electrodes','on','style','blank','drawaxis','off','nosedir','+X','emarkercolors',x,'plotchans',showElecIDs,'plotrad',0.65,'headrad',0.6,'emarker',{'.',[0 0 0],8,1},'plotrad',0.6,'headrad',0.6);
                        axesTopolot=axesTopolot+1;
                    end

                end
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        end
    end
end

%%%%%%%%%%%%%%%%%% Plot Violin PLots %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if displayInsetFlag
    for g=1:length(groupPos)
        for i=1:3
            hPSD = hAllPlots(g,i);
            hPos =  get(hPSD,'Position');
            hInset = axes('position', [hPos(1)+0.119 hPos(2)+0.25  0.0563    0.1114]);
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
            end

            displaySettings.setYLim=[-1 2.3];
            displaySettings.commonYLim = 0;
            displaySettings.xPositionText =0.8;
            displaySettings.yPositionLine=0.05;
            ax=displayViolinPlot(logPower{g,i},[{displaySettings.colorNames(1,:)} {displaySettings.colorNames(2,:)}],1,1,1,pairedDataFlag,displaySettings);
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
            ylabel(hAllPlots(i,j),'Power (log_{10}(\muV^2))','FontWeight','bold','FontSize',15);
        elseif j==3
            ylabel(hAllPlots(i,j),'\DeltaPower (dB)','FontWeight','bold','FontSize',15);
        end
        if i==2
            xlabel(hAllPlots(i,j),'Frequency(Hz)','FontWeight','bold','FontSize',15);
        end
        if i==1  % first row
            xticklabels(hAllPlots(i,j),[]);
            title(hAllPlots(i,j),titlePSDArrays{j},'FontWeight','bold','FontSize',18);
        end
        if j==2
            yticklabels(hAllPlots(i,j),[]);
        end
    end
end
%%%%%%%%%%%%%%%%%% Label plot end  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%---------------------------------------------------
annotation(gcf,'textbox',[0.9310 0.5977 0.0196 0.2509],'String','Spontaneous','Rotation',90,'FontWeight','bold','FontSize',20,'FitBoxToText','off',...
    'EdgeColor','none');

% Create textbox
annotation(gcf,'textbox',[0.9297 0.2068 0.0196 0.2509],'String','Stim-Induced','Rotation',90,'FontWeight','bold','FontSize',20,'FitBoxToText','off',...
    'EdgeColor','none');


%---------------------------------------------------

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

% custom colomap
% if customColorMapFag
%     % red-white-blue
%         mycolormap = customcolormap(linspace(0,1,11), {'#68011d','#b5172f','#d75f4e','#f7a580','#fedbc9','#f5f9f3','#d5e2f0','#93c5dc','#4295c1','#2265ad','#062e61'});
%         colormap(mycolormap);
%
%     mycolormap = customcolormap([0 .25 .5 .75 1], {'#f645db','#f66e45','#ffffbb','#65c0ae','#5e4f9f'});
%     % colorbar('southoutside');
%     colormap(mycolormap);
% end
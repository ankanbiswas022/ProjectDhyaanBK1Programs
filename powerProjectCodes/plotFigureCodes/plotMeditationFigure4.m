% Meditation Figure 2
% Shows spontaneous gamma for EO1(combined), EC1(combined) and G1(Baseline)
%% ------------Inital---------------------------------------------------------------------------
clf
clear
saveFlag=1;
displayInsetFlag = 1;
customColorMapFag = 1;
getOccipitalFlag =0;
fontSize = 16;

% figH = figure('units','normalized','outerposition',[0 0 1 1]);
figH = figure('WindowState','maximized','Color',[1 1 1]);

colormap jet
fontsize = 14;
comparisonStr = 'paired';
colorList = [rgb('Aqua');rgb('Orange')];

protocolNames  = [ {'G1'}  {'G2'}   {'G1'}    {'G2'}   {'G1'}  {'G2'}   {'EO1'}];
refChoices     = [ {'G1'}  {'G2'}   {'none'} {'none'} {'none'} {'none'} {'none'}] ;
analysisChoice = {  'st',   'st',     'bl',    'bl',    'st',    'st',  'combined'};

titlePSDArrays = {'Spontaneous','Stimulus','Change in Power'};

badEyeCondition = 'ep';
badTrialVersion = 'v8';
badElectrodeRejectionFlag = 1;
baselineRange = [-1 0];

stRange = [0.25 1.25]; % hard coded for now

freqRangeList{1} = [8 13];  % alpha
freqRangeList{2} = [24 34]; % slow-Gamma range
freqRangeList{3} = [30 80]; % spontenous Gamma range

axisRangeList{1} = [5 80]; axisRangeName{1} = 'Freq Lims (Hz)';
axisRangeList{2} = [-2 1]; axisRangeName{2} = 'YLims';
axisRangeList{3} = [-2 2]; axisRangeName{3} = 'cLims (topo)';

useMedianFlag = 0;
cutoffList = [3 30]; % elec and trial cuttoff

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

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%% Make Plots %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
hAllPlots = [];

% for the 3 panels: a, b, c
% hPSDAll   = getPlotHandles(2,1,[0.08 0.13 0.2 0.8],0.05,0.05);
% hTopo     = getPlotHandles(2,2,[0.32 0.13 0.25 0.8],0.01,0.05);
% hTF       = getPlotHandles(2,2,[0.63 0.13 0.3 0.8],0.01,0.05);

hRawPSD   = getPlotHandles(2,2,[0.09 0.13 0.28 0.8],0.03,0.07);
hDeltaPSD = getPlotHandles(2,1,[0.42 0.13 0.14 0.8],0.05,0.07);
hTopo0    = getPlotHandles(4,1,[0.582 0.16 0.11 0.767],0.03,0.07);
hTF       = getPlotHandles(2,2,[0.73 0.13 0.2 0.8], 0.02,0.07);

hTopo= reshape(hTopo0,[2 2])';
hAllPlots = [hDeltaPSD hRawPSD];

% Label the plots

annotation('textbox',[.106 .7 .1 .2], 'String','G1','EdgeColor','none','FontWeight','bold','FontSize',20,'Rotation',90);
annotation('textbox',[.106 .24 .1 .2], 'String','G2','EdgeColor','none','FontWeight','bold','FontSize',20,'Rotation',90);



%% %%%%%%%%%%%%%%%%%%%%%%%%%%%% Get Data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
groupPos = 1; % Occipital
freqPos  = 2; % Slow gamma

numGroups = length(groupPos);
numProtocols = length(protocolNames);
logPSDDataTMP = cell(numGroups,numProtocols);
logPowerTMP = cell(numGroups,numProtocols);
logTopoDataTMP = cell(numGroups,numProtocols);
goodSubjectNameListsTMP = cell(numGroups,numProtocols);


if numProtocols==1
    [psdDataToReturn,powerDataToReturn,goodSubjectNameListsToReturn,topoplotDataToReturn,freqVals,montageChanlocs] = displayPowerDataAllSubjects(subjectNameLists,protocolNames{1},analysisChoice,refChoices{1},badEyeCondition,badTrialVersion,badElectrodeRejectionFlag,stRange,freqRangeList,axisRangeList,cutoffList,useMedianFlag,hAllPlots,pairedDataFlag,0);
    logPSDData = psdDataToReturn{groupPos};
    logPower = powerDataToReturn{groupPos,freqPos};

else % either combine or just get the data
    % Combine
    for i=1:numProtocols
        if i==3|| i==4
            freqPos=3; % broadband gamma
        else
            freqPos=2; % slowGamma
        end
        [psdDataTMP,powerDataTMP,goodSubjectNameListsTMP{i},topoplotDataTMP,freqVals] = displayPowerDataAllSubjects(subjectNameLists,protocolNames{i},analysisChoice{i},refChoices{i},badEyeCondition,badTrialVersion,badElectrodeRejectionFlag,stRange,freqRangeList,axisRangeList,cutoffList,useMedianFlag,hAllPlots,pairedDataFlag,0,getOccipitalFlag);
        for g=1:numGroups
            logPSDDataTMP{g,i}   = psdDataTMP{g};
            logPowerTMP{g,i}     = powerDataTMP{g,freqPos};
            logTopoDataTMP{g,i}  = topoplotDataTMP(:,freqPos); % for topoplot there is no groupwise data
        end
    end
    logPSDData  = logPSDDataTMP;
    logPower    = logPowerTMP;
    logTopoData = logTopoDataTMP;
end


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Plot Psd %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

displaySettings.fontSizeLarge    = 14;
displaySettings.tickLengthMedium = [0.025 0];

% Cyan and Blue (CMYK)
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
    displaySettings.colorNames(2,:) = [ 0 1 0];
    displaySettings.colorNames(3,:) = rgb('Brown');
    displaySettings.colorNames(4,:) = rgb('DarkGreen');

    displaySettings.colorNames(5,:) = [ 1 0 0];
    displaySettings.colorNames(6,:) = [ 0 1 0];
end

titleStr{1} = 'Meditators';
titleStr{2} = 'Controls';

freqLims = axisRangeList{1};
yLimsPSD = axisRangeList{2};
cLimsTopo = axisRangeList{3};

% loading Montage for the topoplot
capType = 'actiCap64_UOL';
x = load([capType 'Labels.mat']); montageLabels = x.montageLabels(:,2);
x = load([capType '.mat']); montageChanlocs = x.chanlocs;


rawPlotIndex = 1;
for g=1:length(groupPos)
    for i=1:numProtocols
        if i>2
            if i== 7 % M1 combined
                p = 7; % EO1
                for j=1:2
                    hPSD = hRawPSD(j);
                    showOnlyLineFlag = 1;
                    lineStyle = '--';
                    displaySettings.colorNames(1,:)  = displaySettings.colorNames(3,:);
                    displaySettings.colorNames(2,:)  = displaySettings.colorNames(4,:);
                    displayAndcompareData(hPSD,logPSDData{g,p},freqVals,displaySettings,yLimsPSD,0,useMedianFlag,~pairedDataFlag,showOnlyLineFlag,lineStyle);
                end
                displaySettings.colorNames(1,:)  =displaySettings.colorNames(5,:);
                displaySettings.colorNames(2,:)  = displaySettings.colorNames(6,:);

            else
                % for p=1:4
                hPSD = hRawPSD(rawPlotIndex);
                displayAndcompareData(hPSD,logPSDData{g,i},freqVals,displaySettings,yLimsPSD,1,useMedianFlag,~pairedDataFlag);
                xlim(hPSD,freqLims);
                % end
            end
             yticks(hPSD,yLimsPSD(1):1:yLimsPSD0(end));
            rawPlotIndex= rawPlotIndex+1;
        else
            hPSD = hDeltaPSD(i,g);
            yLimsPSD0 = [-2.5 2.5];
            displayAndcompareData(hPSD,logPSDData{g,i},freqVals,displaySettings,yLimsPSD0,1,useMedianFlag,~pairedDataFlag);
            xlim(hPSD,freqLims);

            % Add lines in PSD plots
            %             for k=1:2
            %                 line([freqRangeList{freqPos}(k) freqRangeList{freqPos}(k)],yLimsPSD0,'LineStyle','--','LineWidth',2,'color','k','parent',hPSD);
            %             end

            if ~strcmp(refChoices{1},'none')
                line([0 freqVals(end)],[0 0],'color','k','parent',hPSD);
            end

            yticks(hPSD,yLimsPSD(1):1:yLimsPSD0(end));

            % if g==1 && i==2
            %     %             legend('','Meditators','','Controls','FontWeight','bold','FontSize',14);
            %     %             legend('boxoff')
            %     text(60,1.7-0.5,'Meditators(29)','FontSize',fontsize+3,'FontWeight','bold','Color','red');
            %     text(60,1.7,'Controls(29)','FontSize',fontsize+3,'FontWeight','bold','Color','green');
            %     text(42+5,-1.6,'p<0.05','Color','k','FontSize',fontsize+3,'FontWeight','bold');
            %     text(65+5,-1.6,'p<0.01','Color','c','FontSize',fontsize+3,'FontWeight','bold');
            % end


            %%%%%%%%%%%%%%%%%%%%%%%%%%%% Plot topoplots %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            for s=1:2 %  meditators  and control
                axes(hTopo(i,s));
                data = logTopoData{i}{s};
                topoplot(data,montageChanlocs,'electrodes','on','maplimits',cLimsTopo,'plotrad',0.6,'headrad',0.6);
                if i==2 && s==2
                    ach=colorbar;
                    ach.Location='southoutside';
                    ach.Position = [0.6087 0.1248 0.0525 0.0160];
                    ach.Label.String = 'Change in power (dB)';
                    ach.Label.FontWeight = "bold";
                    ach.Label.FontSize = 16;
                    ach.Label.Color = [0 0 0];
                    ach.FontSize = 14;                  
                end
            end
        end

    end

end

title(hTF(1,1),'Meditators');
title(hTF(1,2),'Controls');

%% %%%%%%%%%%%%%%%% Plot Violin PLots %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if displayInsetFlag
    for g=1:length(groupPos)
        for i=1:6
            hPSD = hAllPlots(i);
            set(hPSD,'FontSize',14);
            hPos =  get(hPSD,'Position');
            if i>2
                displaySettings.setYLim=[-0.5 1.35];
                if i==3 || i==4
                    if i==3
                        xticklabels(hPSD,[]);
                        title(hAllPlots(i),titlePSDArrays{1},'FontWeight','bold','FontSize',18);
                    elseif i==4
                        xlabel(hPSD,'Frequency (Hz)','FontSize',16);
                    end
                    makeShadedRegion(hPSD,freqRangeList{3},[-2 1],[rgb('Cyan')],0.1);
                    ylabel(hPSD,'Power (log_{10}(\muV^2))','FontSize',16);
                elseif i==5 || i==6
                    yticklabels(hPSD,[]);
                    if i==5
                        xticklabels(hPSD,[]);                         
                        title(hAllPlots(i),titlePSDArrays{2},'FontWeight','bold','FontSize',18);
                    elseif i==6
                        xlabel(hPSD,'Frequency (Hz)','FontSize',16);
                    end
                    makeShadedRegion(hPSD,freqRangeList{2},[-2 1],[rgb('MistyRose')],1);
                end
                if i==3 || i==4
                    hInset = axes('position', [hPos(1)+0.0413 hPos(2)+0.238  0.0563  0.1114]);
                else
                    hInset = axes('position', [hPos(1)+0.07 hPos(2)+0.238  0.0563  0.1114]);
                end
               
            else
                displaySettings.setYLim=[-1 4.6];
                ylim(hPSD,[-2.5 2.5]);
                makeShadedRegion(hPSD,freqRangeList{2},[-2.5 2.5],[rgb('MistyRose')],1);
                ylabel(hPSD,'Change in power (dB)','FontSize',16,'FontWeight','bold');

                if i==1
                    xticklabels(hPSD,[]);
                    title(hAllPlots(i),titlePSDArrays{3},'FontWeight','bold','FontSize',18);
                elseif i==2
                    xlabel(hPSD,'Frequency (Hz)','FontSize',16,'FontWeight','bold');
                end
                hInset = axes('position', [hPos(1)+0.0781 hPos(2)+0.0416  0.0563  0.1114]);
            end

            displaySettings.plotAxes = hInset;
            if ~useMedianFlag
                displaySettings.parametricTest = 1;
            else
                displaySettings.parametricTest = 0;
            end

            displaySettings.showYTicks=1;
            displaySettings.showXTicks=1;
            ylabel(hInset,'Power','FontSize',14);

            displaySettings.commonYLim = 0;
            displaySettings.xPositionText =0.8;
            displaySettings.yPositionLine=0.05;

            ax=displayViolinPlot(logPower{g,i},[{displaySettings.colorNames(1,:)} {displaySettings.colorNames(2,:)}],1,1,1,pairedDataFlag,displaySettings);
        end
    end
end

%%%%%%%%%%%%%%%%%% Plot Violin PLots end %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% %%%%%%%%%%%%%%%%%%%%%%%%%% Plot TF Plots %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

freqRange  = freqRangeList{2}; % Show this range
timeLims   = [-0.5 1];
freqLimsTF = [0 80];
cLims      = axisRangeList{3};
load("meanTFDataProtocolWise.mat",'meanTFDataProtocolWise','tmpData');
diffTF = 1;
for p=1:2 %protocol
    for t=1:2 %med/control
        axes(hTF(p,t));
        tfData = meanTFDataProtocolWise{t,p};

        logP = log10(tfData);
        baselinePower = mean(logP(tmpData.timeValsTF>=baselineRange(1) & tmpData.timeValsTF<=baselineRange(2),:));
        if diffTF
            pcolor(tmpData.timeValsTF,tmpData.freqValsTF,10*(logP'- repmat(baselinePower',1,length(tmpData.timeValsTF))));
        else
            pcolor(tmpData.timeValsTF,tmpData.freqValsTF,logP');
        end

        % Add labels
        shading('interp');
        yline([freqRange(1) freqRange(2)],'--k','LineWidth',2);
        %  line(timeLims,[freqRange(1) freqRange(1)],'color','k','LineStyle','--','LineWidth',2);
        %  line(timeLims,[freqRange(2) freqRange(2)],'color','k','LineStyle','--','LineWidth',2.5);

        axis(hTF(p,t),[timeLims freqLimsTF]);
        clim(hTF(p,t),cLims);

        % xticks and Yticks
        if p==2
            xlabel(hTF(p,t),'Time(s)','FontSize',16,'FontWeight','bold');
        else
            set(hTF(p,t),'Xticklabel',[],'FontSize',14);
        end

        if t==1
            ylabel(hTF(p,t),'Frequency (Hz)','FontSize',16,'FontWeight','bold');
        else
            set(hTF(p,t),'Yticklabel',[],'FontSize',14);
        end

        if p==2 && t==1
            set(hTF(p,t),'FontSize',14);
        end

    end
end

axes(hTF(2,2));
hc = colorbar('Position', [0.94 0.1301 0.0109 0.36]);
hc.FontSize         = 14;
hc.Label.FontSize   = 16;
hc.Label.FontWeight = 'bold';
hc.Label.String = ['Change in power' ' (dB)'];

%%%%%%%%%%%%%%%%%%%%%%%%%%%% Plot TF Plots(end) %%%%%%%%%%%%%%%%%%%%%%%%






%% %%% Labelling %%%%%%

title(hTopo(1,1),'Meditators','FontWeight','bold','FontSize',18,'Color',displaySettings.colorNames(1,:));
title(hTopo(1,2),'Controls','FontWeight','bold','FontSize',18,'Color',displaySettings.colorNames(2,:));

title(hTopo(2,1),'Meditators','FontWeight','bold','FontSize',18,'Color',displaySettings.colorNames(1,:));
title(hTopo(2,2),'Controls','FontWeight','bold','FontSize',18,'Color',displaySettings.colorNames(2,:));

title(hTF(1,1),'Meditators','FontWeight','bold','FontSize',18,'Color',displaySettings.colorNames(1,:));
title(hTF(1,2),'Controls','FontWeight','bold','FontSize',18,'Color',displaySettings.colorNames(2,:));

% if customColorMapFag
%     mycolormap = customcolormap([0 .25 .5 .75 1], {'#9d0142','#f66e45','#ffffbb','#65c0ae','#5e4f9f'});
%     colormap(mycolormap);
% end


%% % Figure post-format %%%%%%%%%%%
%    And savings

annotation(gcf,'textbox',[0.1806    0.7377    0.0738    0.0381],'Color',[0.768627450980392 0.0862745098039216 0.941176470588235],...
    'String',{'Meditators'},...
    'LineStyle','none',...
    'FontWeight','bold',...
    'FontSize',14,...
    'FitBoxToText','off');

annotation(gcf,'textbox',[ 0.1800    0.7112    0.0737    0.0381],'Color',[0.250980392156863 0.411764705882353 0.87843137254902],...
    'String','Controls',...
    'LineStyle','none',...
    'FontWeight','bold',...
    'FontSize',14,...
    'FitBoxToText','off');
annotation(gcf,'textbox',[ 0.1688    0.6822    0.0812    0.0394],'Color',[0.501960784313725 0 0.501960784313725],...
    'String','-- Med (EO1)',...
    'LineStyle','none',...
    'FontWeight','bold',...
    'FontSize',14,...
    'FitBoxToText','off');

annotation(gcf,'textbox',[  0.1681    0.6545    0.0975    0.0381],'Color',[0 0 1], ...
    'String','-- Con (EO1)',...
    'LineStyle','none',...
    'FontWeight','bold',...
    'FontSize',14,...
    'FitBoxToText','off');



%%%%%%%%%%%%%% Occipital 
annotation(gcf,'textbox',[0.03125 0.455494326511818 0.0840624976810069 0.0517023947996571],'String',{'Occipital'},'Rotation',90,'LineStyle','none',...
    'FontWeight','bold',...
    'FontSize',22,...
    'FitBoxToText','off' ...
    ,'Color',colorList(1,:));

% common change across figure!
set(gcf,'color','w');
set(findobj(gcf,'type','axes'),'box','off'...
    ,'FontWeight','Bold'...
    ,'TickDir','out'...
    ,'TickLength',[0.02 0.02]...
    ,'linewidth',1.3...
    ,'xcolor',[0 0 0]...
    ,'ycolor',[0 0 0]...
    );

% figure captions
annotation(figH,'textbox',[0.0581  0.9520  0.0738  0.0381],'String','A','LineStyle','none','FontWeight','bold','FontSize',fontSize+4,...
    'FitBoxToText','off');

annotation(figH,'textbox',[0.4981  0.9520  0.0738  0.0381],'String','B','LineStyle','none','FontWeight','bold','FontSize',fontSize+4,...
    'FitBoxToText','off');

finalPlotsSaveFolder ='D:\Projects\ProjectDhyaan\BK1\ProjectDhyaanBK1Programs\powerProjectCodes\savedFigures';
if saveFlag
    figH.Color = [1 1 1];
    savefig(figH,fullfile(finalPlotsSaveFolder,'MeditationFigure3.fig'));
    print(figH,fullfile(finalPlotsSaveFolder,'MeditationFigure3'),'-dsvg','-r300');
    print(figH,fullfile(finalPlotsSaveFolder,'MeditationFigure3'),'-dtiff','-r300');
    print(mainFigure4,fullfile(finalPlotsSaveFolder,'MeditationFigure3'),'-dpdf','-r300');
    print(mainFigure4,fullfile(finalPlotsSaveFolder,'MeditationFigure3'),'-dpdf','-bestfit','-r300');
end
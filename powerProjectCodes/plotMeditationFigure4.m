% Meditation Figure 2
% Shows spontaneous gamma for EO1(combined), EC1(combined) and G1(Baseline)
% ---------------------------------------------------------------------------------------
% close all
clear

figure();
% figH= figure('units','normalized','outerposition',[0 0 1 1]);
fontsize = 12;
comparisonStr = 'paired';
% % protocolNames = {'G2'}; refChoices = {'none'};

protocolNames  = [{'G1'}  {'G2'}];
refChoices     = [{'G1'} {'G2'}] ;
analysisChoice = {'st','st',};


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
hAllPlots = [];
hPSDAll   = getPlotHandles(2,1,[0.1 0.1 0.2 0.8],0.05,0.05);
hTopo     = getPlotHandles(2,2,[0.36 0.1 0.2 0.8],0.01,0.05);
hTF       = getPlotHandles(2,2,[0.65 0.1 0.3 0.8],0.01,0.05);

% Label the plots

annotation('textbox',[.105 .65 .1 .2], 'String','G1','EdgeColor','none','FontWeight','bold','FontSize',18,'Rotation',90);
annotation('textbox',[.105 .18 .1 .2], 'String','G2','EdgeColor','none','FontWeight','bold','FontSize',18,'Rotation',90);

xlabel(hPSDAll(2,1),'Frequency(Hz)','FontWeight','bold','FontSize',15);
ylabel(hPSDAll(2,1),'\Delta Power (dB)','FontWeight','bold','FontSize',15);

xlabel(hTF(2,1),'Time(s)','FontWeight','bold','FontSize',15);
ylabel(hTF(2,1),'Frequency(Hz)','FontWeight','bold','FontSize',15);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Get Data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
groupPos = 1; % Occipital
freqPos  = 2; % Slow gamma

numGroups = length(groupPos);
numProtocols = length(protocolNames);
logPSDDataTMP = cell(numGroups,numProtocols);
logPowerTMP = cell(numGroups,numProtocols);
goodSubjectNameListsTMP = cell(numGroups,numProtocols);


if numProtocols==1
    [psdDataToReturn,powerDataToReturn,goodSubjectNameListsToReturn,topoplotDataToReturn,freqVals,montageChanlocs] = displayPowerDataAllSubjects(subjectNameLists,protocolNames{1},analysisChoice,refChoices{1},badEyeCondition,badTrialVersion,badElectrodeRejectionFlag,stRange,freqRangeList,axisRangeList,cutoffList,useMedianFlag,hAllPlots,pairedDataFlag,0);
    logPSDData = psdDataToReturn{groupPos};
    logPower = powerDataToReturn{groupPos,freqPos};

else % either combine or just get the data
    % Combine
    for i=1:numProtocols
        [psdDataTMP,powerDataTMP,goodSubjectNameListsTMP{i},topoplotDataTMP,freqVals] = displayPowerDataAllSubjects(subjectNameLists,protocolNames{i},analysisChoice{i},refChoices{i},badEyeCondition,badTrialVersion,badElectrodeRejectionFlag,stRange,freqRangeList,axisRangeList,cutoffList,useMedianFlag,hAllPlots,pairedDataFlag,0);
        for g=1:numGroups
            logPSDDataTMP{g,i}   = psdDataTMP{g};
            logPowerTMP{g,i}     = powerDataTMP{g,freqPos};
            topoplotDataTMP{g,i} = topoplotDataTMP{g};
        end
    end
    logPSDData  = logPSDDataTMP;
    logPower    = logPowerTMP;
    logTopoData = topoplotDataTMP;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Plot Psd %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

displaySettings.fontSizeLarge    = 10;
displaySettings.tickLengthMedium = [0.025 0];
displaySettings.colorNames(1,:)  = [1 0 0];
displaySettings.colorNames(2,:)  = [0 1 0];
titleStr{1} = 'Meditators';
titleStr{2} = 'Controls';

freqLims = axisRangeList{1};
yLimsPSD = axisRangeList{2};
cLimsTopo = axisRangeList{3};

for g=1:length(groupPos)
    for i=1:numProtocols
        hPSD = hPSDAll(i,g);
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


        %%%%%%%%%%%%%%%%%%%%%%%%%%%% Plot topoplots %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        for s=2:3 %  meditators  and control
            capType = 'actiCap64_UOL';
            x = load([capType 'Labels.mat']); montageLabels = x.montageLabels(:,2);
            x = load([capType '.mat']); montageChanlocs = x.chanlocs;
            axes(hTopo(i,s-1));
            data = topoplotDataTMP{i,s};
            topoplot(data,montageChanlocs,'electrodes','on','maplimits',cLimsTopo,'plotrad',0.6,'headrad',0.6); colorbar;
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

saveFlag=0;
finalPlotsSaveFolder ='D:\Projects\ProjectDhyaan\BK1\ProjectDhyaanBK1Programs\powerProjectCodes\savedFigures';
if saveFlag
    figH.Color = [1 1 1];
    savefig(figH,fullfile(finalPlotsSaveFolder,'MeditationFigure4.fig'));
    print(figH,fullfile(finalPlotsSaveFolder,'MeditationFigure2'),'-dsvg','-r600');
    print(figH,fullfile(finalPlotsSaveFolder,'MeditationFigure2'),'-dtiff','-r600');
end
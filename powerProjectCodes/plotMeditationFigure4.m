% Meditation Figure 2
% Shows spontaneous gamma for EO1(combined), EC1(combined) and G1(Baseline)
% ---------------------------------------------------------------------------------------
close all
clear

figH = figure('units','normalized','outerposition',[0 0 1 1]);
set(figH,'color','w');
colormap jet
fontsize = 12;
comparisonStr = 'paired';

protocolNames  = [{'G1'}  {'G2'}];
refChoices     = [{'G1'} {'G2'}] ;
analysisChoice = {'st','st',};

badEyeCondition = 'ep';
badTrialVersion = 'v8';
badElectrodeRejectionFlag = 1;
baselineRange = [-1 0];

stRange = [0.25 1.25]; % hard coded for now

freqRangeList{1} = [8 13];  % alpha
freqRangeList{2} = [20 34]; % modified slow-Gamma range
freqRangeList{3} = [35 65]; % modified fast-Gamma range

axisRangeList{1} = [0 100];    axisRangeName{1} = 'Freq Lims (Hz)';
axisRangeList{2} = [-2.5 2.5]; axisRangeName{2} = 'YLims';
axisRangeList{3} = [-1.5 1.5]; axisRangeName{3} = 'cLims (topo)';

useMedianFlag = 0;
cutoffList = [3 30];

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
hPSDAll   = getPlotHandles(2,1,[0.08 0.13 0.2 0.8],0.05,0.05);
hTopo     = getPlotHandles(2,2,[0.32 0.13 0.25 0.8],0.01,0.05);
hTF       = getPlotHandles(2,2,[0.63 0.13 0.3 0.8],0.01,0.05);

% Label the plots

annotation('textbox',[.106 .7 .1 .2], 'String','G1','EdgeColor','none','FontWeight','bold','FontSize',18,'Rotation',90);
annotation('textbox',[.106 .24 .1 .2], 'String','G2','EdgeColor','none','FontWeight','bold','FontSize',18,'Rotation',90);

xlabel(hPSDAll(2,1),'Frequency(Hz)','FontWeight','bold','FontSize',15);
ylabel(hPSDAll(2,1),'\Delta Power (dB)','FontWeight','bold','FontSize',15);

xlabel(hTF(2,1),'Time(s)','FontWeight','bold','FontSize',15);
ylabel(hTF(2,1),'Frequency(Hz)','FontWeight','bold','FontSize',15);

title(hTF(1,1),'Meditators');
title(hTF(1,2),'Controls');

title(hTopo(1,1),'Meditators');
title(hTopo(1,2),'Controls');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Get Data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
        [psdDataTMP,powerDataTMP,goodSubjectNameListsTMP{i},topoplotDataTMP,freqVals] = displayPowerDataAllSubjects(subjectNameLists,protocolNames{i},analysisChoice{i},refChoices{i},badEyeCondition,badTrialVersion,badElectrodeRejectionFlag,stRange,freqRangeList,axisRangeList,cutoffList,useMedianFlag,hAllPlots,pairedDataFlag,0);
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

% loading Montage for the topoplot
capType = 'actiCap64_UOL';
x = load([capType 'Labels.mat']); montageLabels = x.montageLabels(:,2);
x = load([capType '.mat']); montageChanlocs = x.chanlocs;

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

        if g==1 && i==2
%             legend('','Meditators','','Controls','FontWeight','bold','FontSize',12);
%             legend('boxoff')
            text(60,1.7-0.5,'Meditators(29)','FontSize',fontsize+3,'FontWeight','bold','Color','red');
            text(60,1.7,'Controls(29)','FontSize',fontsize+3,'FontWeight','bold','Color','green');
            text(42+5,-1.6,'p<0.05','Color','k','FontSize',fontsize+3,'FontWeight','bold');
            text(65+5,-1.6,'p<0.01','Color','c','FontSize',fontsize+3,'FontWeight','bold');
        end


        %%%%%%%%%%%%%%%%%%%%%%%%%%%% Plot topoplots %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        for s=1:2 %  meditators  and control
            axes(hTopo(i,s));
            data = logTopoData{i}{s};
            topoplot(data,montageChanlocs,'electrodes','on','maplimits',cLimsTopo,'plotrad',0.6,'headrad',0.6);
            if i==2 && s==1
                ach=colorbar;
                ach.Location='southoutside';
                ach.Position =  [ach.Position(1) ach.Position(2)-0.05 ach.Position(3) ach.Position(4)];
                ach.Label.String = '\Delta Power (dB)';
            end
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%% Plot TF Plots %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        freqRange = [24 34]; % Show this range
        timeLims = [-0.5 1];
        freqLims = [0 100];
        cLims = [-2 2];
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

                axis(hTF(p,t),[timeLims freqLims]);
                clim(hTF(p,t),cLims);

                % xticks and Yticks
                if p==2 && t==1
                    xlabel(hTF(p,t),'Time(s)');
                else
                    set(hTF(p,t),'Xticklabel',[]);
                end

                if p==2 && t==1
                    ylabel(hTF(p,t),'Frequency (Hz)');

                else
                    set(hTF(p,t),'Yticklabel',[]);
                end


            end
        end
    end

end

title(hTF(1,1),'Meditators');
title(hTF(1,2),'Controls');

axes(hTF(2,2));
hc = colorbar('Position', [0.94 0.1301 0.0109 0.3755]);
hc.FontSize         = 12;
hc.Label.FontSize   = 12;
hc.Label.FontWeight = 'bold';
hc.Label.String = ['\Delta Power' '(dB)'];

% common change across figure!
set(findobj(gcf,'type','axes'),'box','off'...
    ,'FontWeight','Bold'...
    ,'TickDir','out'...
    ,'TickLength',[0.02 0.02]...
    ,'linewidth',1.3...
    ,'xcolor',[0 0 0]...
    ,'ycolor',[0 0 0]...
    );

saveFlag=1;
finalPlotsSaveFolder ='D:\Projects\ProjectDhyaan\BK1\ProjectDhyaanBK1Programs\powerProjectCodes\savedFigures';
if saveFlag
    figH.Color = [1 1 1];
    savefig(figH,fullfile(finalPlotsSaveFolder,'MeditationFigure4.fig'));
    print(figH,fullfile(finalPlotsSaveFolder,'MeditationFigure4'),'-dsvg','-r600');
    print(figH,fullfile(finalPlotsSaveFolder,'MeditationFigure4'),'-dtiff','-r600');
end
%% Working on the code on 5-Apr-23
% changed the order. first all the flags followed by loading the data

%% To Do:-
%-------------------------------------------------------
% add significance within the plot function---
% choose signicance test based on the datType flag
% add appropriate legends
% make the proper alignment for the code

%% ----------------Immedietly-----------------------------
% difference plots with ErrorBar
%   - EO1 substract Individual
%   - EO1 substract common
% combine data for the possible segments

%% data Informations:

function plotMeanPsdDataAcrossSubjectsMeditation(medianFlag,biPolarFlag, ...
    removeIndividualUniqueBadTrials,showDeltaPsdFlag,showSignificanceFlag,showSEMFlag,showRawPsdFlag)
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%% Fixed variables %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~exist('medianFlag','var');                          medianFlag = 0;                          end
if ~exist('biPolarFlag','var');                         biPolarFlag = 0;                       end
if ~exist('removeIndividualUniqueBadTrials','var');     removeIndividualUniqueBadTrials = 0;     end
if ~exist('showSignificanceFlag','var');                showSignificanceFlag = 1;                end
if ~exist('showSEMFlag','var');                         showSEMFlag = 0;                       end
if ~exist('showDeltaPsdFlag','var');                    showDeltaPsdFlag = 0;                    end
if ~exist('showRawPsdFlag','var');                      showRawPsdFlag = 1;                    end


% medianFlag = 0;
% biPolarFlag = 1;
% removeIndividualUniqueBadTrials = 0;
removeDeclaredBadElecs = 1;
% clear
close all
%-----------------------------------------------------------------
gridType = 'EEG';
capType = 'actiCap64_UOL';
groupIDs = [{'C'} {'A'}];
protocolNameList = [{'EO1'}  {'EC1'}  {'G1'}  {'M1a'}  {'M1b'}  {'M1c'} {'G2'}  {'EO2'}  {'EC2'}  {'M2a'} {'M2b'} {'M2c'}];
colorNameGroupsIDs = [{[0 1 0]} {[1 0 0]} {[0 0 1]}];


putAxisLabel = 0;

axisLimAuto = 0;
xLimsRange = [0 100];
yLimsRange = [-2 2];

[~,~,~,electrodeGroupList0,groupNameList0,highPriorityElectrodeNums] = electrodePositionOnGrid(1,gridType,[],capType);
electrodeGroupList0{6} = highPriorityElectrodeNums;
groupNameList0{6} = 'highPriority';


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%% Load data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

loadFilepath = getFolderName(biPolarFlag,removeIndividualUniqueBadTrials,removeDeclaredBadElecs);

if isfile(loadFilepath)
    disp('file exists; processing plots');
    data=load(loadFilepath);
else
    error('file dont exist; save the relevant data');
end

% get plot handles for 6 electrode group and 12 different conditions
figure('WindowState','maximized');
gridPos=[0.1 0.1 0.85 0.75];
figHandle = figure(1);
epA = getPlotHandles(6,12,gridPos,0.005,0.005);


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%% get data Informations:
numGroups     =  length(groupIDs);
numProtocols  =  length(protocolNameList);
numElecGroups =  length(electrodeGroupList0);

numSubjects    = size(data.powerValStCombinedControl,1);
numConditions  = size(data.powerValStCombinedControl,2);
numElectrodes  = size(data.powerValStCombinedControl,3);
numFrequencies = size(data.powerValStCombinedControl,4);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get Data and plot
allMeanPSDs = [];
elecDim = 3;
dataForSignificanceTest = zeros(numGroups,numSubjects,numFrequencies);
freqVals=1:numFrequencies;

% combine Data
powerValStCombined{1}=data.powerValStCombinedControl;
powerValStCombined{2}=data.powerValStCombinedAdvanced;

powerValBlCombined{1}=data.powerValBlCombinedControl;
powerValBlCombined{2}=data.powerValBlCombinedAdvanced;


for g=1:numElecGroups % Electrode Group
    for p=1:numProtocols % Segments: EO1/EC1/........
        for group=1:numGroups %Control and meditators

            % setting the displayFlags (there should be better way)
            if g==1
                showTitleFlag=1;
            else
                showTitleFlag=0;
            end

            if p==1
                putElecGroupName = 1;
                if g==6
                    putAxisLabel = 1;
                end
            else
                putElecGroupName = 0;
                putAxisLabel = 0;
            end

            %------------------------------the main code-------------------------------------------------------------------
            electrodeList = electrodeGroupList0{g};
            % g across the selected electrodes in the raw power Domain
            powerValStCombinedThisElecGroup = mean(powerValStCombined{group}(:,:,electrodeList,:),elecDim,'omitnan');
            powerValBlCombinedThisElecGroup = mean(powerValBlCombined{group}(:,:,electrodeList,:),elecDim,'omitnan');
            % log transform the values
            powerValSTCombinedThisGroupLogTransformed = log10(powerValStCombinedThisElecGroup);
            powerValBlCombinedThisGroupLogTransformed = log10(powerValBlCombinedThisElecGroup);
            data = squeeze(powerValSTCombinedThisGroupLogTransformed(:,p,:)); %-squeeze(powerValBlCombinedThisGroupLogTransformed(:,p,:));

            if showDeltaPsdFlag && p==1
                commonBaseLine=getCommonBaseline(data,medianFlag);
            else
                commonBaseLine = [];
            end

            plotData(epA(g,p),freqVals,data,colorNameGroupsIDs{group},showSEMFlag, ...
                showTitleFlag,protocolNameList{p},putElecGroupName,groupNameList0{g},putAxisLabel, ...
                xLimsRange,yLimsRange,biPolarFlag,medianFlag,group, ...
                groupIDs,showDeltaPsdFlag,commonBaseLine,showRawPsdFlag);

            %-----------------Adding significance to the plot---------------------------------------------------------------------------------
            if showSignificanceFlag
                dataForSignificanceTest(group,:,:) = data;
                if group==2
                    axesHandle = epA(g,p);
                    powerControl = squeeze(dataForSignificanceTest(1,:,:));
                    powerAdvance = squeeze(dataForSignificanceTest(2,:,:));
                    compareMeansAndShowSignificance(powerControl,powerAdvance,numFrequencies, ...
                        axesHandle,xLimsRange,yLimsRange,axisLimAuto)
                end
            end
        end
    end
end
end

%%%%%%%%%%%%%%%%%%%%% Helper Functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Helper functions:

function plotData(hPlot,freqVals,data,colorName,showSEMFlag, ...
    showTitleFlag,titleStr,putElecGroupName,groupName,putAxisLabel, ...
    xLimsRange,yLimsRange,biPolarFlag,medianFlag,group, ...
    groupIDs,showDeltaPsdFlag,commonBaseLine,showRawPsdFlag)


hold(hPlot,'on');
yline(hPlot,0,'--');
xline(hPlot,20,'--');
xline(hPlot,34,'--');

tmp=rgb2hsv(colorName);
tmp2 = [tmp(1) tmp(2)/3 tmp(3)];
colorName2 = hsv2rgb(tmp2); % Same color with more saturation

% mData = squeeze(mean(data,1));
if medianFlag
    mData = squeeze(median(data,1,'omitnan'));
else
    mData = squeeze(mean(data,1,'omitnan'));
end

%% Main Plot function
% putting sem before:

if showSEMFlag
    if medianFlag
        getLoc = @(g)(squeeze(median(g,1),'omitnan'));
        bootStat = bootstrp(1000,getLoc,data);
        sData = std(bootStat);
    else
        sData = std(data,[],1,'omitnan')/sqrt(size(data,1));
    end
    xsLong = [freqVals fliplr(freqVals)];
    ysLong = [mData+sData fliplr(mData-sData)];
    patch(xsLong,ysLong,colorName2,'EdgeColor','none','parent',hPlot);
end


if showRawPsdFlag
    if putAxisLabel
        plot(hPlot,freqVals,mData,'color',colorName,'linewidth',1.5,'displayname',groupIDs{group});
        %     legend(hPlot,{'C'});
    else
        %         plot(hPlot,freqVals,mData,'color',colorName,'linewidth',1.5);
        plot(hPlot,freqVals,mData,'color',colorName,'linewidth',1.5);
        %         set(hPlot,'Xscale','log')
    end
end

if showDeltaPsdFlag %&& group==2
    deltaPsd = (mData-commonBaseLine);
    plot(hPlot,freqVals,deltaPsd,'color',colorName,'linewidth',1.5);
end

%% Other flags
if showTitleFlag
    title(hPlot,titleStr);
end

if putElecGroupName
    text(-110,-0.75,groupName,'FontSize',14,'Rotation',45,'parent',hPlot);
end

if putAxisLabel
    xlabel(hPlot,'frequency(Hz)','FontSize',12);
    %     ylabel(hPlot,'log_{10}(Power)','FontSize',12);
    ylabel(hPlot,'lg(Power)','FontSize',12);
    %     legend(hPlot,'Con','Med');
    if biPolarFlag
        sgtitle('Bipolar: Raw PSD for Meditators vs. Control across different protocols, n=31');
    else
        sgtitle('UniPolar: Raw PSD for Meditators vs. Control across different protocols, n=31');
    end
end

xlim(hPlot,xLimsRange);
drawnow

% ylim(hPlot,yLimsRange);
% if group==2
%     hold(hPlot,'off');
% end
end


function compareMeansAndShowSignificance(data1,data2,numFrequencies,axesHandle,xLimsRange,yLimsRange,axisLimAuto)

hPlot = axesHandle;
% set(hPlot,'XTick',[1 3 5 7],'XTickLabel',[1.6 6.25 25 100]);
yLims= getYLims(hPlot,yLimsRange,axisLimAuto); %max(min([0 inf],getYLims(hPlot)),[-inf 1]);

%%%%%%%%%%%%%%%%%%%%%%% compare attIn and attOut %%%%%%%%%%%%%%%%%%%%%%%%%%
dX = 1; dY = diff(yLims)/20;
numDays = 2;
freqIndices = 0:numFrequencies-1;
if numDays>1
    for i=1:numFrequencies

        [~,p] = ttest(data1(:,i),data2(:,i));    % for paired sample (parametric)
        %                 [p] = signrank(data1(:,i),data2(:,i)); % for paired sample (non-parametric)
        %         [p] = ranksum(data1(:,11),data2(:,10))    % for non-paired assumtion
        %                                                     or two independent unequal-sized samples.)
        %         if p<0.05/numContrasts
        %             pColor = 'r';

        if p<0.05
            pColor = 'r';
        else
            pColor = 'w';
        end

        patchX = freqIndices(i)-dX/2;
        patchY = yLims(1)-2*dY;
        patchLocX = [patchX patchX patchX+dX patchX+dX];
        patchLocY = [patchY patchY+dY patchY+dY patchY];
        patch(patchLocX,patchLocY,pColor,'Parent',hPlot,'EdgeColor',pColor);
    end
end
axis(hPlot,[0 numFrequencies-1 yLims+[-2*dY 2*dY]]);
set(hPlot,'xlim',xLimsRange);
legend('off');
% ylabel(hPlot,ylabelStr);
end


% Rescaling functions
function yLims = getYLims(plotHandles,yLimsRange,axisLimAuto)

if axisLimAuto
    [numRows,numCols] = size(plotHandles);
    % Initialize
    yMin = inf;
    yMax = -inf;

    for row=1:numRows
        for column=1:numCols
            % get positions
            axis(plotHandles(row,column),'tight');
            tmpAxisVals = axis(plotHandles(row,column));
            if tmpAxisVals(3) < yMin
                yMin = tmpAxisVals(3);
            end
            if tmpAxisVals(4) > yMax
                yMax = tmpAxisVals(4);
            end
        end
    end
    yLims = [yMin yMax];
else
    yLims = [yLimsRange(1) yLimsRange(2)];
end

end


function commonBaseLine= getCommonBaseline(data,medianFlag)
if medianFlag
    commonBaseLine=median(data,1,'omitnan');
else
    commonBaseLine=mean(data,1,'omitnan');
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function loadFilepath= getFolderName(biPolarFlag,removeIndividualUniqueBadTrials,removeDeclaredBadElecs)
folderSourceString = 'D:\Projects\ProjectDhyaan\BK1';

saveDataDeafultStr ='subjectWise';

if biPolarFlag
    saveDataDeafultStr = [saveDataDeafultStr 'Bipolar'];
    fileName = 'BiPolarGroupedPowerDataPulledAcrossSubjects.mat';
else
    saveDataDeafultStr = [saveDataDeafultStr 'Unipolar'];
    fileName = 'UnipolarGroupedPowerDataPulledAcrossSubjects.mat';
end

if removeIndividualUniqueBadTrials
    saveFolderName = [saveDataDeafultStr 'BadTrialIndElec'];
else
    saveFolderName = [saveDataDeafultStr 'BadTrialComElec'];
end

if removeDeclaredBadElecs
    saveFolderName = [saveFolderName 'DeclaredBadElecRemoved'];
end

loadFilepath = fullfile(folderSourceString,'data','savedData',saveFolderName,fileName);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
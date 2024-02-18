% runDisplayBadElecsAcrossSubjectsBK1
% This script displays bad electrodes across subjects
% Displays for the paired subject if the 'dispForPairedSubject' flag is 'ON'; default: all the subjects
% Can sort the subjects according to date of data collection if 'sortByDate' flag is 'ON';
% default: displays for the Meditators followed by Controls
% Also, displays the badSubjects and bad electrodes according to the threshold value
% Added functionality to display the declaredBadElecs based on the threshold value (set removeDeclaredBadElecs flag=0)
% For paired subject, if we declare bad electrodes the difference is not significant

% close all
clear
figure1 = figure('WindowState','maximized');
fh.WindowState = 'maximized';

h1 = axes('Parent',figure1,'Position',[0.076875+0.03 0.421185372005044 0.871875 0.433795712484237]);
% h1 = getPlotHandles(1,1,[0.15 0.1+0.3 0.8 0.7-0.38]);
% h0 = getPlotHandles(1,1,[0.09 0.1 0.03 0.7]);

% dispForPairedSubject = 0; removeDeclaredBadElecs = 0; removeDeclaredBadSubjects = 0; % Use this option to get all 76 subjects and all electrodes
% dispForPairedSubject = 0; removeDeclaredBadElecs = 1; removeDeclaredBadSubjects = 0; % Use this option to get all 76 subjects but remove the electrodes that are declared to be bad
dispForPairedSubject = 0; removeDeclaredBadElecs = 1; removeDeclaredBadSubjects = 1; % Use this option to get 71 subjects and remove the subjects that are declared to be bad

displayBadElectrodes = 1;
sortByDate = 0;
badElecThresoldBadSub = 0.35; % original thresold 0.5
badElecThresoldAcrossSubject = 0.35;

% color:
colorNames(1,:)     = [0.7 0 0.7];
colorNames(2,:)     = [0 0.7 0.7];

colorList = [rgb('Aqua');rgb('Orange');rgb('Blue')];

% fixed variables
badTrialNameStr = '_wo_v8';
numElecs = 64;
allEEGElecArray = 1:numElecs;
protocolName = 'G1';
gridType = 'EEG';
capType = 'actiCap64_UOL';
folderSourceString = 'N:\Projects\ProjectDhyaan\BK1';
% [~,~,~,electrodeGroupList0,groupNameList0,highPriorityElectrodeNums] = electrodePositionOnGrid(1,gridType,[],capType);
[electrodeGroupList0,groupNameList0] = getElectrodeGroupsAllElec(gridType,capType);

numElecGroups =  length(electrodeGroupList0);
[subjectNameList,expDateList] = getDemographicDetails('BK1');

% get the subject List
if dispForPairedSubject % paired
    pairedSubjectNameList = getPairedSubjectsBK1;
    goodSubjectList = pairedSubjectNameList(:);
    controlSubjectList = pairedSubjectNameList(:,2);
    numSubjects = length(goodSubjectList);
    numMeditators = size(pairedSubjectNameList,1);
    axisTitle = sgtitle(['Paired Subjects: n = ' num2str(numSubjects)]);
    set(axisTitle, 'FontSize', 20);
else % all the subjects
    if removeDeclaredBadSubjects
        [allSubjectList, meditatorList, controlList] = getGoodSubjectsBK1;
    else
        fileName = 'BK1AllSubjectList.mat';
        load(fileName,'allSubjectList','controlList','meditatorList');
    end
    controlSubjectList = controlList;
    goodSubjectList = allSubjectList;
    numSubjects = length(goodSubjectList);
    numMeditators = length(meditatorList);
    axisTitle = sgtitle(['All Subjects (n = ' num2str(numSubjects) ')']);
    set(axisTitle, 'FontSize', 20, 'FontWeight','bold');
end
numControls = numSubjects-numMeditators;
% BadElecs x Subject matrix
%-----------------------------------------------------
absExpDate        = zeros(1,numSubjects);
badSubjectStatus  = zeros(1,numSubjects);
badElecPercentage = zeros(1,numSubjects);
allBadElecsMatrix = zeros(numElecs,numSubjects);
for s=1:numSubjects
    subjectName = goodSubjectList{s};
    disp(['Extracting Subject ' subjectName]);
    expDate = expDateList{strcmp(subjectName,subjectNameList)};
    folderSegment = fullfile(folderSourceString,'data','segmentedData',subjectName,gridType,expDate,protocolName,'segmentedData');
    badTrialsInfo = load(fullfile(folderSegment,['badTrials' badTrialNameStr '.mat']));
    % bad elecs:
    noisyElecs        = badTrialsInfo.badElecs.noisyElecs;
    flatPSDElecs      = badTrialsInfo.badElecs.flatPSDElecs;
    badImpedanceElecs = badTrialsInfo.badElecs.badImpedanceElecs;
    if removeDeclaredBadElecs
        declaredBadElectrodes = getDeclaredBadElecs;
        badElecrodesIndex     = unique([badImpedanceElecs;noisyElecs;flatPSDElecs;declaredBadElectrodes']);
    else
        declaredBadElectrodes = [];
        badElecrodesIndex = unique([badImpedanceElecs;noisyElecs;flatPSDElecs]);
    end

    % assign the values to the matrix
    allBadElecsMatrix(badElecrodesIndex,s) = 1;
    % calculate and save bad elec percentage
    % and assign the badSubject Status
    badElecPercentage(1,s) = length(badElecrodesIndex)/numElecs;
    if badElecPercentage(1,s) > badElecThresoldBadSub
        badSubjectStatus(1,s) = 1;
    end
    % save the absolute date of recording
    x = expDate;
    absExpDate(1,s) = datenum([x(1:2) '/' x(3:4) '/' x(5:6)],'dd/mm/yy');
end

% get the bad elecs percentage for individual subjects per group
badElecPercentageIndMeditators = badElecPercentage(:,1:numMeditators);
badElecPercentageIndConrols    = badElecPercentage(:,numMeditators+1:end);

% gets the bad elecs percentage across subjects
% badElecPercentageAcrossSubjects       = round(sum(allBadElecsMatrix,2)/numSubjects,2);
% binarybadElecPercentageAcrossSubjects = (badElecPercentageAcrossSubjects > badElecThresoldAcrossSubject);

% get the bad elecs percentage across groups
badElecPercentageAcrossMeditators       = round(sum(allBadElecsMatrix(:,1:numMeditators),2)/numMeditators,2);
badElecPercentageAcrossControls         = round(sum(allBadElecsMatrix(:,numMeditators+1:end),2)/numControls,2);
binarybadElecPercentageAcrossSubjects   = (badElecPercentageAcrossMeditators > badElecThresoldAcrossSubject) | (badElecPercentageAcrossControls > badElecThresoldAcrossSubject);
binaryDeclaredBadElecAcrossSubjects     = ismember(allEEGElecArray, declaredBadElectrodes)';

badElecsCurrentThreshold                = allEEGElecArray(binarybadElecPercentageAcrossSubjects);
disp(['Bad elctrodes according to the current thresold(' num2str(badElecThresoldAcrossSubject) ') are ' num2str(badElecsCurrentThreshold)]);

% sorting the subjects accoring to exp dates
[sortedExpDate,orginalSortedIndexExpDate] = sort(absExpDate);
sortedbadElecPercent   = badElecPercentage(orginalSortedIndexExpDate);
sortedBadSubjectStatus = badSubjectStatus(orginalSortedIndexExpDate);
sortedSubjectList      = goodSubjectList(orginalSortedIndexExpDate);

numExpDate=numSubjects;
subjectGroupMatrix = zeros(1,numSubjects);
allBadElecsMatrixSortedExpDate = zeros(numElecs,numSubjects);
for e=1:numExpDate
    if sortByDate
        allBadElecsMatrixSortedExpDate(:,e) = allBadElecsMatrix(:,orginalSortedIndexExpDate(e));
        subjectName = sortedSubjectList(e);
    else
        allBadElecsMatrixSortedExpDate(:,e)=allBadElecsMatrix(:,e);
        subjectName = goodSubjectList(e);
    end
    % assign the control subjects 1; Meditators by default is 0
    if any(strcmp(controlSubjectList,subjectName))
        subjectGroupMatrix(1,e) = 1;
    end
end

% sorting the electrodes according to the different scalp areas
elecVal = 1;
startPos = 1;
elecGroupVec = zeros(numElecs,1);
sortedElecMatrix = zeros(numElecs,numSubjects);
% badDeclaredElecStatus = zeros(numElecs,numSubjects);

for g=1:numElecGroups % Electrode Group
    electrodeList = electrodeGroupList0{g};
    endPos = startPos+length(electrodeList)-1;

    sortedElecMatrix(startPos:endPos,:)         = allBadElecsMatrixSortedExpDate(electrodeList,:);
    badElecStatus(startPos:endPos,:)            = binarybadElecPercentageAcrossSubjects(electrodeList,:);
    badDeclaredElecStatus(startPos:endPos,:)    = binaryDeclaredBadElecAcrossSubjects(electrodeList,:);

    elecGroupVec(startPos:endPos,:) = elecVal;
    startPos = startPos+length(electrodeList);
    elecVal = elecVal+1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Plots %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% plot elcs x Sub Matrix
% h1 = getPlotHandles(1,1,[0.15 0.1 0.8 0.7]);
imagesc(1:numSubjects,numElecs:-1:1,flipud(sortedElecMatrix),'parent',h1);
set(h1,'Xtick',1:1:numSubjects,'XTickLabel',1:1:numSubjects,'TickDir','out','TickLength',[0.005, 0.001],'XTickLabelRotation',0);
% set(h1,'XTickLabel',{1:5:numSubjects});
set(h1,'Ytick',1:1:numElecs,'YTickLabel',[],'TickDir','out','TickLength',[0.005, 0.001]);

colormap(h1,[gray(64)]);
set(gca,'YDir','normal');
if sortByDate
    xlabel('Subject Index (Sorted According to experiment date)','fontsize',15,'fontweight','bold');
else
    xlabel('Subject Index (Sorted According to the subject category)','fontsize',15,'fontweight','bold');
end

% shows the badSubjects
yPos = 75;
xOffSet = 0.265;
if sortByDate
    badSubInd = find(sortedBadSubjectStatus==1);
    for b=1:length(badSubInd)
        text(badSubInd(b)-xOffSet,yPos,'x' ,'Color','Red','FontSize',12,'FontWeight','bold','Parent',h1);
        %         text(badSubInd(b)-xOffSet,yPos+2,sortedSubjectList{badSubInd(b)},'Color','Red','FontSize',12,'FontWeight','bold','Parent',h1);
    end
else
    badSubInd = find(badSubjectStatus==1);
    for b=1:length(badSubInd)
        text(badSubInd(b)-xOffSet,yPos,'x','Color','Red','FontSize',12,'FontWeight','bold','Parent',h1);
        %         text(badSubInd(b)-xOffSet,yPos+2,goodSubjectList{badSubInd(b)},'Color','Red','FontSize',12,'FontWeight','bold','Parent',h1);
    end
end


% shows the badElectrodes
xPos=numSubjects+1;
yOffSet = 0.4;
badElecInd = find(badElecStatus==1);
declaredBadElecInd = find(badDeclaredElecStatus==1);
newBadElecInd = setdiff(badElecInd,declaredBadElecInd);
for e=1:length(badElecInd)
    if ismember(badElecInd(e),newBadElecInd)
        text(xPos,badElecInd(e)+yOffSet,'x','Color','Red','FontSize',12,'FontWeight','bold','Parent',h1);
    else
        text(xPos,badElecInd(e)+yOffSet,'x','Color','Red','FontSize',12,'FontWeight','bold','Parent',h1);
    end
end

% shows the elecGroups
h0 = axes('Parent',figure1,'Position',[0.0781    0.4237    0.0244    0.4313]);
subplot(h0);
% imagesc(1:numSubjects,length(elecGroupVec):-1:1,flipud(elecGroupVec),'parent',h0);
imagesc(1:numSubjects,1:1:length(elecGroupVec),flipud(elecGroupVec),'parent',h0);

colorMapElectrode = zeros(64,3);
colorMapElectrode(1:20,:)  = repmat([colorList(1,:)],20,1);
colorMapElectrode(21:40,:) = repmat([colorList(2,:)],20,1);
colorMapElectrode(41:64,:) = repmat([colorList(3,:)],24,1);

colormap(h0,colorMapElectrode);

% colormap(h0,[turbo(64)]);

yPos = 65;
xPos = -200;
delta = 15;
for g=1:numElecGroups
    groupName = groupNameList0{g};
    text(xPos,yPos,groupName,'Color',colorList(g,:),'FontSize',14,'FontWeight','bold','Rotation',90,'parent',h0);
    if g==2
        delta = 29;
    elseif g==1
        delta = 16;
    end
    yPos = yPos-delta;
end
set(h0,'xTick',[],'Xticklabel',[],'YTick',[],'Yticklabel',[]);

% shows subject groups
h2 = axes('Parent',figure1,'Position',[ 0.1069    0.8625    0.8719    0.0467]);
imagesc(1:numSubjects,length(allBadElecsMatrix):-1:1,flipud(subjectGroupMatrix),'parent',h2);
set(h2,'Xtick',1:1:numSubjects,'XTickLabel',[],'TickDir','out','TickLength',[0.005, 0.001]);

% Make a custom colorMap
colorMapSubject = zeros(64,3);
colorMapSubject(1:32,:)  = repmat([colorNames(1,:)],32,1);
colorMapSubject(33:64,:) = repmat([colorNames(2,:)],32,1);

colormap(h2,colorMapSubject);
set(gca,'YDir','normal','YTick',[],'Yticklabel',[]);

% denotes the subject Groups
text('parent',h2,'String','Meditators','Color',colorNames(1,:),'Rotation',0,'FontSize',14,'fontweight','bold','Position',[15.24229390681 312.702702702703 0]);

text('String','Controls','Color',colorNames(2,:),'Rotation',0,'FontSize',14,'fontweight','bold','Position',[55.4487  312.1622  0],'parent',h2);


%%%%%%%%%%%%%%%% Display the bad electrodes across groups %%%%%%%%%%%%%%%%%

if displayBadElectrodes
    dataArray{1,1} = badElecPercentageIndMeditators * numElecs;
    dataArray{1,2} = badElecPercentageIndConrols * numElecs;

    colorArray = {'r','g'};
    showData = 1;
    plotQuartiles = 1;
    showSignificance = 1;
    pairedDataFlag = dispForPairedSubject;

    fh2 = figure(2);
    fh2.WindowState = 'maximized';
    displayViolinPlot(dataArray,colorArray,showData,plotQuartiles,showSignificance,pairedDataFlag);
    ylabel('Num Bad Elecs');
    xticks(1:length(dataArray));
    xticklabels({'Meditators', 'Controls'});
    set(gca, 'FontSize', 12,'FontWeight','Bold');
    set(gca, 'TickDir', 'out');
end

%%
addSupplementaryFig =0;
if addSupplementaryFig
    dataArray{1,1} = badElecPercentageIndMeditators * numElecs;
    dataArray{1,2} = badElecPercentageIndConrols * numElecs;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%% Add axes for the demographics info
    h2a = axes('Parent',figure1,'Position', [0.2131 0.0760 0.1013 0.2304]);
    h2b = axes('Parent',figure1,'Position', [0.3975 0.0744 0.1013 0.2295]);
    h2c = axes('Parent',figure1,'Position', [0.5750 0.0757 0.0987 0.2277]);
    h2d = axes('Parent',figure1,'Position', [0.7500 0.0773 0.0988 0.2228]);

    hPlot0 = [h2a h2b h2c h2d];

    %%Code for generating paired dots with line

    %plot figure 1 supplementary
    projectName = 'BK1';
    [subjectNameList,expDateList,labelList,ageList,genderList,educationList,mcList] = getDemographicDetails(projectName);

    [goodSubjectList, meditatorList, controlList] = getGoodSubjectsBK1;
    unPairedSubjectNameList{1} = meditatorList;      unPairedSubjectNameList{2} = controlList;

    pairedSubjectNameList = getPairedSubjectsBK1;
    numPairs = size(pairedSubjectNameList,1);
    numGroup = size(pairedSubjectNameList,2);
    strList = [{'Med'} {'Con'}];


    markerList = ['o';'d'];
    gender = ['M','F'];
    dataShift1 = [-0.05 0.05];
    clear colorList
    colorList{1} = [0.8 0 0.8; 0.25 0.41 0.88]; % for males
    colorList{2} = [0.7 0 0.8; 0.15 0.31 0.88];  %for females

    du = struct();  % for unpaired data
    d = struct();
    param = [{'age'} {'education'} {'mc'} {'numBadElecs'}];
    paramUnit = [{' (Years)'} {' (Years)'} {' (Days)'} {' (tot)'}];
    numParam = length(param);


    %getting unpaired demographics
    for iGroup = 1:numGroup
        for iPair=1:length(unPairedSubjectNameList{iGroup})
            pos = strcmp(unPairedSubjectNameList{iGroup}{iPair},subjectNameList);
            du.age{iGroup}(iPair) = ageList(pos);
            du.education{iGroup}(iPair) = educationList(pos);
            du.mc{iGroup}(iPair) = mcList(pos);
            du.gender{iGroup}(iPair) = genderList(pos);
            %         x = expDateList{pos};
            %         du.expDate{iGroup}(iPair)= datenum([x(1:2) '/' x(3:4) '/' x(5:6)],'dd/mm/yy');%datetime(x,'inputFormat','ddmmyy');%
        end
        du.numBadElecs{iGroup} = dataArray{iGroup};
    end

    % getting paired info
    for iGroup = 1:numGroup
        for iPair=1:numPairs
            pos = strcmp(pairedSubjectNameList{iPair,iGroup},subjectNameList);
            d.age{iGroup}(iPair) = ageList(pos);
            d.education{iGroup}(iPair) = educationList(pos);
            d.mc{iGroup}(iPair) = mcList(pos);
            d.gender{iGroup}(iPair) = genderList(pos);
            pos2{iGroup}(iPair) = find(strcmp(pairedSubjectNameList{iPair,iGroup},unPairedSubjectNameList{iGroup}));
            %         x = expDateList{pos};
            %         d.expDate{iGroup}(iPair)= datenum([x(1:2) '/' x(3:4) '/' x(5:6)],'dd/mm/yy');%datetime(x,'inputFormat','ddmmyy');%
        end
        d.numBadElecs{iGroup} = dataArray{iGroup}(pos2{iGroup});
    end


    numRows = 1;    numColumns = numParam;

    for iParam = 1:length(param)
        %% data Plot
        data0 = d.(param{iParam});
        data0UP = du.(param{iParam});

        hPlot(1) = hPlot0(iParam);%subplot(numRows,numColumns,iParam);%hPlot0(1,iParam);%

        hold on;
        for iGender = 1:2
            for iGroup = 1:numGroup
                posGenPaired = find(strcmp(d.gender{iGroup},gender(iGender)));
                data{iGroup} = data0{iGroup}(posGenPaired);

                posGenUnpaired = find(strcmp(du.gender{iGroup},gender(iGender)));
                dataUP{iGroup} = data0UP{iGroup}(posGenUnpaired);
            end

            if iParam == 3
                dataShift = [0 0];
            else
                dataShift = dataShift1;
            end

            plotMatchedPairedDots(hPlot(1),data,dataShift(iGender),markerList(iGender),colorList{iGender},1);
            plotMatchedPairedDots(hPlot(1),dataUP,dataShift(iGender), markerList(iGender),colorList{iGender},0);
        end

        for iGroup = 1:numGroup
            plot(iGroup,nanmean(dataUP{iGroup}),'.k',MarkerSize=18);
            err = nanstd(dataUP{iGroup})./sqrt(length(dataUP{iGroup}));
            er = errorbar(iGroup,nanmean(dataUP{iGroup}),err,err,'LineWidth',2,'Color','k');
        end

        [~,pp] = ttest(data0{1}, data0{2});
        [~,pu] = ttest2(data0UP{1}, data0UP{2});
        xlim([0 3]);
        set(hPlot(1),'XTick',[1 2],'XTickLabel',[{strList{1}} {strList{2}}],'TickLength',[0.04 0.02],'LineWidth',1,'FontWeight','bold',FontSize=12);
        ylabel([upper(param{iParam}(1)) param{iParam}(2:end) paramUnit{iParam}],FontSize=14,FontWeight="bold");
        title([upper(param{iParam}(1)) param{iParam}(2:end)],FontSize=16,FontWeight="bold");

        h = gca;
        ylim1  = h.YLim(2);
        pPosition=ylim1+3; % paired
        %pPosition2=ylim1+2; % unpaired

        if pp<0.001
            text(0.5,pPosition,['p_P = ' num2str(pp,'%.1e')],'FontWeight','bold');
        else
            text(0.5,pPosition,['p_P = ' num2str(pp,'%.2f')],'FontWeight','bold');
        end

        if pu<0.001
            text(1.5,pPosition,['p_U = ' num2str(pu,'%.1e')],'FontWeight','bold');
        else
            text(1.5,pPosition,['p_U = ' num2str(pu,'%.2f')],'FontWeight','bold');
        end

        h.YLim(2) = ylim1+4;
        box off;

    end
end


%%%%%%%%%%%%% associated functions 
function  plotMatchedPairedDots(hPlot,data, dataShift, markerType,colorList,pairedFlag)

if ~exist('dataShift','var');      dataShift = 0;       end
if ~exist('markerType','var');      markerType = 'o';       end

axes(hPlot);
numGroups = length(data);

for i=1:numGroups
    plot(hPlot,i*ones(1,length(data{i}))+dataShift,data{i},markerType,'MarkerFaceColor',colorList(i,:),'MarkerEdgeColor','k','MarkerSize',8);
    hold on;
end

if pairedFlag
    for u= 1:length(data{1})
        plot(hPlot,[1 2]+dataShift,[data{1}(u) data{2}(u)],'color',[0.6 0.6 0.6],'LineWidth',0.9);
        hold on;
    end
end
end

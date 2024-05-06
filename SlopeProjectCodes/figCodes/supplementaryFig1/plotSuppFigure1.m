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

figure;
numRows = 1;    numColumns = numParam;
hPlot0 = getPlotHandles(1,4,[0.06 0.1 0.85 0.25],0.06);
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

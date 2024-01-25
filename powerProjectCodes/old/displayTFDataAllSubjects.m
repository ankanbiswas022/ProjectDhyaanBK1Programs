
% display TF data for two groups: M and C
% Sorted by no of years:
clear
pairedSubjectNameList = getPairedSubjectsBK1;
numPairs  = length(pairedSubjectNameList);
numGroups = size(pairedSubjectNameList,2);

[subjectNameList,expDateList,labelList,ageList,genderList,educationList,mcList] = getDemographicDetails('BK1');

% get the agesList
ageListPaired = zeros(numPairs,2);
for i=1:numGroups
    for j=1:numPairs
        subIndex= find(strcmp(subjectNameList,pairedSubjectNameList(j,i)));
        ageListPaired(j,i) = ageList(subIndex);
    end
end

% sort the ageList and get the corresponding sorted subjectNames!
[ageListPaired_sorted, sort_index] = sort(ageListPaired);
pairedSubjectNameList_sorted = pairedSubjectNameList(sort_index,:);
subjectNameLists{1} = pairedSubjectNameList_sorted(:,1);
subjectNameLists{2} = pairedSubjectNameList_sorted(:,2);

% plot for a single subject:

close all
clf
hTF1 = getPlotHandles(numPairs/2,numGroups,[0.08 0.06 0.4 0.85],0.005,0.005);
hTF2 = getPlotHandles(numPairs/2,numGroups,[0.54  0.06 0.4 0.85],0.005,0.005);
hTF = [hTF1;hTF2];
fontsize = 10;
colormap jet

protocolIndex = 3; % 1 for G1
badElecRejectionFlag = 1;
baselineRange = [-1 0];
% T = 1; % epoch lengh, remains the same for basLine and stimulus period
for i=1:numGroups
    for j=1:numPairs
        subjectName = pairedSubjectNameList_sorted{j,i};
        fileName = fullfile(pwd,'savedData',[subjectName '_ep_v8_TF.mat']);
        load(fileName);
        %-------------------------------------------------------------------------------------------
        if badElecRejectionFlag
            badElecToReject = badElectrodes{protocolIndex};
            goodElecsInd       = not(ismember(electrodeList,badElecToReject));
            if sum(goodElecsInd)>1
                meanTfPower   = squeeze(mean(tfPower{protocolIndex}(goodElecsInd,:,:),1));
            else
                disp('Not enough good electrodes to plot')
                continue
            end
        else
            meanTfPower   = squeeze(mean(tfPower{protocolIndex}(:,:,:),1));
        end

        logP          = log10(meanTfPower);
        baselinePower = mean(logP(timeValsTF>=baselineRange(1) & timeValsTF<=baselineRange(2),:));
        diffTf = 1;
        if diffTf
        pcolor(hTF(j,i),timeValsTF,freqValsTF,10*(logP'- repmat(baselinePower',1,length(timeValsTF))));
        else
            pcolor(hTF(j,i),timeValsTF,freqValsTF,logP');
        end
        shading(hTF(j,i),'interp');
        xlim(hTF(j,i),[-0.25 max(timeValsTF)]);
        %-------------------------------------------------------------------------------------------
        if j==numPairs/2 && i==1
            xlabel(hTF(j,i),'Time(s)');
            ylabel(hTF(j,i),'Frequency (Hz)');
            set(hTF(j,i), 'TickDir', 'out');
            set(hTF(j,i), 'fontsize',fontsize);
            set(hTF(j,i), 'FontWeight','bold');
        else
            set(hTF(j,i),'Yticklabel',[]);
            set(hTF(j,i),'Xticklabel',[]);
        end

        if i==1 && ismember(j,[1,17])
            title(hTF(j,i),'Meditators');
        elseif i==2 && ismember(j,[1,17])
            title(hTF(j,i),'Controls');
        end
        clim(hTF(j,i),[-5 5]);
        ylim(hTF(j,i),[0 60]);
    end
end

% set the colorbar
set(hTF(j,i), 'TickDir', 'out');
hc = colorbar('Position', [0.05 0.2 0.02 0.3]);
hc.Label.String = ['\Delta Power' '(dB)'];

hc.Label.FontWeight = 'bold';
hc.FontSize         = 10;
hc.Label.FontSize   = 10;

if protocolIndex==1
    sgtitle('TF plot for Med vs Control (G1)');
elseif  protocolIndex==2
    sgtitle('TF plot for Med vs Control (G2)');
else
    sgtitle('TF plot for Med vs Control (M2)');
end
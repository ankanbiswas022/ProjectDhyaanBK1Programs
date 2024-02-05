function plotFigure1TopoMed(subjectNameLists0,montageChanlocs, badEyeCondition,badTrialVersion, analysisChoice, badElectrodeRejectionFlag,cutoffNumTrials,useMedianFlag,significanceFlag,hTopoSlope)

% goodSubjectNameLists = getGoodSubjectNameList(subjectNameLists,freqWidth,refType,badEyeCondition,badTrialVersion,protocolPos,protocolPosRef,analysisChoice,badElectrodeRejectionFlag,cutoffNumTrials,pairedDataFlag,saveFolderName);
% subjectNameLists = goodSubjectNameLists;
% 
% montageChanlocs = showElectrodeGroups(hTopo0(1,:),capType,electrodeGroupList,groupNameList);

%% for figure 2 topoplots for slope only

%%%% details

% range: 84-190
if ~exist('significanceFlag','var')
significanceFlag = 1;
end



saveFolderName = 'savedData';

%nanValue = 0; % to omit nan in topoplots
parameterName = [{'Slope'}];
refType = 'unipolar';
freqWidth = 106;



fdrFlag = 0;

numProt = [1 2 4]; %EO1, EC1, M1

colormap("jet");

if ~exist('hTopoSlope','var')
hTopoSlope = getPlotHandles(length(parameterName),length(numProt),[0.1 0.1 0.7 0.3],0.1,0.1);
end

for iProtocol = 1:length(numProt)
    iProt = numProt(iProtocol);

    if length(subjectNameLists0)~=length(numProt)
            subjectNameLists = subjectNameLists0;
    else
        subjectNameLists = subjectNameLists0{iProtocol};
    end


    for i=1:2
        exponentDataTMP = [];

                for j=1:length(subjectNameLists{i})
            subjectName = subjectNameLists{i}{j};

            fileName = fullfile(pwd,saveFolderName,'FOOOF',[subjectName '_freqWidth_' num2str(freqWidth) '_' refType '__' badEyeCondition '_' badTrialVersion 'withoutKnee.mat']);
            %tmpData = load(fullfile(saveFolderName,[subjectName '_' badEyeCondition '_' badTrialVersion '_' num2str(1000*stRange(1)) '_' num2str(1000*stRange(2))]));
            if ~isfile(fileName)
                disp(['fileName for ' subjectName 'does not exist']);
            else
                tmpData = load(fileName);
                reqVals = tmpData.freqVals;

           %      [tmpPower,tmpExponent,tmpOffset] = getPowerData(tmpData,protocolPos,analysisChoice,badElectrodeRejectionFlag,cutoffNumTrials);
          
                [~,tmpExponent] = getPowerData(tmpData,iProt,analysisChoice,badElectrodeRejectionFlag,cutoffNumTrials);
                

                if isempty(tmpExponent)
                    disp(['Not enough trials for subject: ' subjectName]);
                else
                    %powerDataTMP = cat(3,powerDataTMP,tmpPower);
                    exponentDataTMP = cat(2,exponentDataTMP,tmpExponent);
                    %offsetDataTMP = cat(2,offsetDataTMP,tmpOffset);
                end

            end
        end

        % powerData{i} = powerDataTMP;
        paramData{1}{i} = exponentDataTMP;
        % paramData{2}{i} = offsetDataTMP;

        % powerDataRef{i} = powerDataRefTMP;
        %paramDataRef{1}{i} = exponentDataTMPRef;
        % paramDataRef{2}{i} = offsetDataTMPRef;

        for j=1:length(paramData)
                xParam{j}{i} = (paramData{j}{i})';
            
            if useMedianFlag
                dataTopo{j}{i} = squeeze(median(xParam{j}{i},1,'omitnan'));
            else
                dataTopo{j}{i} = squeeze(mean(xParam{j}{i},1,'omitnan'));
            end

        end
    end

    axes(hTopoSlope(iProtocol));

    %dataTopoDiff = dataTopo{j}{1} - dataTopo{j}{2};
    dataTopoDiff = dataTopo{1}{1} - dataTopo{1}{2};
    %topoplot_murty(dataTopoDiff,montageChanlocs,'electrodes','off','style','map','drawaxis','off','nosedir','+X','emarkercolors', dataTopoDiff); hold on;
    topoplot(dataTopoDiff,montageChanlocs,'electrodes','on','plotrad',0.6,'headrad',0.6);
    %caxis([-0.5 0.5])
    caxis([-0.2 0.2])
    if significanceFlag
        sigElectrodes = findSignificantElectrodes(xParam{j},useMedianFlag,fdrFlag);
        if length(find(isnan(sigElectrodes)))~=64
            %topoplot(sigElectrodes,montageChanlocs,'electrodes','on','style','blank','drawaxis','off','nosedir','+X','emarker',{'.','k',12,1});
            topoplot(sigElectrodes,montageChanlocs,'electrodes','on','style','blank','emarker',{'.','k',12,1});
        end
    end
   if iProtocol==1
       c = colorbar;
       c.Location = 'southoutside'; c.Position =  [0.2 0.08 0.4 .02] ; c.FontSize = 8; c.FontWeight = 'bold';
       c.Label.String ='Slope Difference'; c.Label.FontSize = 10; c.Label.FontWeight = 'bold';
   end

end
end


%%%%%%%%%%%%%%%%%%%%% FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [tmpPower,tmpExponent,tmpOffset] = getPowerData(tmpData,protocolPos,analysisChoice,badElectrodeRejectionFlag,cutoffNumTrials)

numTrials = tmpData.numTrials(protocolPos);
badElectrodes = getBadElectrodes(tmpData.badElectrodes,badElectrodeRejectionFlag,protocolPos);

exponentCutoff = 0.01;

if numTrials < cutoffNumTrials
    tmpPower    = [];
    tmpExponent = [];
    tmpOffset   = [];
else
    if strcmpi(analysisChoice,'st')
        tmpPower    = tmpData.SpecPower{2}{protocolPos};
        tmpExponent = tmpData.exponent{2}{protocolPos};
        tmpOffset   = tmpData.offset{2}{protocolPos};
    elseif strcmpi(analysisChoice,'bl')
        tmpPower    = tmpData.SpecPower{1}{protocolPos};
        tmpExponent = tmpData.exponent{1}{protocolPos};
        tmpOffset   = tmpData.offset{1}{protocolPos};
    else
        tmpPower = (tmpData.SpecPower{2}{protocolPos}+tmpData.SpecPower{1}{protocolPos})/2; % average
        tmpExponent = (tmpData.exponent{2}{protocolPos}+tmpData.exponent{1}{protocolPos})/2;
        tmpOffset = (tmpData.offset{2}{protocolPos}+tmpData.offset{1}{protocolPos})/2;
    end

    badExponentElec = find(tmpExponent<exponentCutoff);

    tmpPower(badElectrodes,:) = NaN;
    tmpExponent(union(badElectrodes,badExponentElec)) = NaN;
    tmpOffset(union(badElectrodes,badExponentElec)) = NaN;
end
end

function [sigElecNum] = findSignificantElectrodes(data,useMedianFlag,fdrFlag)

if ~exist('fdrFlag','var');      fdrFlag=0;      end

allData = [];   allIDs = [];
for i=1:size(data,2)
    allData = cat(1,allData,data{i});
    allIDs = cat(1,allIDs,i+zeros(size(data{i},1),1));
end
clear p sigElecNum
sigElecNum = nan(1,size(allData,2));
for j = 1:size(allData,2)
    if useMedianFlag
        p(j)=kruskalwallis(allData(:,j),allIDs,'off');
    else
        [~,p(j)]=ttest2(data{1}(:,j),data{2}(:,j)); % only tests 2 groups
    end
end
if fdrFlag
    pAsc = sort(p,'ascend');

    for k = 1:length(pAsc)
         if ~isnan(p(k))
        p(k) = p(k)*length(p)/(find(pAsc==p(k),1));
         end
    end
end
sigElecNum(p<0.05) = 1;
end

function badElectrodes = getBadElectrodes(badElectrodeList,badElectrodeRejectionFlag,protocolPos)

if badElectrodeRejectionFlag==1 % Bad electrodes for the protocol
    badElectrodes = badElectrodeList{protocolPos};
elseif badElectrodeRejectionFlag==2 % common bad electrodes for all protocols
    badElectrodes=[];
    for i=1:length(badElectrodeList)
        badElectrodes=cat(1,badElectrodes,badElectrodeList{i});
    end
    badElectrodes = unique(badElectrodes);
elseif badElectrodeRejectionFlag==3 % Bad electrodes of G1
    badElectrodes = badElectrodeList{3};
end
end

if combineDataAcrossCommonProtocols         % Average data across protocols

        for g=1:numGroups
            for p=1:length(combIndex)

                indListToCmp = combIndex{p};
                logPSDDataToCombine = {logPSDDataTMP{g,indListToCmp(1)}, logPSDDataTMP{g,indListToCmp(2)}};
                logPowerToCombine   = {logPowerTMP{g,indListToCmp(1)}, logPowerTMP{g,indListToCmp(2)}};

                % Average data across protocols
                logPSDData = cell(1,2);
                logPower = cell(1,2);

                for i=1:2 % meditator/control
                    % Get subjects for each protocol
                    subjectNamesTMP = cell(1,numProtocols);
                    for j=1:numProtocols
                        subjectNamesTMP{j} = goodSubjectNameListsTMP{j}{groupPos,i};
                    end

                    % Get common subjects
                    commonSubjects = subjectNamesTMP{1};
                    for j=2:numProtocols
                        commonSubjects = intersect(commonSubjects,subjectNamesTMP{j},'stable');
                    end

                    % Generate average data across protocols for each common subject
                    numCommonSubjects = length(commonSubjects);

                    logPSDCommon = zeros(numCommonSubjects,length(freqVals));
                    logPowerCommon = zeros(1,numCommonSubjects);
                    for j=1:numCommonSubjects
                        name = commonSubjects{j};

                        psdTMP=[]; powerTMP=[];
                        for k=1:2 %max 2 protocols for combining
                            pos = find(strcmp(name,subjectNamesTMP{k}));
                            psdTMP = cat(3,psdTMP,logPSDDataToCombine{k}{i}(pos,:));
                            powerTMP = cat(2,powerTMP,logPowerToCombine{k}{i}(pos));
                        end

                        logPSDCommon(j,:) = squeeze(mean(psdTMP,3));
                        logPowerCommon(j) = mean(powerTMP);
                    end

                    logPSDData{i} = logPSDCommon;
                    logPower{i}   = logPowerCommon;
                end
            end
        end
    else
        logPSDData = logPSDDataTMP;
        logPower = logPowerTMP;
    end
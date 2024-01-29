
function meanTFDataProtocolWise = meanTFDataProtocolWise()

% subGroupPos = 1; % meditators
% genderIndex = 1; % males
% protocolPos = 1; % G1
load('tfDataAllSubPairedG1G2.mat','tfDataAllSub');
for g=1:2 %control and meditators
    for p=1:2 % G1/G2
        tfDataTMP4= [];
        for s=1:2 %Male/Female
            tfDataTMP  = tfDataAllSub{g,s};
            tfDataTMP2 = tfDataTMP(:,p);

            for i=1:length(tfDataTMP2)
                tfDataTMP3(:,:,i)=tfDataTMP2{i};
            end
            tfDataTMP4=cat(3,tfDataTMP4,tfDataTMP3);
        end
        meanTFDataProtocolWise{g,p} = mean(tfDataTMP4,3);
    end
end

save('meanTFDataProtocolWise.mat','meanTFDataProtocolWise');
end
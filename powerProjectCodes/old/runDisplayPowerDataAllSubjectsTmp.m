% runDisplayPowerDataAllSubjects

[~, meditatorList, controlList] = getGoodSubjectsBK1;
subjectNameLists{1} = meditatorList;
subjectNameLists{2} = controlList;

% pairedSubjectNameList = getPairedSubjectsBK1;
% subjectNameLists{1} = pairedSubjectNameList(:,1);
% subjectNameLists{2} = pairedSubjectNameList(:,2);
clf
protocolName = 'G2'; analysisChoice = 'st'; refChoice = 'G2';
displayPowerDataAllSubjects(subjectNameLists,protocolName,analysisChoice,refChoice);
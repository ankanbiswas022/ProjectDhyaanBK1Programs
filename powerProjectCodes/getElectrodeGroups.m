function [electrodeGroupList,groupNameList] = getElectrodeGroups(gridType,capType)

[~,~,~,~,~,highPriorityElectrodeNums] = electrodePositionOnGrid(1,gridType,[],capType);

% Combine some groups
electrodeGroupList{1} = highPriorityElectrodeNums; % now called occipital
groupNameList{1} = 'Occipital';
% electrodeGroupList{2} = [electrodeGroupList0{3} electrodeGroupList0{4}]; % Fronto-Central and Frontal
% groupNameList{2} = 'Frontal-Central';

% subFrontal            = [1 32      32+[1 2 4 29 30 31]];
% subFrontoCental       = [6 8 25 28 32+[9 24]];
% % subTemporalTwo        = [9 26 32+[10 23 6 27]];
% electrodeGroupList{2} = [subFrontal subFrontoCental]; % Fronto-Central and Frontal
% groupNameList{2}      = 'Sub-FrontoCentral';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

subFrontal            = [1 32      32+[1 2 29 30 5 28]];
subFrontoCental       = [6 8 25 28 32+[9 24]];
% subTemporalTwo        = [9 26 32+[10 23 6 27]];
electrodeGroupList{2} = [subFrontal subFrontoCental]; % Fronto-Central and Frontal
groupNameList{2}      = 'Sub-FrontoCentral';

end
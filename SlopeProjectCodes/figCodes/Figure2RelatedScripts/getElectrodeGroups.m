function [electrodeGroupList,groupNameList] = getElectrodeGroups(gridType,capType)

[~,~,~,electrodeGroupList0,groupNameList0,highPriorityElectrodeNums] = electrodePositionOnGrid(1,gridType,[],capType);

% Combine some groups

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Occipital Electrodes %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Option 1: Choose highPriority electrodes
electrodeGroupList{1} = highPriorityElectrodeNums; % now called occipital
groupNameList{1} = 'Occipital';

% Option 2: Choose occipital electrodes
% electrodeGroupList{1} = electrodeGroupList0{1}; % now called occipital
% groupNameList{1} = 'Occipital';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Fronto-Central Electrodes %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Option 1: Choose default fronto-central electrodes
% electrodeGroupList{2} = [electrodeGroupList0{3} electrodeGroupList0{4}]; % Fronto-Central and Frontal
% groupNameList{2}      = 'Frontal-Central';

% Option 2: Choose only frontal and central electrodes
% subFrontal              = [1 32      32+[1 2 4 29 30 31]];
% subFrontoCental         = [6 8 25 28 32+[9 24]];
% % subTemporalTwo        = [9 26 32+[10 23 6 27]];
% electrodeGroupList{2}   = [subFrontal subFrontoCental]; % Fronto-Central and Frontal
% groupNameList{2}        = 'Sub-FrontoCentral';

% Option 3: Choose frontal, central and temporal electrodes
subFrontal            = [1 32      32+[1 2 29 30 5 28]];
subFrontoCental       = [6 8 25 28 32+[9 24]];
subFrontoTemporal     = [4 31 9 26 32+[6 27 10 23]];
electrodeGroupList{2} = [subFrontal subFrontoCental subFrontoTemporal]; % Fronto-Central and Frontal
groupNameList{2}      = 'Sub-FrontoCentral';

end
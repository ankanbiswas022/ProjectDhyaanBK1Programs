function [electrodeGroupList,groupNameList] = getElectrodeGroupsAllElec(gridType,capType)

[~,~,~,electrodeGroupList0,groupNameList0,highPriorityElectrodeNums] = electrodePositionOnGrid(1,gridType,[],capType);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Occipital Electrodes %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Option 1: Choose highPriority electrodes
electrodeGroupList{1} = highPriorityElectrodeNums; % now called occipital
groupNameList{1} = 'Occipital';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Fronto-Central Electrodes %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Option 3: Choose frontal, central and temporal electrodes
subFrontal            = [1 32      32+[1 2 29 30 5 28]];
subFrontoCental       = [6 8 25 28 32+[9 24]];
subFrontoTemporal     = [4 31 9 26 32+[6 27 10 23]];
electrodeGroupList{2} = [subFrontal subFrontoCental subFrontoTemporal]; % Fronto-Central and Frontal
groupNameList{2}      = 'Fronto-Temporal';

%%%%%%%%%%%%%%%%%%%%%%%%%%%% Others %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Option 3: Choose frontal, central and temporal electrodes
electrodeGroupListTMP = [electrodeGroupList{1} electrodeGroupList{2}]; % Fronto-Central and Frontal
allElecIndex          = 1:64;
electrodeGroupList{3}      = setdiff(allElecIndex,electrodeGroupListTMP);
groupNameList{3}      = 'Others';

end
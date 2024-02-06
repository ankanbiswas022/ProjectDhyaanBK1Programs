function [electrodeGroupList,groupNameList] = getElectrodeGroupsOld(gridType,capType)

[~,~,~,electrodeGroupList0,groupNameList0,highPriorityElectrodeNums] = electrodePositionOnGrid(1,gridType,[],capType);

% Combine some groups
electrodeGroupList{1} = highPriorityElectrodeNums; % now called occipital
groupNameList{1} = 'Occipital';
electrodeGroupList{2} = [electrodeGroupList0{3} electrodeGroupList0{4}]; % Fronto-Central and Frontal
groupNameList{2} = 'Frontal-Central';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
electrodeGroupList{3} = electrodeGroupList0{5}; % Temporal
groupNameList{3} = groupNameList0{5};

electrodeGroupList{4} = [1:4 30:32 (32+[1:5 28:31])];
groupNameList{4} = 'Frontal'; % Frontal
electrodeGroupList{5} = [1 3 4 30 31 32 (32+[1 2 5 28:30])];
groupNameList{5} = 'Sub-Frontal'; % Frontal

%-------------Choosen Groups--23rd Jan------------------

% Combine some groups
electrodeGroupList{1} = highPriorityElectrodeNums; % now called occipital
groupNameList{1} = 'Occipital';

subFrontal            = [1 32      32+[1 2 4 29 30 31]];
subFrontoCental       = [6 8 25 28 32+[9 24]];
electrodeGroupList{2} = [subFrontal subFrontoCental]; % Fronto-Central and Frontal
groupNameList{2}      = 'Sub-FrontoCentral';

end
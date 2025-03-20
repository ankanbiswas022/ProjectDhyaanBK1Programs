% this scripts plots the paired and unpaired data overlayed
% along with showing the gender and age

% load demographics infomration:
% load the demographics data:
[subjectNameList,~,~,ageListAllSub,genderListAllSub] = getDemographicDetails('BK1');
% sub-select based on Gender

% maleSubjectNameList = subjectNameList(strcmpi(genderListAllSub, 'M'));
% femaleSubjectNameList = subjectNameList(strcmpi(genderListAllSub, 'F'));
% if  strcmp(genderStr,'male')
%     subjectNameLists{1} = intersect(subjectNameLists{1},maleSubjectNameList,'stable');
%     subjectNameLists{2} = intersect(subjectNameLists{2},maleSubjectNameList,'stable');
% elseif strcmp(genderStr,'female')
%     subjectNameLists{1} = intersect(subjectNameLists{1},femaleSubjectNameList,'stable');
%     subjectNameLists{2} = intersect(subjectNameLists{2},femaleSubjectNameList,'stable');
% end
% 
% % sub-select based on Age
% ageStr=ageList{get(hAge,'Value')};
% youngSubjectNameList = subjectNameList(ageListAllSub<40);
% midSubjectNameList = subjectNameList(ageListAllSub>=40);

% load the data:
load('dataForG2ProtocolPaired.mat');
load('dataForG2ProtocolUnpaired.mat');
close all

% Create a single figure
hViolin = figure('Name', 'Violin Plot with Gender-Specific Markers');
displaySettings = dataForG2ProtocolUnpaired.displaySettings;

% Ensure required fields exist
if ~isfield(displaySettings,'textFontSize'); displaySettings.textFontSize = 8; end
if ~isfield(displaySettings,'yPositionLine'); displaySettings.yPositionLine = 0.5; end
if ~isfield(displaySettings,'setYLim'); displaySettings.setYLim = [-7 7]; end
if ~isfield(displaySettings,'parametricTest'); displaySettings.parametricTest = 0; end
if ~isfield(displaySettings,'dataMarkerSize'); displaySettings.dataMarkerSize = 12; end

displaySettings.plotAxes = hViolin;

% Find common subjects between paired and unpaired datasets
commonMeditators = intersect(dataForG2ProtocolPaired.subjectList{1,1}, dataForG2ProtocolUnpaired.subjectList{1,1}, 'stable');
commonControls = intersect(dataForG2ProtocolPaired.subjectList{1,2}, dataForG2ProtocolUnpaired.subjectList{1,2}, 'stable');

% Find indices of common subjects in unpaired data
commonDataIndices = cell(1,2);
commonDataIndices{1} = []; % Indices for meditators
commonDataIndices{2} = []; % Indices for controls

for i = 1:length(commonMeditators)
    subjectIdx = find(strcmp(dataForG2ProtocolUnpaired.subjectList{1,1}, commonMeditators{i}));
    if ~isempty(subjectIdx)
        commonDataIndices{1} = [commonDataIndices{1}; subjectIdx];
    end
end

for i = 1:length(commonControls)
    subjectIdx = find(strcmp(dataForG2ProtocolUnpaired.subjectList{1,2}, commonControls{i}));
    if ~isempty(subjectIdx)
        commonDataIndices{2} = [commonDataIndices{2}; subjectIdx];
    end
end

% Map gender and age information
meditatorGender = cell(length(dataForG2ProtocolUnpaired.subjectList{1,1}), 1);
meditatorAge = zeros(length(dataForG2ProtocolUnpaired.subjectList{1,1}), 1); % Store actual age values
controlGender = cell(length(dataForG2ProtocolUnpaired.subjectList{1,2}), 1);
controlAge = zeros(length(dataForG2ProtocolUnpaired.subjectList{1,2}), 1); % Store actual age values

% Get gender and age for meditators
for i = 1:length(dataForG2ProtocolUnpaired.subjectList{1,1})
    subjectName = dataForG2ProtocolUnpaired.subjectList{1,1}{i};
    idx = find(strcmp(subjectNameList, subjectName));
    if ~isempty(idx)
        meditatorGender{i} = genderListAllSub{idx};
        meditatorAge(i) = ageListAllSub(idx); % Store actual age
    else
        meditatorGender{i} = 'U'; % Unknown
        meditatorAge(i) = NaN; % Unknown age
    end
end

% Get gender and age for controls
for i = 1:length(dataForG2ProtocolUnpaired.subjectList{1,2})
    subjectName = dataForG2ProtocolUnpaired.subjectList{1,2}{i};
    idx = find(strcmp(subjectNameList, subjectName));
    if ~isempty(idx)
        controlGender{i} = genderListAllSub{idx};
        controlAge(i) = ageListAllSub(idx); % Store actual age
    else
        controlGender{i} = 'U'; % Unknown
        controlAge(i) = NaN; % Unknown age
    end
end

% Create separate data arrays by gender and age
youngMaleMeditatorData = [];
oldMaleMeditatorData = [];
youngFemaleMeditatorData = [];
oldFemaleMeditatorData = [];
unknownMeditatorData = [];
youngMaleMeditatorIndices = [];
oldMaleMeditatorIndices = [];
youngFemaleMeditatorIndices = [];
oldFemaleMeditatorIndices = [];
unknownMeditatorIndices = [];

youngMaleControlData = [];
oldMaleControlData = [];
youngFemaleControlData = [];
oldFemaleControlData = [];
unknownControlData = [];
youngMaleControlIndices = [];
oldMaleControlIndices = [];
youngFemaleControlIndices = [];
oldFemaleControlIndices = [];
unknownControlIndices = [];

% Separate meditator data by gender and age
for i = 1:length(meditatorGender)
    if strcmp(meditatorGender{i}, 'M')
        if ~isnan(meditatorAge(i)) && meditatorAge(i) < 40
            youngMaleMeditatorData = [youngMaleMeditatorData; dataForG2ProtocolUnpaired.powerData{1}(i)];
            youngMaleMeditatorIndices = [youngMaleMeditatorIndices; i];
        else
            oldMaleMeditatorData = [oldMaleMeditatorData; dataForG2ProtocolUnpaired.powerData{1}(i)];
            oldMaleMeditatorIndices = [oldMaleMeditatorIndices; i];
        end
    elseif strcmp(meditatorGender{i}, 'F')
        if ~isnan(meditatorAge(i)) && meditatorAge(i) < 40
            youngFemaleMeditatorData = [youngFemaleMeditatorData; dataForG2ProtocolUnpaired.powerData{1}(i)];
            youngFemaleMeditatorIndices = [youngFemaleMeditatorIndices; i];
        else
            oldFemaleMeditatorData = [oldFemaleMeditatorData; dataForG2ProtocolUnpaired.powerData{1}(i)];
            oldFemaleMeditatorIndices = [oldFemaleMeditatorIndices; i];
        end
    else
        unknownMeditatorData = [unknownMeditatorData; dataForG2ProtocolUnpaired.powerData{1}(i)];
        unknownMeditatorIndices = [unknownMeditatorIndices; i];
    end
end

% Separate control data by gender and age
for i = 1:length(controlGender)
    if strcmp(controlGender{i}, 'M')
        if ~isnan(controlAge(i)) && controlAge(i) < 40
            youngMaleControlData = [youngMaleControlData; dataForG2ProtocolUnpaired.powerData{2}(i)];
            youngMaleControlIndices = [youngMaleControlIndices; i];
        else
            oldMaleControlData = [oldMaleControlData; dataForG2ProtocolUnpaired.powerData{2}(i)];
            oldMaleControlIndices = [oldMaleControlIndices; i];
        end
    elseif strcmp(controlGender{i}, 'F')
        if ~isnan(controlAge(i)) && controlAge(i) < 40
            youngFemaleControlData = [youngFemaleControlData; dataForG2ProtocolUnpaired.powerData{2}(i)];
            youngFemaleControlIndices = [youngFemaleControlIndices; i];
        else
            oldFemaleControlData = [oldFemaleControlData; dataForG2ProtocolUnpaired.powerData{2}(i)];
            oldFemaleControlIndices = [oldFemaleControlIndices; i];
        end
    else
        unknownControlData = [unknownControlData; dataForG2ProtocolUnpaired.powerData{2}(i)];
        unknownControlIndices = [unknownControlIndices; i];
    end
end

% Clear any existing figure
figure(hViolin); 
clf;
hold on;

% First draw the violin outlines and get the density data
displaySettings.plotQuartiles = 0;
displaySettings.showYTicks = 1; % Enable Y-axis ticks and labels
displaySettings.xTickLabels = {'Med', 'Con'}; % Ensure correct X-axis labels
logPower = dataForG2ProtocolUnpaired.powerData;
[ax, ~, ~, violinData] = displayViolinPlot(logPower, [{displaySettings.colorNames(1,:)} {displaySettings.colorNames(2,:)}], 0, 1, 1, 0, displaySettings);

% Add Y-axis label
ylabel('Delta Power (dB)', 'FontWeight', 'bold');

% Define marker styles
markerSize = 30; % Use consistent marker size
maleMarker = '^'; % Triangle for males
femaleMarker = 'o'; % Circle for females

% Create lighter and darker color versions for young and old subjects
meditatorBaseColor = displaySettings.colorNames(1,:);
controlBaseColor = displaySettings.colorNames(2,:);

% Create lighter versions (for young subjects)
lighterFactor = 0.6; 
youngMeditatorColor = meditatorBaseColor + (1 - meditatorBaseColor) * lighterFactor;
youngControlColor = controlBaseColor + (1 - controlBaseColor) * lighterFactor;

% Create darker versions (for older subjects)
darkerFactor = 0.7;
olderMeditatorColor = meditatorBaseColor * darkerFactor;
olderControlColor = controlBaseColor * darkerFactor;

% Helper function to calculate jitter within violin boundaries
calculateJitterInBounds = @(yValue, pos) calculateViolinJitter(yValue, violinData{pos}.density, ...
                                                            violinData{pos}.value, violinData{pos}.width, pos);

% Store all x-positions for each subject to use when drawing connecting lines
allXPositions = cell(2, 1); % {1} for meditators, {2} for controls
allXPositions{1} = zeros(length(dataForG2ProtocolUnpaired.powerData{1}), 1);
allXPositions{2} = zeros(length(dataForG2ProtocolUnpaired.powerData{2}), 1);

% Plot young male meditators (lighter color)
if ~isempty(youngMaleMeditatorIndices)
    xPos = zeros(size(youngMaleMeditatorIndices));
    for i = 1:length(youngMaleMeditatorIndices)
        xPos(i) = calculateJitterInBounds(youngMaleMeditatorData(i), 1);
        allXPositions{1}(youngMaleMeditatorIndices(i)) = xPos(i);
    end
    hYoungMaleMed = scatter(xPos, youngMaleMeditatorData, markerSize, youngMeditatorColor, maleMarker, 'filled', ...
        'MarkerEdgeColor', 'k', 'LineWidth', 0.5, 'HandleVisibility', 'off');
end

% Plot older male meditators (darker color)
if ~isempty(oldMaleMeditatorIndices)
    xPos = zeros(size(oldMaleMeditatorIndices));
    for i = 1:length(oldMaleMeditatorIndices)
        xPos(i) = calculateJitterInBounds(oldMaleMeditatorData(i), 1);
        allXPositions{1}(oldMaleMeditatorIndices(i)) = xPos(i);
    end
    hOldMaleMed = scatter(xPos, oldMaleMeditatorData, markerSize, olderMeditatorColor, maleMarker, 'filled', ...
        'MarkerEdgeColor', 'k', 'LineWidth', 0.5, 'HandleVisibility', 'off');
end

% Plot young female meditators (lighter color)
if ~isempty(youngFemaleMeditatorIndices)
    xPos = zeros(size(youngFemaleMeditatorIndices));
    for i = 1:length(youngFemaleMeditatorIndices)
        xPos(i) = calculateJitterInBounds(youngFemaleMeditatorData(i), 1);
        allXPositions{1}(youngFemaleMeditatorIndices(i)) = xPos(i);
    end
    hYoungFemaleMed = scatter(xPos, youngFemaleMeditatorData, markerSize, youngMeditatorColor, femaleMarker, 'filled', ...
        'MarkerEdgeColor', 'k', 'LineWidth', 0.5, 'HandleVisibility', 'off');
end

% Plot older female meditators (darker color)
if ~isempty(oldFemaleMeditatorIndices)
    xPos = zeros(size(oldFemaleMeditatorIndices));
    for i = 1:length(oldFemaleMeditatorIndices)
        xPos(i) = calculateJitterInBounds(oldFemaleMeditatorData(i), 1);
        allXPositions{1}(oldFemaleMeditatorIndices(i)) = xPos(i);
    end
    hOldFemaleMed = scatter(xPos, oldFemaleMeditatorData, markerSize, olderMeditatorColor, femaleMarker, 'filled', ...
        'MarkerEdgeColor', 'k', 'LineWidth', 0.5, 'HandleVisibility', 'off');
end

% Apply same pattern for controls
if ~isempty(youngMaleControlIndices)
    xPos = zeros(size(youngMaleControlIndices));
    for i = 1:length(youngMaleControlIndices)
        xPos(i) = calculateJitterInBounds(youngMaleControlData(i), 2);
        allXPositions{2}(youngMaleControlIndices(i)) = xPos(i);
    end
    hYoungMaleCon = scatter(xPos, youngMaleControlData, markerSize, youngControlColor, maleMarker, 'filled', ...
        'MarkerEdgeColor', 'k', 'LineWidth', 0.5, 'HandleVisibility', 'off');
end

if ~isempty(oldMaleControlIndices)
    xPos = zeros(size(oldMaleControlIndices));
    for i = 1:length(oldMaleControlIndices)
        xPos(i) = calculateJitterInBounds(oldMaleControlData(i), 2);
        allXPositions{2}(oldMaleControlIndices(i)) = xPos(i);
    end
    hOldMaleCon = scatter(xPos, oldMaleControlData, markerSize, olderControlColor, maleMarker, 'filled', ...
        'MarkerEdgeColor', 'k', 'LineWidth', 0.5, 'HandleVisibility', 'off');
end

if ~isempty(youngFemaleControlIndices)
    xPos = zeros(size(youngFemaleControlIndices));
    for i = 1:length(youngFemaleControlIndices)
        xPos(i) = calculateJitterInBounds(youngFemaleControlData(i), 2);
        allXPositions{2}(youngFemaleControlIndices(i)) = xPos(i);
    end
    hYoungFemaleCon = scatter(xPos, youngFemaleControlData, markerSize, youngControlColor, femaleMarker, 'filled', ...
        'MarkerEdgeColor', 'k', 'LineWidth', 0.5, 'HandleVisibility', 'off');
end

if ~isempty(oldFemaleControlIndices)
    xPos = zeros(size(oldFemaleControlIndices));
    for i = 1:length(oldFemaleControlIndices)
        xPos(i) = calculateJitterInBounds(oldFemaleControlData(i), 2);
        allXPositions{2}(oldFemaleControlIndices(i)) = xPos(i);
    end
    hOldFemaleCon = scatter(xPos, oldFemaleControlData, markerSize, olderControlColor, femaleMarker, 'filled', ...
        'MarkerEdgeColor', 'k', 'LineWidth', 0.5, 'HandleVisibility', 'off');
end

% Create dedicated legend entries for male and female
hMaleYoung = scatter(-100, -100, markerSize, [0.7 0.7 0.7], maleMarker, 'filled', 'MarkerEdgeColor', 'k'); 
hMaleOld = scatter(-100, -100, markerSize, [0.3 0.3 0.3], maleMarker, 'filled', 'MarkerEdgeColor', 'k'); 
hFemaleYoung = scatter(-100, -100, markerSize, [0.7 0.7 0.7], femaleMarker, 'filled', 'MarkerEdgeColor', 'k'); 
hFemaleOld = scatter(-100, -100, markerSize, [0.3 0.3 0.3], femaleMarker, 'filled', 'MarkerEdgeColor', 'k'); 

% Add comprehensive legend with gender and age information
legend([hMaleYoung, hMaleOld, hFemaleYoung, hFemaleOld], ...
       {'Male <40', 'Male ≥40', 'Female <40', 'Female ≥40'}, ...
       'Location', 'best');

% Add connecting lines for common subjects
if ~isempty(commonMeditators) && ~isempty(commonControls)
    % Calculate p-value for paired data using common subjects
    pairedMedData = [];
    pairedConData = [];
    
    % Extract paired data for common subjects
    for i = 1:length(commonMeditators)
        medIdx = find(strcmp(dataForG2ProtocolPaired.subjectList{1,1}, commonMeditators{i}));
        if ~isempty(medIdx)
            pairedMedData = [pairedMedData; dataForG2ProtocolPaired.powerData{1}(medIdx)];
        end
    end
    
    for i = 1:length(commonControls)
        conIdx = find(strcmp(dataForG2ProtocolPaired.subjectList{1,2}, commonControls{i}));
        if ~isempty(conIdx)
            pairedConData = [pairedConData; dataForG2ProtocolPaired.powerData{2}(conIdx)];
        end
    end
    
    % Draw connecting lines between existing data points for common subjects
    for i = 1:min(length(commonDataIndices{1}), length(commonDataIndices{2}))
        medIdx = commonDataIndices{1}(i);
        conIdx = commonDataIndices{2}(i);
        
        % Use the stored x-positions from when we plotted the data points
        medX = allXPositions{1}(medIdx);
        conX = allXPositions{2}(conIdx);
        
        medY = dataForG2ProtocolUnpaired.powerData{1}(medIdx);
        conY = dataForG2ProtocolUnpaired.powerData{2}(conIdx);
        
        % Draw connecting line using existing data points - hide from legend
        plot([medX conX], [medY conY], 'Color', [0.5 0.5 0.5], 'LineWidth', 1, 'HandleVisibility', 'off');
    end
    
    % Calculate and display p-values
    if length(pairedMedData) == length(pairedConData) && ~isempty(pairedMedData)
        if displaySettings.parametricTest
            [~, p_paired, ~, ~] = ttest(pairedMedData, pairedConData);
        else
            [p_paired, ~, ~] = signrank(pairedMedData, pairedConData);
        end
        
        % Get the p-value for unpaired data directly
        if displaySettings.parametricTest
            [~, p_unpaired, ~, ~] = ttest2(dataForG2ProtocolUnpaired.powerData{1}, dataForG2ProtocolUnpaired.powerData{2});
        else
            [p_unpaired, ~, ~] = ranksum(dataForG2ProtocolUnpaired.powerData{1}, dataForG2ProtocolUnpaired.powerData{2});
        end
        
        % Display p-values with significance markers
        yTop = displaySettings.setYLim(2);
        
        % Show unpaired p-value
        if p_unpaired > 0.05
            text(1.5, yTop + displaySettings.yPositionLine*2, ['Unpaired: N.S. (' num2str(round(p_unpaired,3)) ')'], ...
                'FontSize', displaySettings.textFontSize, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
        elseif p_unpaired > 0.01
            text(1.5, yTop + displaySettings.yPositionLine*2, ['Unpaired: * (' num2str(round(p_unpaired,3)) ')'], ...
                'FontSize', displaySettings.textFontSize, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
        elseif p_unpaired > 0.005
            text(1.5, yTop + displaySettings.yPositionLine*2, ['Unpaired: ** (' num2str(round(p_unpaired,3)) ')'], ...
                'FontSize', displaySettings.textFontSize, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
        else
            text(1.5, yTop + displaySettings.yPositionLine*2, ['Unpaired: *** (' num2str(round(p_unpaired,3)) ')'], ...
                'FontSize', displaySettings.textFontSize, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
        end
        
        % Show paired p-value
        if p_paired > 0.05
            text(1.5, yTop - displaySettings.yPositionLine, ['Paired: N.S. (' num2str(round(p_paired,3)) ')'], ...
                'FontSize', displaySettings.textFontSize, 'FontWeight', 'bold', 'BackgroundColor', [0.95 0.95 0.95], ...
                'EdgeColor', [0.7 0.7 0.7], 'HorizontalAlignment', 'center');
        elseif p_paired > 0.01
            text(1.5, yTop - displaySettings.yPositionLine, ['Paired: * (' num2str(round(p_paired,3)) ')'], ...
                'FontSize', displaySettings.textFontSize, 'FontWeight', 'bold', 'BackgroundColor', [0.95 0.95 0.95], ...
                'EdgeColor', [0.7 0.7 0.7], 'HorizontalAlignment', 'center');
        elseif p_paired > 0.005
            text(1.5, yTop - displaySettings.yPositionLine, ['Paired: ** (' num2str(round(p_paired,3)) ')'], ...
                'FontSize', displaySettings.textFontSize, 'FontWeight', 'bold', 'BackgroundColor', [0.95 0.95 0.95], ...
                'EdgeColor', [0.7 0.7 0.7], 'HorizontalAlignment', 'center');
        else
            text(1.5, yTop - displaySettings.yPositionLine, ['Paired: *** (' num2str(round(p_paired,3)) ')'], ...
                'FontSize', displaySettings.textFontSize, 'FontWeight', 'bold', 'BackgroundColor', [0.95 0.95 0.95], ...
                'EdgeColor', [0.7 0.7 0.7], 'HorizontalAlignment', 'center');
        end
    end
    
    fprintf('Found %d common meditators and %d common controls between paired and unpaired datasets\n', ...
        length(commonMeditators), length(commonControls));
else
    fprintf('No common subjects found between paired and unpaired datasets\n');
end

title('Violin Plot with Gender-Specific Markers and P-values');

% Add helper function at the end of the script
function xPos = calculateViolinJitter(yValue, density, value, width, pos)
    % Calculate jitter exactly the way displayViolinPlot does it
    [~, unique_idx] = unique(value);
    
    % Interpolate jitter strength based on the density at the y-value
    jitterstrength = interp1(value(unique_idx), density(unique_idx)*width, yValue, 'linear', 'extrap');
    
    % Apply random jitter between -1 and 1
    jitter = 2*(rand()-0.5);
    
    % Calculate position
    xPos = pos + jitter*jitterstrength;
end



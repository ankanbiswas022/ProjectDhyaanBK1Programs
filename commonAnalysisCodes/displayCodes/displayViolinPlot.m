function [ax, xPosDataGroups, dataValues, violinData]=displayViolinPlot(dataArray,colorArray,showData,plotMean,showSignificance,pairedDataFlag,displaySettings)
% displayViolinPlot makes the violin plots using the kernel desnsity estimate
% of the original data, kernel density is estimated using the Matlab statistical toolbox function, ksdensity
% The code is adapted from the original source, "https://github.com/bastibe/Violinplot-Matlab"
% To know about the violinplot please refer to "stat.cmu.edu/~rnugent/PCMI2016/papers/ViolinPlots.pdf"

if ~exist('plotMean','var');                      plotMean=0;                                     end
if ~exist('displaySettings','var');               displaySettings=struct();                       end
if ~isfield(displaySettings,'alpha');             displaySettings.alpha=0.3;                      end
if ~isfield(displaySettings,'dataMarkerSize');    displaySettings.dataMarkerSize=12;              end
if ~isfield(displaySettings,'medianMarkerSize');  displaySettings.medianMarkerSize=20;            end
if ~isfield(displaySettings,'textFontSize');      displaySettings.textFontSize=8;                 end
if ~isfield(displaySettings,'yPositionLine');     displaySettings.yPositionLine=0.5;              end
if ~isfield(displaySettings,'xPositionText');     displaySettings.xPositionText=0.5;              end
if ~isfield(displaySettings,'plotAxes');          displaySettings.plotAxes=gca;                   end
if ~isfield(displaySettings,'showYTicks');        displaySettings.showYTicks=0;                   end
if ~isfield(displaySettings,'setYLim');           displaySettings.setYLim=[-7 7];                 end
if ~isfield(displaySettings,'commonYLim');        displaySettings.commonYLim=0;                   end
if ~isfield(displaySettings,'showXTicks');        displaySettings.showXTicks=1;                   end
if ~isfield(displaySettings,'xTickLabels');       displaySettings.xTickLabels=[{'Med'},{'Con'}];  end
if ~isfield(displaySettings,'parametricTest');    displaySettings.parametricTest=0;               end
if ~isfield(displaySettings,'tickLengthMedium');  displaySettings.tickLengthMedium=[0.025 0];     end
if ~isfield(displaySettings,'plotQuartiles');     displaySettings.plotQuartiles=0;                end
if ~isfield(displaySettings,'BoxWidth');          displaySettings.BoxWidth=0.005;                end

alpha            = displaySettings.alpha;
dataMarkerSize   = displaySettings.dataMarkerSize ;
medianMarkerSize = displaySettings.medianMarkerSize;
textFontSize     = displaySettings.textFontSize;
yPositionLine    = displaySettings.yPositionLine;
xPositionText    = displaySettings.xPositionText;
setYLim          = displaySettings.setYLim;
commonYLim       = displaySettings.commonYLim;
showXTicks       = displaySettings.showXTicks;
showYTicks       = displaySettings.showYTicks;  % Extract showYTicks from displaySettings
xTickLabels      = displaySettings.xTickLabels;
parametricTest   = displaySettings.parametricTest;
plotQuartiles    = displaySettings.plotQuartiles;
BoxWidth         = displaySettings.BoxWidth;

% get the data in the cell array
bandwidth = [];
Y{:,1}=dataArray{1,1};
Y{:,2}=dataArray{1,2};

% set Plot Options:
axes(displaySettings.plotAxes);
ax=gca;
set(ax,'TickDir','out','TickLength',displaySettings.tickLengthMedium);
ax.XTick=[1 2];
if showXTicks
    ax.XTickLabel = xTickLabels;
else
    ax.XTickLabel = [];
end

% Enable Y tick marks if requested
if showYTicks
    set(ax, 'YTickMode', 'auto'); % Show Y-axis tick marks
    set(ax, 'Box', 'off'); % Cleaner look
else
    set(ax, 'YTickLabel', []); % Hide Y-axis labels
end

% calculate kernel density
meanData = zeros(1,size(Y,2));
semData  = zeros(1,size(Y,2));
xPosDataGroups = cell(1, size(Y,2));
dataValues = Y;
violinData = cell(1, size(Y,2)); % Store violin data for later use

for pos=1:size(Y,2)
    width = 0.3;
    data = Y{pos};
    [density, value] = ksdensity(data,'bandwidth',bandwidth);
    density = density(value >= min(data) & value <= max(data));
    value = value(value >= min(data) & value <= max(data));
    value(1) = min(data);
    value(end) = max(data);
    value = [value(1)*(1-1E-10), value, value(end)*(1+1E-10)];
    density = [0, density, 0];

    % violinWidth and the boxWidth
    width = width/max(density);
    
    % Store data for external use
    violinData{pos}.density = density;
    violinData{pos}.value = value;
    violinData{pos}.width = width;

    % plot violin plot
    patch([pos+density*width pos-density(end:-1:1)*width], ...
        [value value(end:-1:1)],...
        colorArray{pos},'FaceAlpha',alpha);
    hold on

    if showData
        [~, unique_idx] = unique(value);
        jitterstrength = interp1(value(unique_idx), density(unique_idx)*width, data, 'linear','extrap');
        jitter = 2*(rand(size(data))-0.5);
        xPosData = pos + jitter.*jitterstrength;
        xPosDataGroups{pos} = xPosData;
        
        % Only call scatter if dataMarkerSize is positive
        if dataMarkerSize > 0
            scatter(xPosData, data, dataMarkerSize, 'filled', 'MarkerFaceColor', colorArray{pos});
        end
    else
        % Even if not showing data, still need to generate positions for potential later use
        jitter = 0.1 * (2*(rand(size(data))-0.5));
        xPosDataGroups{pos} = pos + jitter;
    end

    meanData(pos) = mean(data,'omitnan');
    semData(pos)  = std(data,'omitnan')./sqrt(nnz(~isnan(data)));

    if plotQuartiles
        quartiles = quantile(data, [0.25, 0.5, 0.75]);
        IQR = quartiles(3) - quartiles(1);
        lowhisker = quartiles(1) - 1.5*IQR;
        lowhisker = max(lowhisker, min(data(data > lowhisker)));
        hiwhisker = quartiles(3) + 1.5*IQR;
        hiwhisker = min(hiwhisker, max(data(data < hiwhisker)));

        patch(pos+[-1,1,1,-1]*(BoxWidth+0.005), ...
            [quartiles(1) quartiles(1) quartiles(3) quartiles(3)], ...
            [0 0 0]);
        plot([pos pos], [lowhisker hiwhisker]);
        scatter(pos, quartiles(2), medianMarkerSize, [1 1 1], 'filled');
    end
end

if pairedDataFlag
    for i=1:length(Y{1,1})
        xPosLine = [xPosDataGroups{1}(i) xPosDataGroups{2}(i)];
        yPosLine = [Y{1,1}(i) Y{1,2}(i)];
        plot(xPosLine,yPosLine,'Color',[0.8 0.8 0.8]);
    end
end

if plotMean
    for pos=1:size(Y,2)
        patch(pos+[-1,1,1,-1]*(BoxWidth+0.005), ...
            [meanData(pos)-semData(pos) meanData(pos)-semData(pos) meanData(pos)+semData(pos) meanData(pos)+semData(pos)], ...
            [1 1 1]);
        scatter(pos, meanData(pos), medianMarkerSize+20, [0 0 0], 'filled');
    end
end

if showSignificance
    if pairedDataFlag
        if parametricTest
            [~, p, ~, ~] = ttest(Y{:,1},Y{:,2});
        else
            % Perform Wilcoxon signed-rank test
            [p, ~, ~] = signrank(Y{:,1},Y{:,2});
        end
    else
        if parametricTest
            [~, p, ~, ~] = ttest2(Y{:,1},Y{:,2});
        else
            % Perform Mann-Whitney U test
            [p,~,~] = ranksum(Y{:,1},Y{:,2});
        end
    end

    xPos = 1:size(Y,2);
    commonMax=max([max(Y{:,1}) max(Y{:,2})]);
    commonMin = min([max(Y{:,1}) min(Y{:,2})]);

    if commonYLim
        set(ax,'YLim',setYLim);
    else
        % Determine Y-axis limits based on data range
        dataMin = min([min(Y{:,1}) min(Y{:,2})]);
        dataMax = max([max(Y{:,1}) max(Y{:,2})]);
        yRangeBuffer = (dataMax - dataMin) * 0.1; % Add 10% buffer to y-axis range
        set(ax,'YLim',[dataMin-yRangeBuffer dataMax+yPositionLine*6]);
    end

    % shows the p-value
    if p>0.05
        text(mean(xPos)-xPositionText/2,setYLim(2)+yPositionLine,['N.S. (' num2str(round(p,3)) ')'],'FontSize',textFontSize,'FontWeight','bold');
    elseif p>0.01
        text(mean(xPos)-xPositionText/2,setYLim(2)+yPositionLine,['* (' num2str(round(p,3)) ')'],'FontSize',textFontSize,'FontWeight','bold');
    elseif p>0.005
        text(mean(xPos)-xPositionText/2,setYLim(2)+yPositionLine,['** (' num2str(round(p,3)) ')'],'FontSize',textFontSize,'FontWeight','bold');
    else
        text(mean(xPos)-xPositionText/2,setYLim(2)+yPositionLine,['*** (' num2str(round(p,3)) ')'],'FontSize',textFontSize,'FontWeight','bold');
    end
end
end
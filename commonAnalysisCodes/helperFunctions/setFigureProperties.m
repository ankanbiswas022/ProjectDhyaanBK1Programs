% Set figure properties
% Vinay Shirhatti, 04 May 2017
%&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

function figH = setFigureProperties(usedefault)
if ~exist('usedefault','var'); usedefault=1; end
if usedefault
figH = figure;
figH.Color = [1 1 1];
else
figH = figure;
fullwidth = 18.3;
fullheight = 24.7;

% NATURE
figH.PaperPositionMode = 'manual';
figH.PaperUnits = 'centimeters';
figH.Units = 'centimeters';
fullwidth = 18.3; halfwidth = 8.9; 
oneandhalfwidth1 = 12; oneandhalfwidth2 = 13.6;
fullheight = 24.7;
figH.PaperPosition = [0, 0, fullwidth, fullheight];
figH.PaperSize = [fullwidth, fullheight];
figH.Position = [0, 0, fullwidth, fullheight/2];
figH.Resize = 'on';
figH.InvertHardcopy = 'off';
figH.Color = [1 1 1];
% figH.FontName = 'Helvetica';
set(0,'defaultLineLineWidth',1);
set(figH,'Renderer','painters');
end
end
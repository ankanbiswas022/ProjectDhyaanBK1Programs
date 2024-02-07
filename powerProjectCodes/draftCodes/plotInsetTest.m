% Draw a small plot inset to a larger one.
% Ref: https://www.mathworks.com/matlabcentral/answers/60376-how-to-make-an-inset-of-matlab-figure-inside-the-figure#comment_654093
% Another: https://www.mathworks.com/help/matlab/ref/axes.html?s_tid=doc_ta#buzt8qr-2

clc;    % Clear the command window.
close all;  % Close all figures (except those of imtool.)
clear;  % Erase all existing variables. Or clearvars if you want.
workspace;  % Make sure the workspace panel is showing.
format long g;
format compact;
fontSize = 18;

x1 = linspace(0, 1);
x2 = linspace(3/4, 1);
y1 = sin(2*pi*x1);
y2 = sin(2*pi*x2);
figure(1)
% plot on large axes
plot(x1, y1, 'LineWidth', 2)
grid on;
ax1 = gca; % Store handle to axes 1.

% Create smaller axes in top right, and plot on it
% Store handle to axes 2 in ax2.
ax2 = axes('Position',[.7 .7 .2 .2])
box on;
plot(x2, y2, 'b-', 'LineWidth', 2)
grid on;

% Now draw something back on axis 1
hold(ax1, 'on'); % Don't blow away existing curve.
y1b = cos(2*pi*x1/3);
plot(ax1, x1, y1b, 'r-', 'LineWidth', 2);

% Now draw something back on axis 2
hold(ax2, 'on'); % Don't blow away existing curve.
y2b = cos(2*pi*x2/3);
plot(ax2, x2, y2b, 'r-', 'LineWidth', 2);

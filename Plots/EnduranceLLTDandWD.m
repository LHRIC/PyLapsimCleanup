function EnduranceLLTDandWD(xdata1, ydata1, zdata1)
%CREATEFIGURE(xdata1, ydata1, zdata1)
%  XDATA1:  surface xdata
%  YDATA1:  surface ydata
%  ZDATA1:  surface zdata

%  Auto-generated by MATLAB on 22-Oct-2022 10:40:10

% Create figure
figure1 = figure('WindowState','maximized');

% Create axes
axes1 = axes('Parent',figure1);
hold(axes1,'on');

% Create surf
surf(xdata1,ydata1,zdata1,'Parent',axes1);

% Create zlabel
zlabel('Endurance Time (s)','FontSize',18);

% Create ylabel
ylabel('LLTD','FontSize',18);

% Create xlabel
xlabel('Weight Distribution','FontSize',18);

% Create title
title('Endurance time sensitivity to LLTD and Weight Distribution',...
    'FontWeight','bold',...
    'FontSize',24);

view(axes1,[90.0036320651504 15.5497155474082]);
grid(axes1,'on');
hold(axes1,'off');
% Create colorbar
colorbar(axes1);

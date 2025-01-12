function EnduranceFrictionlong(X1, Y1)
%CREATEFIGURE1(X1, Y1)
%  X1:  vector of plot x data
%  Y1:  vector of plot y data

%  Auto-generated by MATLAB on 22-Oct-2022 12:08:46

% Create figure
figure1 = figure('WindowState','maximized');

% Create axes
axes1 = axes('Parent',figure1);
hold(axes1,'on');

% Create multiple line objects using matrix input to plot
plot(X1,Y1,'o',X1,Y1)

% Create ylabel
ylabel('Endurance Time (s)','FontSize',18);

% Create xlabel
xlabel('Longitdinal Friction Scaling','FontSize',18);

% Create title
title('Endurance time sensitivity to Longitudinal Friction Scaling',...
    'FontWeight','bold',...
    'FontSize',24);

box(axes1,'on');
grid(axes1,'on');
hold(axes1,'off');
% Set the remaining axes properties
set(axes1,'XMinorGrid','on','YMinorGrid','on','ZMinorGrid','on');

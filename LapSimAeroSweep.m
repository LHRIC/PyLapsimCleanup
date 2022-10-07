%%% LapSim Aero Sweep

clear all;
clc

% Vechicle Paramaters

%% Section 1: Vehicle Architecture
%disp('Loading Vehicle Characteristics')
% These are the basic vehicle architecture primary inputs:
LLTD = 51.5; % Front lateral load transfer distribution (%)
WBase = 600; % vehicle + driver weight (lbs)
WDF = 50; % front weight distribution (%)
cg = 13.2/12; % center of gravity height (ft)
l = 60.5/12; % wheelbase (ft)
twf = 46/12; % front track width (ft)
twr = 44/12; % rear track width (ft)

%% Section 2: Input Suspension Kinematics
%disp('Loading Suspension Kinematics')
% this section is actually optional. So if you set everything to zero, you
% can essentially leave this portion out of the analysis. Useful if you are
% only trying to explore some higher level relationships

% Pitch and roll gradients define how much the car's gonna move around
rg_f = 0; % front roll gradient (deg/g)
rg_r = 0; % rear roll gradient (deg/g)
pg = 0; % pitch gradient (deg/g)
WRF = 180; % front and rear ride rates (lbs/in)
WRR = 180; 

% then you can select your camber alignment
IA_staticf = 0; % front static camber angle (deg)
IA_staticr = 0; % rear static camber angle (deg)
IA_compensationf = 10; % front camber compensation (%)
IA_compensationr = 20; % rear camber compensation (%)

% lastly you can select your kingpin axis parameters
casterf = 0; % front caster angle (deg)
KPIf = 0; % front kingpin inclination angle (deg)
casterr = 4.1568; % rear caster angle (deg)
KPIr = 0; % rear kingpin inclination angle (deg)

%% Section 3: Input Aero Parameters
%disp('Loading Aero Model')

CoP = 48; % front downforce distribution (%)

CLA = [-2.9:0.2:0.5] * -0.3345 * 0.03824; % Lift equation without Velocity component

cdOffsetM = [0:0.1:0.4] * 0.3345 * 0.03824;

k = 1;

IterTotal = length(CLA) * length(cdOffsetM);

fprintf('Running %.0f iterations.\n', IterTotal);

for j = 1:length(cdOffsetM)
    
    cdOffset = cdOffsetM(j);
    
for i = 1:length(CLA)

    Cl = CLA(i);
    Cd = 0.24 * Cl + (0.3 * 0.3345 * 0.03824) + cdOffset;

    W = WBase + (1.85 + 357*Cl + 10721*Cl^2);

LapSimOutput = LapSim(LLTD, W, WDF, cg, l, twf, twr, rg_f, rg_r,pg, WRF, WRR, IA_staticf, IA_staticr, IA_compensationr, IA_compensationf, casterf, KPIf, casterr, KPIr, Cl, Cd, CoP);

T_axismax = max(LapSimOutput.time_elapsed);

ClaM(k) = Cl;
CdaM(k) = Cd;
TimeM(k) = T_axismax;
WeightM(k) = W;

clear LapSimOutput

fprintf('Completed iteration %.0f of %.0f.\n', k, IterTotal);

k = k + 1;

end

end

figure(3)
xlin = linspace(min(ClaM), max(ClaM), 100);
ylin = linspace(min(CdaM), max(CdaM), 100);
[X,Y] = meshgrid(xlin, ylin);
Z = griddata(ClaM,CdaM,TimeM,X,Y,'v4');
[dfdx, dfdy] = gradient(Z);
s = mesh(X/(-0.3345 * 0.03824),Y/(0.3345 * 0.03824),Z, sqrt(dfdx.^2 + dfdy.^2));
colormap(turbo);
axis tight; hold on
plot3(ClaM/(-0.3345 * 0.03824),CdaM/(0.3345 * 0.03824),TimeM,'m.','MarkerSize',5)
s.FaceColor = 'interp';
s.EdgeColor = 'none';
xlabel('Cla')
ylabel('Cda')
zlabel('Time(s)')
g = colorbar;
title(g, 'gradient')
caxis([0 0.1])
hold off
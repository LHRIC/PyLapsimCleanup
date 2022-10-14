%% SETUP
close all;
clear all;
clc;

g = 9.81;

%% Car Specs

% Vehicle Specs
Rt = 0.2032; % wheel radius
redline = 12000; % desired maximum rpm
acc_max = 100;

% Engine Data 
engine_torque_data = readmatrix('Inline_Torque.csv');
engine_primary_reduction = 1;
engine_gear_ratio = [33/12, 32/16, 30/18, 26/18, 30/23, 29/24];

% Plots Engine Data
figure();
    plot(engine_torque_data(:,1), engine_torque_data(:,2))
    title("Engine Torque Curve")
    xlabel("RPM")
    ylabel("Torque (Nm)")

% Effictive Mass Calculation
 effective_mass = 294.835;

% Final Drive Ratio
final_drive_ratio = 5;

%% Accel Test 

engine_gear_ratio = engine_gear_ratio .* engine_primary_reduction;

% Trims Engine Data to fit inside rpm bounds (0, redline)
redline_I = find(engine_torque_data(:,1)>redline);
engine_torque_data = engine_torque_data(1:redline_I(1),:);

% Data conversion factors
rpm_mps = (2*pi()*Rt)/60; % rpm to m/s
Nm_mps2 = 1/(Rt*effective_mass); % Nm to m/s2

% Converts engine torque data to acceleration(m/s2) / velocity(m/s) 
engine_acc_vel = [engine_torque_data(:,1)*rpm_mps, engine_torque_data(:,2)*Nm_mps2];

% Declare
time_calc = @(FDr) Torque_Curve_Optimizer(engine_acc_vel, acc_max, engine_gear_ratio, FDr, 75, false);

% DONT QUESTION THIS, I'm too dumb to debug why fminsearch is not working and this is my solution
times = [];
i_range = linspace(1,10,50);
for i = i_range
    times = [times, time_calc(i)];
end 
figure();
    plot(i_range, times)
    xlabel("Final Drive Ratio")
    ylabel("75m Drag Time")

times = [];
i_range = linspace(2,6,200);
for i = i_range
    times = [times, time_calc(i)];
end 
figure();
    plot(i_range, times)
    xlabel("Final Drive Ratio")
    ylabel("75m Drag Time")

[~,min_I] = min(times);
final_drive_ratio = i_range(min_I);

disp("75m drag time:")
disp(Torque_Curve_Optimizer(engine_acc_vel, acc_max, engine_gear_ratio, final_drive_ratio, 75, true))

disp("Final Drive Ratio:")
disp(final_drive_ratio)
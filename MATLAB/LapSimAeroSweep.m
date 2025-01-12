%%% LapSim Aero Sweep

clear all;
clc

% Vechicle Paramaters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% OPTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
showPlots = false;
sweepControl = [0 0 1 0];
saveParam = 0;
parforvalue = 1;
sf_x = 0.6;
sf_y = 0.6;
tqMod = 1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Section 1: Vehicle Architecture
% These are the basic vehicle architecture primary inputs:
LLTD = 0.515; % Front lateral load transfer distribution (%)
WBase = 650; % vehicle + driver weight (lbs)
WDF = .45; % front weight distribution (%)
cg = 12.5; % center of gravity height (ft)
L = 60.63/12; % wheelbase (ft)
twf = 50.5/12; % front track width (ft)
twr = 48.5/12; % rear track width (ft)

WBase = WBase*4.4482216153; % convert to N
cg = cg/39.37; % conver to m
L = L/3.280839895013123; % convert to m
twf = twf/3.280839895013123; % convert to m
twr = twr/3.280839895013123; % convert to m

FD = 37/11;

%% Section 2: Input Suspension Kinematics
% this section is actually optional. So if you set everything to zero, you
% can essentially leave this portion out of the analysis. Useful if you are
% only trying to explore some higher level relationships

% Pitch and roll gradients define how much the car's gonna move around
rg_f = 0; % front roll gradient (deg/g)
rg_r = 0; % rear roll gradient (deg/g)
pg = 0; % pitch gradient (deg/g)
WRF = 31522.830300000003; % front and rear ride rates (N/m)
WRR = 31522.830300000003; 

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

CoP = 0.48; % front downforce distribution (%)

CLA = [-4:0.05:0.3] * -0.6125; % Lift equation without Velocity component

cdOffsetM = [0:0.025:0.5] * 0.6125;

%% Section 4: CL-CD Sweep

if sweepControl(1) == 1

    k = 1;

    IterTotal = length(CLA) * length(cdOffsetM);
    fprintf('Running %.0f iterations of CL-CD sweep.\n', IterTotal);

    for j = 1:length(cdOffsetM)
    
        cdOffset = cdOffsetM(j);
    
        for i = 1:length(CLA)

            Cl = CLA(i);
            Cd = 0.24 * Cl + (0.3 * 0.6125) + cdOffset;

            W = WBase + (5.38 + 24.7*Cl + 23.7*Cl^2);
    
            LapSimOutput = LapSim(LLTD, W, WDF, cg, L, twf, twr, rg_f, rg_r,pg, WRF, WRR, IA_staticf, IA_staticr, IA_compensationr, IA_compensationf, casterf, KPIf, casterr, KPIr, Cl, Cd, CoP, tqMod, showPlots, sf_x, sf_y, parforvalue, FD);

            T_axismax = max(LapSimOutput.time_elapsed);

            ClaM(k) = Cl;
            CdaM(k) = Cd;
            TimeM(k) = T_axismax;
            WeightM(k) = W;

            clear LapSimOutput

            fprintf('Completed iteration %.0f of %.0f.\n', k, IterTotal);
            fprintf('Config with CLA of %.2f, CDA of %.2f, and weight of %.2f resulted with a time of %.2f seconds.\n', (Cl / (-0.6125)), (Cd / (0.6125)), W, T_axismax);

            k = k + 1;

        end

    end

end

%% Section 5: CoP Sweep

if sweepControl(2) == 1

    ClaSet = [-2.9 -1.75 -1] * 0.6125;
    CdaSet = [1.1 0.75 0.5] * 0.6125;

    CoPRange = [0.25:0.025:0.85];

    IterTotalCoP = length(CoPRange) * length(ClaSet);
    fprintf('Running %.0f iterations CoP sweep.\n', IterTotalCoP);

    for iCoP = 1:length(ClaSet)
    
        kCoP = 1;
    
        ClaSetI = ClaSet(iCoP);
        CdaSetI = CdaSet(iCoP);

        for kCoP = 1:length(CoPRange)
    
            CoPC = CoPRange(kCoP);
   
            LapSimOutput = LapSim(LLTD, WBase, WDF, cg, L, twf, twr, rg_f, rg_r,pg, WRF, WRR, IA_staticf, IA_staticr, IA_compensationr, IA_compensationf, casterf, KPIf, casterr, KPIr, ClaSetI, CdaSetI, CoPC, tqMod, showPlots, sf_x, sf_y, parforvalue, FD);

            T_axismax = max(LapSimOutput.time_elapsed);
    
            TimeMCoP(kCoP, iCoP) = T_axismax;

            clear LapSimOutput

            fprintf('Completed iteration %.0f of %.0f.\n', kCoP + (length(CoPRange)*(iCoP - 1)), IterTotalCoP);
            fprintf('Config with CLA of %.2f, CDA of %.2f, and weight of %.2f resulted with a time of %.2f seconds.\n', (ClaSetI / (-0.6125)), (CdaSetI / (0.6125)), WBase, T_axismax);

        end

    end

end

%% Section 6: CoP + CG Sweep

if sweepControl(3) == 1

    CoPRange2 = [0.35:0.025:0.65];

    CGRange = [0.40:0.0125:0.60];

    ClaSet = -2.9 * 0.6125;
    CdaSet = 1.1 * 0.6125;

    IterTotalCoPCG = length(CoPRange2) * length(CGRange);

    kCoPCG = 1;

    fprintf('Running %.0f iterations CoP-CG sweep.\n', IterTotalCoPCG);

    for iCG = 1:length(CGRange)

        CG = CGRange(iCG);

        for iCoPG = 1:length(CoPRange2)
   
            CoPCG = CoPRange2(iCoPG);

            LapSimOutput = LapSim(LLTD, WBase, CG, cg, L, twf, twr, rg_f, rg_r,pg, WRF, WRR, IA_staticf, IA_staticr, IA_compensationr, IA_compensationf, casterf, KPIf, casterr, KPIr, ClaSet, CdaSet, CoPCG, tqMod, showPlots, sf_x, sf_y, parforvalue, FD);

            T_axismax = max(LapSimOutput.time_elapsed);

            TimeMCoPCG(kCoPCG) = T_axismax;

            CoPM(kCoPCG) = CoPCG;
            CGM(kCoPCG) = CG;

            clear LapSimOutput

            fprintf('Completed iteration %.0f of %.0f.\n', kCoPCG, IterTotalCoPCG);

            fprintf('Config with CLA of %.2f, CDA of %.2f, and weight of %.2f resulted with a time of %.2f seconds.\n', (ClaSet / (-0.6125)), (CdaSet / (0.6125)), WBase, T_axismax);

            kCoPCG = kCoPCG + 1;

        end

    end

end

%% Section 7: Balance Sweep
% set lower Cl (like -2.5) at the best CoP and CG combo. Then gradually
% increase Cl and move CoP forward to see how times change (representing
% increasing fwng performance)

if sweepControl(4) == 1

    CoPB = 0.35;

    CdaB = 0.9;

    ClaB = -2.5;

    ClaDelta = [0:0.0125:1.5];

    IterTotalB = length(ClaDelta);

    fprintf('Running %.0f iterations Balance sweep.\n', IterTotalB);

    for iB = 1:length(ClaDelta)

        ClaNew = ClaB - ClaDelta(iB);

        CoPShift = (2.25 * ClaDelta(iB) - L * CoPB * ClaDelta(iB))/(-1 * ClaB + ClaDelta(iB));

        CoPNew = (L * CoPB + CoPShift)/L;

        LapSimOutput = LapSim(LLTD, WBase, WDF, cg, L, twf, twr, rg_f, rg_r,pg, WRF, WRR, IA_staticf, IA_staticr, IA_compensationr, IA_compensationf, casterf, KPIf, casterr, KPIr, (ClaNew * -0.6125), (CdaB * 0.6125), CoPNew, tqMod, showPlots, sf_x, sf_y, parforvalue, FD);

        T_axismax = max(LapSimOutput.time_elapsed);

        TimeBM(iB) = T_axismax;
        ClaBM(iB) = ClaNew;
        CoPBM(iB) = CoPNew;

        clear LapSimOutput

        fprintf('Completed iteration %.0f of %.0f.\n', iB, IterTotalB);
        fprintf('Config with CLA of %.2f, CoP of %.2f, and base CoP of %.2f resulted with a time of %.2f seconds.\n', ClaNew, CoPNew, CoPB, T_axismax);

    end

end

%% Section 000: Data Visualization

if saveParam == 1

    save('AeroSweepData.mat', 'ClaM', 'CdaM', 'TimeM', 'WeightM', 'CoPRange', 'TimeMCoP', 'CoPM', 'CGM', 'TimeMCoPCG', 'CoPBM', 'TimeBM', 'ClaBM');

end

if sweepControl(1) == 1

    figure(1)
    xlin = linspace(min(ClaM), max(ClaM), 100);
    ylin = linspace(min(CdaM), max(CdaM), 100);
    [X,Y] = meshgrid(xlin, ylin);
    Z = griddata(ClaM,CdaM,TimeM,X,Y,'natural');
    [dfdx, dfdy] = gradient(Z);
    s = mesh(X/(-0.6125),Y/(0.6125),Z, sqrt(dfdx.^2 + dfdy.^2));
    colormap(turbo);
    axis tight; hold on
    plot3(ClaM/(-0.6125),CdaM/(0.6125),TimeM,'m.','MarkerSize',5)
    s.FaceColor = 'interp';
    s.EdgeColor = 'none';
    zlim([min(TimeM) max(TimeM)])
    title('CLA-CDA-Time Plot', 'fontsize', 15)
    xlabel('Cla', 'fontsize', 15)
    ylabel('Cda', 'fontsize', 15)
    zlabel('Time(s)', 'fontsize', 15)
    g = colorbar;
    % fontsize(g, 30, 'pixels')
    title(g, 'gradient', 'fontsize', 15)
    caxis([0 0.07])
    hold off

elseif sweepControl(2) == 1

    figure(2)
    plot(CoPRange, TimeMCoP(:, 1), 'b-', 'LineWidth', 2)
    hold on
    plot(CoPRange, TimeMCoP(:, 2), 'g-', 'LineWidth', 2)
    plot(CoPRange, TimeMCoP(:, 3), 'm-', 'LineWidth', 2)
    title('Time vs. Center of Pressure', 'fontsize', 15);
    subtitle('at various CL-CD combinations', 'fontsize', 12);
    xlabel('CoP Location (% front distribution)', 'fontsize', 15)
    ylabel('Time', 'fontsize', 15)
    legend('CL=-2.9, CD=1.1','CL=-1.75, CD=0.75', 'CL=-1, CD=0.5', 'location', 'northwest', 'fontsize', 15);

elseif sweepControl(3) == 1

    figure(3)
    CoPlin = linspace(min(CoPM), max(CoPM), 100);
    CGlin = linspace(min(CGM), max(CGM), 100);
    [XCoP,YCG] = meshgrid(CoPlin, CGlin);
    ZCoPCG = griddata(CoPM,CGM,TimeMCoPCG,XCoP,YCG,'v4');
    [dfdxCoPCG, dfdyCoPCG] = gradient(ZCoPCG);
    s = mesh(XCoP,YCG,ZCoPCG, sqrt(dfdxCoPCG.^2 + dfdyCoPCG.^2));
    colormap(turbo);
    axis tight; hold on
    plot3(CoPM,CGM,TimeMCoPCG,'m.','MarkerSize',5)
    s.FaceColor = 'interp';
    s.EdgeColor = 'none';
    title('CoP-CG-Laptime', 'fontsize', 15);
    subtitle('Endurance', 'fontsize', 12);
    xlabel('CoP', 'fontsize', 15)
    ylabel('CG', 'fontsize', 15)
    zlabel('Time(s)', 'fontsize', 15)
    g = colorbar;
    title(g, 'gradient', 'fontsize', 15)
    caxis([0 0.1])
    hold off

elseif sweepControl(4) == 1

    figure(4)
    scatter(CoPBM, TimeBM, 50, ClaBM, 'filled');
    hold on
    title('CoP vs Time', 'fontsize', 15)
    subtitle('Sacrificing aerodynamic balance for greater downforce', 'fontsize', 12)
    xlabel('CoP', 'fontsize', 15)
    ylabel('Time', 'fontsize', 15)
    colormap('turbo')
    gB = colorbar;
    title(gB, 'Total CL', 'fontsize', 15)

    [minB, iBmin] = min(TimeBM);
    minCoPB = CoPBM(iBmin);
    plot(minCoPB, minB, 'm*', 'MarkerSize', 25, 'linewidth', 1.5)
    legend('Data Points', 'Minimum Configuration', 'location', 'northwest')
    minConfigCoP = "CoP: " + minCoPB;
    minConfigTime = "Laptime: " + minB;
    minConfig = [minConfigCoP; minConfigTime];
    text(0.6, 80.6, minConfig, "FontSize", 20, "Color", "red");

    hold off

end
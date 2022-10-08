global FZ0

FZ0 = 800/4.448
Fz = 333;

load("vogel_optim_params.mat")

B = [OptimParameterSet.PCX1 OptimParameterSet.PDX1 OptimParameterSet.PDX2 OptimParameterSet.PDX3 OptimParameterSet.PEX1 OptimParameterSet.PEX2 OptimParameterSet.PEX3 OptimParameterSet.PEX4 OptimParameterSet.PKX1 OptimParameterSet.PKX2 OptimParameterSet.PKX3 OptimParameterSet.PHX1 OptimParameterSet.PHX2 OptimParameterSet.PVX1 OptimParameterSet.PVX2 OptimParameterSet.PPX1 OptimParameterSet.PPX2 OptimParameterSet.PPX3 OptimParameterSet.PPX4 OptimParameterSet.RBX1 OptimParameterSet.RBX2 OptimParameterSet.RBX3 OptimParameterSet.RCX1 OptimParameterSet.REX1 OptimParameterSet.REX2 OptimParameterSet.RHX1 ];
SL = -0.11:0.001:0.11;


IA = 0;
X = [Fz IA];

F_x = MF52_Fx_fcn(B, X,SL);


plot(SL, F_x)
legend('vogel')
hold on

load("longitudinal tire parameters.mat")

B = [OptimParameterSet.PCX1 OptimParameterSet.PDX1 OptimParameterSet.PDX2 OptimParameterSet.PDX3 OptimParameterSet.PEX1 OptimParameterSet.PEX2 OptimParameterSet.PEX3 OptimParameterSet.PEX4 OptimParameterSet.PKX1 OptimParameterSet.PKX2 OptimParameterSet.PKX3 OptimParameterSet.PHX1 OptimParameterSet.PHX2 OptimParameterSet.PVX1 OptimParameterSet.PVX2 OptimParameterSet.PPX1 OptimParameterSet.PPX2 OptimParameterSet.PPX3 OptimParameterSet.PPX4 OptimParameterSet.RBX1 OptimParameterSet.RBX2 OptimParameterSet.RBX3 OptimParameterSet.RCX1 OptimParameterSet.REX1 OptimParameterSet.REX2 OptimParameterSet.RHX1 ];

F_x = MF52_Fx_fcn(B, X,SL);


plot(SL, F_x)
hold off
figure
legend('vogel','ours')
load("Hoosier_R25B_18.0x7.5-10_FX_12psi.mat")
fnplt(full_send_x)

wf = 333.16;
IA = -.0041;
SL = .11;
sf_x = .6;

evalF = MF52_Fx_fcn(B,[-wf rad2deg(-IA)],SL)*sf_x


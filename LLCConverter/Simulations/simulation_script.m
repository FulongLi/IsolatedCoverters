%% this script is created by Fulong @ Oct,2023. 
% design-oriented analysis.
close all;
clear,clc;
Results = [];
i=1;
%% step 1: define operation conditions
Vo_pfc = 750;
Vin = Vo_pfc;
Vout = 55;
Po = 10e3;
Po_max = Po;
Time_hu = 20e-3; %20ms
eff = 1;
Pin = Po/eff;
fr = 156e3;

%% step 2: define simulation component values
C_pfc = 470e-6*3;
Cin = 470e-6;
Cout = 470e-6*5;
Rcinp = 1e-3;
fs_max = 300e3;
fs_min = 30e3;
deadtime = (1/fs_min)/800;
Vf = 0;
mos_vf = 0;
Rds_on = 150e-6;
Rd_on = 10e-6;

Vin_min = sqrt(Vo_pfc^2-(2*Pin*Time_hu/C_pfc));
Vin_max = Vo_pfc;
% half bridge or full bridge?
bridge_gain = 1; % full bridge = 1;

% design transformer turns ratio
LLC_gain_norm = 1;
n = Vin*bridge_gain*LLC_gain_norm/(Vout+2*Vf);
LLC_gain_max = Vin/Vin_min*LLC_gain_norm;
LLC_gain_min = Vin/Vin_max*LLC_gain_norm;
%ratio_NpNs = n;
%% delete this part in normal design procedure, for SD design analysis only.
ratio_NpNs = 14;
LLC_gain_max_required = (Vout+2*Vf)*ratio_NpNs*1/bridge_gain/Vin; % put Vin if Vin_min not sure.
%%
% validation
m = 7;
Q = 0.3;
%
Rac = 8/pi^2*(ratio_NpNs)^2*(Vout^2/Po_max); 
Cr = 1/(2*pi*fr*Q*Rac);
Lr = 1/((2*pi*fr)^2*Cr);
Lm = (m-1)*Lr;
fr = 1/(2*pi*sqrt(Lr*Cr));
%
fprintf('Solution:\n');
fprintf('Lr = %.4f uH\n', Lr*1e6);
fprintf('Cr = %.4f uF\n', Cr*1e6);
fprintf('Lm = %.4f uH\n', Lm*1e6);
fprintf('fr = %.4f kHz\n', fr*1e-3);
fprintf('turns ratio：p2s = %.4f turns\n', ratio_NpNs);
fprintf('minimum input voltage: %.4f V\n', Vin_min);


%% step 4: modeling 
s = tf('s');
Lm_p_Rac = s*Lm*Rac/(s*Lm+Rac);
Kprime = Lm_p_Rac/(1/(s*Cr)+s*Lr+Lm_p_Rac);
Max_gain = getPeakGain(Kprime);

% save the data
% result = [m, Q, Lr*1e6, Cr*1e6, Lm*1e6, Max_gain, fr];
% Results(i,:) = result; 
% i = i+1;
%% step 5: graphics shown,etc...
figure(1)
bode(Kprime);
grid on;
hold on;

% figure(2)
% eff = (Lm_p_Rac)^2/(Rac*(1/(s*Cr)+s*Lr+Lm_p_Rac));
% bode(eff);
% grid on;
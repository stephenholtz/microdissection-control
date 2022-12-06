%% Ideal Gas Check
P_1 = 4.49103; % ATM
T_1 = 20.9 + 273.15;
V_1 = 1;

P_2 = 4.457011; %  ATM
T_2 = 20.1 + 273.15;

% Should be within 1-2% else there is a leak
V_2 = (P_1*V_1*T_2)/(T_1*P_2);

disp((V_2-V_1)*100)

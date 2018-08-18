%% Set up workspace
clear all force; %#ok<*CLALL>
close all force;
% Assert checkpoints for manual configuration steps
pump.initWarningDlgs()

%% Initalize national instruments daq interface
D = pump.daq();

%% Open up ROI/Camera GUI
%R = pump.roiGUI();

%% configure/run dissection

% Set number of shuttered pulses (stabilization time)
D.nShutteredPulses = 150;
% Set number of delivered (unshuttered) pulses
D.nDeliveredPulses = 40;
% Set the frequency of pulses (60-100Hz)
D.pulseFrequency = 100;
% Set duration of the N2 purge prior to lasing (10 seconds is OK)
D.purgeDurSeconds = 5;

% Prompt manual entry into laser control software
config_complete = pump.initGAMDlgs(D.nDeliveredPulses + D.nShutteredPulses);
if config_complete
    % It sometimes takes ~10 seconds to be ready to fire
    pause(8-D.purgeDurSeconds)
    dataIn = D.runDissection();
end
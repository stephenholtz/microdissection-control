%% Workspace initalization
addpath(genpath('C:\code\microdissection-control'));
clear all force; close all force; clc; %#ok<*CLALL>
if ~pump.startupWarnings(); return; end

%% Initalize Laser interface
L = pump.LaserIO('Dev3','D:\pump_prep_data_images\');

% Constant dissection settings
L.energyLevelMiliJoules = 7.0;  % manually entered in ATL software, this sets prompt text
L.nDeliveredPulses = 0;         % number of dissection pulses (w/ beam shutter open)
L.nShutteredPulses = 200;       % number of shuttered pulses, a for energy stabilization
L.pulseFrequency = 100;         % laser pulse freq, >60Hz is stable for closed loop mode
L.purgeDurSeconds = 3;          % duration of N2 purge prior to lasing (3+ seconds is OK)

%% Run a test cut on thorax for centering cut
L.nDeliveredPulses = 300; L.runDissection();

%% Cut into head capsule to help remove muscles + improve superfusion

% @ 7mJ, 3+ day old flies on anterior face
% 500 does not cut all the way through 
% 650 begins to penetrate but not uniformly
% 700 also not yet fully
L.nDeliveredPulses = 700; L.runDissection();

%% get into a2 cut

% @ 7mJ, 3+ day old flies
% 100 does not penetrate
% 125 does not penetrate
% 150 clearly penetrates
% 200 too deep for physiology
L.nDeliveredPulses = 150; L.runDissection();

%% Antenna a2 dissection. See notes for numbers
L.nDeliveredPulses = 106; % (75a2)/85/93/117      
[data_in, data_out] = L.runDissection(); %#ok<*ASGLU> 

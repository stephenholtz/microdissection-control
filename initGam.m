% initGam.m
% Send commands to laser and shutter

% Make gui with aperture projection images

%% Set up daq session and channels
fprintf('\nGAM Laser Control Script')
fprintf('\n************************\n');
fprintf('Initializing DAQ channels ');

daqreset;
% D = daq.getDevices;
S = daq.createSession('ni');
S.Rate = 50E3;

% Analog Input -- currently unused
% ai(1) = S.addAnalogInputChannel('Dev1',0','Voltage');
% ai(1).Name = 'Photodiode Out';
% use02sensor = 0;
% if use02sensor 
%     ai(2) = S.addAnalogInputChannel('Dev1',1,'Voltage');
%     ai(2).Name = 'Trace 02 4-20ma out w/ 250Ohm Resistor'; % 4-20 mA out w/a 250 Ohm resistor (~5V)
%     S.Rate = 125E3;
% else
%     % Set rate higher if not using the 02 sensors
%     S.Rate = 250E3;
% end

% Digital IO
dio(1) = S.addDigitalChannel('Dev1','port0/line0','OutputOnly');
dio(1).Name = 'Laser Trigger';
dio(2) = S.addDigitalChannel('Dev1','port0/line1','InputOnly');
dio(2).Name = 'Laser Sync Out';
dio(3) = S.addDigitalChannel('Dev1','port0/line2','OutputOnly');
dio(3).Name = 'Shutter Trigger';
dio(4) = S.addDigitalChannel('Dev1','port0/line3','OutputOnly');
dio(4).Name = 'Solenoid Command';
% dio(4) = S.addDigitalChannel('Dev1','port0/line4','InputOnly');
% dio(4).Name = 'Shutter Output';

fprintf('\t\t\t[Done]\n');
fprintf('Set Uniblitz shutter driver to STD, N.O., and Remote\n');

%% Make signals
% Pulse frequency etc.,
pulseFreqHz = 100;
nPulsesShuttered = 50;
nPulsesOpened = 60;
durPurgeSeconds = 10;

% Requires one extra pulse to initiate (not documented)
nPulsesShuttered = nPulsesShuttered + 1;

% Short buffer in the beginning baseline period
pre = 0*ones(1,S.Rate * .25);

% Make each pulse 100ns
pulse = [0*ones(1,(S.Rate * 1/pulseFreqHz)-(0.0001*S.Rate)) 1*ones(1,(0.0001*S.Rate)) ];

% Append and format for queue data
dioPulses = [pre repmat(pulse,1,nPulsesShuttered) repmat(pulse,1,nPulsesOpened)];

% Open the shutter after a some laser pulses
nWaitSamples = nPulsesShuttered*length(pulse);
dioShutter = [pre 0*ones(1,nWaitSamples)];
dioShutter = [dioShutter 1*ones(1,length(dioPulses) - length(dioShutter))];
% Add slop for the laser-shutter timing
dioShutter = circshift(dioShutter,[0.001*S.Rate,0]);

% Add off ending
post = 0*ones(1,S.Rate * .1);
dioPulses = [dioPulses post]';
dioShutter = [dioShutter post]';
dioSolenoid = 0.*dioShutter';

% Final command
dataOut = [dioPulses dioShutter dioSolenoid];

%% Send signals

% Make sure we start at zero
S.outputSingleScan([ 0 0 ]);
% Time before sending data to daq (to prepare line)
tDelayPrePulseSeconds = 2;

% Start out zeroed
S.outputSingleScan([ 0 0 ]);
% Queue output data
S.queueOutputData(dataOut);

% Warn user + start data trans
fprintf('Ensure purge line is open\n')
fprintf('Data being sent for %.2f seconds\n',size(dataOut,1)/S.Rate)
dataIn = S.startForeground();

% Make sure to end at zero
S.outputSingleScan([ 0 0 ]);

%% Display output
close all;

figure;
plot(dataOut);
hold on
plot(dataIn);
legend('Pulse Command','Shutter Command','Solenoid Command','Laser Sync Out')
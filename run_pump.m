%% Assert checkpoints for manual configuration steps
clear all force;
close all force;

pump.initWarningDlgs()

%% Initalize interfaces

% Start national instruments daq
D = pump.daq();

% Start camera interface
C = pump.cam();

%% configure dissection


%% run dissection

%%
for i = 1:100
    [frame,metadata] = step(C.dev);
    imagesc(frame)
    pause(.1)
end
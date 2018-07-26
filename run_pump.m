%% Assert checkpoints for manual configuration steps
pump.utils.initSystem()

%% Start national instruments daq
pump.daq.init()

%% Start camera ROI GUI
pump.cam.init()
pump.cam.roiGUI()

%% configure dissection


%% run system


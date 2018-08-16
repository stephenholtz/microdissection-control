classdef roiGUI
    properties
        camDev
        displayTimer
        frame
    end

    properties (Constant)
        % Device Properties from imaqtool
        adaptorName = 'pointgrey';
        deviceID = 1;
        vidFormat = 'F7_Mono8_1024x1024_Mode1';
        FrameRate = 30;
        
        % GUI properties
        displayRateHz = 30;
        
        um_per_pix_mode0 = 10/214.7; % 
        um_per_pix_mode2 = 10/107.3; %
    end
    
    methods
        function obj = roiGUI()
            % Start camera interface
            obj = obj.initCam();
            
            % Start GUI 
            %obj = obj.initGUI();
            
        end
        
        function obj = initCam(obj)
            % Create camera interface
            fprintf('Initializing PtGrey camera... ');
            
            % Clear the air a bit
            delete(imaqfind);
            imaqreset;
            
            obj.camDev = imaq.VideoDevice(obj.adaptorName,obj.deviceID,obj.vidFormat);
            obj.camDev.DeviceProperties.FrameRate = obj.FrameRate;
            
            fprintf('Done\n');
        end
        
        function obj = initGUI(obj)
            fprintf('Initializing PtGrey camera... ');
            figure;
            
            % Create timer for refreshing GUI with camera grabs
            delete(timerfindall); delete(timerfindall);

            obj.displayTimer = timer();
            obj.displayTimer.StartDelay = 0; % Start asap
            obj.displayTimer.BusyMode = 'drop';
            obj.displayTimer.Period = round(1/obj.displayRateHz,3);
            obj.displayTimer.ExecutionMode = 'fixedRate';
            obj.displayTimer.TimerFcn = @obj.newFrame;
            start(obj.displayTimer)
            
            fprintf('Done\n');
        end
        
        function obj = newFrame(obj,~,~)
            obj.frame = step(obj.camDev);
        end
    end
end
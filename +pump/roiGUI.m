classdef roiGUI
    properties
        camDev
        displayTimer
    end

    properties (Constant)
        % Device Properties from imaqtool
        adaptorName = 'pointgrey';
        deviceID = 1;
        vidFormat = 'F7_Mono8_1024x1024_Mode1'; % more manageable size
        %vidFormat = 'F7_Raw8_1024x1024_Mode2'; % more manageable size
        FrameRate = 50
        
        displayRateHz = 4;
        
        um_per_pix_mode0 = 10/214.7; % 
        um_per_pix_mode2 = 10/107.3; %
    end
    
    methods
        function obj = roiGUI()
            
            obj = obj.initCam();
            
            % Create timer for refreshing GUI with camera grabs
            obj.displayTimer = timer();
            obj.displayTimer.BusyMode = 'drop';
            obj.displayTimer.Period = 1/obj.displayRateHz;
            obj.displayTimer.ExecutionMode = 'fixedRate';
            
            % Create the roi GUI
            
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
        
        function obj = initGUI()
            
        end
    end
    
end
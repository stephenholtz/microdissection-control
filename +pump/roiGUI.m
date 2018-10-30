classdef roiGUI
    properties
        vidDev % video device adapter
        hImage % image object of preview
        figH % figure handle
        cax % axes for camera preview
    end

    properties (Constant)
        % Device Properties from imaqtool
        adaptorName = 'pointgrey';
        deviceID = 1;
        vidFormat = 'F7_Mono8_1024x1024_Mode1';
        
        % getselectedsource() settings
        FrameRate = 25;
        Gamma = 1;
        Shutter = 20;
        
        roi_x = 512; % display x in middle of x
        roi_y = 512; % display x in middle of y
        um_per_pix_mode0 = 10/214.7; % 
        um_per_pix_mode2 = 10/107.3; %
    end
    
    methods
        function obj = roiGUI()
            obj = obj.initCam();
            obj = obj.initGUI();
        end
        
        function obj = initCam(obj)
            % Create camera interface
            fprintf('Initializing PtGrey camera... ');
            delete(imaqfind);
            imaqreset;
            obj.vidDev = videoinput(obj.adaptorName,...
                                    obj.deviceID, obj.vidFormat);
            
            % use this command to configure settings
            src = getselectedsource(obj.vidDev);
            src.FrameRate = obj.FrameRate;
            src.Gamma = obj.Gamma;
            src.Shutter = obj.Shutter;
            
            fprintf('Done\n');
        end
        
        function obj = initGUI(obj)
            obj.figH = figure('Name', 'PUMP GUI',...
                              'NumberTitle', 'off');
            obj.cax = axes(obj.figH);
            obj.cax.Box = 'off';
            frame = getsnapshot(obj.vidDev);
            obj.hImage = imshow(frame,[],...
                                'InitialMagnification','fit',...
                                'Parent',obj.cax);
            preview(obj.vidDev, obj.hImage); hold on
            plot(obj.roi_x,obj.roi_y,'c+','MarkerSize',14,'LineWidth',2,'Parent',obj.cax);
        end
        
        function obj = saveImg(obj,savepath)
            frame = getsnapshot(obj.vidDev);
            imwrite(frame,[savepath '.tif'],'tif');
        end
    end
end
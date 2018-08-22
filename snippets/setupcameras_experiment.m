function cam = setupcameras_experiment()
% sets all cameras up and starts previews.
%
% cam.up
% cam.down
% cam.ant
% cam.post
warning off

%% get cameras
% imaqhwinfo 
adaptorName = 'pointgrey';    % 'pointgrey' sometimes only sees two cameras (but now it sees all 4)
hwInfo = imaqhwinfo(adaptorName); 
cameraNames = cat(2, hwInfo.DeviceInfo.DeviceName);
cameraNums = length(hwInfo.DeviceInfo);
cameraNamesReadable = cat(1, hwInfo.DeviceInfo.DeviceName);
disp(cameraNamesReadable)


%% cam.up - create a video input object and set properties
ID_camera = ceil(strfind(cameraNames, '12A2M') / (length(cameraNames)/cameraNums)); %name will still be ambiguous for same model cameras.
cam.up.vid = videoinput(adaptorName, ID_camera, hwInfo.DeviceInfo(ID_camera).DefaultFormat);
cam.up.src = getselectedsource(cam.up.vid);

% Preview the Video Stream (at any time after you create the vid object)   
handles.Image = preview(cam.up.vid);
handles.Figure = ancestor(handles.Image, 'figure');
handles.Figure.WindowStyle = 'normal';

handles.Figure.Units = 'pixels';
WindowAPI(handles.Figure,'Position', 'full', 1);  % to make it a *real* fullscreen, in the monitor specified by last argument
handles.Figure.Units = 'pixels'; 
WindowAPI(handles.Figure,'Position', 'full', 1);  % at least one of these two lines does not work the first time...

cam.up.src.FrameRate = 19;
cam.up.src.Gamma = 1;
cam.up.hFig = handles.Figure;


%% camera down
ID_camera3 = ceil(strfind(cameraNames, '20E4M') / (length(cameraNames)/cameraNums)); %name will still be ambiguous for same model cameras.
cam.down.vid = videoinput(adaptorName, ID_camera3, hwInfo.DeviceInfo(ID_camera3).DefaultFormat);
cam.down.src = getselectedsource(cam.down.vid);

% Preview the Video Stream (at any time after you create the vid object)   
handles.Image = preview(cam.down.vid);
handles.Figure = ancestor(handles.Image, 'figure');
handles.Figure.WindowStyle = 'normal';

handles.Figure.Units = 'pixels';
WindowAPI(handles.Figure,'Position', 'work', 3);  % to make it a *real* fullscreen, in the monitor specified by last argument
handles.Figure.Units = 'pixels'; 
WindowAPI(handles.Figure,'Position', 'work', 3);  % at least one of these two lines does not work the first time...

cam.down.hFig = handles.Figure;


%% camera Right antenna (posterior piezo)
ID_camera2 = ceil(strfind(cameraNames, '13E4M') / (length(cameraNames)/cameraNums)); %name will still be ambiguous for same model cameras.
vid2 = videoinput(adaptorName, ID_camera2(1), hwInfo.DeviceInfo(ID_camera2(1)).DefaultFormat);

src = getselectedsource(vid2);
SerialNumber = src.SerialNumber;
delete(vid2)
clear vid2 src

if strcmp(SerialNumber, '14466065') % use it to disambiguate the two 13X cameras
    cam.post.vid = videoinput(adaptorName, ID_camera2(1), hwInfo.DeviceInfo(ID_camera2(1)).DefaultFormat);
    cam.ant.vid  = videoinput(adaptorName, ID_camera2(2), hwInfo.DeviceInfo(ID_camera2(2)).DefaultFormat);
else
    cam.ant.vid = videoinput(adaptorName, ID_camera2(1), hwInfo.DeviceInfo(ID_camera2(1)).DefaultFormat);
    cam.post.vid  = videoinput(adaptorName, ID_camera2(2), hwInfo.DeviceInfo(ID_camera2(2)).DefaultFormat);
end
    
% Preview the Video Stream (at any time after you create the vid object)   
handlesP.Image = preview(cam.post.vid);
handlesP.Figure = ancestor(handlesP.Image, 'figure');
handlesP.Figure.Name = 'Video Preview - posterior';
% handlesP.Figure.WindowStyle = 'normal';
% handlesP.Figure.Units = 'pixels';
% WindowAPI(handlesP.Figure,'Position', 'work', 4);  % to make it a *real* fullscreen, in the monitor specified by last argument
% handlesP.Figure.Units = 'pixels'; 
% WindowAPI(handlesP.Figure,'Position', 'work', 4);  % at least one of these two lines does not work the first time...
cam.post.src = getselectedsource(cam.post.vid);
cam.post.src.FrameRate = 40;
cam.post.src.Gamma = 1;
cam.post.src.Exposure = 0.3;
pause(0.2)
cam.post.src.FrameRate = 40;
cam.post.src.Gamma = 1;
cam.post.src.Exposure = 0.3;

cam.post.hFig = handlesP.Figure;



handlesA.Image = preview(cam.ant.vid);
handlesA.Figure = ancestor(handlesA.Image, 'figure');
handlesA.Figure.Name = 'Video Preview - anterior';
% handlesA.Figure.WindowStyle = 'normal';
% handlesA.Figure.Units = 'pixels';
% WindowAPI(handlesA.Figure,'Position', 'work', 4);  % to make it a *real* fullscreen, in the monitor specified by last argument
% handlesA.Figure.Units = 'pixels'; 
% WindowAPI(handlesA.Figure,'Position', 'work', 4);  % at least one of these two lines does not work the first time...
cam.ant.src = getselectedsource(cam.ant.vid);
cam.ant.src.FrameRate = 40;
cam.ant.src.Gamma = 1;
cam.ant.src.Exposure = 0.3;
pause(0.2)
cam.ant.src.FrameRate = 40;
cam.ant.src.Gamma = 1;
cam.ant.src.Exposure = 0.3;

cam.ant.hFig = handlesA.Figure;

warning on
end
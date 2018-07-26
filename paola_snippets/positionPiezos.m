function varargout = positionPiezos(varargin)
% POSITIONPIEZOS MATLAB code for positionPiezos.fig
%      POSITIONPIEZOS, by itself, creates a new POSITIONPIEZOS or raises the existing
%      singleton*.
%
%      H = POSITIONPIEZOS returns the handle to a new POSITIONPIEZOS or the handle to
%      the existing singleton*.
%
%      POSITIONPIEZOS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in POSITIONPIEZOS.M with the given input arguments.
%
%      POSITIONPIEZOS('Property','Value',...) creates a new POSITIONPIEZOS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before positionPiezos_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to positionPiezos_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help positionPiezos

% Last Modified by GUIDE v2.5 20-Apr-2018 17:44:34

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @positionPiezos_OpeningFcn, ...
                   'gui_OutputFcn',  @positionPiezos_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before positionPiezos is made visible.
function positionPiezos_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to positionPiezos (see VARARGIN)

% Choose default command line output for positionPiezos
% hObject.Position =  [592   49.6154  250.4000   42.9231];
hObject.WindowStyle = 'normal';
hObject.OuterPosition = [591.4000   49.0000  253.6000   45.9231];
hObject.Position =  [593.0000   49.6154  250.4000   42.9231];


% handles.output = hObject;

handles.cam = varargin{1};

handles.vidnames(1).name = 'handles.cam.post.vid';
handles.vidnames(2).name = 'handles.cam.down.vid';
handles.vidnames(3).name = 'handles.cam.ant.vid';

handles.currentFrames(1).baseline = [];
handles.currentFrames(2).baseline = [];
handles.currentFrames(3).baseline = [];
handles.currentFrames(1).piezoON = [];
handles.currentFrames(2).piezoON = [];
handles.currentFrames(3).piezoON = [];


handles.axes3.YTick = [];
handles.axes3.XTick = [];
handles.axes6.YTick = [];
handles.axes6.XTick = [];

% % default popoupmenu is 'Posterior'. Update axes accordingly (get frames)
handles.currentPiezo = 1;
% handles.currentFrames(handles.currentPiezo).baseline = getsnapshot( eval( handles.vidnames(handles.currentPiezo).name ) );
% axes(handles.axes3);
% imshow(handles.currentFrames(handles.currentPiezo).baseline)
% 
% handles.currentFrames(2).baseline = getsnapshot( eval( handles.vidnames(2).name ) );
% axes(handles.axes6);
% imshow(handles.currentFrames(2).baseline)


% Update handles structure
guidata(hObject, handles);
% UIWAIT makes StimulusControllerII wait for user response (see UIRESUME)
uiwait(handles.figure1);
% UIWAIT makes positionPiezos wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isequal(get(hObject, 'waitstatus'), 'waiting')
    %the GUI is still in UIWAIT, use UIRESUME
    uiresume(hObject);
else
    % the GUI is no longer waiting, just close it
    % Hint: delete(hObject) closes the figure
    delete(hObject);
end



% --- Outputs from this function are returned to the command line.
function varargout = positionPiezos_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure

if isempty(handles)
    disp('use DONE button to pass data to workspace')
    varargout{1} = [];
    delete(hObject);
else
    varargout{1} = handles.currentFrames;
    delete(handles.figure1);
end


% posterior vs anterior piezo
% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents = cellstr(get(hObject,'String'));
selectedString = contents{get(hObject,'Value')};
switch selectedString
    case 'Posterior'
        handles.currentPiezo = 1;
    case 'Anterior'
        handles.currentPiezo = 3;
end
guidata(hObject, handles);   

% set slider to baseline and show the current baseline

handles.slider2.Value = 0;
handles.togglebutton1.Value = 0;

axes(handles.axes3);
imshow(handles.currentFrames(handles.currentPiezo).baseline)

axes(handles.axes6);
imshow(handles.currentFrames(2).baseline)





% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end








% grab BASELINE
% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.currentFrames(handles.currentPiezo).baseline = getsnapshot( eval( handles.vidnames(handles.currentPiezo).name ) );
axes(handles.axes3);
imshow(handles.currentFrames(handles.currentPiezo).baseline)

handles.currentFrames(2).baseline = getsnapshot( eval( handles.vidnames(2).name ) );
axes(handles.axes6);
imshow(handles.currentFrames(2).baseline)

handles.slider2.Value = 0;
handles.togglebutton1.Value = 0;

guidata(hObject, handles); 





% grab PIEZO ON
% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.currentFrames(handles.currentPiezo).piezoON = getsnapshot( eval( handles.vidnames(handles.currentPiezo).name ) );
axes(handles.axes3);
imshow(handles.currentFrames(handles.currentPiezo).piezoON)

handles.currentFrames(2).piezoON = getsnapshot( eval( handles.vidnames(2).name ) );
axes(handles.axes6);
imshow(handles.currentFrames(2).piezoON)

handles.slider2.Value = 1;
handles.togglebutton1.Value = 0;

guidata(hObject, handles); 





% --- Executes on slider movement.
function slider2_Callback(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
% Min is 0 - MAx is 1

handles.togglebutton1.Value = 0;

showPiezoON = get(hObject,'Value');

if showPiezoON
    axes(handles.axes3);
    imshow(handles.currentFrames(handles.currentPiezo).piezoON)
    
    axes(handles.axes6);
    imshow(handles.currentFrames(2).piezoON)
else
    axes(handles.axes3);
    imshow(handles.currentFrames(handles.currentPiezo).baseline)
    
    axes(handles.axes6);
    imshow(handles.currentFrames(2).baseline)
end

guidata(hObject, handles); 



% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end




% show composite
% --- Executes on button press in togglebutton1.
function togglebutton1_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if get(hObject,'Value')
    if (isempty(handles.currentFrames(handles.currentPiezo).baseline) || isempty(handles.currentFrames(handles.currentPiezo).piezoON) )
        set(hObject, 'Value', 0);
        handles.togglebutton1.Value = 0;
    else
        axes(handles.axes3);
        imshowpair(handles.currentFrames(handles.currentPiezo).baseline, handles.currentFrames(handles.currentPiezo).piezoON)
        
        axes(handles.axes6);
        imshowpair(handles.currentFrames(2).baseline, handles.currentFrames(2).piezoON)
    end
else
    slider2_Callback(hObject, eventdata, handles);
end
guidata(hObject, handles); 


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

figure1_CloseRequestFcn(handles.figure1, eventdata, handles)


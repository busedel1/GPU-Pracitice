function varargout = WaveEqnGUI(varargin)
% WAVEEQNGUI MATLAB code for WaveEqnGUI.fig
%      WAVEEQNGUI, by itself, creates a new WAVEEQNGUI or raises the existing
%      singleton*.
%
%      H = WAVEEQNGUI returns the handle to a new WAVEEQNGUI or the handle to
%      the existing singleton*.
%
%      WAVEEQNGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in WAVEEQNGUI.M with the given input arguments.
%
%      WAVEEQNGUI('Property','Value',...) creates a new WAVEEQNGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before WaveEqnGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to WaveEqnGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2011 The MathWorks, Inc.

% Edit the above text to modify the response to help WaveEqnGUI

% Last Modified by GUIDE v2.5 13-Jun-2018 14:45:28

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
   'gui_Singleton',  gui_Singleton, ...
   'gui_OpeningFcn', @WaveEqnGUI_OpeningFcn, ...
   'gui_OutputFcn',  @WaveEqnGUI_OutputFcn, ...
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


% --- Executes just before WaveEqnGUI is made visible.
function WaveEqnGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to WaveEqnGUI (see VARARGIN)

% Choose default command line output for WaveEqnGUI
handles.output = hObject;

handles.maxIterValue = str2double(get(handles.maxIterEdit, 'String'));
handles.gridSizeValue = str2double(get(handles.gridSizeEdit, 'String'));

% Update handles structure
guidata(hObject, handles);

movegui(hObject, 'center');

% UIWAIT makes WaveEqnGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = WaveEqnGUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in StartButton.
function StartButton_Callback(hObject, eventdata, handles)
% hObject    handle to StartButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

button_state = get(hObject,'Value');

if get(handles.radiobutton1,'Value') == 1
   fh = @WaveEqn_CPU;
else
   try
      gpuDeviceCount;
   catch ME
      errordlg({['Supported GPU hardware not found. ', ...
         'Check the documentation to see what''s supported.'], '', ...
         ME.message}, 'Error', 'modal');
      set(hObject,'Value',get(hObject,'Min'));
      return;
   end
   
   fh = @WaveEqn_GPU;
end

if button_state == get(hObject,'Max')
   set(hObject,'String', 'Stop')
   t = tic;
   set(handles.ElapsedTimeText, 'String', 'Elapsed Time:');
   fh(handles.axes1,handles.axes2,hObject,handles.text1,handles.gridSizeValue,handles.maxIterValue);
   set(handles.ElapsedTimeText, 'String', sprintf('Elapsed Time:\n%0.1f sec', toc(t)));
   set(hObject,'Value', get(hObject,'Min'), 'String', 'Start')
else
   set(hObject,'String', 'Start')
end



function gridSizeEdit_Callback(hObject, eventdata, handles)
% hObject    handle to gridSizeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gridSizeEdit as text
%        str2double(get(hObject,'String')) returns contents of gridSizeEdit as a double

val = str2double(get(hObject,'String'));
if isnan(val)
   set(hObject, 'String', handles.gridSizeValue)
else
   handles.gridSizeValue = val;
   guidata(hObject, handles);
end


% --- Executes during object creation, after setting all properties.
function gridSizeEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gridSizeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
   set(hObject,'BackgroundColor','white');
end



function maxIterEdit_Callback(hObject, eventdata, handles)
% hObject    handle to maxIterEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxIterEdit as text
%        str2double(get(hObject,'String')) returns contents of maxIterEdit as a double

val = str2double(get(hObject,'String'));
if isnan(val)
   set(hObject, 'String', handles.maxIterValue)
else
   handles.maxIterValue = val;
   guidata(hObject, handles);
end

% --- Executes during object creation, after setting all properties.
function maxIterEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxIterEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
   set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function text1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

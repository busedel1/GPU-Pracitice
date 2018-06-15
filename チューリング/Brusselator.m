function varargout = Brusselator(varargin)
% BRUSSELATOR MATLAB code for Brusselator.fig
%      BRUSSELATOR, by itself, creates a new BRUSSELATOR or raises the existing
%      singleton*.
%
%      H = BRUSSELATOR returns the handle to a new BRUSSELATOR or the handle to
%      the existing singleton*.
%
%      BRUSSELATOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BRUSSELATOR.M with the given input arguments.
%
%      BRUSSELATOR('Property','Value',...) creates a new BRUSSELATOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Brusselator_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Brusselator_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Brusselator

% Last Modified by GUIDE v2.5 13-Jun-2018 15:37:40

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Brusselator_OpeningFcn, ...
                   'gui_OutputFcn',  @Brusselator_OutputFcn, ...
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


% --- Executes just before Brusselator is made visible.
function Brusselator_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Brusselator (see VARARGIN)

% Choose default command line output for Brusselator
handles.output = hObject;

%エディットボックスからmaxIterEdit,gridSizeEditを取得
handles.maxIterValue = str2double(get(handles.maxIterEdit, 'String'));
handles.gridSizeValue = str2double(get(handles.gridSizeEdit, 'String'));

% handlesを更新
guidata(hObject, handles);
movegui(hObject, 'center');
%画面中央に表示
% movegui(hObject, 'center');

% UIWAIT makes Brusselator wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = Brusselator_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in Startbutton.
function Startbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Startbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Startプッシュボタンが押されているかどうかの情報を取得
button_state = get(hObject,'Value');

%関数ハンドルをfhに格納
% fh = @Brusselator_2D_CPU;
% fh1 = @Brusselator_2D_CPU;
% fh2 = @Brusselator_2D_GPU;
% fh3 = @Brusselator_2D_GPU_CUDA;

%CPU,GPU,GPU with button の選択
if get(handles.CPU_button,'Value') == 1
   fh = @Brusselator_2D_CPU;
   
elseif get(handles.GPU_button,'Value') == 1
   try
      gpuDeviceCount;
   catch ME
      errordlg({['Supported GPU hardware not found. ', ...
         'Check the documentation to see what''s supported.'], '', ...
         ME.message}, 'Error', 'modal');
      set(hObject,'Value',get(hObject,'Min'));
      return;
   end
   fh = @Brusselator_2D_GPU;
   
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
   fh = @Brusselator_2D_GPU_CUDA;
end

%Startプッシュボタンが押されると開始
if button_state == get(hObject,'Max')
   set(hObject,'String', 'Stop')
   t = tic;
%    set(handles.ElapsedTimeText, 'String', 'Elapsed Time:');
   fh(handles.axes1,hObject,handles.iteration,handles.gridSizeValue,handles.maxIterValue);
   set(handles.ElapsedTimeText, 'String', sprintf('%0.1f sec', toc(t)));
   set(hObject,'Value', get(hObject,'Min'), 'String', 'Start')
else
   set(hObject,'String', 'Start')
end

function gridSizeEdit_Callback(hObject, eventdata, handles)
% hObject    handle to gridSizeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%グリッド数の入力値をとる
val = str2double(get(hObject,'String'));
if isnan(val)
   set(hObject, 'String', handles.gridSizeValue)
else
   handles.gridSizeValue = val;
   guidata(hObject, handles);
end
% if isnan(val)
%    set(hObject, 'String', handles.gridSizeValue)
% else
%    handles.gridSizeValue = val;
%    % Save the change you made to the structure
%    guidata(hObject, handles);
% end
% Hints: get(hObject,'String') returns contents of gridSizeEdit as text
%        str2double(get(hObject,'String')) returns contents of gridSizeEdit as a double


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
   % Save the change you made to the structure
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
function iteration_CreateFcn(hObject, eventdata, handles)
% hObject    handle to iteration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
% if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%     set(hObject,'BackgroundColor','white');
% end


% --- Executes on button press in CPU_button.
function CPU_button_Callback(hObject, eventdata, handles)
% hObject    handle to CPU_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CPU_button


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in GPU_button.
function GPU_button_Callback(hObject, eventdata, handles)
% hObject    handle to GPU_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of GPU_button

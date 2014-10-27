function varargout = Preprocessing(varargin)
% PREPROCESSING M-file for Preprocessing.fig
%      PREPROCESSING, by itself, creates a new PREPROCESSING or raises the existing
%      singleton*.
%
%      H = PREPROCESSING returns the handle to a new PREPROCESSING or the handle to
%      the existing singleton*.
%
%      PREPROCESSING('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PREPROCESSING.M with the given input arguments.
%
%      PREPROCESSING('Property','Value',...) creates a new PREPROCESSING or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Preprocessing_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Preprocessing_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Preprocessing

% Last Modified by GUIDE v2.5 14-Mar-2014 17:47:42

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @Preprocessing_OpeningFcn, ...
    'gui_OutputFcn',  @Preprocessing_OutputFcn, ...
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


% --- Executes just before Preprocessing is made visible.
function Preprocessing_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Preprocessing (see VARARGIN)
if isempty(varargin)
    loaddata % Loads data from a selected file
    handles.data = data;
    handles.timeAxis = timeAxis;
    handles.samplingInt = samplingInt;
else
    handles.data = varargin{1};
    handles.timeAxis = varargin{2};
    handles.samplingInt = handles.timeAxis(2)-handles.timeAxis(1);
    
end
handles.nSignals=size(handles.data,2);
handles.zData=zscore(handles.data); % Data as z-scores.
handles.timeAxis_mod=handles.timeAxis;
handles.samplingInt_mod=handles.samplingInt;
handles.c=colormap;
handles.cSkip=floor(length(handles.c)/handles.nSignals);
m=0;
for k=1:handles.nSignals,
    m = m+1;
    subplot(handles.nSignals,1,k),plot(handles.timeAxis_mod,handles.zData(:,k),'color', handles.c(m*handles.cSkip,:))
    yMin = min(handles.zData(:,k));
    yMax = max(handles.zData(:,k));
    ylim([yMin yMax]), xlim([-inf inf])
    box off
end

% Choose default command line output for Preprocessing
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
% UIWAIT makes Preprocessing wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Preprocessing_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in Tools.
function Tools_Callback(hObject, eventdata, handles)
% hObject    handle to Tools (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
str = get(hObject, 'String');
val = get(hObject,'Value');
switch str{val};
    case 'Truncate'
        prompt={'Enter the starting time point','Enter the ending time point'};
        name='Truncating data';
        numlines=1;
        defaultanswer={'0','50'};
        answer=inputdlg(prompt,name,numlines,defaultanswer);
        fTime=str2double(answer{1});
        lTime=str2double(answer{2});
        fpt=min(find(handles.timeAxis_mod>=fTime));
        lpt=min(find(handles.timeAxis_mod>=lTime));
        handles.zData = handles.zData(fpt:lpt,:);
        handles.timeAxis_mod=handles.timeAxis_mod(fpt:lpt);
        % Updating plots
        m=0;
        for k=1:handles.nSignals,
            m = m+1;
            subplot(handles.nSignals,1,k),plot(handles.timeAxis_mod,handles.zData(:,k),'color', handles.c(m*handles.cSkip,:))
            yMin = min(handles.zData(:,k));
            yMax = max(handles.zData(:,k));
            ylim([yMin yMax]), xlim([-inf inf])
            box off
        end
    case 'Filter'
        prompt={'Low','High'};
        name=['Filtering: Sf = ' num2str(handles.samplingInt)];
        numlines=1;
        defaultanswer={'0','0'};
        answer=inputdlg(prompt,name,numlines,defaultanswer);
        low=str2double(answer{1});
        high=str2double(answer{2});
        if all([low high]==0)
            return;
        elseif low==0
            handles.zData=chebfilt(handles.zData,handles.samplingInt_mod,high,'low');
        elseif high==0
            handles.zData=chebfilt(handles.zData,handles.samplingInt_mod,low,'high');
        else
            handles.zData=chebfilt(handles.zData,handles.samplingInt_mod,[low high]);
        end
        % Updating plots
        m=0;
        for k=1:handles.nSignals,
            m = m+1;
            subplot(handles.nSignals,1,k),plot(handles.timeAxis_mod,handles.zData(:,k),'color', handles.c(m*handles.cSkip,:))
            yMin = min(handles.zData(:,k));
            yMax = max(handles.zData(:,k));
            ylim([yMin yMax]), xlim([-inf inf])
            box off
        end
    case 'Rectify'
        handles.zData(handles.zData<0)=0;
        % Updating plots
        m=0;
        for k=1:handles.nSignals,
            m = m+1;
            subplot(handles.nSignals,1,k),plot(handles.timeAxis_mod,handles.zData(:,k),'color', handles.c(m*handles.cSkip,:))
            yMin = min(handles.zData(:,k));
            yMax = max(handles.zData(:,k));
            ylim([yMin yMax]), xlim([-inf inf])
            box off
        end
    case 'Decimate'
        prompt={'Enter the new sampling frequency'};
        name='Decimating data';
        numlines=1;
        defaultanswer={num2str(1./handles.samplingInt_mod)};
        answer=inputdlg(prompt,name,numlines,defaultanswer);
        newsf=str2double(answer{1});
        handles.zData=reduceData(handles.zData,handles.samplingInt_mod, newsf);
        handles.timeAxis_mod=reduceData(handles.timeAxis_mod(:),handles.samplingInt_mod,newsf);
        handles.samplingInt_mod=1/newsf;
        
end
% Update handles structure.
guidata(hObject,handles)


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




% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% prompt={'Enter file name'};
% name= ['Saving Processed Data'];
% defaultanswer= {datestr(now)};
% numlines=1;
% answer=inputdlg(prompt,name,numlines,defaultanswer);

checkLabels = {'Save data as','Save time as','Save sampling int as'...
    ,'Save processed data as','Save processed time as',...
    'Save new sampling int as'};
varNames = {'data','timeAxis','samplingInt','zData','timeAxis_mod','samplingInt_mod'};
items = {handles.data,handles.timeAxis,handles.samplingInt,...
    handles.zData,handles.timeAxis_mod, handles.samplingInt_mod};
export2wsdlg(checkLabels,varNames,items, 'Save variables');


% --- Executes on selection change in listbox2.
function listbox2_Callback(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox2


% --- Executes during object creation, after setting all properties.
function listbox2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function uipanel2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uipanel2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

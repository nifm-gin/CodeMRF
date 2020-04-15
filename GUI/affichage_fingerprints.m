function varargout = affichage_fingerprints(varargin)
% AFFICHAGE_FINGERPRINTS MATLAB code for affichage_fingerprints.fig
%      AFFICHAGE_FINGERPRINTS, by itself, creates a new AFFICHAGE_FINGERPRINTS or raises the existing
%      singleton*.
%
%      H = AFFICHAGE_FINGERPRINTS returns the handle to a new AFFICHAGE_FINGERPRINTS or the handle to
%      the existing singleton*.
%
%      AFFICHAGE_FINGERPRINTS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in AFFICHAGE_FINGERPRINTS.M with the given input arguments.
%
%      AFFICHAGE_FINGERPRINTS('Property','Value',...) creates a new AFFICHAGE_FINGERPRINTS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before affichage_fingerprints_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to affichage_fingerprints_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help affichage_fingerprints

% Last Modified by GUIDE v2.5 02-Apr-2020 14:00:59

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @affichage_fingerprints_OpeningFcn, ...
                   'gui_OutputFcn',  @affichage_fingerprints_OutputFcn, ...
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

% --- Executes just before affichage_fingerprints is made visible.
function affichage_fingerprints_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to affichage_fingerprints (see VARARGIN)

% Choose default command line output for affichage_fingerprints
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% This sets up the initial plot - only do when we are invisible
% so window can get raised using affichage_fingerprints.
% if strcmp(get(hObject,'Enable'),'off')
%     plot(rand(5));
% end

% UIWAIT makes affichage_fingerprints wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = affichage_fingerprints_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function OpenMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OpenMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
file = uigetfile('*.fig');
if ~isequal(file, 0)
    open(file);
end

% --------------------------------------------------------------------
function PrintMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to PrintMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
printdlg(handles.figure1)

% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = questdlg(['Close ' get(handles.figure1,'Name') '?'],...
                     ['Close ' get(handles.figure1,'Name') '...'],...
                     'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

delete(handles.figure1)


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


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

set(hObject, 'String', {'plot(rand(5))', 'plot(sin(1:0.01:25))', 'bar(1:.5:10)', 'plot(membrane)', 'surf(peaks)'});


% --- Executes on slider movement.
function slider_T1_Callback(hObject, eventdata, handles)
% hObject    handle to slider_T1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

klist=find(handles.T2(:)<handles.T1(round(get(hObject,'Value'))));
Value=min(klist(end),get(handles.slider_T2,'Value'));
set(handles.slider_T2,'Max',klist(end),'SliderStep',[1,1]/(klist(end)-1),'Value',Value);
set(handles.texte_T2value,'String',strcat(num2str(handles.T2(round(get(handles.slider_T2,'Value')))),' ms'));
handles.fingerprint=handles.dictionary(find(handles.T1list(:)==handles.T1(round(get(handles.slider_T1,'Value'))) & handles.T2list(:)==handles.T2(round(get(handles.slider_T2,'Value'))) & handles.dflist(:)==handles.df(round(get(handles.slider_df,'Value'))) & handles.B1list(:)==handles.B1(round(get(handles.slider_B1,'Value')))),:,(round(get(handles.slider_v,'Value'))));

plot(handles.graphe_fingerprint,abs(handles.fingerprint)./norm(abs(handles.fingerprint)));
set(handles.graphe_fingerprint, 'XLim', [1, handles.nPulses]);
title(handles.graphe_fingerprint,'Fingerprint (valeur absolue)');
xlabel(handles.graphe_fingerprint,'timepoint #');
ylabel(handles.graphe_fingerprint,'Signal (AU)');
set(handles.texte_T1value,'String',strcat(num2str(handles.T1(round(get(handles.slider_T1,'Value')))),' ms'));
guidata(hObject,handles);
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider_T1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_T1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider_T2_Callback(hObject, eventdata, handles)
% hObject    handle to slider_T2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.fingerprint=handles.dictionary(find(handles.T1list(:)==handles.T1(round(get(handles.slider_T1,'Value'))) & handles.T2list(:)==handles.T2(round(get(handles.slider_T2,'Value'))) & handles.dflist(:)==handles.df(round(get(handles.slider_df,'Value'))) & handles.B1list(:)==handles.B1(round(get(handles.slider_B1,'Value')))),:,(round(get(handles.slider_v,'Value'))));
plot(handles.graphe_fingerprint,abs(handles.fingerprint)./norm(abs(handles.fingerprint)));
set(handles.graphe_fingerprint, 'XLim', [1, handles.nPulses]);
title(handles.graphe_fingerprint,'Fingerprint (valeur absolue)');
xlabel(handles.graphe_fingerprint,'timepoint #');
ylabel(handles.graphe_fingerprint,'Signal (AU)');
set(handles.texte_T2value,'String',strcat(num2str(handles.T2(round(get(handles.slider_T2,'Value')))),' ms'));
guidata(hObject,handles);

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider_T2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_T2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider_df_Callback(hObject, eventdata, handles)
% hObject    handle to slider_df (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.fingerprint=handles.dictionary(find(handles.T1list(:)==handles.T1(round(get(handles.slider_T1,'Value'))) & handles.T2list(:)==handles.T2(round(get(handles.slider_T2,'Value'))) & handles.dflist(:)==handles.df(round(get(handles.slider_df,'Value'))) & handles.B1list(:)==handles.B1(round(get(handles.slider_B1,'Value')))),:,(round(get(handles.slider_v,'Value'))));
plot(handles.graphe_fingerprint,abs(handles.fingerprint)./norm(abs(handles.fingerprint)));
set(handles.graphe_fingerprint, 'XLim', [1, handles.nPulses]);
title(handles.graphe_fingerprint,'Fingerprint (valeur absolue)');
xlabel(handles.graphe_fingerprint,'timepoint #');
ylabel(handles.graphe_fingerprint,'Signal (AU)');
set(handles.texte_dfvalue,'String',strcat(num2str(handles.df(round(get(handles.slider_df,'Value')))),' Hz'));
guidata(hObject,handles);
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider_df_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_df (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2


% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_hold.
% ----------------------------------------------------------------------------------------------------------------------------------------------------------
function checkbox_hold_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_hold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if get(hObject,'Value')==1.0
    hold(handles.graphe_fingerprint,'on')
% set(handles.graphe_fingerprint'), 'Nextplot', 'add')
else
    hold(handles.graphe_fingerprint,'off')
% set(handles.graphe_fingerprint'), 'Nextplot', 'replace')
end

% Hint: get(hObject,'Value') returns toggle state of checkbox_hold


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over checkbox_hold.
function checkbox_hold_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to checkbox_hold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on slider movement.
function slider_B1_Callback(hObject, eventdata, handles)
% hObject    handle to slider_B1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.fingerprint=handles.dictionary(find(handles.T1list(:)==handles.T1(round(get(handles.slider_T1,'Value'))) & handles.T2list(:)==handles.T2(round(get(handles.slider_T2,'Value'))) & handles.dflist(:)==handles.df(round(get(handles.slider_df,'Value'))) & handles.B1list(:)==handles.B1(round(get(handles.slider_B1,'Value')))),:,(round(get(handles.slider_v,'Value'))));

plot(handles.graphe_fingerprint,abs(handles.fingerprint)./norm(abs(handles.fingerprint)));
set(handles.graphe_fingerprint, 'XLim', [1, handles.nPulses]);
title(handles.graphe_fingerprint,'Fingerprint (valeur absolue)');
xlabel(handles.graphe_fingerprint,'timepoint #');
ylabel(handles.graphe_fingerprint,'Signal (AU)');
set(handles.texte_B1value,'String',num2str(handles.B1(round(get(handles.slider_B1,'Value')))));
guidata(hObject,handles);
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider_B1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_B1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in pushbutton_load_sequence_rand.
function pushbutton_load_sequence_rand_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_load_sequence_rand (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% clear T1 T2 df handles.T1 handles.T2 handles.df handles.T1list handles.T2list hangles.dflist handles.dictionary handles.TE handles.TR handles.M0 handles.Ncycles handles.nPulses B1 handles.B1 handles.B1list handles.fingerprint

tmpDir  = fileparts(mfilename('fullpath'));
idx = strfind(tmpDir,'/');
rootDir = tmpDir(1:idx(end));
[filename, pathname] = uigetfile('*.mat', 'Choose dico_*.mat file', [rootDir, 'DictionaryCreation/Results/']);
% name=[pathname filename];
load([pathname, filename], 'dictionary');
splitPath = split(pathname, filesep);
load([pathname, 'prop_', splitPath{end-1}, '.mat'], 'Properties');
load([pathname, 'seq_', splitPath{end-1}, '.mat'], 'Sequence');
T1=unique(Properties.T1list);
T2=unique(Properties.T2list);
% df=unique(Properties.dflist);
handles.T1=T1;
handles.T2=T2;
% handles.df=df;
handles.T1list=Properties.T1list;
handles.T2list=Properties.T2list;
handles.dflist=Properties.dflist;
if exist('dictionary')
handles.dictionary=dictionary;
elseif exist('dico_flux')
handles.dictionary=dico_flux;
else
    disp('Error : no dictionary')
end
% handles.indices=indices; % VERIFIER SI UTILE
handles.TE=Sequence.TE;
handles.TR=Sequence.TR;
handles.FA=Sequence.FA;%_deg*pi/180;
handles.M0=Sequence.m0;
% handles.Ncycles=Sequence.Ncycles;
handles.nPulses=Sequence.nPulses;

% if exist('Properties.B1rellist')
if length(Properties.B1rel)>1
    set(handles.slider_B1,'Enable','on');
%     B1=unique(Properties.B1rel);
    handles.B1=Properties.B1rel;
    handles.B1list=squeeze(Properties.B1rellist);
else
    handles.B1=0;
    handles.B1list=0;
    set(handles.slider_B1,'Enable','off');
end

if length(Properties.vlist)>1
    set(handles.slider_v,'Enable','on');
    handles.v=Properties.vlist;
else
     handles.v=0;
     set(handles.slider_v,'Enable','off');
end

if length(Properties.df)>1
    handles.df = Properties.df;
    set(handles.slider_df,'Enable','on');
else
    handles.df = 0;
    set(handles.slider_df,'Enable','off');
end

if length(Properties.B1rel)>1
% set(handles.slider_B1'),'Min',1,'Max',length(B1),'Value',length(B1),'SliderStep',[1,1]/(length(B1)-1));
    set(handles.slider_B1,'Min',1,'Max',length(handles.B1),'Value',find(abs(handles.B1-1)==min(abs(handles.B1-1))),'SliderStep',[1,1]/(length(handles.B1)-1));
else
%     set(handles.slider_B1,'Min',-1,'Max',1 ,'Value',find(abs(B1-1)==min(abs(B1-1))),'SliderStep',[0,0]);
end

if length(handles.v)>1
    set(handles.slider_v,'Min',1,'Max',length(handles.v),'Value',1,'SliderStep',[1,1]/(length(handles.v)-1));
else
%     set(handles.slider_v,'Min', 0, 'Max', 0, 'Value',find(abs(handles.v)==min(abs(handles.v))),'SliderStep',[0,0]);   
end

if length(handles.df) > 1
    set(handles.slider_df,'Min',1,'Max',length(handles.df),'Value',find(abs(handles.df)==min(abs(handles.df))),'SliderStep',[1,1]/(length(handles.df)-1));
else
%     set(handles.slider_df,'Min',0,'Max',0,'Value',find(abs(df)==min(abs(df))),'SliderStep',[0,0]);
end

set(handles.slider_T1,'Min',1,'Max',length(T1),'Value',length(T1),'SliderStep',[1,1]/(length(T1)-1));
klist=find(handles.T2(:)<handles.T1(round(get(handles.slider_T1,'Value'))));
set(handles.slider_T2,'Min',1,'Max',klist(end),'Value',1,'SliderStep',[1,1]/(klist(end)-1));

    
set(handles.texte_T1value,'String',strcat(num2str(handles.T1(round(get(handles.slider_T1,'Value')))),' ms'));
set(handles.texte_T2value,'String',strcat(num2str(handles.T2(round(get(handles.slider_T2,'Value')))),' ms'));
set(handles.texte_dfvalue,'String',strcat(num2str(handles.df(round(get(handles.slider_df,'Value')))),' Hz'));
set(handles.texte_B1value,'String',num2str(handles.B1(round(get(handles.slider_B1,'Value')))));
set(handles.texte_vvalue,'String',strcat(num2str(handles.v(round(get(handles.slider_v,'Value')))),' mm/s'));

cla(handles.graphe_FA)
plot(handles.graphe_FA,handles.FA*180/pi)
title(handles.graphe_FA,'Flip angles');
xlabel(handles.graphe_FA,'Pulse #');
ylabel(handles.graphe_FA,'FA (°)');
set(handles.graphe_FA, 'XLim', [1, handles.nPulses]);



cla(handles.graphe_TR)
plot(handles.graphe_TR,handles.TR)
hold(handles.graphe_TR,'on')
plot(handles.graphe_TR,handles.TE)
title(handles.graphe_TR,'Repetition times (blue) & echo times (red)');
xlabel(handles.graphe_TR,'Pulse #');
ylabel(handles.graphe_TR,'TR & TE (ms)');
ylim(handles.graphe_TR,[0 max(handles.TR)+5])
set(handles.graphe_TR, 'XLim', [1, handles.nPulses]);

% handles.figFingerprint=handles.graphe_fingerprint');
handles.fingerprint=handles.dictionary(find(handles.T1list(:)==handles.T1(round(get(handles.slider_T1,'Value'))) & ...
    handles.T2list(:)==handles.T2(round(get(handles.slider_T2,'Value'))) & handles.dflist(:)==handles.df(round(get(handles.slider_df,'Value'))) & handles.B1list(:)==handles.B1(round(get(handles.slider_B1,'Value')))),:,(round(get(handles.slider_v,'Value'))));

cla(handles.graphe_fingerprint)
plot(handles.graphe_fingerprint,abs(handles.fingerprint)./norm(abs(handles.fingerprint)));
set(handles.graphe_fingerprint, 'XLim', [1, handles.nPulses]);
title(handles.graphe_fingerprint,'Fingerprint');
xlabel(handles.graphe_fingerprint,'Pulse #');
ylabel(handles.graphe_fingerprint,'Signal (AU)');
set(handles.graphe_fingerprint, 'XLim', [1, handles.nPulses]);


% set(hObject,'Enable','off');
% set(handles.pushbutton_load_sequence'),'Enable','off')

guidata(hObject,handles);


% --- Executes on slider movement.
function slider_v_Callback(hObject, eventdata, handles)
% hObject    handle to slider_v (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.fingerprint=handles.dictionary(find(handles.T1list(:)==handles.T1(round(get(handles.slider_T1,'Value'))) & handles.T2list(:)==handles.T2(round(get(handles.slider_T2,'Value'))) & handles.dflist(:)==handles.df(round(get(handles.slider_df,'Value'))) & handles.B1list(:)==handles.B1(round(get(handles.slider_B1,'Value')))),:,(round(get(handles.slider_v,'Value'))));

plot(handles.graphe_fingerprint,abs(handles.fingerprint)./norm(abs(handles.fingerprint)));
set(handles.graphe_fingerprint, 'XLim', [1, handles.nPulses]);
title(handles.graphe_fingerprint,'Fingerprint (valeur absolue)');
xlabel(handles.graphe_fingerprint,'timepoint #');
ylabel(handles.graphe_fingerprint,'Signal (AU)');
set(handles.texte_vvalue,'String',strcat(num2str(handles.v(round(get(handles.slider_v,'Value')))),' mm/s'));
guidata(hObject,handles);
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider_v_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_v (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in checkbox_normalization.
function checkbox_normalization_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_normalization (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_normalization

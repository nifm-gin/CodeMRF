function varargout = dataVsMatch(varargin)
% DATAVSMATCH MATLAB code for dataVsMatch.fig
%      DATAVSMATCH, by itself, creates a new DATAVSMATCH or raises the existing
%      singleton*.
%
%      H = DATAVSMATCH returns the handle to a new DATAVSMATCH or the handle to
%      the existing singleton*.
%
%      DATAVSMATCH('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DATAVSMATCH.M with the given input arguments.
%
%      DATAVSMATCH('Property','Value',...) creates a new DATAVSMATCH or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before dataVsMatch_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to dataVsMatch_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help dataVsMatch

% Last Modified by GUIDE v2.5 20-May-2020 10:06:42
switch numel(varargin)
    case 1
        assert(isstruct(varargin{1}), 'Single argument must be a struct containing Images, Reconstruction, dictionary, Properties structures')
end
% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @dataVsMatch_OpeningFcn, ...
                   'gui_OutputFcn',  @dataVsMatch_OutputFcn, ...
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


% --- Executes just before dataVsMatch is made visible.
function dataVsMatch_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to dataVsMatch (see VARARGIN)

switch numel(varargin)
    case 0
        handles.Images = struct;
        handles.Reconstruction = struct;
        handles.Properties = struct;
    case 1
        handles.Images = varargin{1}.Images;
        handles.Reconstruction = varargin{1}.Reconstruction;
        handles.Properties = varargin{1}.Properties;
    case 3
        handles.Images = varargin{1};
        handles.Reconstruction = varargin{2};
        handles.Properties = varargin{3};
    otherwise
        error('Inputs must be Images, Reconstruction, Properties structures, on a struct containing them')
end

% Choose default command line output for dataVsMatch
handles.output = hObject;
% handles.Images = evalin('base', 'Images');
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes dataVsMatch wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = dataVsMatch_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in startButton.
function startButton_Callback(hObject, eventdata, handles)
% hObject    handle to startButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% reset handles
handles.signalsDrawn = 0;
handles.x = 0; 
handles.y = 0;
handles.patch = zeros(handles.Images.nX, handles.Images.nY);
set(handles.coordDisp, 'String', 'X: Y:');
set(handles.matchIdx, 'String', 'Match #:');

% clear plots
cla(handles.rawDataPlot)
cla(handles.signals)
cla(handles.image1)
cla(handles.image2)
cla(handles.image3)
handles.valTable.Data{2,2}='ms';
handles.valTable.Data{3,2}='ms';
handles.valTable.Data{4,2}='Hz';
handles.valTable.Data{6,2}='mm/s';
% set(handles.rawDataPlot, 'PickableParts', 'all'); 
% Set raw plot
clickableImage(handles.rawDataPlot, squeeze(handles.Images.Images_dicom(:,:,round(handles.Images.nImages/2))))
set(handles.rawDataPlot, 'ColorMap', gray);
% Set slice selector initial value 
set(handles.frameNum, 'String', 'Frame:');
% Set slice selector range
% maxPt = round(min(size(handles.Images.Images_dicom,1), size(handles.Images.Images_dicom,2))/2);
maxPt = 5;
set(handles.sliceSelector, 'Min', 1, 'Max', handles.Images.nZ);
set(handles.frameNum, 'String', sprintf('Frame : %i/%i', round(handles.Images.nImages/2), handles.Images.nImages ));
set(handles.avgSlider, 'Min', 1, 'Max', maxPt);
set(handles.avgSlider, 'SliderStep', [1,1]/(maxPt-1), 'Value', 1)
set(handles.avgDisp, 'String', sprintf('Averaging: 1'));
guidata(hObject,handles);

% --- Executes on selection change in dataSelector1.
function dataSelector1_Callback(hObject, eventdata, handles)
% hObject    handle to dataSelector1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
localHandle = handles.image1;
choice = cellstr(get(hObject,'String'));
choice = choice{get(hObject,'Value')};
changePlot(localHandle, choice, handles);

% --- Executes during object creation, after setting all properties.
function dataSelector1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dataSelector1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in dataSelector2.
function dataSelector2_Callback(hObject, eventdata, handles)
% hObject    handle to dataSelector2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

localHandle = handles.image2;
choice = cellstr(get(hObject,'String'));
choice = choice{get(hObject,'Value')};
changePlot(localHandle, choice, handles);

% --- Executes during object creation, after setting all properties.
function dataSelector2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dataSelector2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in dataSelector3.
function dataSelector3_Callback(hObject, eventdata, handles)
% hObject    handle to dataSelector3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

localHandle = handles.image3;
choice = cellstr(get(hObject,'String'));
choice = choice{get(hObject,'Value')};
changePlot(localHandle, choice, handles);

% --- Executes during object creation, after setting all properties.
function dataSelector3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dataSelector3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in sliceSelector.
function sliceSelector_Callback(hObject, eventdata, handles)
% hObject    handle to sliceSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes during object creation, after setting all properties.
function sliceSelector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliceSelector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function rawDataPlot_CreateFcn(hObject, eventdata, handles)

%     handles.Images = evalin('base', 'Images');
%     imagesc(squeeze(handles.Images.Images_dicom(:,:,round(size(handles.Images.Images_dicom,3)/2))))
    set(gca,'xtick',[]); set(gca,'ytick',[]);
% hObject    handle to rawDataPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% --- Executes during object creation, after setting all properties.
function image1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to image1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(gca,'xtick',[]); set(gca,'ytick',[]);

% --- Executes during object creation, after setting all properties.
function image2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to image2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(gca,'xtick',[]); set(gca,'ytick',[]);

% --- Executes during object creation, after setting all properties.
function image3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to image3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(gca,'xtick',[]); set(gca,'ytick',[]);

function changePlot(localHandle, choice, handles)
% executes chen changing selection below plots
switch choice
    case 'Score'
        clickableImage(localHandle, handles.Reconstruction.innerproduct);
        caxis(localHandle, [min(handles.Reconstruction.innerproduct, [], 'All'), max(handles.Reconstruction.innerproduct, [], 'All')])
        colorbar(localHandle)
    case 'PD'
        clickableImage(localHandle, handles.Reconstruction.PDmap);
        caxis(localHandle, [min(handles.Reconstruction.PDmap, [], 'All'), max(handles.Reconstruction.PDmap, [], 'All')])
        colorbar(localHandle)
    case 'T1'
        clickableImage(localHandle, handles.Reconstruction.T1Map);
        caxis(localHandle, [min(handles.Reconstruction.T1Map, [], 'All'), max(handles.Reconstruction.T1Map, [], 'All')])
        c=colorbar(localHandle);
        set(get(c,'title'),'string','ms');
       
    case 'T2'
        clickableImage(localHandle, handles.Reconstruction.T2Map);
        caxis(localHandle, [min(handles.Reconstruction.T2Map, [], 'All'), max(handles.Reconstruction.T2Map, [], 'All')])
        c=colorbar(localHandle);
        set(get(c,'title'),'string','ms');
    case 'df'
        clickableImage(localHandle, handles.Reconstruction.dfMap);
        if numel(handles.Properties.df)>1
            caxis(localHandle, [min(handles.Reconstruction.dfMap, [], 'All'), max(handles.Reconstruction.dfMap, [], 'All')])
            c=colorbar(localHandle);
            set(get(c,'title'),'string','Hz');
        end
    case 'B1'        
        clickableImage(localHandle, handles.Reconstruction.B1relMap);
        if numel(handles.Properties.B1rel)>1
            caxis(localHandle, [min(handles.Reconstruction.B1relMap, [], 'All'), max(handles.Reconstruction.B1relMap, [], 'All')])
            colorbar(localHandle)
        end
    case 'Match #'
        clickableImage(localHandle, handles.Reconstruction.idxMatch);
        caxis(localHandle, [min(handles.Reconstruction.idxMatch, [], 'All'), max(handles.Reconstruction.idxMatch, [], 'All')])
        colorbar(localHandle)
    otherwise
        clickableImage(localHandle, zeros(size(handles.Images.Images_dicom, 1), size(handles.Images.Images_dicom, 2)));
end
set(localHandle, 'ColorMap', parula)
set(localHandle,'xtick',[]); set(localHandle,'ytick',[]);

function clickableImage(localHandle, dataToDisplay, cmap)
if nargin<3
    cmap=parula;
end
image(dataToDisplay, 'CDataMapping', 'Scaled', 'Parent', localHandle)
set(localHandle, 'ColorMap', cmap)
set(get(localHandle, 'Children'), 'HitTest', 'off');
set(localHandle,'ButtonDownFcn', @getCoord);
set(get(localHandle, 'Children'), 'ButtonDownFcn', @getCoord);
set(localHandle,'xtick',[]); set(localHandle,'ytick',[]);


% --- Executes on mouse press over axes background.
function getCoord(hObject, eventdata)
% hObject    handle to rawDataPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(hObject);
C = get(hObject, 'CurrentPoint');
% need to inverse x and y to match with matlab index convention : x must be the
% vertical dimension
x=round(C(1,2)); 
y=round(C(1,1));
if x > size(handles.Images.Images_dicom,1)
    x = size(handles.Images.Images_dicom,1);
end
if y > size(handles.Images.Images_dicom,1)
    y = size(handles.Images.Images_dicom,1);
end
set(handles.coordDisp, 'String', sprintf('X: %i, Y: %i', x, y));
handles.x = x;
handles.y = y;
drawSignals(hObject, eventdata, handles); % handles.patch is 0 outside this
handles = guidata(hObject);
guidata(hObject, handles)

% --- Executes on mouse press over axes background.
function signals_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to signals (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% disp(handles.sliceSelector.Value)
C = get(hObject, 'CurrentPoint');
frame = round(C(1,1));
clickableImage(handles.rawDataPlot, squeeze(handles.Images.Images_dicom(:,:, handles.sliceSelector.Value, frame)), gray)
set(handles.frameNum, 'String', sprintf('Frames : %i/%i', frame, handles.Images.nImages));

function drawSignals(hObject, eventdata, handles)
% Executed when clicking on a plot
sliceIdx = handles.sliceSelector.Value;
X = 1:handles.Images.nImages;
handles.patch = zeros(handles.Images.nX, handles.Images.nY); % Initialize transparent mask for averaging region display
if handles.avgSlider.Value == 1
    rawData = squeeze(handles.Images.Image_normalized_dicom(handles.x,handles.y, sliceIdx, :));
    match = handles.Reconstruction.sigMatch{sliceIdx}(handles.x,handles.y, :);
    handles.patch(handles.x, handles.y) = 1; % Set visibility for current voxel
else
    avg = handles.avgSlider.Value;
    rawData = zeros(size(squeeze(handles.Images.Image_normalized_dicom(handles.x,handles.y,:))));
    match = rawData;
    count = 0;
    % compute mean signal in a square around selected voxel
    for i = 0:2*avg-2
        for j=0:2*avg-2
            rawData = rawData + squeeze(handles.Images.Image_normalized_dicom(handles.x-(avg-1)+i,handles.y-(avg-1)+j,:));
            localMatch = handles.Reconstruction.sigMatch{sliceIdx}(handles.x-(avg-1)+i, handles.y-(avg-1)+j, :);
            match = match + squeeze(localMatch);
            handles.patch(handles.x-(avg-1)+i,handles.y-(avg-1)+j)=1; % Set visibility for current voxel
            count = count+1;
        end
    end
    rawData = rawData/count;
    match = match/count;
end
avgShow_Callback(hObject, eventdata, handles);
guidata(hObject, handles);
set(handles.matchIdx, 'String', sprintf('Match #: %i', handles.Reconstruction.idxMatch(handles.x,handles.y)));
set(handles.signals, 'nextPlot','replacechildren');
cla(handles.signals);
axes(handles.signals)
plot(X, rawData, 'b', X, squeeze(match), 'r')
legend(handles.signals, 'Acquired', 'Simulated')
handles.signalsDrawn = 1;

handles.valTable.Data{1,1} = num2str(handles.Reconstruction.innerproduct(handles.x, handles.y));
handles.valTable.Data{2,1} = num2str(handles.Reconstruction.T1Map(handles.x, handles.y));
handles.valTable.Data{3,1} = num2str(handles.Reconstruction.T2Map(handles.x, handles.y));
handles.valTable.Data{4,1} = num2str(handles.Reconstruction.dfMap(handles.x, handles.y));
handles.valTable.Data{5,1} = num2str(handles.Reconstruction.B1relMap(handles.x, handles.y));
handles.valTable.Data{6,1} = num2str(handles.Reconstruction.vMap(handles.x, handles.y));
handles.valTable.Data{7,1} = num2str(handles.Reconstruction.PDmap(handles.x, handles.y));

guidata(hObject, handles)


% --- Executes on slider movement.
function avgSlider_Callback(hObject, eventdata, handles)
% hObject    handle to avgSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.avgDisp, 'String', sprintf('Averaging: %i', round(get(hObject, 'Value'))))
if handles.signalsDrawn==1
    drawSignals(hObject, eventdata, handles)
end

% --- Executes during object creation, after setting all properties.
function avgSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to avgSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in avgShow.
function avgShow_Callback(hObject, eventdata, handles)
% hObject    handle to avgShow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
switch handles.avgShow.Value
    case 1
        if numel(handles.rawDataPlot.Children)>1
            handles.rawDataPlot.Children(1).Visible=0;
        end
        hold(handles.rawDataPlot, 'on')
        red = cat(3, ones(handles.Images.nX, handles.Images.nY), zeros(handles.Images.nX, handles.Images.nY), zeros(handles.Images.nX, handles.Images.nY));
        axes(handles.rawDataPlot)
        h = image(red, 'CDataMapping', 'Scaled', 'Parent', handles.rawDataPlot, 'AlphaData', handles.patch);
        % set(h, 'AlphaData', patch);
        set(get(handles.rawDataPlot, 'Children'), 'HitTest', 'off');
        set(handles.rawDataPlot,'ButtonDownFcn', @getCoord);
        set(get(handles.rawDataPlot, 'Children'), 'ButtonDownFcn', @getCoord);
        set(handles.rawDataPlot,'xtick',[]); set(handles.rawDataPlot,'ytick',[]);
    case 0
        if numel(handles.rawDataPlot.Children)>1
            handles.rawDataPlot.Children(1).Visible=0;
        end
end

% --- Executes when entered data in editable cell(s) in valTable.
function valTable_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to valTable (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in loadButton.
function loadButton_Callback(hObject, eventdata, handles)
% hObject    handle to loadButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file, path] = uigetfile;
load(fullfile(path, file), 'Images', 'Reconstruction', 'Properties');
handles.Images = Images;
handles.Reconstruction = Reconstruction;
handles.Properties = Properties;
clear Images Reconstruction Properties
guidata(hObject, handles)

% --- Executes on button press in saveButton.
function saveButton_Callback(hObject, eventdata, handles)
% hObject    handle to saveButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Images = handles.Images;
Reconstruction = handles.Reconstruction;
Properties = handles.Properties;
[file, path] = uiputfile;
save(fullfile(path, file),'Images', 'Reconstruction', 'Properties');



% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over saveButton.
function saveButton_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to saveButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

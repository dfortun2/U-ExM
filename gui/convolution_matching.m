function varargout = convolution_matching(varargin)
% CONVOLUTION_MATCHING MATLAB code for convolution_matching.fig
%      CONVOLUTION_MATCHING, by itself, creates a new CONVOLUTION_MATCHING or raises the existing
%      singleton*.
%
%      H = CONVOLUTION_MATCHING returns the handle to a new CONVOLUTION_MATCHING or the handle to
%      the existing singleton*.
%
%      CONVOLUTION_MATCHING('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CONVOLUTION_MATCHING.M with the given input arguments.
%
%      CONVOLUTION_MATCHING('Property','Value',...) creates a new CONVOLUTION_MATCHING or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before convolution_matching_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to convolution_matching_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help convolution_matching

% Last Modified by GUIDE v2.5 20-Nov-2017 13:24:14

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @convolution_matching_OpeningFcn, ...
                   'gui_OutputFcn',  @convolution_matching_OutputFcn, ...
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


% --- Executes just before convolution_matching is made visible.
function convolution_matching_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to convolution_matching (see VARARGIN)

handles.lambdaFull=str2double(get(handles.boxSmoothnessFinal,'String'));
handles.lambda=str2double(get(handles.boxSmoothnessConvMatch,'String'));
handles.symmetryC=str2double(get(handles.boxSymmetryC,'String'));
handles.shiftRange=str2double(get(handles.boxShiftRange,'String'));
handles.downsampling=str2double(get(handles.boxDownsampling,'String'));
handles.crop=str2double(get(handles.boxCrop,'String'));
handles.fnOutput=get(handles.boxFnOutput,'String');
handles.fnInputParts=get(handles.boxFnInputParts,'String');
handles.fnPsf=get(handles.boxFnPsf,'String');
handles.fnInitVol=get(handles.boxFnInitVol,'String');
handles.nbItersFinal=get(handles.boxIterationsFinal,'String');
handles.nbItersConvMatch=get(handles.boxNbItersConvMatch,'String');

listChannels={'Channel 1','Channel 2','Multichannel'};
set(handles.listChannels,'string',listChannels);
set(handles.listChannelsConvMatch,'string',listChannels);
set(handles.listChannelsFinal,'string',listChannels);

str=get(handles.boxAngleSampling,'String');
n=[];
nNew='';
for i=1:length(str)
    nNew=[nNew,str(i)];
    if (str(i)==',' || str(i)==' ' || i==length(str))
        n=[n,str2num(nNew)];
        nNew='';
    end
end
handles.angleSampling=n;

str=get(handles.boxAngleRange,'String');
n=[];
nNew='';
for i=1:length(str)
    nNew=[nNew,str(i)];
    if (str(i)==',' || str(i)==' ' || i==length(str))
        n=[n,str2num(nNew)];
        nNew='';
    end
end
handles.angleRange=n;

str=get(handles.boxShiftRange,'String');
n=[];
nNew='';
for i=1:length(str)
    nNew=[nNew,str(i)];
    if (str(i)==',' || str(i)==' ' || i==length(str))
        n=[n,str2num(nNew)];
        nNew='';
    end
end
handles.shiftRange=n;

% Choose default command line output for reference_free
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes convolution_matching wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = convolution_matching_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
% varargout{1} = handles.output;


% --- Executes on button press in buttonFinal.
function buttonFinal_Callback(hObject, eventdata, handles)
% hObject    handle to buttonFinal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

poseFinal=handles.poses;
poseFinal(:,4:6)=poseFinal(:,4:6)/handles.downsampling;

% Force even size
l=length(handles.inVolsC1);
newC1=cell(l,1);
newC2=cell(l,1);
for i=1:l
    yi=handles.inVolsC1{i}(:,:,:);
    newC1{i}=crop_fit_size_center(yi,size(yi)-mod(size(yi),2));
    yi=handles.inVolsC2{i}(:,:,:);
    newC2{i}=crop_fit_size_center(yi,size(yi)-mod(size(yi),2));
end

for i=1:l
    handles.inVolsC1{i}=newC1{i};
    handles.inVolsC2{i}=newC2{i};
end

set(handles.boxProgressFinalChannel,'String','Channel 1');drawnow;
handles.outVolC1 = reconstruction_InvPbLib(handles.inVolsC1,handles.psfC1,poseFinal,handles.lambdaFull,['C',num2str(handles.symmetryC)],handles.nbItersFinal,handles.ImXYFinal,handles.ImZYFinal,handles.ImXZFinal,handles.boxProgressFinal);
set(handles.boxProgressFinalChannel,'String','Channel 2');drawnow;
handles.outVolC2 = reconstruction_InvPbLib(handles.inVolsC2,handles.psfC2,poseFinal,handles.lambdaFull,['C',num2str(handles.symmetryC)],handles.nbItersFinal,handles.ImXYFinal,handles.ImZYFinal,handles.ImXZFinal,handles.boxProgressFinal);

axes(handles.ImXYFinal)
imagesc(squeeze(handles.outVolC1(:,:,floor(size(handles.outVolC1,3)/2)-1))); axis image; axis off ; colormap gray;
axes(handles.ImXZFinal)
imagesc(squeeze(handles.outVolC1(:,floor(size(handles.outVolC1,2)/2),:))); axis image; axis off ; colormap gray;
axes(handles.ImZYFinal)
imagesc(imrotate(squeeze(handles.outVolC1(floor(size(handles.outVolC1,1)/2),:,:)),90)); axis image; axis off ; colormap gray;

guidata(hObject, handles);

function boxSmoothnessFinal_Callback(hObject, eventdata, handles)
% hObject    handle to boxSmoothnessFinal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of boxSmoothnessFinal as text
%        str2double(get(hObject,'String')) returns contents of boxSmoothnessFinal as a double

handles.lambdaFull=str2double(get(hObject,'String'));

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function boxSmoothnessFinal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to boxSmoothnessFinal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in buttonSave.
function buttonSave_Callback(hObject, eventdata, handles)
% hObject    handle to buttonSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

reconC1=handles.outVolC1;
reconC2=handles.outVolC2;
save(handles.fnOutput,'reconC1','reconC2');

function boxDownsampling_Callback(hObject, eventdata, handles)
% hObject    handle to boxDownsampling (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of boxDownsampling as text
%        str2double(get(hObject,'String')) returns contents of boxDownsampling as a double

handles.downsampling=str2double(get(hObject,'String'));

contents=cellstr(get(handles.listParticles,'String'));
particle=contents{get(handles.listParticles,'Value')};
n='';
for i=length(particle):-1:1
    if strcmp(particle(i),' ')
        break
    end
    n=[particle(i),n];
end
n=str2num(n);

vol=handles.inVolsC1{n};
sizeDown = floor(size(vol)*handles.downsampling) + mod(floor(size(vol)*handles.downsampling),2);
vol=resizeVol(vol,[sizeDown(1),sizeDown(2),sizeDown(3)]);
vol=crop_fit_size_center(vol,[handles.crop,handles.crop,handles.crop]);

axes(handles.ImXYC1)
imagesc(squeeze(vol(:,:,floor(size(vol,3)/2)-1))); axis image; axis off ; colormap gray;
axes(handles.ImXZC1)
imagesc(squeeze(vol(:,floor(size(vol,2)/2),:))); axis image; axis off ; colormap gray;
axes(handles.ImZYC1)
imagesc(imrotate(squeeze(vol(floor(size(vol,1)/2),:,:)),90)); axis image; axis off ; colormap gray;

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function boxDownsampling_CreateFcn(hObject, eventdata, handles)
% hObject    handle to boxDownsampling (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function boxSymmetryC_Callback(hObject, eventdata, handles)
% hObject    handle to boxSymmetryC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of boxSymmetryC as text
%        str2double(get(hObject,'String')) returns contents of boxSymmetryC as a double

handles.symmetryC=str2double(get(hObject,'String'));

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function boxSymmetryC_CreateFcn(hObject, eventdata, handles)
% hObject    handle to boxSymmetryC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function boxCrop_Callback(hObject, eventdata, handles)
% hObject    handle to boxCrop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of boxCrop as text
%        str2double(get(hObject,'String')) returns contents of boxCrop as a double

handles.crop=str2double(get(hObject,'String'));

contents=cellstr(get(handles.listParticles,'String'));
particle=contents{get(handles.listParticles,'Value')};
n='';
for i=length(particle):-1:1
    if strcmp(particle(i),' ')
        break
    end
    n=[particle(i),n];
end
n=str2num(n);

vol=handles.inVolsC1{n};
sizeDown = floor(size(vol)*handles.downsampling) + mod(floor(size(vol)*handles.downsampling),2);
vol=resizeVol(vol,[sizeDown(1),sizeDown(2),sizeDown(3)]);
vol=crop_fit_size_center(vol,[handles.crop,handles.crop,handles.crop]);

axes(handles.ImXYC1)
imagesc(squeeze(vol(:,:,floor(size(vol,3)/2)-1))); axis image; axis off ; colormap gray;
axes(handles.ImXZC1)
imagesc(squeeze(vol(:,floor(size(vol,2)/2),:))); axis image; axis off ; colormap gray;
axes(handles.ImZYC1)
imagesc(imrotate(squeeze(vol(floor(size(vol,1)/2),:,:)),90)); axis image; axis off ; colormap gray;

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function boxCrop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to boxCrop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in buttonConvMatch.
function buttonConvMatch_Callback(hObject, eventdata, handles)
% hObject    handle to buttonConvMatch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[inVolsC1Prep,inVolsC2Prep,psf1Prep,psf2Prep,initVolC1Prep] = preprocessing_convmatch(handles.inVolsC1,handles.inVolsC2,handles.psfC1,handles.psfC2,handles.initVolC1,handles.downsampling,[handles.crop,handles.crop,handles.crop]);

options={'symmetry','C9','lambda',handles.lambda,'samplingList',handles.angleSampling,'rangeList',handles.angleRange,'rangeListShift',handles.shiftRange,'downsampling',handles.downsampling,'nbIters',handles.nbItersConvMatch};

[handles.convMatchReconC1,handles.convMatchReconC2,handles.poses] = convolution_matching_mc_indpt(handles,inVolsC1Prep,inVolsC2Prep,psf1Prep,psf2Prep,initVolC1Prep,options{:});

guidata(hObject, handles);

function boxProgress_Callback(hObject, eventdata, handles)
% hObject    handle to boxProgress (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of boxProgress as text
%        str2double(get(hObject,'String')) returns contents of boxProgress as a double


% --- Executes during object creation, after setting all properties.
function boxProgress_CreateFcn(hObject, eventdata, handles)
% hObject    handle to boxProgress (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function boxFnInitVol_Callback(hObject, eventdata, handles)

handles.fnInputPsf=get(hObject,'String');
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function boxFnInitVol_CreateFcn(hObject, eventdata, handles)
% hObject    handle to boxFnInitVol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function boxSmoothnessConvMatch_Callback(hObject, eventdata, handles)
% hObject    handle to boxSmoothnessConvMatch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of boxSmoothnessConvMatch as text
%        str2double(get(hObject,'String')) returns contents of boxSmoothnessConvMatch as a double

handles.lambda=str2double(get(hObject,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function boxSmoothnessConvMatch_CreateFcn(hObject, eventdata, handles)
% hObject    handle to boxSmoothnessConvMatch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function boxAngleSampling_Callback(hObject, eventdata, handles)
% hObject    handle to boxAngleSampling (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of boxAngleSampling as text
%        str2double(get(hObject,'String')) returns contents of boxAngleSampling as a double

str=get(hObject,'String');
n=[];
nNew='';
for i=1:length(str)
    nNew=[nNew,str(i)];
    if (str(i)==',' || str(i)==' ' || i==length(str))
        n=[n,str2num(nNew)];
        nNew='';
    end
end

handles.angleSampling=n;
           
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function boxAngleSampling_CreateFcn(hObject, eventdata, handles)
% hObject    handle to boxAngleSampling (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function boxAngleRange_Callback(hObject, eventdata, handles)
% hObject    handle to boxAngleRange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of boxAngleRange as text
%        str2double(get(hObject,'String')) returns contents of boxAngleRange as a double

str=get(hObject,'String');
n=[];
nNew='';
for i=1:length(str)
    nNew=[nNew,str(i)];
    if (str(i)==',' || str(i)==' ' || i==length(str))
        n=[n,str2num(nNew)];
        nNew='';
    end
end

handles.angleRange=n;
           
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function boxAngleRange_CreateFcn(hObject, eventdata, handles)
% hObject    handle to boxAngleRange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function boxShiftRange_Callback(hObject, eventdata, handles)
% hObject    handle to boxShiftRange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of boxShiftRange as text
%        str2double(get(hObject,'String')) returns contents of boxShiftRange as a double

str=get(hObject,'String');
n=[];
nNew='';
for i=1:length(str)
    nNew=[nNew,str(i)];
    if (str(i)==',' || str(i)==' ' || i==length(str))
        n=[n,str2num(nNew)];
        nNew='';
    end
end

handles.shiftRange=n;
           
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function boxShiftRange_CreateFcn(hObject, eventdata, handles)
% hObject    handle to boxShiftRange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listParticles.
function listParticles_Callback(hObject, eventdata, handles)
% hObject    handle to listParticles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listParticles contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listParticles

contents=cellstr(get(hObject,'String'));
particle=contents{get(hObject,'Value')};
n='';
for i=length(particle):-1:1
    if strcmp(particle(i),' ')
        break
    end
    n=[particle(i),n];
end
n=str2num(n);

contents=cellstr(get(handles.listChannels,'String'));
particle=contents{get(handles.listChannels,'Value')};
if strcmp(particle,'Channel 1')
    vol=handles.inVolsC1{n};
elseif strcmp(particle,'Channel 2')
    vol=handles.inVolsC2{n};
elseif strcmp(particle,'Multichannel')
    volC1=handles.inVolsC1{n};   
    volC2=handles.inVolsC2{n};    
    vol=cat(4,volC1/max(volC1(:)),volC2/max(volC2(:)),zeros(size(volC1)));
end

sizeDown = floor(size(vol)*handles.downsampling) + mod(floor(size(vol)*handles.downsampling),2);
volTmp=vol;
vol=zeros(handles.crop,handles.crop,handles.crop,size(vol,4));
for i=1:size(vol,4)
    volTmp2=resizeVol(volTmp(:,:,:,i),[sizeDown(1),sizeDown(2),sizeDown(3)]);
    vol(:,:,:,i)=crop_fit_size_center(volTmp2,[handles.crop,handles.crop,handles.crop]);
end
disp3D_gui(vol,handles.ImXYC1,handles.ImZYC1,handles.ImXZC1);

% --- Executes during object creation, after setting all properties.
function listParticles_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listParticles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function boxFnOutput_Callback(hObject, eventdata, handles)
% hObject    handle to boxFnOutput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of boxFnOutput as text
%        str2double(get(hObject,'String')) returns contents of boxFnOutput as a double

handles.fnOutput=get(hObject,'String');
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function boxFnOutput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to boxFnOutput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in buttonFnOutput.
function buttonFnOutput_Callback(hObject, eventdata, handles)
% hObject    handle to buttonFnOutput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[fn,path] = uiputfile('*.mat');
handles.fnOutput = [path,fn];
set(handles.boxFnOutput, 'String', handles.fnOutput);
guidata(hObject, handles);

% --- Executes on button press in buttonFnInitVol.
function buttonFnInitVol_Callback(hObject, eventdata, handles)

[fn,path] = uigetfile('*.mat');
handles.fnInitVol = [path,fn];
set(handles.boxFnInitVol, 'String', handles.fnInitVol);
guidata(hObject, handles);

% --- Executes on selection change in listParticles.
function listbox2_Callback(hObject, eventdata, handles)
% hObject    handle to listParticles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listParticles contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listParticles


% --- Executes during object creation, after setting all properties.
function listbox2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listParticles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in buttonLoad.
function buttonLoad_Callback(hObject, eventdata, handles)

load(handles.fnInitVol);
load(handles.fnPsf);
load(handles.fnInputParts);

handles.initVolC1=initVolC1;
handles.initVolC2=initVolC2;
handles.inVolsC1=inVolsC1;
handles.inVolsC2=inVolsC2;
handles.psfC1=psf1;
handles.psfC2=psf2;

N=length(handles.inVolsC1);
listParticles=cell(N,1);
for i=1:N
    listParticles{i}=['Particle ',num2str(i)];
end
 
set(handles.listParticles,'string',listParticles);

vol=handles.inVolsC1{1};
sizeDown = floor(size(vol)*handles.downsampling) + mod(floor(size(vol)*handles.downsampling),2);
vol=resizeVol(vol,[sizeDown(1),sizeDown(2),sizeDown(3)]);
vol=crop_fit_size_center(vol,[handles.crop,handles.crop,handles.crop]);
 
axes(handles.ImXYC1)
imagesc(squeeze(vol(:,:,floor(size(vol,3)/2)-1))); axis image; axis off ; colormap gray;
axes(handles.ImXZC1)
imagesc(squeeze(vol(:,floor(size(vol,2)/2),:))); axis image; axis off ; colormap gray;
axes(handles.ImZYC1)
imagesc(imrotate(squeeze(vol(floor(size(vol,1)/2),:,:)),90)); axis image; axis off ; colormap gray;

guidata(hObject, handles);

function boxFnPsf_Callback(hObject, eventdata, handles)

handles.fnInputPsf=get(hObject,'String');
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function boxFnPsf_CreateFcn(hObject, eventdata, handles)
% hObject    handle to boxFnPsf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in buttonFnPsf.
function buttonFnPsf_Callback(hObject, eventdata, handles)

[fn,path] = uigetfile('*.mat');
handles.fnPsf = [path,fn];
set(handles.boxFnPsf, 'String', handles.fnPsf);
guidata(hObject, handles);

function boxFnInputParts_Callback(hObject, eventdata, handles)

handles.fnInputParts=get(hObject,'String');
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function boxFnInputParts_CreateFcn(hObject, eventdata, handles)
% hObject    handle to boxFnInputParts (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in buttonFnInputParticles.
function buttonFnInputParticles_Callback(hObject, eventdata, handles)

[fn,path] = uigetfile('*.mat');
handles.fnInputParts = [path,fn];
set(handles.boxFnInputParts, 'String', handles.fnInputParts);
guidata(hObject, handles);

function boxIterationsFinal_Callback(hObject, eventdata, handles)

handles.nbItersFinal=str2double(get(hObject,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function boxIterationsFinal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to boxIterationsFinal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function boxNbItersConvMatch_Callback(hObject, eventdata, handles)

handles.nbItersConvMatch=str2double(get(hObject,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function boxNbItersConvMatch_CreateFcn(hObject, eventdata, handles)
% hObject    handle to boxNbItersConvMatch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listChannelsFinal.
function listChannelsFinal_Callback(hObject, eventdata, handles)

contents=cellstr(get(hObject,'String'));
particle=contents{get(hObject,'Value')};
if strcmp(particle,'Channel 1')
    vol=handles.outVolC1;
elseif strcmp(particle,'Channel 2')
    vol=handles.outVolC2;
elseif strcmp(particle,'Multichannel')
    volC1=handles.outVolC1;
    volC2=handles.outVolC2;
    vol=cat(4,volC1/max(volC1(:)),volC2/max(volC2(:)),zeros(size(volC1)));
end

disp3D_gui(vol,handles.ImXYFinal,handles.ImZYFinal,handles.ImXZFinal);

% --- Executes during object creation, after setting all properties.
function listChannelsFinal_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listChannels.
function listChannels_Callback(hObject, eventdata, handles)

contents=cellstr(get(handles.listParticles,'String'));
particle=contents{get(handles.listParticles,'Value')};
n='';
for i=length(particle):-1:1
    if strcmp(particle(i),' ')
        break
    end
    n=[particle(i),n];
end
n=str2num(n);

contents=cellstr(get(hObject,'String'));
particle=contents{get(hObject,'Value')};
if strcmp(particle,'Channel 1')
    vol=handles.inVolsC1{n};
elseif strcmp(particle,'Channel 2')
    vol=handles.inVolsC2{n};
elseif strcmp(particle,'Multichannel')
    volC1=handles.inVolsC1{n};   
    volC2=handles.inVolsC2{n};    
    vol=cat(4,volC1/max(volC1(:)),volC2/max(volC2(:)),zeros(size(volC1)));
end

sizeDown = floor(size(vol)*handles.downsampling) + mod(floor(size(vol)*handles.downsampling),2);
volTmp=vol;
vol=zeros(handles.crop,handles.crop,handles.crop,size(vol,4));
for i=1:size(vol,4)
    volTmp2=resizeVol(volTmp(:,:,:,i),[sizeDown(1),sizeDown(2),sizeDown(3)]);
    vol(:,:,:,i)=crop_fit_size_center(volTmp2,[handles.crop,handles.crop,handles.crop]);
end
disp3D_gui(vol,handles.ImXYC1,handles.ImZYC1,handles.ImXZC1);

% --- Executes during object creation, after setting all properties.
function listChannels_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listChannelsConvMatch.
function listChannelsConvMatch_Callback(hObject, eventdata, handles)

contents=cellstr(get(hObject,'String'));
particle=contents{get(hObject,'Value')};
if strcmp(particle,'Channel 1')
    vol=handles.convMatchReconC1;
elseif strcmp(particle,'Channel 2')
    vol=handles.convMatchReconC2;
elseif strcmp(particle,'Multichannel')
    volC1=handles.convMatchReconC1;
    volC2=handles.convMatchReconC2;
    vol=cat(4,volC1/max(volC1(:)),volC2/max(volC2(:)),zeros(size(volC1)));
end

disp3D_gui(vol,handles.ImXYRecon,handles.ImZYRecon,handles.ImXZRecon);

% --- Executes during object creation, after setting all properties.
function listChannelsConvMatch_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in buttonSaveTiff.
function buttonSaveTiff_Callback(hObject, eventdata, handles)

fnMat=handles.fnOutput;
for i=length(fnMat):-1:1
    if strcmp(fnMat(i),'.')
        fnTiffC1=[fnMat(1:i-1),'_C1.tif'];
        fnTiffC2=[fnMat(1:i-1),'_C2.tif'];
        break
    end
end

reconC1=handles.outVolC1;
reconC2=handles.outVolC2;
mijwrite_stack(reconC1,fnTiffC1,0);
mijwrite_stack(reconC2,fnTiffC2,0);

% --- Executes on button press in buttonFnOutputTiff.
function buttonFnOutputTiff_Callback(hObject, eventdata, handles)

[fn,path] = uigetfile('*.mat');
handles.fnOutput = [path,fn];
set(handles.boxFnOutput, 'String', handles.fnOutput);
guidata(hObject, handles);

function boxFnOutputTiff_Callback(hObject, eventdata, handles)

handles.fnOutputTiff=get(hObject,'String');
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function boxFnOutputTiff_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function boxProgressFinal_Callback(hObject, eventdata, handles)
% hObject    handle to boxProgressFinal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of boxProgressFinal as text
%        str2double(get(hObject,'String')) returns contents of boxProgressFinal as a double


% --- Executes during object creation, after setting all properties.
function boxProgressFinal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to boxProgressFinal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function boxProgressFinalChannel_Callback(hObject, eventdata, handles)
% hObject    handle to boxProgressFinalChannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of boxProgressFinalChannel as text
%        str2double(get(hObject,'String')) returns contents of boxProgressFinalChannel as a double


% --- Executes during object creation, after setting all properties.
function boxProgressFinalChannel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to boxProgressFinalChannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

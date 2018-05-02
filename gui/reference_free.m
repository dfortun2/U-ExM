function varargout = reference_free(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @reference_free_OpeningFcn, ...
                   'gui_OutputFcn',  @reference_free_OutputFcn, ...
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

% --- Executes just before reference_free is made visible.
function reference_free_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to reference_free (see VARARGIN)

handles.lambdaFull=str2double(get(handles.boxSmoothness,'String'));
handles.lambdaMcmc=str2double(get(handles.boxLambdaMcmc,'String'));
handles.symmetryC=str2double(get(handles.boxSymmetryC,'String'));
handles.nbIters=str2double(get(handles.boxIterations,'String'));
handles.nbItersFinal=str2double(get(handles.boxIterationsFinal,'String'));
handles.shiftRange=str2double(get(handles.boxShift,'String'));
handles.downsampling=str2double(get(handles.boxDownsampling,'String'));
handles.crop=str2double(get(handles.boxCrop,'String'));
handles.fnInputParts=get(handles.boxFnInputParts,'String');
handles.fnInputPsf=get(handles.boxFnInputPsf,'String');
handles.fnOutput=get(handles.boxFnOutput,'String');

listChannels={'Channel 1','Channel 2','Multichannel'};
set(handles.listChannels,'string',listChannels);
set(handles.listChannelsRefFree,'string',listChannels);
set(handles.listChannelsFinal,'string',listChannels);

% Choose default command line output for reference_free
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes reference_free wait for user response (see UIRESUME)
uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = reference_free_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
%varargout{1} = handles.output;

function boxDownsampling_Callback(hObject, eventdata, handles)

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

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function boxDownsampling_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function boxSymmetryC_Callback(hObject, eventdata, handles)

handles.symmetryC=str2double(get(hObject,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function boxSymmetryC_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function boxIterationsFullSize_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function boxShift_Callback(hObject, eventdata, handles)

handles.shiftRange=str2double(get(hObject,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function boxShift_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% % --- Executes on button press in buttonRunRefFree.
% function buttonRunRefFree_Callback(hObject, eventdata, handles)
% 
% [inVolsC1,inVolsC2,psf1,psf2] = preprocessing(handles.inVolsC1,handles.inVolsC2,handles.psf1,handles.psf2,downsampling,sizeCrop);

% --- Executes during object creation, after setting all properties.
function textCrop_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function listParticles_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in buttonRefFree.
function buttonRefFree_Callback(hObject, eventdata, handles)

[inVolsC1,inVolsC2,psf1,psf2] = preprocessing(handles.inVolsC1,handles.inVolsC2,handles.psfC1,handles.psfC2,handles.downsampling,[handles.crop,handles.crop,handles.crop]);

optionsMcmc={'lambda',handles.lambdaMcmc,'nbItersAngle',handles.nbIters,'symmetryC',handles.symmetryC,'shiftrange',handles.shiftRange};

if handles.symmetryC == 1
    [handles.initVolC1,handles.initVolC2,handles.initPose] = mcmc_recon_clean_nosymmetry_shift(handles,inVolsC1,inVolsC2,psf1,psf2,optionsMcmc{:});
else
    [handles.initVolC1,handles.initVolC2,handles.initPose] = mcmc_recon_clean_symmetryC_shift(handles,inVolsC1,inVolsC2,psf1,psf2,optionsMcmc{:});
end

guidata(hObject, handles);

% --- Executes on button press in buttonFullSize.
function buttonFullSize_Callback(hObject, eventdata, handles)

poseFinal=handles.initPose;
poseFinal(:,4:6)=poseFinal(:,4:6)/handles.downsampling;

% Force even size
for i=1:length(handles.inVolsC1)
    yi=handles.inVolsC1{i};
    handles.inVolsC1{i}=crop_fit_size_center(yi,size(yi)-mod(size(yi),2));
    yi=handles.inVolsC2{i};
    handles.inVolsC2{i}=crop_fit_size_center(yi,size(yi)-mod(size(yi),2));

    psfC1=handles.psfC1;
    psfC2=handles.psfC2;
    handles.psfC1=crop_fit_size_center(psfC1,size(psfC1)-mod(size(psfC1),2));
    handles.psfC2=crop_fit_size_center(psfC2,size(psfC2)-mod(size(psfC2),2));
end

set(handles.boxProgressFinalChannel,'String','Channel 1');drawnow;
initVolFinalC1 = reconstruction_InvPbLib(handles.inVolsC1,handles.psfC1,poseFinal,handles.lambdaFull,['C',num2str(handles.symmetryC)],handles.nbItersFinal,handles.ImXYFinal,handles.ImZYFinal,handles.ImXZFinal,handles.boxProgressFinal);
set(handles.boxProgressFinalChannel,'String','Channel 2');drawnow;
initVolFinalC2 = reconstruction_InvPbLib(handles.inVolsC2,handles.psfC2,poseFinal,handles.lambdaFull,['C',num2str(handles.symmetryC)],handles.nbItersFinal,handles.ImXYFinal,handles.ImZYFinal,handles.ImXZFinal,handles.boxProgressFinal);

disp3D_gui(initVolFinalC1,handles.ImXYFinal,handles.ImZYFinal,handles.ImXZFinal);

handles.initVolFinalC1=initVolFinalC1;
handles.initVolFinalC2=initVolFinalC2;

set(handles.boxProgressFinalChannel,'String','Done');drawnow;
set(handles.boxProgressFinal,'String','');drawnow;

guidata(hObject, handles);


function boxSmoothness_Callback(hObject, eventdata, handles)

handles.lambdaFull=str2double(get(hObject,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function boxSmoothness_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function boxProgress_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function boxProgress_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in buttonFinish.
function buttonFinish_Callback(hObject, eventdata, handles)

initVolC1=handles.initVolFinalC1;
initVolC2=handles.initVolFinalC2;
save(handles.fnOutput,'initVolC1','initVolC2');

% --- Executes on selection change in listParticles.
function listParticles_Callback(hObject, eventdata, handles)

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
function listbox2_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function boxFnInputParts_Callback(hObject, eventdata, handles)

handles.fnInputParts=get(hObject,'String');
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function boxFnInputParts_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function boxFnInputPsf_Callback(hObject, eventdata, handles)

handles.fnInputPsf=get(hObject,'String');
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function boxFnInputPsf_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in buttonInputParts.
function buttonInputParts_Callback(hObject, eventdata, handles)

[fn,path] = uigetfile('*.mat');
handles.fnInputParts = [path,fn];
set(handles.boxFnInputParts, 'String', handles.fnInputParts);
guidata(hObject, handles);

% --- Executes on button press in buttonInputPsf.
function buttonInputPsf_Callback(hObject, eventdata, handles)

[fn,path] = uigetfile('*.mat');
handles.fnInputPsf = [path,fn];
set(handles.boxFnInputPsf, 'String', handles.fnInputPsf);
guidata(hObject, handles);

function boxFnOutput_Callback(hObject, eventdata, handles)

handles.fnOutput=get(hObject,'String');
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function boxFnOutput_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in buttonOutput.
function buttonOutput_Callback(hObject, eventdata, handles)

[fn,path] = uiputfile('*.mat');
handles.fnOutput = [path,fn];
set(handles.boxFnOutput, 'String', handles.fnOutput);
guidata(hObject, handles);

function boxLambdaMcmc_Callback(hObject, eventdata, handles)

handles.lambdaMcmc=str2double(get(hObject,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function boxLambdaMcmc_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in buttonLoad.
function buttonLoad_Callback(hObject, eventdata, handles)

load(handles.fnInputParts);
load(handles.fnInputPsf);

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

disp3D_gui(vol,handles.ImXYC1,handles.ImZYC1,handles.ImXZC1)

guidata(hObject, handles);



function boxIterationsFinal_Callback(hObject, eventdata, handles)

handles.nbItersFinal=str2double(get(hObject,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function boxIterationsFinal_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function boxIterations_Callback(hObject, eventdata, handles)

handles.nbIters=str2double(get(hObject,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function boxIterations_CreateFcn(hObject, eventdata, handles)
% hObject    handle to boxIterations (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function boxCrop_Callback(hObject, eventdata, handles)

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

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function boxCrop_CreateFcn(hObject, eventdata, handles)

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


% --- Executes on selection change in listChannelsFinal.
function listChannelsFinal_Callback(hObject, eventdata, handles)

contents=cellstr(get(hObject,'String'));
particle=contents{get(hObject,'Value')};
if strcmp(particle,'Channel 1')
    vol=handles.initVolFinalC1;
elseif strcmp(particle,'Channel 2')
    vol=handles.initVolFinalC2;
elseif strcmp(particle,'Multichannel')
    volC1=handles.initVolFinalC1;
    volC2=handles.initVolFinalC2;
    vol=cat(4,volC1/max(volC1(:)),volC2/max(volC2(:)),zeros(size(volC1)));
end

disp3D_gui(vol,handles.ImXYFinal,handles.ImZYFinal,handles.ImXZFinal);

% --- Executes during object creation, after setting all properties.
function listChannelsFinal_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listChannelsRefFree.
function listChannelsRefFree_Callback(hObject, eventdata, handles)

contents=cellstr(get(hObject,'String'));
particle=contents{get(hObject,'Value')};
if strcmp(particle,'Channel 1')
    vol=handles.initVolC1;
elseif strcmp(particle,'Channel 2')
    vol=handles.initVolC2;
elseif strcmp(particle,'Multichannel')
    volC1=handles.initVolC1;
    volC2=handles.initVolC2;
    vol=cat(4,volC1/max(volC1(:)),volC2/max(volC2(:)),zeros(size(volC1)));
end

disp3D_gui(vol,handles.ImXYRecon,handles.ImZYRecon,handles.ImXZRecon);


% --- Executes during object creation, after setting all properties.
function listChannelsRefFree_CreateFcn(hObject, eventdata, handles)

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

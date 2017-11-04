function varargout = Sim_Optimize_Protocol_GUI(varargin)
% Sim_SimOptProt MATLAB code for Sim_SimOptProt.fig

% Edit the above text to modify the response to help Sim_SimOptProt

% Last Modified by GUIDE v2.5 06-Oct-2017 17:47:23

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @Sim_SimOptProt_OpeningFcn, ...
    'gui_OutputFcn',  @Sim_SimOptProt_OutputFcn, ...
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

% --- Executes just before Sim_SimOptProt is made visible.
function Sim_SimOptProt_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
handles.Model = varargin{1};
if ~isfield(handles,'opened')
    % clear axe
    %axes(handles.SimOptAxe)
    % fill table
    Nparam=length(handles.Model.xnames);
    if isprop(handles.Model,'st') && ~isempty(handles.Model.st)
        FitOptTable(1,:)=mat2cell(handles.Model.st,1,ones(Nparam,1));
    elseif isprop(handles.Model,'ub') && ~isempty(handles.Model.ub) && isprop(handles.Model,'lb') && ~isempty(handles.Model.lb)
        FitOptTable(1,:)=mat2cell((handles.Model.ub-handles.Model.lb)/2,ones(1,Nparam));
    end
    set(handles.ParamTable,'ColumnName',handles.Model.xnames)
    set(handles.ParamTable,'ColumnEditable',true(1,Nparam))
    set(handles.ParamTable,'Data',FitOptTable)
    
    % Options
    opts = {};
    if isprop(handles.Model,'Sim_Optimize_Protocol_buttons'), opts = cat(2,opts,handles.Model.Sim_Optimize_Protocol_buttons); end
    handles.options = GenerateButtons(opts,handles.OptionsPanel,.15);

    handles.opened = 1;
end
% Update handles structure
guidata(hObject, handles);


% UIWAIT makes Sim_SimOptProt wait for user response (see UIRESUME)
% uiwait(handles.Simu);


% --- Outputs from this function are returned to the command line.
function varargout = Sim_SimOptProt_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure



% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in Save.
function Save_Callback(hObject, eventdata, handles)
if isfield(handles,'ProtOpt')
    Method = class(handles.Model);
    [FileName,PathName] = uiputfile([Method '_ProtocolOptim.mat']);
    if PathName == 0, return; end
    Model = handles.Model;
    Model.Prot.(Model.MRIinputs{1}).Mat = handles.ProtOpt;
    save(fullfile(PathName,FileName),'Model')
end

% --- Executes on button press in SimOptProtUpdate.
function SimOptProtUpdate_Callback(hObject, eventdata, handles)
set(findobj('Name','SimOptProt'),'pointer', 'watch'); drawnow;
% Read Table
Model_new = getappdata(0,'Model');
if ~isempty(Model_new) && strcmp(class(Model_new),class(handles.Model))
    handles.Model = Model_new;
end
ParamOpt = get(handles.ParamTable,'Data');
Opt = button_handle2opts(handles.options);
axes(handles.uipanel12);
xvalues=cell2mat(ParamOpt);
handles.ProtOpt = handles.Model.Sim_Optimize_Protocol(xvalues, Opt);
guidata(hObject, handles);

Model = handles.Model;
Model.Prot.(Model.MRIinputs{1}).Mat = handles.ProtOpt;
if ismethod(Model,'plotProt')
Model.plotProt;
else
    Model.plotmodel(xvalues(1,:));
end
set(findobj('Name','SimOptProt'),'pointer', 'arrow'); drawnow;



% GETAPPDATA
function varargout = GetAppData(varargin)
for k=1:nargin; varargout{k} = getappdata(0, varargin{k}); end

%SETAPPDATA
function SetAppData(varargin)
for k=1:nargin; setappdata(0, inputname(k), varargin{k}); end

% RMAPPDATA
function RmAppData(varargin)
for k=1:nargin; rmappdata(0, varargin{k}); end


% --- Executes when entered data in editable cell(s) in ParamTable.
function ParamTable_CellEditCallback(hObject, eventdata, handles)
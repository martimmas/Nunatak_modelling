
function [UserVar,CtrlVar,MeshBoundaryCoordinates]=DefineInitialInputs(UserVar,CtrlVar)
%% General info for the simulation
CtrlVar.Experiment='Transient'; % Name of the experiment to be run (see "Types of runs")
UserVar.OutputFileName='IceCap-spn0y3n10km_msh05km';      % Name of the output file correspondent to this run

% Implemented Experiment options
% '-Transient'

CtrlVar.FlowApproximation='SSTREAM' ;  % 'SSTREAM'|'SSHEET'|'Hybrid'        

%% Runs controls (might be overwritten based on choice of experiment)
% Choose which Control run to base the run in 
% UserVar.RefControl='Control1';                  % for sensitivity experiments (Default: 'Control1')
UserVar.TransRestartRef = '';

% Choose which member to run for multi-member runs
UserVar.SensEnsMember = 'SMP-SpinupDyn';  % Valid for '-Sensitivity-Ensemble' and '-Sensitivity-ModParams' only!
UserVar.ControlMember = '3';     % Valid for '-Control' only!

%% Restart (might be overwritten based on choice of experiment)
CtrlVar.Restart=0;  CtrlVar.WriteRestartFile=1;
CtrlVar.NameOfRestartFiletoWrite=['../../ResultsFiles/Restart',UserVar.OutputFileName,'.mat'];

%% plotting
CtrlVar.doplots=1; CtrlVar.doRemeshPlots=0;
CtrlVar.PlotLabels=0 ; CtrlVar.PlotMesh=1; CtrlVar.PlotBCs=0;
CtrlVar.PlotXYscale=1000;     % used to scale x and y axis of some of the figures, only used for plotting purposes

UserVar.DoTransientPlots=0;
UserVar.SaveTransientFiles =  1;
CtrlVar.DefineOutputsDt        = 100; % every years

%% Setting the mesh domain
UserVar.xd=150e3; UserVar.xu=-150e3 ; UserVar.yl=100e3 ; UserVar.yr=-100e3;

MeshBoundaryCoordinates=flipud([UserVar.xu UserVar.yr ; UserVar.xd UserVar.yr ;...
                                UserVar.xd UserVar.yl ; UserVar.xu UserVar.yl]);
CtrlVar.GmshGeoFileAdditionalInputLines{1}='Periodic Line {1,2} = {3,4};'; % necessary for periodic BCs
%CtrlVar.GmshGeoFileAdditionalInputLines{1}='Periodic Line {2} = {4};'; % necessary for periodic BCs

%% Time settings

CtrlVar.dt=0.01;
CtrlVar.AdaptiveTimeStepping=1 ;
CtrlVar.TotalTime=400;

%% Types of runs
switch CtrlVar.Experiment
                                     
    case 'Transient'  
        CtrlVar.TimeDependentRun=1;
        if strcmp(UserVar.TransRestartRef,'') == 1
            CtrlVar.Restart     = 0;
        else
            CtrlVar.Restart     = 1;
        end
        CtrlVar.ResetTime   = 1;
        CtrlVar.TotalTime   = 2e4;                % Set duration of simulation (years)
        CtrlVar.RestartTime = 0;

        
        %UserVar.EnsMember = UserVar.TransRestartRef(4:end);
        UserVar = SetEnsembleParams(UserVar);       
        % Updating C and AGlen to match ice-stream margin values according
        % to Gudmundsson et al. (2019)
        UserVar.IceTemp = -20.0; % -20 deg. C based on log10(AGlen) ~ -8.5
        UserVar.Cub     =  50.0; % 50.0 Based on log10(C) ~ -4.5; 500 based on log10(C) ~ -3.5
        UserVar.CenterH  = 1200.;
        
        UserVar.SaveTransientFiles =1;        
        
        if contains(UserVar.TransRestartRef,'/')
            CtrlVar.NameOfRestartFiletoRead=UserVar.TransRestartRef;
        else
            CtrlVar.NameOfRestartFiletoRead=['../../ResultsFiles/',UserVar.TransRestartRef];
        end
        UserVar.Slipperiness.ReadFromFile=0;
        UserVar.AGlen.ReadFromFile=0;        
        
        UserVar.MassBalance.Distribution = 'symmetrical'; %options: 'linear', 's', 'symmetrical', 'symmetrical enhanced', 'none'
        UserVar.MassBalance.Evolution    = 'none'; % 'step'|'scaled'|'none/default' (linear is the default)
        UserVar.MassBalance.ScalingFile  = '../../InputFiles/LR04_scaled_curve.mat'; % THIS WILL ONLY SCALE START AND END VALUES
        UserVar.MassBalance.EdgeMax      = -0.3;% - 0.04;     % maximum value at the edge for the 'linear' distribution (signal controls the slope)
        UserVar.MassBalance.CentreValue  =  1.3;% + 0.02;
        UserVar.MassBalance.StartValue   =  0.0;     % Set mass balance value for start of run (m/yr at upstream boundary)
        UserVar.MassBalance.EndValue     =  0.0;    % Set mass balance value for end of run (m/yr at upstream boundary) [default: -0.1 m/a]        
        
        %UserVar.MassBalance.IncMeltFactor   = 5.4;    % for use with symmetrical enhanced only!
        %UserVar.MassBalance.IncMeltDistance = 130e3;  % for use with symmetrical enhanced only!
                
        % Only for Step-wise increase in SMB                
        %UserVar.MassBalance.dStep      = -0.01; % will add up the following mass balance
        %UserVar.MassBalance.dtStep     = 2.0e3; % after this amount of time        
        
        UserVar.BasalMelt.Mode = 'None'; %{'ShelfMelt'|'ShelfBreak'|'None'}
        UserVar.BasalMelt.BreakTimeStart = 5.0e3;
        UserVar.BasalMelt.dtCalv         = 2.0e3;
        %UserVar.BasalMelt.BreakTimeEnd   = 5.5e3;
        UserVar.SeaLevelRise=0;
        UserVar.BasalMelt.StartValue = 0.;%-100.0;
        UserVar.BasalMelt.EndValue   = 0.;%-160.0;
        
        UserVar.BedrockType = 'sloping';
        UserVar.BedrockSlope = -9e-3; % -5e-3; 1e-3 for retrograde
        UserVar.CenterB      = 750; % +250 for prograde; -600 for retrograde w/ floating terminus
        if contains(UserVar.TransRestartRef,'Spinup0')
            UserVar.NunatakQuantity = 0;
        else
            UserVar.NunatakQuantity = str2double(UserVar.ControlMember);
        end
        UserVar.NunatakShape = '0y';
        UserVar.NunatakSpacing = 15e3; % how far away the nunataks are from each other, in m            
                                      % N.B.: when considering the exposed bedrock at 2000 m surface height and base bedrock elevation of 500 m
                                      % testing: 5e3; 10e3; 15e3; 20e3;
                                      % In the current setup, the distance is actually smaller. Consider 5e3
                                      % to be 0 km spacing, 10e3 as 5 km spacing, 15e3 as 10, 20e3 as 15 km
        
        CtrlVar.AdaptMesh=0;
        UserVar.DoTransientPlots=1;
        UserVar.nunatak_points.x = 50e3 + [-50e3, -20e3,-1.5e3,1.5e3,20e3, 50e3]; % Specify x-coordinates for nunatak points
        UserVar.nunatak_points.y = [0.,0.,0.,0.,0.,0.]; % Specify y-coordinates for nunatak points                

end

%% Surface points to be plotted
if UserVar.DoTransientPlots==1
    if isfield(UserVar,'nunatak_points')
        if ~isfield(UserVar.nunatak_points,'x') 
            UserVar.nunatak_points.x = [-5e3, -1e3, -5e2, -2.5e2, 0, 2.5e2, 5e2, 1e3, 5e3];
        end
        if ~isfield(UserVar.nunatak_points,'y') && UserVar.DoTransientPlots
            UserVar.nunatak_points.y = [0, 0, 0, 0, 0, 0, 0, 0, 0];
        end
    else
        UserVar.nunatak_points.x = [-5e3, -1e3, -5e2, -2.5e2, 0, 2.5e2, 5e2, 1e3, 5e3];
        UserVar.nunatak_points.y = [0, 0, 0, 0, 0, 0, 0, 0, 0];
    end
end
%% Velocity constraints 
CtrlVar.ThicknessConstraints=1; % Activates "minimum thickness for ice flow actually being computed"
CtrlVar.ThickMin=1.; % threshold [m] for the minimum thickness


%% Extra Parameters for time-dependent runs

if isfield(CtrlVar,'TotalTime')
    CtrlVar.TotalNumberOfForwardRunSteps=10e6;    
else
    CtrlVar.TotalTime = 10e6;
    CtrlVar.TotalNumberOfForwardRunSteps=50;
end

if isfield(CtrlVar,'RestartTime') && ~isnan(CtrlVar.RestartTime)
    CtrlVar.time=CtrlVar.RestartTime;
else
    CtrlVar.time=0;
end

%CtrlVar.Implicituvh=0;      CtrlVar.TG3=0;
%CtrlVar.uvhTimeSteppingMethod='theta';  % theta | tg3 | supg
%CtrlVar.uvhTimeSteppingMethod='supg';  % theta | tg3 | supg
%CtrlVar.SUPG.beta0=0.5 ; CtrlVar.SUPG.beta1=0.0 ;
%CtrlVar.theta=0.5;

%CtrlVar.uvhTimeSteppingMethod='tg3';  CtrlVar.TG3=1 ; % theta | tg3 | supg
%CtrlVar.uvhTimeSteppingMethod='shocks';

%CtrlVar.SpeedZero=1e-10;


%% Solver
CtrlVar.NLtol=1e-15; % this is the square of the error, i.e. not root-mean-square error
CtrlVar.InfoLevelNonLinIt=1;
CtrlVar.InfoLevel=10;
CtrlVar.LineSeachAllowedToUseExtrapolation=1;

%% Mesh generation, loading, and (re)meshing parameters

% if CtrlVar.Restart == 1
%     CtrlVar.ReadInitialMesh=1; % if true then read FE mesh (coordinates, connectivity) directly from a .mat file
%                                % unless the adaptive meshing option is used, no further meshing is done.
%     CtrlVar.ReadInitialMeshFileName='GmshFileDeglac.mat';
% else
%     CtrlVar.ReadInitialMesh=0;
% end

%CtrlVar.GmshMeshingMode = 'load .msh file'; % meshing mode for use with gmesh or mesh2d
                                        % 'create new gmsh .geo input file' :: creates a .geo mesh file
                                        % 'mesh domain'                     :: uses .geo file to create the mesh
                                        % 'load .msh file'                  :: loads the .msh file
                                        % these can be combined accordingly using 'and' in the MeshingMode string 
CtrlVar.GmshFile = 'GmshFile';
CtrlVar.TriNodes=3 ;
CtrlVar.MeshSize=5e3;
CtrlVar.MeshSizeMin=5e3;%2.5e2;
CtrlVar.MeshSizeMax=CtrlVar.MeshSize;
CtrlVar.MaxNumberOfElements=250000;


%% for adaptive meshing
CtrlVar.AdaptMesh=0;
CtrlVar.MeshGenerator='gmsh';  % possible values: {mesh2d|gmsh}
CtrlVar.GmshMeshingAlgorithm=8;     % see gmsh manual

if contains(CtrlVar.Experiment,'Transient')    
    CtrlVar.SaveAdaptMeshFileName = 'GmshFileDeglac';
else
    CtrlVar.SaveAdaptMeshFileName = 'GmshFile';
end
CtrlVar.SaveInitialMeshFileName = '';

CtrlVar.AdaptMeshInitial=0  ; % remesh in first run-step irrespecitivy of the value of AdaptMeshInterval
% CtrlVar.AdaptMeshInterval=100; %6 ; % Number of run-steps between mesh adaptation
% CtrlVar.AdaptMeshMaxIterations=10;  % Number of adapt mesh iterations within each run-step.
% CtrlVar.AdaptMeshUntilChangeInNumberOfElementsLessThan=0;

CtrlVar.InfoLevelAdaptiveMeshing=1;
CtrlVar.MeshRefinementMethod='explicit:local:newest vertex bisection';

I=1;
CtrlVar.ExplicitMeshRefinementCriteria(I).Name='effective strain rates';
CtrlVar.ExplicitMeshRefinementCriteria(I).Scale=0.01;
CtrlVar.ExplicitMeshRefinementCriteria(I).EleMin=[];
CtrlVar.ExplicitMeshRefinementCriteria(I).EleMax=[];
CtrlVar.ExplicitMeshRefinementCriteria(I).p=[];
CtrlVar.ExplicitMeshRefinementCriteria(I).InfoLevel=1;
CtrlVar.ExplicitMeshRefinementCriteria(I).Use=false;


I=I+1;
CtrlVar.ExplicitMeshRefinementCriteria(I).Name='effective strain rates gradient';
CtrlVar.ExplicitMeshRefinementCriteria(I).Scale=0.001/1000;
CtrlVar.ExplicitMeshRefinementCriteria(I).EleMin=[];
CtrlVar.ExplicitMeshRefinementCriteria(I).EleMax=[];
CtrlVar.ExplicitMeshRefinementCriteria(I).p=[];
CtrlVar.ExplicitMeshRefinementCriteria(I).InfoLevel=1;
CtrlVar.ExplicitMeshRefinementCriteria(I).Use=true;

I=I+1;
CtrlVar.ExplicitMeshRefinementCriteria(I).Name='thickness gradient';
CtrlVar.ExplicitMeshRefinementCriteria(I).Scale=0.01;
CtrlVar.ExplicitMeshRefinementCriteria(I).EleMin=[];
CtrlVar.ExplicitMeshRefinementCriteria(I).EleMax=[];
CtrlVar.ExplicitMeshRefinementCriteria(I).p=[];
CtrlVar.ExplicitMeshRefinementCriteria(I).InfoLevel=1;
CtrlVar.ExplicitMeshRefinementCriteria(I).Use=true;


I=I+1;
CtrlVar.ExplicitMeshRefinementCriteria(I).Name='upper surface gradient';
CtrlVar.ExplicitMeshRefinementCriteria(I).Scale=0.01;
CtrlVar.ExplicitMeshRefinementCriteria(I).EleMin=[];
CtrlVar.ExplicitMeshRefinementCriteria(I).EleMax=[];
CtrlVar.ExplicitMeshRefinementCriteria(I).p=[];
CtrlVar.ExplicitMeshRefinementCriteria(I).InfoLevel=1;
CtrlVar.ExplicitMeshRefinementCriteria(I).Use=false;

% Mesh elements within [X]m from the GL should be no larger than [Y]m
%CtrlVar.MeshAdapt.GLrange=[5000 CtrlVar.MeshSizeMin];
                                                   
% CtrlVar.MeshAdapt.GLrange=[10000 2000 ; 2000 500]; % and sequentially it goes if needed                                                    

%% Prescribing the initial surfaces and input velocity    
    %if strcmp(CtrlVar.Experiment,'Transient') == 0
        [UserVar,x_grid,y_grid,ice_surf,bedrock]=CreateSurfaces(UserVar);  
        % Creating the Interpolant (i.e., "transfer function") for the created surfaces to the current mesh
        UserVar.Fs = griddedInterpolant(x_grid',y_grid',ice_surf');
        UserVar.FB = griddedInterpolant(x_grid',y_grid',bedrock');
    %end
    
    if contains(CtrlVar.Experiment,'-Invert')
        [u_obs_synth,v_obs_synth]=CreateSynthVelocities(x_grid,y_grid);
        UserVar.Uobs = griddedInterpolant(x_grid',y_grid',u_obs_synth');
        UserVar.Vobs = griddedInterpolant(x_grid',y_grid',v_obs_synth');
    end

end

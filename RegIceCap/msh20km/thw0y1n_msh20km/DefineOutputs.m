function  UserVar=UaOutputs(UserVar,CtrlVar,MUA,BCs,F,l,GF,InvStartValues,InvFinalValues,Priors,Meas,BCsAdjoint,RunInfo);

v2struct(F);

time=CtrlVar.time; 

CtrlVar.DefineOutputs='-s-tH-save-';

%%
if ~isfield(CtrlVar,'DefineOutputs')
    CtrlVar.uvPlotScale=[];
    %plots='-ubvb-udvd-log10(C)-log10(Surfspeed)-log10(DeformationalSpeed)-log10(BasalSpeed)-log10(AGlen)-';
    %plots='-ubvb-log10(BasalSpeed)-sbB-ab-log10(C)-log10(AGlen)-';
    plots='-save-';
else
    plots=CtrlVar.DefineOutputs;
end

%%
TRI=[];
x=MUA.coordinates(:,1);  y=MUA.coordinates(:,2);

profile_y_coord = 0; % To be implemented later
x_array = UserVar.xu:CtrlVar.MeshSizeMin:UserVar.xd;
y_array = zeros(size(x_array)) + profile_y_coord;
    
%% For Transient Plots

if UserVar.DoTransientPlots
    
    % Record time interval
    this_time = CtrlVar.time;
    if ~isfield(UserVar,'times')
        UserVar.times(1) = this_time;
    else
        UserVar.times(end+1) = this_time;
    end
        
    % Extract ice surface at specified points
    s_interp = scatteredInterpolant(MUA.coordinates(:,1),MUA.coordinates(:,2),F.s);
    this_point_s = s_interp(UserVar.nunatak_points.x,UserVar.nunatak_points.y);
    if ~isfield(UserVar.nunatak_points,'s')
        UserVar.nunatak_points.s = zeros(1,length(UserVar.nunatak_points.x));
        UserVar.nunatak_points.s(1,:) = this_point_s;
    else
        UserVar.nunatak_points.s(end+1,:) = this_point_s;
    end
    
    % Plot ice surface at specified points (optional, otherwise comment out)    
    figtName='Ice Surface Evolution';
    figt = findobj(0,'name',figtName);
    if isempty(figt)
        figt = figure('name',figtName,'NumberTitle','off');        
    else
        figure(figt);         
    end
    hold on; % for lack of a better way to keep the same figure open
    linehandles = [];
    linelabels  =  {};    
    for i = 1:length(UserVar.nunatak_points.x)        
        linehandle = plot(UserVar.times,UserVar.nunatak_points.s(:,i));     
        linehandles = [linehandles linehandle];
        current_coord = sprintf('(%-g,%-g) km',UserVar.nunatak_points.x(i)./CtrlVar.PlotXYscale,...
                                               UserVar.nunatak_points.y(i)./CtrlVar.PlotXYscale);
        linelabels{end+1} = current_coord;
    end
    hold off;
    hLegend = legend(linehandles,linelabels,'Location','northwest');
    hLegend.Title.String = 'Points';
    title('Ice surface at reference point(s)');    
    xlabel('Model time (yr)');
    ylabel('Elevation (m a.s.l.)');
    
    if contains(plots,'-tH-')
        fighName='Ice Thickness'; % plot h
        figh = findobj(0,'name',fighName);
        if isempty(figh)
            figh= figure('name',fighName,'NumberTitle','off');        
        else
            figure(figh);         
        end        
        PlotNodalBasedQuantities(MUA.connectivity,MUA.coordinates,h,CtrlVar);
        title(sprintf('h at t=%-g ',time)) ; xlabel('x (km)') ; ylabel('y (km)');
    end
    if contains(plots,'-ts-')
        figsName='Surface Elevation'; % Plot s
        figs = findobj(0,'name',figsName);
        if isempty(figs)
            figs= figure('name',figsName,'NumberTitle','off');        
        else
            figure(figs);         
        end
        PlotNodalBasedQuantities(MUA.connectivity,MUA.coordinates,s,CtrlVar);
        title(sprintf('s at t=%-g ',time)) ; xlabel('x (km)') ; ylabel('y (km)');
    end
    
    if contains(plots,'-tUs-')
        us = ub+ud;
        vs = vb+vd;        
        Us = sqrt(us.^2 + vs.^2);
        %Us(Us <= 0.01) = NaN;
        Us(s <= B+5) = NaN;        
        %PlotMeshScalarVariable(CtrlVar,MUA,Us)
        figUName='Surface Velocity'; % Plot s
        figU = findobj(0,'name',figUName);
        if isempty(figU)
            figU= figure('name',figUName,'NumberTitle','off');        
        else
            figure(figU);         
        end
        [FigHandle,ColorbarHandel,tri]=PlotNodalBasedQuantities(MUA.connectivity,MUA.coordinates,Us,CtrlVar)    ;
        title(sprintf('Surface velocity at t=%-g ',time)) ; xlabel('x (km)') ; ylabel('y (km)'); title(colorbar,'(m/a)');
        caxis([0, 80])                
    end

end

%% Saving data
if contains(plots,'-save-')

    % save data in files with running names
    % check if folder 'ResultsFiles' exists, otherwise create
    if strcmp(CtrlVar.DefineOutputsInfostring,'First call') && exist('ResultsFiles','dir')~=7
        mkdir('ResultsFiles') ;
    end
    
    if strcmp(CtrlVar.DefineOutputsInfostring,'First call') && exist('PlotFiles','dir')~=7        
        mkdir('PlotFiles') ;        
    end
    
    %if strcmp(CtrlVar.DefineOutputsInfostring,'Last call')==0
        %FileName=['ResultsFiles/',sprintf('%07i',round(100*time)),'-TransPlots-',CtrlVar.Experiment]; good for transient runs
        
    if UserVar.SaveTransientFiles
        %if mod(CtrlVar.UaOutputsCounter,CtrlVar.UaOutputsDeltaT) == 0 || strcmp(CtrlVar.DefineOutputsInfostring,'Last call')==1
            %FileName=['PlotFiles/','Trans-',UserVar.OutputFileName,sprintf('_%07i',CtrlVar.UaOutputsCounter)]; % save by timestep
            FileName=['../../PlotFiles/','Trans-',UserVar.OutputFileName,sprintf('_%07i',round(100*time))]; % save by time
            fprintf('Saving data in %s \n',FileName)
            %save(FileName,'CtrlVar','MUA','time','s','b','S','B','h','u','v','dhdt','dsdt','dbdt','C','AGlen','m','n','rho','rhow','as','ab','GF')
            save(FileName,'CtrlVar','UserVar','MUA','time','s','b','S','B','h','ub','vb','ud','vd',...
                          'dhdt','dsdt','dbdt','C','AGlen','m','n','rho','rhow','as','ab','GF')
        %end
    end

    %end
end

%% only do plots at end of run
if ~strcmp(CtrlVar.DefineOutputsInfostring,'Last call') ; return ; end

[~,I]=sort(x) ;

if contains(plots,'-txzb(x)-')
    
    [txzb,tyzb]=CalcNodalStrainRatesAndStresses(CtrlVar,MUA,AGlen,n,C,m,GF,s,b,ub,vb);
    
    figure ;  plot(x/CtrlVar.PlotXYscale,txzb) ; title('txzb(x)')
    
end


if contains(plots,'-ub(x)-')
    figure
    plot(x(I)/CtrlVar.PlotXYscale,ub(I)) ;
    title(sprintf('u_b(x) at t=%-g ',time)) ; xlabel('x') ; ylabel('u_b')
    drawnow
end


if contains(plots,'-dhdt(x)-')
    figure
    plot(x(I)/CtrlVar.PlotXYscale,dhdt(I)) ;
    title(sprintf('dhdt(x) at t=%-g ',time)) ; xlabel('x') ; ylabel('dh/dt')
    drawnow
end


if contains(plots,'-h(x)-')
    figure;
    %plotyy(x(I)/CtrlVar.PlotXYscale,h(I),x(I)/CtrlVar.PlotXYscale,GF.node(I)) ;
    plot(x(I)/CtrlVar.PlotXYscale,h(I)) ;
    
    if CtrlVar.Implicituvh
        title(sprintf('fully-implicit h(x) at t=%-g (%s)',time,CtrlVar.uvhTimeSteppingMethod)) ;
    else
        title(sprintf('semi-implicit h(x) at t=%-g (TG3=%i)',time,CtrlVar.TG3)) ;
    end
    xlabel('x') ; ylabel('h')
    drawnow
end

if contains(plots,'-ud(x)-')
    figure
   plot(x/CtrlVar.PlotXYscale,ud) ;
    title(sprintf('u_d(x) at t=%-g ',time)) ; xlabel('x') ; ylabel('u_d')
end


if contains(plots,'-sbSB(x)-')
    figure
    
    plot(x(I)/CtrlVar.PlotXYscale,S(I),'k--') ; hold on
    plot(x(I)/CtrlVar.PlotXYscale,B(I),'k') ; 
    plot(x(I)/CtrlVar.PlotXYscale,b(I),'b') ; 
    plot(x(I)/CtrlVar.PlotXYscale,s(I),'b') ;
    
    title(sprintf('sbSB(x) at t=%-g ',time)) ; xlabel('x') ; ylabel('z')
    drawnow
end


if contains(plots,'-sbB-')
    figure(5)
    hold off
    if isempty(TRI) ;  TRI = delaunay(x,y); end
    trisurf(TRI,x/CtrlVar.PlotXYscale,y/CtrlVar.PlotXYscale,s,'EdgeColor','none') ; hold on
    trisurf(TRI,x/CtrlVar.PlotXYscale,y/CtrlVar.PlotXYscale,b,'EdgeColor','none') ;
    trisurf(TRI,x/CtrlVar.PlotXYscale,y/CtrlVar.PlotXYscale,B,'EdgeColor','none') ;
    view(50,20); lightangle(-45,30) ; lighting phong ;
    xlabel('y') ; ylabel('x') ;
    colorbar ; title(colorbar,'(m)')
    hold on
    
    title(sprintf('sbB at t=%#5.1g ',time))
    axis equal ; tt=daspect ; daspect([mean(tt(1)+tt(2)) mean(tt(1)+tt(2)) tt(3)*CtrlVar.PlotXYscale]); axis tight
    hold off
end


if contains(plots,'-ubvb-')
    % plotting horizontal velocities
    figure
    N=1;
    speed=sqrt(ub.*ub+vb.*vb);
%     CtrlVar.VelPlotIntervalSpacing='log10';
%     CtrlVar.VelColorMap='default';
%     CtrlVar.RelativeVelArrowSize=10;
    QuiverColorGHG(x(1:N:end),y(1:N:end),ub(1:N:end),vb(1:N:end),CtrlVar);
    hold on
    title(sprintf('(ub,vb) t=%-g ',time)) ; xlabel('xps (km)') ; ylabel('yps (km)')
    axis equal tight
    
end

if contains(plots,'-usvs-')
    % plotting horizontal velocities
    figure
    N=1;
    us = ub+ud; vs = vb+vd;    
    speed=sqrt(us.*us+vs.*vs);
%     CtrlVar.VelPlotIntervalSpacing='log10';
%     CtrlVar.VelColorMap='default';
%     CtrlVar.RelativeVelArrowSize=10;
    QuiverColorGHG(x(1:N:end),y(1:N:end),us(1:N:end),vs(1:N:end),CtrlVar);
    hold on
    title(sprintf('(us,vs) t=%-g ',time)) ; xlabel('xps (km)') ; ylabel('yps (km)')
    axis equal tight
    
end


if contains(plots,'-dhdt-')
    figure
    [FigHandle,ColorbarHandel,tri]=PlotNodalBasedQuantities(MUA.connectivity,MUA.coordinates,dhdt,CtrlVar)    ;
    title(sprintf('dhdt t=%-g ',time)) ; xlabel('x (km)') ; ylabel('y (km)')  
end

if contains(plots,'-s-')
    figure
    [FigHandle,ColorbarHandel,tri]=PlotNodalBasedQuantities(MUA.connectivity,MUA.coordinates,s,CtrlVar)    ;
    title(sprintf('Ice Surface at t=%-g ',time)) ; xlabel('x (km)') ; ylabel('y (km)')  
end

if contains(plots,'-e-')
    % plotting effectiv strain rates
    
    % first get effective strain rates, e :
    %[etaInt,xint,yint,exx,eyy,exy,Eint,e,txx,tyy,txy]=calcStrainRatesEtaInt(CtrlVar,MUA,u,v,AGlen,n);    
    [etaInt,xint,yint,exx,eyy,exy,Eint,e,txx,tyy,txy]=calcStrainRatesEtaInt(CtrlVar,MUA,ub,vb,AGlen,n);    
    % all these variables are are element variables defined on integration points
    % therfore if plotting on nodes, must first project these onto nodes
    eNod=ProjectFintOntoNodes(MUA,e);
    
    figure
    [FigHandle,ColorbarHandel,tri]=PlotNodalBasedQuantities(MUA.connectivity,MUA.coordinates,eNod,CtrlVar)    ;
    title(sprintf('e t=%-g ',time)) ; xlabel('x (km)') ; ylabel('y (km)')
    
end

if contains(plots,'-ub-')    
    figure
    [FigHandle,ColorbarHandel,tri]=PlotNodalBasedQuantities(MUA.connectivity,MUA.coordinates,ub,CtrlVar)    ;
    title(sprintf('ub t=%-g ',time)) ; xlabel('x (km)') ; ylabel('y (km)')
    
end

if contains(plots,'-s(x)-')        
        
    eps_thickness = 5; % CtrlVar.ThickMin            
    min_y = nanmin(s);
    max_y = nanmax(s);
        
    B_interp = scatteredInterpolant(MUA.coordinates(:,1),MUA.coordinates(:,2),B);
    B_remesh = B_interp(x_array,y_array);        
    s_interp= scatteredInterpolant(MUA.coordinates(:,1),MUA.coordinates(:,2),s);
    s_remesh = s_interp(x_array,y_array);        
    s_remesh(s_remesh<=B_remesh+eps_thickness) = NaN;
    s(s<=B+eps_thickness) = NaN;

    figure;
    %plotyy(x(I)/CtrlVar.PlotXYscale,h(I),x(I)/CtrlVar.PlotXYscale,GF.node(I)) ;
    plot(x(I)/CtrlVar.PlotXYscale,s(I),'.b') ; hold on
    plot(x_array/CtrlVar.PlotXYscale,s_remesh,'-r') ;        

    title(sprintf('Ice Surface at t=%-g',time)) ;

    xlabel('x (km)') ; ylabel('s (m)'); legend('all points',sprintf('y=%-g km',profile_y_coord/CtrlVar.PlotXYscale));
    ylim([min_y,max_y]); xlim([-150.,150.])
    drawnow
end

end

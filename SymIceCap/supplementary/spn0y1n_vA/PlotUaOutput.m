
function  PlotUaOutput(UaOutputFiles, plots)
    %% function for plotting one or more variables from an Ua output .mat file
    % Variables currently implemented:
    % -sbB-  -ubsb-  -usvs-  -h-  -dhdt-  -us-  -Us- -h0-
    
    %UaOutputFiles = 'ResultsFiles/RestartTestIceStream-Control0';      
    filter_ripples = 1;
    addpath /mnt/3tb/Ua/cbrewer
    addpath /mnt/3tb/Ua/cmocean

    try
        if contains(UaOutputFiles,'Restart')
            load(UaOutputFiles,'CtrlVarInRestartFile','UserVarInRestartFile','MUA','F') ;
            CtrlVar = CtrlVarInRestartFile;
            UserVar = UserVarInRestartFile; % not really nedded    
            v2struct(struct(F));            % unpacks the struct F for easier access to the fields        
        else
            load(UaOutputFiles) ;
        end
    catch
        sprintf('Error opening File.')
    end
    
    if isempty(plots)
        plots='-ubvb-dhdt-ub-usvs-us-';
    end

       
    % just for a more consistent naming    
    if ~exist('UserVar','var') 
       UserVar.xd=150e3; UserVar.xu=-150e3 ; UserVar.yl=100e3 ; UserVar.yr=-100e3;
    end
        
    time    = CtrlVar.time;        
    name_run = split(UaOutputFiles,'/'); name_run = string(name_run(end));
    
    TRI=[];
    x=MUA.coordinates(:,1);  y=MUA.coordinates(:,2);    
    %GLgeo=GLgeometry(MUA.connectivity,MUA.coordinates,GF,CtrlVar);       
        
    profile_y_coord = 0; % To be implemented later
    [~,I]=sort(x) ;
    x_array = UserVar.xu:CtrlVar.MeshSizeMin:UserVar.xd;    
    y_array = zeros(size(x_array)) + profile_y_coord;           
    
    % set up the regular grid    
    xdim=x_array;
    %ydim=linspace(UserVar.yr,UserVar.yl,length(xdim));
    ydim=UserVar.yr:CtrlVar.MeshSizeMin:UserVar.yl;

    %% creates NetCDF file if requested to output to .nc
    if contains(plots,'-savenc-')                
        
        % set up the output file name
        dummy = strsplit(UaOutputFiles,'/');
        fin = char(dummy(2));
        if contains(fin,'.')
            foutname=fin(1:end-4);
        else
            foutname=fin;
        end


        ncid = netcdf.create([foutname,'.nc'],'CLOBBER'); % create file
        dimid1 = netcdf.defDim(ncid,'x',length(xdim));
        dimid2 = netcdf.defDim(ncid,'y',length(ydim));
        varidx = netcdf.defVar(ncid,'x','NC_FLOAT',dimid1);
        varidy = netcdf.defVar(ncid,'y','NC_FLOAT',dimid2);        
        
        if contains(plots,'-B-')
            varidB = netcdf.defVar(ncid,'B','NC_FLOAT',[dimid1 dimid2]);
        end
        if contains(plots,'-b-')
            varidb = netcdf.defVar(ncid,'b','NC_FLOAT',[dimid1 dimid2]);
        end
        if contains(plots,'-s-')
            varids = netcdf.defVar(ncid,'s','NC_FLOAT',[dimid1 dimid2]);
        end
        if contains(plots,'-h-')
            varidh = netcdf.defVar(ncid,'h','NC_FLOAT',[dimid1 dimid2]);
        end
        if contains(plots,'-Us-')
            varidUs = netcdf.defVar(ncid,'Us','NC_FLOAT',[dimid1 dimid2]);
        end
        netcdf.endDef(ncid)
        netcdf.putVar(ncid,varidx,xdim)
        netcdf.putVar(ncid,varidy,ydim)                
    end

    %% Plots what is assigned in the 'plots' string
    if contains(plots,'-mesh-')
        figure;
        CtrlVar.MeshColor='b';
        CtrlVar.NodeColor='b';
        PlotMuaMesh(CtrlVar,MUA)
        hold on ;
        [xGL,yGL,GLgeo]=PlotGroundingLines(CtrlVar,MUA,GF,GLgeo,xGL,yGL,'color',[0.9290, 0.6940, 0.1250]);
        PlotMuaBoundary(CtrlVar,MUA,'k')    
    end
    
    
    if contains(plots,'-sbB-')
        figure
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
    
    
if contains(plots,'-sbSB(x)-')
    figure
    
    plot(x(I)/CtrlVar.PlotXYscale,S(I),'k--') ; hold on
    plot(x(I)/CtrlVar.PlotXYscale,B(I),'k') ; 
    plot(x(I)/CtrlVar.PlotXYscale,b(I),'b') ; 
    plot(x(I)/CtrlVar.PlotXYscale,s(I),'b') ;
    
    title(sprintf('sbSB(x) at t=%-g ',time)) ; xlabel('x') ; ylabel('z')
    drawnow
end

if contains(plots,'-b(x)-')
    figure
    %plot(x(I)/CtrlVar.PlotXYscale,B(I),'k') ; hold on 
    plot(x(I)/CtrlVar.PlotXYscale,b(I),'b') ;         
    title(sprintf('bB(x) at t=%-g ',time)) ; xlabel('x') ; ylabel('z')
    drawnow
end



    if contains(plots,'-ubvb-')
        % plotting horizontal velocities         
        figure
        N=1;
        %speed=sqrt(ub.*ub+vb.*vb);
        %CtrlVar.VelPlotIntervalSpacing='log10';
        %CtrlVar.VelColorMap='hot';
        %CtrlVar.RelativeVelArrowSize=10;
        QuiverColorGHG(x(1:N:end),y(1:N:end),ub(1:N:end),vb(1:N:end),CtrlVar);
        hold on
        title(sprintf('Basal velocities (ub,vb) t=%-g ',time)) ; xlabel('xps (km)') ; ylabel('yps (km)')
        axis equal tight
    end

    if contains(plots,'-usvs-')
        % plotting horizontal velocities
        
        % CtrlVar.MinSpeedToPlot=0.1;          % where speed is less, speed is not plotted, default value is zero
        % CtrlVar.VelPlotIntervalSpacing='lin' % 'lin' or 'log10' vel scale
        % CtrlVar.MaxPlottedSpeed=100.;        % When plotting, speed above this value is set equal to this value, i.e. this is the maximum plotted speed
        % CtrlVar.MinPlottedSpeed=5.;          % When plotting, speed below this value is set equal to this value, i.e. this is the mainimum plotted speed
        % CtrlVar.SpeedTickLabels=10.:10.:100. % numerical array of values

        figure
        N=1;
        %speed=sqrt(ub.*ub+vb.*vb);
        %CtrlVar.VelPlotIntervalSpacing='log10';
        %CtrlVar.VelColorMap='hot';
        %CtrlVar.RelativeVelArrowSize=10;
        QuiverColorGHG(x(1:N:end),y(1:N:end),ub(1:N:end)+ud(1:N:end),vb(1:N:end)+vd(1:N:end),CtrlVar);
        hold on
        title(sprintf('Surface velocities (us,vs) t=%-g ',time)) ; xlabel('xps (km)') ; ylabel('yps (km)')
        axis equal tight;
    end
    
    if contains(plots,'-h-')
        
        if contains(plots,'-savenc-')
            h_int = scatteredInterpolant(MUA.coordinates(:,1),MUA.coordinates(:,2),h);
            h_reg = h_int({xdim, ydim});        
            netcdf.putVar(ncid,varidh,[0 0], [length(xdim) length(ydim)], h_reg);
        end
        
        figure
        PlotMeshScalarVariable(CtrlVar,MUA,h);
        hold on
        %plot(GLgeo(:,[3 4])'/CtrlVar.PlotXYscale,GLgeo(:,[5 6])'/CtrlVar.PlotXYscale,'k','LineWidth',1);    
        I=h(h<=CtrlVar.ThickMin);
        plot(MUA.coordinates(I,1)/CtrlVar.PlotXYscale,MUA.coordinates(I,2)/CtrlVar.PlotXYscale,'.w');        
        title(sprintf('Thickness (h) t=%-g ',CtrlVar.time)) ; xlabel('x (km)') ; ylabel('y (km)') ; title(colorbar,'(m)')
        axis equal
        %h(s<=B+20) = NaN;
        sprintf('h Min: %-g \n h Med: %-g \n h Max: %-g',nanmin(h),nanmedian(h),nanmax(h))
    end
    
    if contains(plots,'-ab-')                
        
        figure
        PlotMeshScalarVariable(CtrlVar,MUA,ab);
        hold on
        %plot(GLgeo(:,[3 4])'/CtrlVar.PlotXYscale,GLgeo(:,[5 6])'/CtrlVar.PlotXYscale,'k','LineWidth',1);    
        I=h(h<=CtrlVar.ThickMin);
        plot(MUA.coordinates(I,1)/CtrlVar.PlotXYscale,MUA.coordinates(I,2)/CtrlVar.PlotXYscale,'.w');        
        title(sprintf('Basal melt (ab) t=%-g ',CtrlVar.time)) ; xlabel('x (km)') ; ylabel('y (km)') ; title(colorbar,'(m)')
        axis equal                
    end
    
    if contains(plots,'-s-')
        
        if contains(plots,'-savenc-')
            s_int = scatteredInterpolant(MUA.coordinates(:,1),MUA.coordinates(:,2),s);
            s_reg = s_int({xdim, ydim});        
            netcdf.putVar(ncid,varids,[0 0], [length(xdim) length(ydim)], s_reg);
        end
        
        hf = figure('Position',[10 10 900 400]);
        PlotMeshScalarVariable(CtrlVar,MUA,s)
        hold on
        caxis([0 1800]);
        xlim([0 150]);        
        ylim([-50 50]);                
        title(colorbar,'m a.s.l.'); %title(sprintf('Surface height (s) t=%-g ',CtrlVar.time)) ; 
        xlabel('x (km)') ; ylabel('y (km)') ;         
        %axis equal      
        sprintf('s Min: %-g \n s Med: %-g \n s Max: %-g',nanmin(h)+500,nanmedian(h)+500,nanmax(h)+500)                
        cmap = cmocean('ice');
        %colormap(flip(cmap))
        colormap(cmap)
        set(gca,'fontsize',13)
        %text(5,30,'a','fontsize',18, 'fontweight','bold')
        box on
    end
    
    if contains(plots,'-B-')
        
        figure
        PlotMeshScalarVariable(CtrlVar,MUA,B)
        hold on
        %plot(GLgeo(:,[3 4])'/CtrlVar.PlotXYscale,GLgeo(:,[5 6])'/CtrlVar.PlotXYscale,'k','LineWidth',1);            
        title(sprintf('Bedrock elevation (B) t=%-g ',CtrlVar.time)) ; xlabel('x (km)') ; ylabel('y (km)') ; title(colorbar,'(m a.s.l.)')        
        axis equal                
        
        if contains(plots,'-savenc-')
            B_int = scatteredInterpolant(MUA.coordinates(:,1),MUA.coordinates(:,2),B);
            B_reg = B_int({xdim, ydim});        
            netcdf.putVar(ncid,varidB,[0 0], [length(xdim) length(ydim)], B_reg);
        end
    end
    
    if contains(plots,'-b-')
        
        figure
        PlotMeshScalarVariable(CtrlVar,MUA,b)
        hold on
        %plot(GLgeo(:,[3 4])'/CtrlVar.PlotXYscale,GLgeo(:,[5 6])'/CtrlVar.PlotXYscale,'k','LineWidth',1);            
        title(sprintf('Bedrock elevation (b) t=%-g ',CtrlVar.time)) ; xlabel('x (km)') ; ylabel('y (km)') ; title(colorbar,'(m a.s.l.)')        
        axis equal                
        
        if contains(plots,'-savenc-')
            b_int = scatteredInterpolant(MUA.coordinates(:,1),MUA.coordinates(:,2),b);
            b_reg = b_int({xdim, ydim});        
            netcdf.putVar(ncid,varidb,[0 0], [length(xdim) length(ydim)], b_reg);
        end
    end


    if contains(plots,'-dhdt-')
        figure
        [FigHandle,ColorbarHandel,tri]=PlotNodalBasedQuantities(MUA.connectivity,MUA.coordinates,dhdt,CtrlVar)    ;
        title(sprintf('dhdt t=%-g ',time)) ; xlabel('x (km)') ; ylabel('y (km)'); title(colorbar,'(m/??)');
    end

    if contains(plots,'-ub-')
        figure        
        [FigHandle,ColorbarHandel,tri]=PlotNodalBasedQuantities(MUA.connectivity,MUA.coordinates,ub,CtrlVar)    ;
        title(sprintf('ub t=%-g ',time)) ; xlabel('x (km)') ; ylabel('y (km)'); title(colorbar,'(m/a)');
        caxis([-80, 80])
    end
    
    if contains(plots,'-ud-')
        figure        
        [FigHandle,ColorbarHandel,tri]=PlotNodalBasedQuantities(MUA.connectivity,MUA.coordinates,ud,CtrlVar)    ;
        title(sprintf('ud t=%-g ',time)) ; xlabel('x (km)') ; ylabel('y (km)'); title(colorbar,'(m/a)');
        caxis([-80, 80])
    end

    if contains(plots,'-us-')
        figure
        [FigHandle,ColorbarHandel,tri]=PlotNodalBasedQuantities(MUA.connectivity,MUA.coordinates,ub+ud,CtrlVar)    ;
        title(sprintf('us t=%-g ',time)) ; xlabel('x (km)') ; ylabel('y (km)'); title(colorbar,'(m/a)');
        %cmap = redbluecmap(11);
        caxis([-80, 80])
        %colormap(cmap)
    end
    
    if contains(plots,'-Us-')
        us = ub+ud;
        vs = vb+vd;        
        Us = sqrt(us.^2 + vs.^2);
        Us_int = scatteredInterpolant(MUA.coordinates(:,1),MUA.coordinates(:,2),Us);
        
        if contains(plots,'-savenc-')            
            Us_reg = Us_int({xdim, ydim});        
            netcdf.putVar(ncid,varidUs,[0 0], [length(xdim) length(ydim)], Us_reg);
        end
        
        %Us(Us <= 0.01) = NaN;
        %Us(s <= B+1) = NaN;
        figure
        Us(s<=B+10) = NaN; PlotMeshScalarVariable(CtrlVar,MUA,Us)
        %[FigHandle,ColorbarHandel,tri]=PlotNodalBasedQuantities(MUA.connectivity,MUA.coordinates,Us,CtrlVar)    ;
        %title(sprintf('Surface velocity t=%-g ',time)) ; 
        title(sprintf('Surface velocity t=%-g ',time)) ; 
        xlabel('x (km)') ; ylabel('y (km)'); title(colorbar,'(m/a)');
        caxis([0, 100])            
        
        sprintf('Us Min: %-g \n Us Med: %-g \n Us Mean: %-g \n Us Max: %-g',nanmin(Us),nanmedian(Us),nanmean(Us),nanmax(Us))
        sprintf('Us flanks: %-g',Us_int(50e3,8.68e3))
        ylim([-50 50])
        xlim([0 150])
    end
%      (metres)
    
    if contains(plots,'-h(x)-')        
        figure;
        %plotyy(x(I)/CtrlVar.PlotXYscale,h(I),x(I)/CtrlVar.PlotXYscale,GF.node(I)) ;
        plot(x(I)/CtrlVar.PlotXYscale,h(I),'.b') ; hold on
        %plot(x_array/CtrlVar.PlotXYscale,var_remesh,'-r') ;

        title(sprintf('%s\n Ice Thickness at t=%-g yr',name_run,time)) ;
        xlabel('x (km)') ; ylabel('h (m)'); %legend('all points','center line');
        xlim([-10.,10.]); ylim([1300.,1700.]); 
        drawnow
        
        if contains(plots,'-savef-')     
            beg_expname = strfind(UaOutputFiles,'-');
            expname = UaOutputFiles(beg_expname(1)+1:end);            
            fig_name = ['ThkPoints-',expname];            
            print(char(['/home/mama9638/phd/NunatakModelling/',fig_name]),'-dpng','-r300')
        end
    end
    
    if contains(plots,'-s(x)-')            
        addpath '/mnt/3tb/Ua/'
        y = abs(MUA.coordinates(:,2))/CtrlVar.PlotXYscale;
        
        f = figure; 
        axes(f,'FontSize',16);        
        scatter(x(I)/CtrlVar.PlotXYscale,s(I),10,y(I),'filled')        
        caxis([0, 50]) %nanmax(abs(y))])        
        %title(sprintf('%s\n Ice Surface at t=%-g yr',name_run,time)) ;
        title(sprintf('%s',name_run)) ;
        xlabel('x (km)') ; ylabel('Elevation (m a.s.l.)');
        xlim([-80.,80.]); %ylim([820.,1520.]); %ylim([1820.,2200.]); 
        colormap parula
        box on; grid on;
        %drawnow
        %cbh = colorbar('southoutside','FontSize',14);
        %ctitleh = get(cbh,'Title');
        %set(ctitleh,'String','Distance from centre (km)')        
        %cbarrow('right')
        if contains(plots,'-savef-')     
            beg_expname = strfind(UaOutputFiles,'-');
            expname = UaOutputFiles(beg_expname(1)+1:end);            
            fig_name = ['SurfPoints-',expname];            
            print(char(['/home/mama9638/phd/NunatakModelling/',fig_name]),'-dpng','-r300')
        end
    
    end
    
    if contains(plots,'-b(x)-')            
        addpath '/mnt/3tb/Ua/'
        y = abs(MUA.coordinates(:,2))/CtrlVar.PlotXYscale;
        
        f = figure; 
        axes(f,'FontSize',16);        
        scatter(x(I)/CtrlVar.PlotXYscale,b(I),10,y(I),'filled')        
        caxis([0, 50]) %nanmax(abs(y))])        
        %title(sprintf('%s\n Ice Surface at t=%-g yr',name_run,time)) ;
        title(sprintf('%s',name_run)) ;
        xlabel('x (km)') ; ylabel('Elevation (m a.s.l.)');
        xlim([-80.,80.]); %ylim([820.,1520.]); %ylim([1820.,2200.]); 
        colormap parula
        box on; grid on;
        %drawnow
        %cbh = colorbar('southoutside','FontSize',14);
        %ctitleh = get(cbh,'Title');
        %set(ctitleh,'String','Distance from centre (km)')        
        %cbarrow('right')        
    
    end
    
    if contains(plots,'-B(x)-')        
        
        eps_thickness = 20; % CtrlVar.ThickMin
        
        %B_interp = scatteredInterpolant(MUA.coordinates(:,1),MUA.coordinates(:,2),B);
        %B_remesh = B_interp(x_array,y_array);        
                
        figure;
        %plotyy(x(I)/CtrlVar.PlotXYscale,h(I),x(I)/CtrlVar.PlotXYscale,GF.node(I)) ;
        plot(x(I)/CtrlVar.PlotXYscale,B(I),'.b') ; hold on
        %plot(x_array/CtrlVar.PlotXYscale,s_remesh,'-r') ;        
        
        %title(sprintf('%s\n Ice Surface at t=%-g (%s)',name_run,time,CtrlVar.uvhTimeSteppingMethod)) ;
        title(sprintf('%s\n Bedrock at t=%-g yr',name_run,time)) ;
                
        xlabel('x (km)') ; ylabel('s (m)'); legend('all points','center line');
        xlim([-150.,150.]); %ylim([1700.,2400.]); 
        drawnow
    end
    
    if contains(plots,'-h0-')               
        
        h0 = CtrlVar.ThickMin*2.;        
        h_int = scatteredInterpolant(MUA.coordinates(:,1),MUA.coordinates(:,2),h);
        h_reg = h_int({xdim, ydim});            
        [xplot,yplot] = meshgrid(xdim,ydim);
        %h_reg_trim(h_reg <= h0) = NaN; % useful for plotting a " contourf"  plot
        
        figure        
        hold on        
        %contourf(xplot/CtrlVar.PlotXYscale,yplot/CtrlVar.PlotXYscale,h_reg_trim')        
        contour(xplot/CtrlVar.PlotXYscale,yplot/CtrlVar.PlotXYscale,h_reg',[h0 h0],'linecolor','k')        
        title(sprintf('Ice Edge (h=0) t=%-g ',CtrlVar.time)) ; xlabel('x (km)') ; ylabel('y (km)') ;
        xlim([-15 15]); ylim([-15 15]); %axis equal;        
    end
    
    if contains(plots,'-savenc-')
        netcdf.close(ncid)
    end        

    

if contains(plots,'-sb(x)-')        
    
    if ~exist('UserVar','var') 
       UserVar.xd=150e3; UserVar.xu=-150e3 ; UserVar.yl=100e3 ; UserVar.yr=-100e3;
    end        
    xdim= UserVar.xu:CtrlVar.MeshSizeMin*1:UserVar.xd;        
                
    s_interp = scatteredInterpolant(MUA.coordinates(:,1),MUA.coordinates(:,2),s,'linear','nearest');
    sx = s_interp({xdim, 0});
    
    b_interp = scatteredInterpolant(MUA.coordinates(:,1),MUA.coordinates(:,2),b,'linear','nearest');
    bx = b_interp({xdim, 0});                             

    B_interp = scatteredInterpolant(MUA.coordinates(:,1),MUA.coordinates(:,2),B,'linear','nearest');
    Bx = B_interp({xdim, 0});
    base_plot = ones(size(Bx))*-500';
    
    sx=smooth(sx,5);
    hf = figure('Position',[10 10 900 400]);
    hold on                    
    %plot(xdim/CtrlVar.PlotXYscale,sx,'color','k');    
    %plot(xdim/CtrlVar.PlotXYscale,bx,'color','k');
    
    hps = patch([xdim/CtrlVar.PlotXYscale fliplr(xdim/CtrlVar.PlotXYscale)],[bx; fliplr(sx)],'k');
    hps.FaceColor = [0., 1., 1.];
    hps.EdgeColor = [0., 0., 0.];
    
    plot(xdim/CtrlVar.PlotXYscale,zeros(size(xdim)),'--k');
    hpB = patch([xdim/CtrlVar.PlotXYscale fliplr(xdim/CtrlVar.PlotXYscale)],[base_plot; fliplr(Bx)],'k');
    hpB.FaceColor = [0.6, 0.3, 0.15];
    hpB.EdgeColor = [0., 0., 0.];
    box on;
    
    xlabel('Distance along centre line (km)') ; ylabel('Elevation (m a.s.l.)') ;
    %title('Ice surface Evolution') ; 
    xlim([0 150]); ylim([-500 2200]); box on; %axis equal;    
    
    set(gca,'fontsize',13)
    %text(140,1900,'b','fontsize',18, 'fontweight','bold')
    
end

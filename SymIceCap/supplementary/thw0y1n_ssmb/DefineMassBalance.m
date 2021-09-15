function [UserVar,as,ab,dasdh,dabdh]=DefineMassBalance(UserVar,CtrlVar,MUA,time,s,b,h,S,B,rho,rhow,GF,dhdt)

persistent curve curve_time calved
dasdh = zeros(MUA.Nnodes,1);
dabdh = zeros(MUA.Nnodes,1);
if isempty(calved)
    calved = 0;
end
switch CtrlVar.Experiment
    
    case 'Transient'
        
        % Find upstream and downstream boundary nodes
        x=MUA.coordinates(:,1); y=MUA.coordinates(:,2); xd=max(x(:)); xu=min(x(:));
        nodesd=find(abs(x-xd)<1e-5); [~,ind]=sort(MUA.coordinates(nodesd,2)); nodesd=nodesd(ind);
        nodesu=find(abs(x-xu)<1e-5); [~,ind]=sort(MUA.coordinates(nodesu,2)); nodesu=nodesu(ind);
        
        %nodesd=find(abs(x-xd)<1e-3); [~,ind]=sort(MUA.coordinates(nodesd,2)); nodesd=nodesd(ind);
        %nodesu=find(abs(x-xu)<1e-3); [~,ind]=sort(MUA.coordinates(nodesu,2)); nodesu=nodesu(ind);
        
        % Get mass balance for timestep
        as_time = CtrlVar.RestartTime:1:CtrlVar.TotalTime; % Create array of model time
        
        %UserVar.MassBalance.StartThick = mode(UserVar.InitialThick(nodesu)); % Get initial h at start of run
        %h_arr = interp1([CtrlVar.RestartTime,CtrlVar.TotalTime],[UserVar.MassBalance.StartThick,UserVar.MassBalance.EndThick],as_time); % Interpolate h gradient
        %h_per_yr = h_arr-UserVar.MassBalance.StartThick;
        switch UserVar.MassBalance.Evolution
            case 'step'
                if ~isfield(UserVar.MassBalance,'StartValue')  UserVar.MassBalance.StartValue  = 0.;     end
                if ~isfield(UserVar.MassBalance,'dStep')       UserVar.MassBalance.dStep  = -0.01;  end
                if ~isfield(UserVar.MassBalance,'dtStep')      UserVar.MassBalance.dtStep = 2.0e3;  end

                first_step = ones(1,UserVar.MassBalance.dtStep) * UserVar.MassBalance.StartValue;
                prev_step = first_step;
                as_arr_full = [UserVar.MassBalance.StartValue first_step];

                while length(as_arr_full) < length(as_time)
                    next_step = ones(1,UserVar.MassBalance.dtStep) * UserVar.MassBalance.dStep + prev_step;
                    as_arr_full = [as_arr_full next_step];  
                    prev_step = next_step;
                end
                as_arr = as_arr_full(1:length(as_time)); % truncates probable excess steps
            case 'scaled' 
                if isempty(curve) || isempty(curve_time)
                    load(UserVar.MassBalance.ScalingFile,'curve','curve_time');
                    curve = smoothdata(curve);
                end
                scaled_curve = UserVar.MassBalance.StartValue + curve*UserVar.MassBalance.EndValue;                
                as_arr = interp1(curve_time,scaled_curve,as_time);
            otherwise
                as_arr = interp1([CtrlVar.RestartTime,CtrlVar.TotalTime],[UserVar.MassBalance.StartValue,UserVar.MassBalance.EndValue],as_time); % Interpolate as gradient           
        end
        as_value = interp1(as_time,as_arr,time); % Get mass balance for timestep
        xarray = UserVar.xu:CtrlVar.MeshSizeMin:UserVar.xd;
        yarray = UserVar.yr:CtrlVar.MeshSizeMin:UserVar.yl;
        [x_grid,y_grid] = meshgrid(xarray,yarray);
                
        switch UserVar.MassBalance.Distribution
            case 'linear' % SMB is prescribed as as(x,t) = alpha*x + b(t), where integral(alpha*x)dx = 0 for the whole domain
                as_slope = UserVar.MassBalance.EdgeMax/xd;
                                
                as_var = xarray*as_slope;
                [as_distribx,~] = meshgrid(as_var ,yarray);
                as_distnodes = griddedInterpolant(x_grid',y_grid',as_distribx');
            case 'S' % favours a more intense accumulation/ablation closer to the edges
                Lx = UserVar.xd;%-UserVar.xu;                                                
                smb = UserVar.MassBalance.CentreValue -(UserVar.MassBalance.CentreValue-UserVar.MassBalance.EdgeMax).*tan(abs(xarray)/Lx).*sin(abs(xarray)/Lx).^2;
                %as_func = smb* UserVar.MassBalance.EdgeMax/nanmax(smb);
                [as_distribx,~] = meshgrid(smb ,yarray);
                as_distnodes = griddedInterpolant(x_grid',y_grid',as_distribx');  
                
            case 'symmetrical'
                smb = UserVar.MassBalance.CentreValue -(UserVar.MassBalance.CentreValue-UserVar.MassBalance.EdgeMax)/xd * abs(xarray);
                [as_distribx,~] = meshgrid(smb ,yarray);
                as_distnodes = griddedInterpolant(x_grid',y_grid',as_distribx');
                
            case 'symmetrical enhanced'
                smb = UserVar.MassBalance.CentreValue -(UserVar.MassBalance.CentreValue-UserVar.MassBalance.EdgeMax)/xd * abs(xarray);
                smb(abs(xarray) > UserVar.MassBalance.IncMeltDistance) = UserVar.MassBalance.IncMeltFactor*smb(abs(xarray) > UserVar.MassBalance.IncMeltDistance);
                [as_distribx,~] = meshgrid(smb ,yarray);
                as_distnodes = griddedInterpolant(x_grid',y_grid',as_distribx');

            otherwise
                [as_distribx,~] = meshgrid(zeros(size(xarray)) ,yarray);
                as_distnodes = griddedInterpolant(x_grid',y_grid',as_distribx');
        end
        
        ab=s*0;
        as=s*0;
        %as(nodesu)=as_value; % Apply to upstream boundary only

        as(:)=as_distnodes(x,y)+as_value; % Apply to whole domain

        % Check that upstream mass balance equals downstream mass balance
        as_u = as(nodesu);  as_d = as(nodesd);
        try
            if strcmp(UserVar.MassBalance.Distribution,'linear') || strcmp(UserVar.MassBalance.Distribution,'S')
                as_ud_diff = as_u+as_d;
            else
                as_ud_diff = as_u-as_d;
            end                
        catch
            warning("Upstream nodes and downstream nodes are different!");
            as_ud_diff = 0;
        end
        if any(as_ud_diff>0) && UserVar.DynamicThinning ~= 1
            warning('Upstream and downstream mass balance is not equal.');
        end        
        
        if strcmp(UserVar.BasalMelt.Mode,'ShelfMelt') == 1            
            ab_series = interp1([CtrlVar.RestartTime,CtrlVar.TotalTime],[UserVar.BasalMelt.StartValue,UserVar.BasalMelt.EndValue],as_time); % Interpolate as gradient                        
            ab_t = interp1(as_time,ab_series,time); % Get value for timestep
            
            ab=(1-GF.node).* ab_t.*(b-S)./(B-S);
        elseif strcmp(UserVar.BasalMelt.Mode,'ShelfBreak') == 1
            if CtrlVar.time > UserVar.BasalMelt.BreakTimeStart && mod(CtrlVar.time,UserVar.BasalMelt.dtCalv) == 0
                ab=(1-GF.node).* -0.9.*h;
                %dabdh=zeros(MUA.Nnodes,1)+1;
                calved = 1;
            end
        end
        
        
        % Plot
        if UserVar.DoTransientPlots
            figasName='Surface Mass Balance';
            figas = findobj(0,'name',figasName);
            if isempty(figas)
                figas = figure('name',figasName,'NumberTitle','off');        
            else
                figure(figas);         
            end
            subplot(2,1,1)
            plot(as_time,as_arr,'-'); hold on;
            plot(time,as_value,'ok'); hold off;
            title(sprintf('Applied mass balance curve at t=%-g ',CtrlVar.time));
            xlabel('Time (yr)'); ylabel('as Value (m/a)');
            subplot(2,1,2)
            PlotNodalBasedQuantities(MUA.connectivity,MUA.coordinates,as+ab,CtrlVar);
            title(sprintf('Mass Balance spatial distribution at t=%-g ',CtrlVar.time));
            xlabel('x (m)'); ylabel('y (m)');
            %if strcmp(CtrlVar.UaOutputsInfostring,'First Call')
            %    print(['/home/mama9638/phd/NunatakModelling/SMB0-',UserVar.OutputFileName],'-dpng','-r300')
            %end
        end
        
        
        
    otherwise

        as=s*0;%+0.3 ; 
        ab=s*0;
end

% Plot
% figure(11);
% PlotMeshScalarVariable(CtrlVar,MUA,as);
% title(sprintf('as t=%-g ',CtrlVar.time)); xlabel('x (km)'); ylabel('y (km)') ; title(colorbar,'(m/yr)');
% axis equal;

%figure(10);
%PlotMeshScalarVariable(CtrlVar,MUA,ab);
%title(sprintf('ab t=%-g ',CtrlVar.time)); xlabel('x (km)'); ylabel('y (km)') ; title(colorbar,'(m/yr)');
%axis equal;


end


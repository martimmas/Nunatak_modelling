function [UserVar,x_grid,y_grid,ice_surf,topo_xy]=CreateSurfaces(UserVar)

%%
% Determine grid
minmax_x = [UserVar.xu,UserVar.xd]; % Set min and max values for x grid (metres)
minmax_y = [UserVar.yr,UserVar.yl]; % Set min and max values for y grid (metres)
grid_res = 2.5e2; % Set resolution for grid (metres)

x_arr = minmax_x(1):grid_res:minmax_x(2);
y_arr = minmax_y(1):grid_res:minmax_y(2);
nx = length(x_arr); ny = length(y_arr);
[x_grid,y_grid] = meshgrid(x_arr,y_arr);
xy = [x_grid(:) y_grid(:)];

%% Constants
% Create bedrock
if isfield(UserVar,'CenterB')
    bed_elev_mid = UserVar.CenterB;
else
    bed_elev_mid = 500;
end
if isfield(UserVar,'CenterH')
    ice_elev_mid = bed_elev_mid + UserVar.CenterH;     
else
    UserVar.CenterH = 1500;
    ice_elev_mid = bed_elev_mid + 1500.;
end
if isfield(UserVar,'SurfSlope')
    surf_slope = UserVar.SurfSlope;
else
    surf_slope = 0.;
end

% max_elev = 3000 - bed_elev_mid; % Set maximum elevation
max_elev = 2750 - bed_elev_mid; % Set maximum elevation
%% Creating Nunataks
if ~isfield(UserVar,'NunatakShape')
    UserVar.NunatakShape = 'o';
end
if ~isfield(UserVar,'NunatakQuantity')
    UserVar.NunatakQuantity = 0;
end
% Spacing from the Nunataks
if isfield(UserVar,'NunatakScale')
    widening_factor = 4 * UserVar.NunatakScale; % How large the nunataks are.
else
    widening_factor = 4 * 0.2;
end
if isfield(UserVar,'NunatakSpacing') % their spacing, given in metres
    spacing = 15e3 + UserVar.NunatakSpacing;
else
    spacing = 20000;
end
separation_distance=widening_factor * spacing; % distance between the center of two nunataks
separation_distancex = 100e3;

% Choose which case of nunatak distribution we want
switch UserVar.NunatakQuantity
case 1 % one bump at each side of the domain
	z_pdf = CreateGaussian(xy,nx,ny,-0.5*separation_distancex/1000,0.5*mean(minmax_y)/1000,...
                           UserVar.NunatakShape,widening_factor);
    z_pdf = z_pdf + CreateGaussian(xy,nx,ny,0.5*separation_distancex/1000,0.5*mean(minmax_y)/1000,...
                           UserVar.NunatakShape,widening_factor);

case 3 % three bumps, combining 1 and 2 (i.e., all equally spaced and even distributed)
	z_pdf = CreateGaussian(xy,nx,ny,-0.5*separation_distancex/1000,0.5*mean(minmax_y)/1000,...
                           UserVar.NunatakShape,widening_factor);
	z_pdf = z_pdf + CreateGaussian(xy,nx,ny,-0.5*separation_distancex/1000,separation_distance/1000,...
                                   UserVar.NunatakShape,widening_factor);    
	z_pdf = z_pdf + CreateGaussian(xy,nx,ny,-0.5*separation_distancex/1000,-separation_distance/1000,...
                                   UserVar.NunatakShape,widening_factor);
                               
    z_pdf = z_pdf + CreateGaussian(xy,nx,ny,0.5*separation_distancex/1000,0.5*mean(minmax_y)/1000,...
                           UserVar.NunatakShape,widening_factor);
	z_pdf = z_pdf + CreateGaussian(xy,nx,ny,0.5*separation_distancex/1000,separation_distance/1000,...
                                   UserVar.NunatakShape,widening_factor);    
	z_pdf = z_pdf + CreateGaussian(xy,nx,ny,0.5*separation_distancex/1000,-separation_distance/1000,...
                                   UserVar.NunatakShape,widening_factor);                           
otherwise
	z_pdf = zeros([ny nx]);
end


%% Generating baseline bed topography, overlying nunataks and generating ice surface
if ~isfield(UserVar,'BedrockType')
    UserVar.BedrockType = 'flat';
end
if ~isfield(UserVar,'BedrockSlope')
    UserVar.BedrockSlope = -0.; % Set slope of bedrock in %
end

bed_elev_us = bed_elev_mid;
bed_elev_ds = bed_elev_mid;
switch UserVar.BedrockType
	case 'sloping' % linearly sloping
        if UserVar.BedrockSlope ~= 0.
            bed_elev_arr = UserVar.BedrockSlope*abs(x_grid(1,:)) + bed_elev_mid;
            bed_elev_us = bed_elev_arr(ceil(end/2));
            bed_elev_ds = bed_elev_arr(end);
            %bed_elev_arr = interp1([x_grid(1,1),x_grid(1,end)],[bed_elev_us,bed_elev_ds],x_grid(1,:));            
            bed_surf = zeros([ny nx]);
            for i = 1:length(z_pdf(:,1))
                bed_surf(i,:) = bed_elev_arr;
            end
        else             
            bed_surf = zeros([ny nx]) + bed_elev_mid;
        end
    case 'sudden_drop'
        % Not yet implemented
        print('Sudden drop not yet implemented!')
    otherwise         
		bed_surf = zeros([ny nx]) + bed_elev_mid;
end

% Convert PDF to an elevation grid and add the "baseline bedrock"
if max(z_pdf(:)) == 0 && min(z_pdf(:)) == 0
    topo_xy = z_pdf + bed_surf;
else
    topo_xy = z_pdf * max_elev/max(z_pdf(:)) + bed_surf;
end

% the '-1' sign is there because we prescribe a downstream value, but think of the slope from up to downstream
ice_elev_us = ice_elev_mid;
ice_elev_ds = ice_elev_mid;
ice_surf = zeros([ny nx]);
if surf_slope ~= 0
    ice_elev_us = ice_elev_us - surf_slope/abs(surf_slope)*(surf_slope/100)*diff(minmax_x);
    ice_elev_ds = ice_elev_ds + surf_slope/abs(surf_slope)*(surf_slope/100)*diff(minmax_x);
    ice_elev_arr = interp1([x_grid(1,1),x_grid(1,end)],[ice_elev_us,ice_elev_ds],x_grid(1,:));            
    for i = 1:length(topo_xy(:,1))
        ice_surf(i,:) = ice_elev_arr;
    end
else    
%     for i = 1:length(topo_xy(:,1))
%         ice_surf(i,:) = ice_elev_mid;
%     end
      ice_surf = ice_elev_mid + +bed_surf;
end

UserVar.UpstreamH   = ice_elev_us - bed_elev_us;
UserVar.DownstreamH = ice_elev_ds - bed_elev_ds;

% figure; hold on; plot(x_arr,ice_surf(400,:)); plot(x_arr, topo_xy(400,:))

%% Check plot to see how surfaces are
% subplot(1,1,1);
% contourf(x_arr/1000,y_arr/1000,ice_surf/1000); hold on;
% xlabel('x (km)'); ylabel('y (km)'); zlabel('Elevation (m)'); colormap(cool);
% axis equal; grid on;
% 
% hf = figure;
% subplot(1,2,1);
% contourf(x_arr/1000,y_arr/1000,topo_xy/1000); hold on;
% xlabel('x (km)'); ylabel('y (km)'); zlabel('Elevation (m)'); colormap(cool); title('Please approve shape!');
% axis equal; grid on;
% subplot(1,2,2);
% surf(x_arr/1000,y_arr/1000,topo_xy/1000,'FaceColor','interp'); hold on;
% surf(x_grid/1000,y_grid/1000,ice_surf/1000,'FaceAlpha',0.5,'EdgeColor','none'); hold off;
% xlabel('x (km)'); ylabel('y (km)'); zlabel('Elevation (m)'); colormap(cool);
% axis equal; ax = gca; ax.ZTickLabel = num2cell(str2double(ax.ZTickLabel)*1000);
% set(hf,'Position',[150 150 1000 500])
% colorbar()
% 


end

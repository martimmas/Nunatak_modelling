function bump = CreateGaussian(xy,nx,ny,centerx,centery,shp,multiplier)

	% Determine the position of the Gaussian bump	
	mean_xy = [centerx,centery]; % Set mean x,y of the bump (grid km)    
	%mean_xy = [minmax_x(2)/2/1000,minmax_y(2)/2/1000]; % Set mean x,y of the bump (grid km)    

    % Determine the nature of the Gaussian bump	
	shape_T = 0; shape_X = 0; shape_o = 0; shape_0 = 0; shp_0_x = 0; %shp_0_y = 0;
	switch shp
	    case 'Tu'
	        shape_T = 1;
            upstream_T = 1;
        case 'Td'
	        shape_T = 1;
            upstream_T = 0;
	    case 'X'
	        shape_X = 1;
	    case 'o'
	        shape_o = 1;
	    case '0x'
	        shape_0 = 1;
	        shp_0_x = 1; % elongate along the X axis
	    case '0y'
	        shape_0 = 1;	        
	    otherwise
	        shape_o = 1;
	end
		
	xy_covar = 0; % Set the covariance between x and y (the off-diagonal) - zero to be perpendicular to axis
	if (shape_0 && ~shp_0_x)
	    x_var = 4000; % Set the variance from the mean for x (the diagonal) - higher to be wider
	    y_var = 32000; % Set the variance from the mean for y (the diagonal) - higher to be longer	    
	elseif (shape_0 && shp_0_x)  || (shape_T || shape_X)
	    x_var = 32000; % Set the variance from the mean for x (the diagonal) - higher to be wider
	    y_var = 4000; % Set the variance from the mean for y (the diagonal) - higher to be longer	    
	elseif shape_o
	    x_var = 4000; % Set the variance from the mean for x (the diagonal) - higher to be wider
	    y_var = 4000; % Set the variance from the mean for y (the diagonal) - higher to be longer
	    
	end
	% Generate grid and the multivariate Gaussian PDF	
	sigma_xy = [x_var*1000, xy_covar; xy_covar, y_var*1000]; % Produce the covariance matrix
	z_pdf = mvnpdf(xy,mean_xy*1000,multiplier.*sigma_xy); % Generate the Gaussian PDF
	z_pdf = reshape(z_pdf,ny,nx);

	if shape_T || shape_X
		if shape_T
            if upstream_T
                mean_xy_2 = [mean_xy(1)-4,mean_xy(2)]; % Set mean x,y of the 2nd bump (grid km)
            else
                mean_xy_2 = [mean_xy(1)+4,mean_xy(2)]; % Set mean x,y of the 2nd bump (grid km)
            end
			x_var = 4000; % Set the variance from the mean for x - higher to be wider
			y_var = 32000; % Set the variance from the mean for y - higher to be longer
			xy_covar = 0; % Set the covariance between x and y - zero to be perpendicular to axis
			weight_z2 = 2; % Set the weighting of bump - >1 means down-weighting and <1 means up-weighting, relative to 1st bump	
		elseif shape_X	
            mean_xy_2 = mean_xy;
			x_var = 4000; % Set the variance from the mean for x - higher to be wider
			y_var = 32000; % Set the variance from the mean for y - higher to be longer
			xy_covar = 0; % Set the covariance between x and y - zero to be perpendicular to axis
			weight_z2 = 2; % Set the weighting of bump - >1 means down-weighting and <1 means up-weighting, relative to 1st bump		
		end		
		sigma_xy = [x_var*1000, xy_covar; xy_covar, y_var*1000];
		z_pdf_2 = mvnpdf(xy,mean_xy_2*1000,multiplier.*sigma_xy);
		z_pdf_2 = reshape(z_pdf_2,ny,nx);        
		z_pdf = z_pdf + (z_pdf_2/weight_z2); % Combine the two bumps                
	end
	bump = z_pdf;
end
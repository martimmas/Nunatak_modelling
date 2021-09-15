function UserVar=SetEnsembleParams(UserVar)

% Default parameters
if ~isfield(UserVar,'SurfSlope')       UserVar.SurfSlope       = 0.;     end
if ~isfield(UserVar,'CenterH')         UserVar.CenterH         = 2000;   end
if ~isfield(UserVar,'NunatakShape')    UserVar.NunatakShape    = 'o';    end
if ~isfield(UserVar,'NunatakQuantity') UserVar.NunatakQuantity = 1;      end
if ~isfield(UserVar,'NunatakScale')    UserVar.NunatakScale    = 0.2;    end
if ~isfield(UserVar,'CenterB')         UserVar.CenterB         = 500.;   end
if ~isfield(UserVar,'BedrockType')     UserVar.BedrockType     = 'flat'; end
if ~isfield(UserVar,'BedrockSlope')    UserVar.BedrockSlope    = -0.;    end
if ~isfield(UserVar,'Alpha')           UserVar.Alpha           = 0.00;   end
if ~isfield(UserVar,'Ctau')            UserVar.Ctau            = 80;     end
if ~isfield(UserVar,'Cub')             UserVar.Cub             = 10;     end
if ~isfield(UserVar,'IceTemp')         UserVar.IceTemp         = -10.;   end
if ~isfield(UserVar,'GlenN')           UserVar.GlenN           = 3.;     end

switch UserVar.SensEnsMember
    
    % Different cases of bedrock inclination
    case 'SMP-Bed0'
        UserVar.NunatakShape = '0y';                
    case 'SMP-Bed1'
        UserVar.NunatakShape = '0y';
        UserVar.BedrockType  = 'sloping';
        UserVar.BedrockSlope = -0.01;
    case 'SMP-Bed2'
        UserVar.NunatakShape = '0y';
        UserVar.BedrockType  = 'sloping';
        UserVar.BedrockSlope = +0.01;
        
    % Sensitivity to Nunataks
    % Nunatak shapes ensemble
    case 'Sh1'
        UserVar.NunatakShape = '0x';    
        UserVar.NunatakQuantity = 1;
    case 'Sh2'
        UserVar.NunatakShape = '0y';    
        UserVar.NunatakQuantity = 1;
    case 'Sh3'
        UserVar.NunatakShape = 'Tu';    
        UserVar.NunatakQuantity = 1;
    case 'Sh4'
        UserVar.NunatakShape = 'Td';    
        UserVar.NunatakQuantity = 1;        
    case 'Sh5'
        UserVar.NunatakShape = 'X';    
        UserVar.NunatakQuantity = 1;
        
    % Nunatak sizes ensemble
    case 'Sz1'
        UserVar.NunatakShape = '0y';    
        UserVar.NunatakQuantity = 1;
        UserVar.NunatakScale = 0.075;
    case 'Sz2'
        UserVar.NunatakShape = '0x';    
        UserVar.NunatakQuantity = 1;
        UserVar.NunatakScale = 0.075;
    case 'Sz3'
        UserVar.NunatakShape = 'Tu';
        UserVar.NunatakQuantity = 1;
        UserVar.NunatakScale = 0.075;
    case 'Sz4'
        UserVar.NunatakShape = 'Td';    
        UserVar.NunatakQuantity = 1;
        UserVar.NunatakScale = 0.075;
    case 'Sz5'
        UserVar.NunatakShape = 'X';    
        UserVar.NunatakQuantity = 1;
        UserVar.NunatakScale = 0.075;
    case 'Sz6'
        UserVar.NunatakShape = '0y';    
        UserVar.NunatakQuantity = 1;
        UserVar.NunatakScale = 1.;
    case 'Sz7'
        UserVar.NunatakShape = '0x';    
        UserVar.NunatakQuantity = 1;
        UserVar.NunatakScale = 1.;
    case 'Sz8'
        UserVar.NunatakShape = 'Tu';
        UserVar.NunatakQuantity = 1;
        UserVar.NunatakScale = 1.;
    case 'Sz9'
        UserVar.NunatakShape = 'Td';    
        UserVar.NunatakQuantity = 1;
        UserVar.NunatakScale = 1.;
    case 'Sz10'
        UserVar.NunatakShape = 'X';    
        UserVar.NunatakQuantity = 1;
        UserVar.NunatakScale = 1.;
        
    % Sensitivity to model parameters
    case 'SMP-Alpha1'
        UserVar.Alpha = 0.005;
    case 'SMP-Alpha2'
        UserVar.Alpha = 0.01;
    case 'SMP-Alpha3'
        UserVar.Alpha = 0.012;
    case 'SMP-Alpha4'
        UserVar.Alpha = 0.015;
    case 'SMP-Alpha5'
        UserVar.Alpha = 0.02;
        
    case 'SMP-Slip1'        
        UserVar.Cub = 10.;
    case 'SMP-Slip2'        
        UserVar.Cub = 15.;
    case 'SMP-Slip3'        
        UserVar.Cub = 20.;
    case 'SMP-Slip4'        
        UserVar.Cub = 25.;    
    case 'SMP-Slip5'        
        UserVar.Cub = 30.;
        
    case 'SMP-Slip6'        
        UserVar.Ctau = 60.;
    case 'SMP-Slip7'        
        UserVar.Ctau = 70.;
    case 'SMP-Slip8'        
        UserVar.Ctau = 80.;
    case 'SMP-Slip9'        
        UserVar.Ctau = 90.;
    case 'SMP-Slip10'        
        UserVar.Ctau = 100.;
        
    case 'SMP-AGlen1'        
        UserVar.IceTemp = -20.;
    case 'SMP-AGlen2'        
        UserVar.IceTemp = -17.5;    
    case 'SMP-AGlen3'
        UserVar.IceTemp = -15.;
    case 'SMP-AGlen4'        
        UserVar.IceTemp = -12.5;    
    case 'SMP-AGlen5'
        UserVar.IceTemp = -10.;
        
        
    case 'SMP-AGlen6'
        UserVar.GlenN = 2.;
    case 'SMP-AGlen7'
        UserVar.GlenN = 2.5;
    case 'SMP-AGlen8'
        UserVar.GlenN = 3.;
    case 'SMP-AGlen9'
        UserVar.GlenN = 3.5;
    case 'SMP-AGlen10'
        UserVar.GlenN = 4;     
        
    case 'SMP-Thk1'
        UserVar.CenterH = 1000.;
    case 'SMP-Thk2'
        UserVar.CenterH = 1500.;
    case 'SMP-Thk3'
        UserVar.CenterH = 2000.;
    case 'SMP-Thk4'
        UserVar.CenterH = 2500.;      
    case 'SMP-Thk5'
        UserVar.CenterH = 3000.;               
   
    case 'SMP-Spinup0'
        UserVar.CenterH = 2000.;        
        UserVar.Cub = 10;
        UserVar.Ctau = 120;
    case 'SMP-Spinup1'     
        UserVar.CenterH = 1500.;
        UserVar.NunatakShape = '0y';                
    case 'SMP-Spinup2'     
        UserVar.CenterH = 2000.;
        UserVar.NunatakShape = '0y';        
        UserVar.Cub = 10;
        UserVar.Ctau = 120;    
    case 'SMP-Spinup3'
        UserVar.CenterH  = 3200.;  
        UserVar.NunatakShape = '0y';
        UserVar.Cub = 2;
        UserVar.Ctau = 120;    
    case 'SMP-SpinupDyn'
        UserVar.CenterH  = 3500.;  
        UserVar.NunatakShape = '0y';
        UserVar.Cub = 10;
        UserVar.Ctau = 120;    
        
    % Examples from Cuffey & Patterson (2010, 4th ed.)
    case 'SMP-Whillans'
        UserVar.Cub = 400;
        UserVar.Ctau = 3;
    case 'MacAyeal'
        UserVar.Cub = 400;
        UserVar.Ctau = 14;
    case 'SMP-Bindschadler'
        UserVar.Cub = 360;
        UserVar.Ctau = 10;
        
    case 'ESC-Spinup2'
        UserVar.CenterH = 2000.;
        UserVar.NunatakShape = '0y';        
        UserVar.Cub = 10;
        UserVar.Ctau = 120;    
    case 'ESC-Spinup3'
        UserVar.CenterH = 2000.;
        UserVar.NunatakShape = '0y';        
        UserVar.Cub = 10;
        UserVar.Ctau = 120;         
                
    % Default otherwise
    otherwise
        sprintf('Using default parameters...')                                                                 
end

end
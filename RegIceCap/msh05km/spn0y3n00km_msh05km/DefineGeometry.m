
function [UserVar,s,b,S,B,alpha]=DefineGeometry(UserVar,CtrlVar,MUA,time,FieldsToBeDefined)
    % FieldsToBeDefined='sbSB' ; 
    
    x=MUA.coordinates(:,1); y=MUA.coordinates(:,2);
  
    %%
%     alpha=0.01; hmean=1000; 
%     ampl_b=0.5*hmean; sigma_bx=5000 ; sigma_by=5000;
%     Deltab=ampl_b*exp(-((x/sigma_bx).^2+(y/sigma_by).^2));
%     Deltab=Deltab-mean(Deltab);
%     
%     B=zeros(MUA.Nnodes,1) + Deltab;
%     S=B*0-1e10;
%     b=B;
%     s=B*0+hmean;
%% Assigning the proper variables to be used

if contains(FieldsToBeDefined,'S')
    S=x*0;
else
    S=NaN;
end
if contains(FieldsToBeDefined,'B')
    B=UserVar.FB(x,y);
else
    B=NaN;
end
if contains(FieldsToBeDefined,'b')
    b=B;
else
    b=NaN;
end
if contains(FieldsToBeDefined,'s')
    s=UserVar.Fs(x,y);
else
    s=NaN;
end
alpha = 0.0;

if UserVar.SeaLevelRise==1    
    S = x*0 + 120;
end

% if isfield(UserVar,'Alpha')
%     alpha = UserVar.Alpha;
% else
%     alpha=0.01; % you can use this to tilt the domain with respect to gravity (angle given in radians)
% end

% if UserVar.DynamicThinning == 1 && contains(UserVar.OutputFileName,'Spinup') == 0   
%     if CtrlVar.time < 410 % one early calving event
%         downstream_reg_nodes = find(x>1.45e5);             
%         [~,indd]=sort(MUA.coordinates(downstream_reg_nodes,2)); 
%         downstream_reg_nodes=downstream_reg_nodes(indd);            
%         s(downstream_reg_nodes)=b(downstream_reg_nodes)+CtrlVar.ThickMin; % calving 5 km of ice downstream
%     end
% end

% Save the thickness at start of run
if contains(FieldsToBeDefined,'s') && contains(FieldsToBeDefined,'b')
    UserVar.InitialThick = s-b;
end

end

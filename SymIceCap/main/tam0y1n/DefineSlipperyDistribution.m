function [UserVar,C,m]=DefineSlipperyDistribution(UserVar,CtrlVar,MUA,time,s,b,h,S,B,rho,rhow,GF)

 persistent FC

 if ~UserVar.Slipperiness.ReadFromFile
    
     m=3;
     if isfield(UserVar,'Ctau')
         tau=UserVar.Ctau ; % units meters, year , kPa
     else
         tau=80 ; % units meters, year , kPa
     end
     if isfield(UserVar,'Cub')
         ub = UserVar.Cub;
     else
         ub=10 ; 
     end

     C0=ub/tau^m;
     C=C0; % 2.89e-5 %1.8012e-5; %C0; 
%      if UserVar.DynamicThinning == 1         
%          %Cweight_linear = MUA.coordinates(:,1)/nanmax(MUA.coordinates(:,1));
%          %C_linear = Cweight_linear * C0 + C0;
%          
%          h0 = UserVar.CenterH;
%          fact_increase = 1 - nanmedian(h)/h0;
%          C = C.*(1+fact_increase);
%          
%          %C0 = C0*ceil(10*CtrlVar.time/CtrlVar.TotalTime);
%    
%          %Cweight  = tan(MUA.coordinates(:,1)/nanmax(MUA.coordinates(:,1)));%.*sin(MUA.coordinates(:,1)/nanmax(MUA.coordinates(:,1))).^ 2; 
%          %C = Cweight * C0 + C0;
%          C(C<C0) = C0;
%      end
 else
    
    
     if isempty(FC)
         fprintf('DefineSlipperyDistribution: loading file: %-s ',UserVar.CFile)
         load(UserVar.CFile,'FC')
         fprintf(' done \n')
         
     end
    
     Caux=FC(MUA.coordinates(:,1),MUA.coordinates(:,2));
     C=median(Caux(:)) + zeros(size(Caux));
     m=3;
 end
    
end
function [UserVar,AGlen,n]=DefineAGlenDistribution(UserVar,CtrlVar,MUA,time,s,b,h,S,B,rho,rhow,GF)


persistent FA


 if ~UserVar.AGlen.ReadFromFile
    
    if isfield(UserVar,'IceTemp')
        AGlen = AGlenVersusTemp(UserVar.IceTemp);
    else
        AGlen=AGlenVersusTemp(-10);
    end
    if isfield(UserVar,'GlenN')
        n = UserVar.GlenN;
    else
        n=3;
    end
    
else
    
    if isempty(FA)
        fprintf('DefineSlipperyDistribution: loading file: %-s ',UserVar.AFile)
        load(UserVar.AFile,'FA')
        fprintf(' done \n')
        
    end
    
    AGlen_aux=FA(MUA.coordinates(:,1),MUA.coordinates(:,2));
    AGlen=median(AGlen_aux(:)) + zeros(size(AGlen_aux));
    n=3;
 end
end


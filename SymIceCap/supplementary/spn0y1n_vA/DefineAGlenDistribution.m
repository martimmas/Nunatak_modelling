function [UserVar,AGlen,n]=DefineAGlenDistribution(UserVar,CtrlVar,MUA,time,s,b,h,S,B,rho,rhow,GF)


persistent FA


if ~UserVar.AGlen.ReadFromFile
         
    if isfield(UserVar,'IceTemp')
        AGlen = AGlenVersusTemp(UserVar.IceTemp);
    else
        AGlen=AGlenVersusTemp(-10);
    end
    
    if isfield(UserVar.AGlen,'SofterNunatak') && UserVar.AGlen.SofterNunatak==1
        UserVar2 = UserVar;
        UserVar2.BedrockType='flat';
        UserVar2.BedrockSlope=0.;
        [~,xgrd,ygrd,~,topo_xy]=CreateSurfaces(UserVar2);
        w_soft=(topo_xy-nanmean(topo_xy(:)))./nanstd(topo_xy(:));
        w_soft = w_soft./nanmax(w_soft(:));
        w_hard = 1-w_soft;
        T_soft = -5;
        if isfield(UserVar,'IceTemp')
            T_hard = UserVar.IceTemp;
        else
            T_hard = -20;
        end
        T_field = T_hard .* w_hard + T_soft .* w_soft;
        %imagesc(w_soft); colorbar;
        AGlen_grd = AGlenVersusTemp(T_field);
        FA = griddedInterpolant(xgrd',ygrd',AGlen_grd');
        AGlen = FA(MUA.coordinates(:,1),MUA.coordinates(:,2));
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


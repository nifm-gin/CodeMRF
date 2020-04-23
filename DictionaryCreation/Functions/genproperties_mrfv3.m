function Properties = genproperties_mrfv3(Properties)
%GENPROPERTIES Generates voxel properties
% Explores Properties struct from main parameter files
% Creates meshes and removes points where T2>T1
% Properties must contain fields T1, T2, df and B1rel
% Adds to struct fields with similar names, appended with "list"
% corresponding to meshed parameters

% if niveau == 1
%     T1=[2500];
%     T2=[110];
%     df=[0];
%     B1rel=[1.0];
%     
% elseif niveau == 2
%     T1=[500 1000 1500 2000 2500 3000];
%     T2=[40 100 500 1200];
%     df=[-100 -40 -20 0 20 40 100];
%     B1rel=[0.8 0.9 1 1.1];
% 
% elseif niveau == 3
%     T1=[200:200:1200 1300:100:1800 1900:200:3100];
%     T2=[10:10:100 150:50:300 400:100:600 1000 1500 2000];
%     df=[-100:20:-40 -35:10:-5 -4:2:4 5:10:35 40:20:100];
%     B1rel=[0.9:0.1:1.1];
%     
% elseif niveau == 4
%         T1=[300:100:1000 1100:50:1800 1900:100:2300 2350:50:2700 2800 2900 3000];%[300:100:1100 1200:50:2100 2200:100:3000];
%         T2=[20 40 60:10:140 160:20:200 210:10:300 320 340 350 360 370 400 500 700 1000];%[10:10:100 150:50:500 600:200:1000 2000:400:2800];
%         df=[-300:20:-100 -80:10:80 100:20:300];%[-100:10:-40 -35:5:-10 -9:2:-1 0 1:2:9 10:5:35 40:10:100];
%         B1rel=[0.7:0.1:1.1];%[0.85:0.05:1.15]; %[0.6:0.1:1.1];
% end  
    
    [T2mesh,T1mesh,dfmesh,B1relmesh]    = ndgrid(Properties.T2, Properties.T1, Properties.df, Properties.B1rel);
    indices                             = find(T1mesh(:)>T2mesh(:));
    Properties.T1list                   = T1mesh(indices(:));
    Properties.T2list                   = T2mesh(indices(:));
    Properties.dflist                   = dfmesh(indices(:));
    Properties.B1rellist                = B1relmesh(indices(:));
    
    
%% Code pour changer manuellement une liste de propri�t�s (valeurs � modifier manuellement)
%     Properties.T1=[200:200:1200 1300:100:1800 1900:200:3100];
%     Properties.T2=[10:10:100 150:50:300 400:100:600 1000 1500 2000];
%     Properties.df=[-100:20:-40 -35:10:-5 -4:2:4 5:10:35 40:20:100];
%     Properties.B1rel=[0.9:0.1:1.1];
% 
%     [T2mesh,T1mesh,dfmesh,B1relmesh]=ndgrid(Properties.T2,Properties.T1,Properties.df,Properties.B1rel);
%     indices=find(T1mesh(:)>T2mesh(:));
%     Properties.T1list=T1mesh(indices(:));
%     Properties.T2list=T2mesh(indices(:));
%     Properties.dflist=dfmesh(indices(:));
%     Properties.B1rellist=B1relmesh(indices(:));
%     clear T1mesh T2mesh dfmesh B1relmesh indices
    
%% 
%     Properties.T1=[200:200:3100];
%     Properties.T2=[10:20:100 150:50:300 400:100:600 1000 1500 2000];
%     Properties.df=[0:20:100];
%     Properties.B1rel=[0.9:0.1:1.1];
% 
%     [T2mesh,T1mesh,dfmesh,B1relmesh]=ndgrid(Properties.T2,Properties.T1,Properties.df,Properties.B1rel);
%     indices=find(T1mesh(:)>T2mesh(:));
%     Properties.T1list=T1mesh(indices(:));
%     Properties.T2list=T2mesh(indices(:));
%     Properties.dflist=dfmesh(indices(:));
%     Properties.B1rellist=B1relmesh(indices(:));
%     clear T1mesh T2mesh dfmesh B1relmesh indices
    
    
end


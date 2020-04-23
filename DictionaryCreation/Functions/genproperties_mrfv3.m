function Properties = genproperties_mrfv3(Properties)
%GENPROPERTIES Generates voxel properties
% Explores Properties struct from main parameter files
% Creates meshes and removes points where T2>T1
% Properties must contain fields T1, T2, df and B1rel
% Adds to struct fields with similar names, appended with "list"
% corresponding to meshed parameters

[T2mesh,T1mesh,dfmesh,B1relmesh]    = ndgrid(Properties.T2, Properties.T1, Properties.df, Properties.B1rel);
indices                             = find(T1mesh(:)>T2mesh(:));
Properties.T1list                   = T1mesh(indices(:));
Properties.T2list                   = T2mesh(indices(:));
Properties.dflist                   = dfmesh(indices(:));
Properties.B1rellist                = B1relmesh(indices(:));

end


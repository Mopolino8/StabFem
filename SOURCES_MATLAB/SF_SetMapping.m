function fffield = SF_SetMapping(fffield, varargin)
%
% This is part of StabFem Project, D. Fabre, July 2017 -- present
% Matlab Driver to specify the mapping
%
% Usage : 1/ (for fress surface problems)
%   ffmesh = SF_SetMapping(ffmesh,'typemapping',type,'parammapping',Params)
%         2/ for base-flow associated problems
%   bf = SF_MeshStretch(bf,'typemapping',type,'parammapping',Params)
%
%  Params is a vector whose size depends on the type. Currently implemented
%  cases are as follows :
%  typemapping = "jet" -> Params = [Lm, LA, LC, gammaC, yA, yB]
%  typemapping = "box" -> Params = [x0 x1 LA LC GC yo LAy LCy GCy ]
%  typemapping = "spherical" -> Params = ... (to be implemented...)
%
%

global ff ffdir ffdatadir sfdir verbosity

% Interpreting parameters
p = inputParser;
addParameter(p, 'MappingType', 'Jet'); % Array of parameters for the cases involving mapping
addParameter(p, 'MappingParams', 'default'); % Array of parameters for the cases involving mapping
parse(p, varargin{:});


if(strcmpi(fffield.datatype,'mesh'))
    ffmesh = fffield;
else
    ffmesh = fffield.mesh;
end

% designation of the adapted mesh
if(isfield(ffmesh,'meshgeneration'))
     meshgeneration = ffmesh.meshgeneration+1;
else
    meshgeneration = 1;
    disp('WARNING : no mesh generation in SF_MeshStretch');
end
%designation = ['_stretch',num2str(meshgeneration)];
% this desingation will be added to the names of the mesh/BF files


%%

    createMappingParamFile(p.Results.MappingType,p.Results.MappingParams); %% See auxiliary function of this file
    command = [ ff, ' ', ffdir, 'SetMapping.edp'];
    errormsg = 'ERROR : FreeFem SetMapping aborted';
    status = mysystem(command, errormsg);
 
    fileToRead4 = [ffdatadir,'Mapping.ff2m'];
    m2 = importFFdata(ffmesh,fileToRead4);
    ffmesh.xphys = m2.xphys;
    ffmesh.yphys = m2.yphys;
    ffmesh.Hx = m2.Hx;
    ffmesh.Hy = m2.Hy;


%mycp(ffmesh.filename, [ffdatadir, 'mesh_guess.msh']); % position mesh file
%command = ['echo ', num2str(p.Results.Xratio), ' ', num2str(p.Results.Yratio), ' ', num2str(p.Results.Xmin), ' ', num2str(p.Results.Ymin),  ' | ', ff, ' ', ffdir, 'MeshStretch.edp'];
%errormsg = 'ERROR : FreeFem MeshStretch aborted';
%status = mysystem(command, errormsg);
%mycp('WORK/mesh_guess.msh',[ffdatadir,'MESHES/mesh',designation,'.msh']);
%mycp('WORK/mesh_guess.ff2m',[ffdatadir,'MESHES/mesh',designation,'.ff2m']);
%ffmesh = importFFmesh([ffdatadir,'MESHES/mesh',designation,'.msh']);
%ffmesh.generation = meshgeneration;


if(strcmpi(fffield.datatype,'mesh'))
    % first argument was a mesh ; then result is also the mesh
    fffield=ffmesh;
    
else
    
    % designation of the adapted mesh
    if(isfield(ffmesh,'meshgeneration'))
     meshgeneration = ffmesh.meshgeneration+1;
    else
    meshgeneration = 1;
    disp('WARNING : no mesh generation in SF_MeshStretch');
    end
    designation = ['_mapped',num2str(meshgeneration)];
    
    % first argument was a baseflow ; then baseflow will be recomputed
    fffield.mesh=ffmesh;
     mydisp(2,' SF_Adapt : recomputing base flow');
    baseflowNew  = SF_BaseFlow(fffield, 'type', 'POSTADAPT'); 
     if (baseflowNew.iter > 0)
     fffield = baseflowNew; 
     
     mycp('WORK/mesh.msh',[ffdatadir,'MESHES/mesh',designation,'.msh']);
     mycp('WORK/mesh.ff2m',[ffdatadir,'MESHES/mesh',designation,'.ff2m']);
     ffmesh = importFFmesh([ffdatadir,'MESHES/mesh',designation,'.msh']);
     
     mycp([ffdatadir, 'BaseFlow.txt'],  [ffdatadir, 'MESHES/BaseFlow', designation, '.txt']);
     mycp([ffdatadir, 'BaseFlow.ff2m'], [ffdatadir, 'MESHES/BaseFlow', designation, '.ff2m']);   
     fffield.filename = [ffdatadir, 'MESHES/BaseFlow', designation, '.txt'];
%     myrm([ffdatadir '/BASEFLOWS/*']); % after adapt we clean the "BASEFLOWS" directory as the previous baseflows are no longer compatible
     mycp([ffdatadir, 'BaseFlow.txt'],  [ffdatadir, 'BASEFLOWS/BaseFlow_Re',num2str(fffield.Re),'.txt']);
     mycp([ffdatadir, 'BaseFlow.ff2m'],  [ffdatadir, 'BASEFLOWS/BaseFlow_Re',num2str(fffield.Re),'.ff2m']);
     else
         error('ERROR in SF_Adapt : baseflow recomputation failed');
     end
end


end



function [] = createMappingParamFile(MappingType,MappingParams)
% This auxiliary function creates the file with complex parameters
% There are currently 2 different cases (to be generalized someday...)
    if(isnumeric(MappingParams))  
    switch(lower(MappingType))   
            case({'jet','type1'})  
        % Mapping with 6 parameters for axisym. flow across a hole 
            fid = fopen('Param_Mapping.edp', 'w');
            fprintf(fid, '// Parameters for complex mapping (file generated by matlab driver)\n');
            fprintf(fid, ['real ParamMapLm = ', num2str(MappingParams(1)), ' ;']);
            fprintf(fid, ['real ParamMapLA = ',  num2str(MappingParams(2)), ' ;']);
            fprintf(fid, ['real ParamMapLC = ', num2str(MappingParams(3)), ' ;']);
            fprintf(fid, ['real ParamMapGC = ',  num2str(MappingParams(4)), ' ;']);
            fprintf(fid, ['real ParamMapyA = ', num2str(MappingParams(5)), ' ;']);
            fprintf(fid, ['real ParamMapyB = ',  num2str(MappingParams(6)), ' ;']);
            fclose(fid);
          case({'box','type2'})      
        % Mapping with 9 parameters for 2D flow around an object
                fid = fopen('Param_Mapping.edp', 'w');
                fprintf(fid, '// Parameters for complex mapping (file generated by matlab driver)\n');
                fprintf(fid, ['real ParamMapx0 = ', num2str(MappingParams(1)), ' ;']);
                fprintf(fid, ['real ParamMapx1 = ', num2str(MappingParams(2)), ' ;']);
                fprintf(fid, ['real ParamMapLA = ',  num2str(MappingParams(3)), ' ;']);
                fprintf(fid, ['real ParamMapLC = ', num2str(MappingParams(4)), ' ;']);
                fprintf(fid, ['real ParamMapGC = ',  num2str(MappingParams(5)), ' ;']);
                fprintf(fid, ['real ParamMapyo = ', num2str(MappingParams(6)), ' ;']);
                fprintf(fid, ['real ParamMapLAy = ',  num2str(MappingParams(7)), ' ;']);
                fprintf(fid, ['real ParamMapLCy = ', num2str(MappingParams(8)), ' ;']);
                fprintf(fid, ['real ParamMapGCy = ',  num2str(MappingParams(9)), ' ;']);
                fclose(fid);
 
    end
    end
end
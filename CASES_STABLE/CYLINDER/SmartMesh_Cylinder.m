

function [bf]= SCRIPT_CYLINDER_MESHGENERATION(type,dimensions)
% THIS little functions generates and adapts a mesh for the wake of a cylinder.
% Adaptation type is either 'S' (mesh M2) or 'D' (mesh M4).

if(varargin==0)
    type='S';
end

if(varargin<2)
    dimensions = [-40 80 40];
end
    
bf=SF_Init('Mesh_Cylinder.edp',dimensions);
bf=SF_BaseFlow(bf,'Re',1);
bf=SF_BaseFlow(bf,'Re',10);
bf=SF_BaseFlow(bf,'Re',60);
bf=SF_Adapt(bf,'Hmax',5);
bf=SF_Adapt(bf,'Hmax',5);
disp(' ');
disp(['mesh adaptation  : type ',type])
[ev,em] = SF_Stability(bf,'shift',0.04+0.76i,'nev',1,'type',type);
bf=SF_Adapt(bf,em,'Hmax',5);
[ev,em] = SF_Stability(bf,'shift',0.04+0.76i,'nev',1,'type',type);
bf=SF_Adapt(bf,em,'Hmax',5);

disp([' Adapted mesh has been generated ; number of vertices = ',num2str(bf.mesh.np)]);


end
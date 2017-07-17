global ff ffdir ffdatadir sfdir 
ff = '/usr/local/ff++/openmpi-2.1/3.55/bin/FreeFem++-nw -v 0'; %% Freefem command with full path 
sfdir = '../SOURCES_MATLAB'; % where to find the matlab drivers
ffdir = '../SOURCES_FREEFEM/'; % where to find the freefem scripts
ffdatadir = './DATA_FREEFEM_BIRDCALL_ERCOFTAC';
addpath(sfdir);

%%% ON CONSTRUIT UN MESH CORRECT POUR Re=400

%system('cp Params_BirdCall_ForFlavio.edp Params_BirdCall.edp');

Re = 400; % Reference value for the robust mesh generation

if(exist([ ffdatadir '/CHBASE/chbase_Re' num2str(Re) '.txt'])==2)
    disp(['base flow and adapted mesh for Re = ' num2str(Re) ' already computed']);
    if(exist('bf')==0) % may happen for instance after clear all or restart
        bf.mesh = importFFmesh('mesh.msh');
    	bf = FreeFem_BaseFlow(bf,Re);
    load('baseflow.mat');
    end
    
else
    disp('computing base flow and adapting mesh')

disp('generating base flow and mesh')
bf = FreeFem_Init('Mesh_BirdCall.edp'); %% this is the mesh from Benjamin/Raffaele
plotFF(bf,'u0');
ReTab = [10, 30, 100, 200, 300, 400]% 600]%, 750, 1000]%, 1250, 1500];
%ReTab = [ 400 550 750 1000];
for Re = ReTab
    bf = FreeFem_BaseFlow(bf,Re);
    if(Re>100) 
        bf = FreeFem_Adapt(bf);
    end
end

 
[ev,em] = FreeFem_Stability(bf,400,0,-0.1549 + 5.343i,1)
[bf]=FreeFem_Adapt(bf,em); 

end

bf.mesh.xlim=[-2,5];
bf.mesh.ylim=[0 4];

bf.mesh.xlim=[-2,5];
bf.mesh.ylim=[0 4];
plotFF(bf,'mesh');
plotFF(bf,'u0'); 

pause(0.1);


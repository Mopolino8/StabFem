
function bf = SmartMesh_Hole_NoMap(chi)
SF_Start;

verbosity=10;
close all;

bf = SF_Init('Mesh_OneHole.edp',[chi,15,60,10,10]);

bf = SF_BaseFlow(bf,'Re',1);
bf = SF_BaseFlow(bf,'Re',10);
bf = SF_BaseFlow(bf,'Re',30 );
bf = SF_BaseFlow(bf,'Re',100 );
%SF_Status('BASEFLOWS')
bf = SF_Adapt(bf,'Hmax',1); 
%SF_Status('BASEFLOWS')
bf = SF_BaseFlow(bf,'Re',300 );
bf = SF_Adapt(bf,'Hmax',1);
bf = SF_BaseFlow(bf,'Re',600 );
bf = SF_Adapt(bf,'Hmax',1);
bf = SF_BaseFlow(bf,'Re',1000 );
bf = SF_Adapt(bf,'Hmax',1);
bf = SF_BaseFlow(bf,'Re',1500 );
bf = SF_Adapt(bf,'Hmax',1);


%[ev,em]=SF_Stability(bf,'nev',1,'type','A','m',0,'shift', -2.06i)
%bf=SF_Adapt(bf,em,'Hmax',1)

bf = SF_BaseFlow(bf,'Re',2000 );

em1 = SF_LinearForced(bf,2.6);
em2 = SF_LinearForced(bf,8.25);
bf=SF_Adapt(bf,em1,em2,'Hmax',1)

em1 = SF_LinearForced(bf,2.6);
em2 = SF_LinearForced(bf,8.25);
bf=SF_Adapt(bf,em1,em2,'Hmax',0.25)

end
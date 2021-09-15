Point(1) = {-150000.000000,100000.000000,0.000000,20000.000000};
Point(2) = {150000.000000,100000.000000,0.000000,20000.000000};
Point(3) = {150000.000000,-100000.000000,0.000000,20000.000000};
Point(4) = {-150000.000000,-100000.000000,0.000000,20000.000000};
Line(1) = {1,2};
Line(2) = {2,3};
Line(3) = {3,4};
Line(4) = {4,1};
Line Loop(1) = {1:4};
Plane Surface(1) = {1};
Mesh.Algorithm = 8 ; 
Mesh.CharacteristicLengthMin = 20000.000000 ; 
Mesh.CharacteristicLengthMax = 20000.000000 ; 
Mesh.CharacteristicLengthExtendFromBoundary = 0 ; 
Mesh.CharacteristicLengthFromCurvature = 0 ; 
 Periodic Line {1,2} = {3,4}; 
 
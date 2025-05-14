%[text] # Test the Application of Boundary Conditions
%[text:tableOfContents]{"heading":"Table of Contents"}
%[text] %[text:anchor:H_7E81E991] ## Brief summary of this function
%[text] Tests whether the boundary conditions are applied correctly for the motorcycle swingarm
function testApplicationBoundaryConditionsAndLoads(testCase)
%[text] %[text:anchor:H_51D4211A] ## Definition of tolerance
tol = 1e-14;
tol6 = tol*1e6;
%[text] ## Apply the boundary conditions
structModel = applyBoundaryConditions(testCase.structModel);
%[text] ## Tests
%[text] ### Test the number of faces
FaceBC = structModel.FaceBC;
FaceLoad = structModel.FaceLoad;
expNumFaces = 76;
testCase.verifyEqual(numel(FaceBC), expNumFaces, "RelTol", tol, ...
    'Unexpected number of FaceBC entries.');
%[text] ### Test whether the expected face is constrained
allConstraints = {FaceBC.Constraint};
expConstraints = repmat({strings(1, 0)}, 1, expNumFaces);
expConstraints{71} = "fixed";
testCase.verifyEqual(allConstraints, expConstraints, ...
    'Only Face 71 should be fixed; others should be empty.');
testCase.verifyTrue(all(cellfun(@isempty, {FaceBC.XDisplacement})), ...
    'All XDisplacement should be empty.');
testCase.verifyTrue(all(cellfun(@isempty, {FaceBC.YDisplacement})), ...
    'All YDisplacement should be empty.');
testCase.verifyTrue(all(cellfun(@isempty, {FaceBC.ZDisplacement})), ...
    'All ZDisplacement should be empty.');
%[text] ### Test whether the expected load is applied
allSurfaceTraction = {FaceLoad.SurfaceTraction};
expSurfaceTraction = repmat({zeros(1, 0)}, 1, 76);
expSurfaceTraction{9}  = [0 0 388476];
expSurfaceTraction{51} = [0 0 388476];
expSurfaceTraction{66} = [-2.004055797174397e+06 0 -4.297711526127794e+06];
expSurfaceTraction{68} = [-2.004055797174397e+06 0 -4.297711526127794e+06];
testCase.verifyEqual(allSurfaceTraction, expSurfaceTraction, "RelTol", tol6, ...
    'Only Faces 9, 51, 66, and 68 should have SurfaceTraction; others should be empty.');
testCase.verifyTrue(all(cellfun(@isempty, {FaceLoad.Temperature})), ...
    'All Temperature should be empty.');
testCase.verifyTrue(all(cellfun(@isempty, {FaceLoad.Heat})), ...
    'All Heat should be empty.');
testCase.verifyTrue(all(cellfun(@isempty, {FaceLoad.ConvectionCoefficient})), ...
    'All ConvectionCoefficient should be empty.');
testCase.verifyTrue(all(cellfun(@isempty, {FaceLoad.AmbientTemperature})), ...
    'All AmbientTemperature should be empty.');
testCase.verifyTrue(all(cellfun(@isempty, {FaceLoad.Emissivity})), ...
    'All Emissivity should be empty.');
testCase.verifyTrue(all(cellfun(@isempty, {FaceLoad.Pressure})), ...
    'All Pressure should be empty.');
testCase.verifyTrue(all(cellfun(@isempty, {FaceLoad.TranslationalStiffness})), ...
    'All TranslationalStiffness should be empty.');
testCase.verifyTrue(all(cellfun(@isempty, {FaceLoad.SurfaceCurrentDensity})), ...
    'All SurfaceCurrentDensity should be empty.');
testCase.verifyTrue(all(cellfun(@isempty, {FaceLoad.ChargeDensity})), ...
    'All ChargeDensity should be empty.');
testCase.verifyTrue(all(cellfun(@isempty, {FaceLoad.CurrentDensity})), ...
    'All CurrentDensity should be empty.');
testCase.verifyTrue(all(cellfun(@isempty, {FaceLoad.Magnetization})), ...
    'All Magnetization should be empty.');
testCase.verifyTrue(all(cellfun(@isempty, {FaceLoad.Gravity})), ...
    'All Gravity should be empty.');
testCase.verifyTrue(all(cellfun(@isempty, {FaceLoad.AngularVelocity})), ...
    'All AngularVelocity should be empty.');
%[text] 
end

%[appendix]{"version":"1.0"}
%---

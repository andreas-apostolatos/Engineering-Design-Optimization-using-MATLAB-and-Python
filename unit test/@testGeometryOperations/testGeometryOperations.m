classdef testGeometryOperations < matlab.unittest.TestCase
    %% Class definition
    %
    % Test suites for the geometry operations using PythonOCC
    % - Tests reading the geometry file (STEP)
    % - 

    properties
        geometryObj
        geometryFunctions
    end

    %% Setup method definitions
    methods (TestMethodSetup)
        function createStructModel(testCase)
            % Obtain the geometry functions based on PythonOCC
            testCase.geometryFunctions = env_conf;
            testCase.geometryObj = testCase.geometryFunctions.MyApp();

            % Read-in the IGS-description of the motorcycle swingarm
            fileName = fullfile("..", "geometry", "swingarm brep.igs");
            testCase.geometryObj.readGeometryFile(fileName)
        end
    end

    %% Test method definitions
    methods (Test)
        testGeometryImport(testCase)
        testEdges4Fillet(testCase)
        testGeometryUpdateAndSolidCreation(testCase)
    end

end
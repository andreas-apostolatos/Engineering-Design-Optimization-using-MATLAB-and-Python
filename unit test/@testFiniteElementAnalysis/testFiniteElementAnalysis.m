classdef testFiniteElementAnalysis < matlab.unittest.TestCase
    %% Class definition
    %
    % Test suites for the Finite Element Analysis model
    % - Tests the geometry of the motorcycle swingarm
    % - Tests the application of boundary conditions

    properties
        structModel
        geometryFunctions
        geometryObj
    end

    %% Setup method definitions
    methods (TestMethodSetup)
        function createStructModel(testCase)
            % Create a structural model based on the default STEP-file
            geomFileName = fullfile("..", "geometry", "swingarm solid.step");
            testCase.structModel = femodel(AnalysisType="structuralStatic", Geometry=geomFileName);

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
        testGeometry(testCase)
        testApplicationBoundaryConditionsAndLoads(testCase)
        testStrainEnergyComputation(testCase)
    end

end
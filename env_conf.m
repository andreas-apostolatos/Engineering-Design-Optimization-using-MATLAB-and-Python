function geometryFunctions = env_conf(setupPython, isApp)
    %ENV_CONF Sets up the environment needed for the workshop

    % Validate inputs
    if nargin < 2
        isApp = false;
    end
    validateattributes(isApp, {'logical'}, {'scalar'}, mfilename, 'isApp');

    if nargin < 1
        setupPython = false;
    end
    validateattributes(setupPython, {'logical'}, {'scalar'}, mfilename, 'setupPython');

    % Ensure auxiliary functions are in the MATLAB path
    ensurePath('auxiliary functions');

    % Determine environment
    homeDir = determineEnvironment();

    % Set paths based on environment
    [pythonPath, condaPath, miniforgeInstaller, miniforgeInstallCmd] = setPaths(homeDir);

    % Check whether Python and PythonOCC have been installed
    [isPythonMiniforgeInstalled, isPythonOCCInstalled] = verifyInstallations(pythonPath, false);

    % Install Python and PythonOCC if needed
    isPythonEnvInstalled = isPythonMiniforgeInstalled && isPythonOCCInstalled;
    if setupPython && ~isPythonEnvInstalled && ~isApp
        installPythonEnvironment(isPythonMiniforgeInstalled, isPythonOCCInstalled, ...
            miniforgeInstaller, miniforgeInstallCmd, condaPath, pythonPath);
    end

    % Verify installations
    [isPythonMiniforgeInstalled, isPythonOCCInstalled] = verifyInstallations(pythonPath, true);

    % Handle installation failures
    if ~isPythonMiniforgeInstalled || ~isPythonOCCInstalled
        geometryFunctions = [];
        warning('PythonOCC setup failed. Geometry functions are unavailable.');
        return;
    else
        % Return geometry functions if setup correctly
        geometryFunctions = py.importlib.import_module('geometryFunctions');
    end
end

function ensurePath(folderName)
    if ~contains(path, folderName)
        addpath(genpath(folderName));
        fprintf('Added "%s" to MATLAB path.\n', folderName);
    end
end

function homeDir = determineEnvironment()
    if ispc
        homeDir = getenv('USERPROFILE');
    else
        if ~ismac
            homeDir = getenv('HOME');
        else
            error("Automated PythonOCC setup is not implemented for MacOS")
        end
    end
end

function [pythonPath, condaPath, miniforgeInstaller, miniforgeInstallCmd] = setPaths(homeDir)
    if ispc
        pythonPath = fullfile(homeDir, 'miniforge3', 'python.exe');
        condaPath = fullfile(homeDir, 'miniforge3', 'Scripts', 'conda.exe');
        miniforgeInstaller = fullfile("metadata", "Miniforge3-Windows-x86_64.exe");
        miniforgeInstallCmd = miniforgeInstaller + " /S /D=" + fullfile(homeDir, 'miniforge3');
    else
        if ~ismac
            pythonPath = fullfile(homeDir, "miniforge3", "bin", "python3");
            condaPath = fullfile(homeDir, "miniforge3", "bin", "conda");
            miniforgeInstaller = fullfile('metadata', 'Miniforge3-Linux-x86_64.sh');
            miniforgeInstallCmd = ['bash ', miniforgeInstaller, ' -b -u'];
        else
            error("Automated PythonOCC setup is not implemented for MacOS")
        end
    end
end

function installPythonEnvironment(isPythonMiniforgeInstalled, isPythonOCCInstalled, ...
    miniforgeInstaller, miniforgeInstallCmd, condaPath, pythonPath)
    % Download miniforge based on the environment and install it
    if ~isPythonMiniforgeInstalled
        [pathStr, ~, ~] = fileparts(miniforgeInstaller);
        pathParts = strsplit(pathStr, filesep);
        metadataDirectory = pathParts{1};
        if ~isfolder(metadataDirectory)
            mkdir(metadataDirectory)
        end
        if ispc
            if ~isfile(miniforgeInstaller)
                fileName = 'https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Windows-x86_64.exe';
                websave(miniforgeInstaller, fileName);
            end
        else
            if ~ismac
                if ~isfile(miniforgeInstaller)
                    fileName = 'https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh';
                    websave(miniforgeInstaller, fileName)
                end
            else
                error("Automated PythonOCC setup is not implemented for MacOS")
            end
        end
        system(miniforgeInstallCmd);
    end

    % Install PythonOCC on the Python installation
    if ~isPythonOCCInstalled
        installPythonOCC = sprintf('"%s" install -c conda-forge -y pythonocc-core=7.8.1', condaPath);
        system(installPythonOCC);
    end

    % Check installation of Python, and PythonOCC, set Python environment 
    % in MATLAB, and finally test the PythonOCC-MATLAB interoperability
    if ~isfile(pythonPath)
        warning(['Python could not be installed.', newline, ...
            'Please navigate back to the "Engineering-Design-Optimization-using-MATLAB-and-Python" ', newline, ...
            'repository on MATLAB (Online or Desktop) and try again.']);
    else
        if ispc
            terminate(pyenv);
        end
        pyenv('Version', pythonPath, 'ExecutionMode', 'OutOfProcess');
        insert(py.sys.path, int32(0), fullfile("auxiliary functions"));
    end
end

function [isPythonMiniforgeInstalled, isPythonOCCInstalled] = verifyInstallations(pythonPath, isFinal)
    isPythonMiniforgeInstalled = isfile(pythonPath);
    isPythonOCCInstalled = false;
    if isPythonMiniforgeInstalled 
        isPythonOCCInstalled = true;
        try
            py.OCC.Core.BRepPrimAPI.BRepPrimAPI_MakeBox(10, 20, 30);
        catch
            isPythonOCCInstalled = false;
            if isFinal
                warning(['Something went wrong with the installation of PythonOCC.', newline, ...
                    'Please make sure that you have a stable internet connection and try again.', newline, ...
                    'If the issue persists, please seek assistance.']);
            end
        end
    end
end
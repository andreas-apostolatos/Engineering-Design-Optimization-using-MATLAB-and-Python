function geometryFunctions = env_conf(setupPython, isApp)
    %ENV_CONF Sets up the environment needed for the workshop
    arguments
        setupPython (1, 1) {mustBeNumericOrLogical} = true
        isApp (1, 1) {mustBeNumericOrLogical} = false
    end

    % PythonOCC ver, with which the workshop was developed
    expVersionOCC = "7.8.1";

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
            miniforgeInstaller, miniforgeInstallCmd, condaPath, pythonPath, ...
            expVersionOCC, homeDir);
    end

    % Verify installations
    [isPythonMiniforgeInstalled, isPythonOCCInstalled] = verifyInstallations(pythonPath, true);

    % Handle installation failures
    if ~isPythonMiniforgeInstalled || ~isPythonOCCInstalled
        geometryFunctions = [];
        warning('PythonOCC setup failed. Geometry functions are unavailable.');
        return;
    else
        % Check PythonOCC version and assert a warning, if necessary
        majorVerOCC = int32(py.OCC.PYTHONOCC_VERSION_MAJOR);
        minorVerOCC = int32(py.OCC.PYTHONOCC_VERSION_MINOR);
        patchVerOCC = int32(py.OCC.PYTHONOCC_VERSION_PATCH);
        versionOCC = majorVerOCC + "." + minorVerOCC + "." + patchVerOCC;
        if ~strcmp(versionOCC, expVersionOCC)
            warning("This workshop is developed using PythonOCC Version " + expVersionOCC + "." + newline + ...
                "However, your Python environment appears to use PythonOCC Version " + versionOCC + "." + newline + ...
                "This might lead to unexpected behavior, please consider adjusting the" + newline + ...
                "PythonOCC version to the recommended one and then try again.");
        end

        % Return geometry functions if setup correctly
        insert(py.sys.path, int32(0), fullfile("auxiliary functions"));
        geometryFunctions = py.importlib.import_module('geometryFunctions');
    end
end

function ensurePath(folderName)
    if ~contains(path, folderName)
        addpath(genpath(folderName));
        fprintf('Added "%s" to MATLAB path\n', folderName);
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
    miniforgeInstaller, miniforgeInstallCmd, condaPath, pythonPath, PythonOCCVer, homeDir)

    % Download miniforge based on the environment and install it
    if ~isPythonMiniforgeInstalled
        % Get the file parts of the installation location for Miniforge
        [pathStr, ~, ~] = fileparts(miniforgeInstaller);
        pathParts = strsplit(pathStr, filesep);
        metadataDirectory = pathParts{1};

        % Create a folder metadata, if not existent
        if ~isfolder(metadataDirectory)
            mkdir(metadataDirectory)
        end

        % Download the Miniforge installer based on user input
        if ~isfile(miniforgeInstaller)
            % Download the Miniforge executable based on the system
            if ispc
                fileName = "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Windows-x86_64.exe";
            else
                if ~ismac
                    fileName = "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh";
                else
                    error("Automated PythonOCC setup is not implemented for MacOS")
                end
            end
            fprintf("\nThe Miniforge installer will be downloaded using link " + fileName + ".\n")
            prompt = "Should the Miniforge installer be downloaded and stored under folder " + metadataDirectory + string(filesep) + "? (yes/no): ";
            isDownloadMiniforgeInstaller = approveInstallationProcess(prompt);
            if ~isDownloadMiniforgeInstaller
                error("Download of the Miniforge installer was stopped by the user." + newline + ...
                    "Please download Miniforge installer manually and store it under folder " + metadataDirectory + string(filesep) + "." + newline + ...
                    "Then try again.")
            end
            websave(miniforgeInstaller, fileName);

            % Display the SHA256 checksum of the downloaded Miniforge 
            % executable
            checksum = sha256file(miniforgeInstaller);
            fprintf('%sThe SHA256 checksum of the downloaded Miniforge installer is: %s%s', newline, checksum, newline);
            fprintf('You can verify this checksum against the official value at: ');
            fprintf(['https://github.com/conda-forge/miniforge#miniforge3', newline, newline]);
        end

        % Install Miniforge
        fprintf("%sMiniforge will be installed under %s using console command '%s'.%s", newline, homeDir, miniforgeInstallCmd, newline)
        prompt = "Should Miniforge be installed? (yes/no): ";
        isInstallMiniforge = approveInstallationProcess(prompt);
        if ~isInstallMiniforge
            error("Installation of Miniforge was stopped by the user. Please install Miniforge under " + string(homeDir) + " manually and then try again")
        end
        status = system(miniforgeInstallCmd);
        if status
            error("Installation of Miniforge failed. Refer to the console output for more information and then try again")
        end
        isPythonMiniforgeInstalled = true;
    end

    % Install PythonOCC on the Python installation provided by Miniforge
    if ~isPythonOCCInstalled
        if isPythonMiniforgeInstalled
            installPythonOCC = sprintf('"%s" install -c conda-forge --override-channels pythonocc-core=%s', condaPath, PythonOCCVer);
            fprintf("%sPythonOCC will be installed at Python executable %s using console command '%s'.%s", newline, pythonPath, installPythonOCC, newline)
            prompt = "Should PythonOCC be installed? (yes/no): ";
            isInstallPythonOCC = approveInstallationProcess(prompt);
            if ~isInstallPythonOCC
                error("Installation of PythonOCC was stopped by the user. Please install PythonOCC manually and then try again")
            end
            system(installPythonOCC);
        else
            error("Miniforge was not successfully installed automatically." + newline + ...
                  "Therefore, PythonOCC cannot be installed using Miniforge." + newline + ...
                  "Please install PythonOCC at your Python installation manually," + newline + ...
                  "and setup the Python environment manually using function pyenv, see:" + newline + ...
                  "https://www.mathworks.com/help/matlab/ref/pyenv.html")
        end
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

function isAction = approveInstallationProcess(prompt)
arguments
    prompt (1, :) {mustBeText}
end
isAction = [];
while isempty(isAction)
    userInput = input(prompt, 's');
    if ismember(lower(userInput), {'yes', 'y'})
        isAction = true;
    elseif ismember(lower(userInput), {'no', 'n'})
        isAction = false;
    else
        fprintf('Invalid input. Please enter "yes" or "no".\n');
    end
end

end

function checksum = sha256file(filename)
    % Read file as bytes
    fid = fopen(filename, 'r');
    if fid == -1
        error('Cannot open file: %s', filename);
    end
    data = fread(fid, Inf, '*uint8');
    fclose(fid);

    % Compute SHA-256 using Java
    md = java.security.MessageDigest.getInstance('SHA-256');
    md.update(data);
    hashBytes = typecast(md.digest, 'uint8');
    checksum = lower(reshape(dec2hex(hashBytes)',1,[]));
end

% Copyright 2025 The MathWorks, Inc.
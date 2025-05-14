# Workshop on Engineering Design Optimization using MATLAB&reg; and Python&trade;

[![View Courseware on Finite Element Methods on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://www.mathworks.com/matlabcentral/fileexchange/125135-courseware-on-finite-element-methods) or [![Open in MATLAB&reg; Online](https://www.mathworks.com/images/responsive/global/open-in-matlab-online.svg)](https://matlab.mathworks.com/open/github/v1?repo=andreas-apostolatos/Engineering-Design-Optimization-using-MATLAB-and-Python&file=Engineering-Design-Optimization-using-MATLAB-and-Python.prj)

## Description ##

This workshop on Engineering Design Optimization using [MATLAB&reg;](https://www.mathworks.com/products/matlab.html) and Python addresses the shape optimization of mechanical components for strength. Python&trade; package PythonOCC [1] (Retrieved from [`https://github.com/tpaviot/pythonocc-core`](https://github.com/tpaviot/pythonocc-core)), which is under the LPGLv3 license, is used to read-in and manipulate geometries, whereas MATLAB&reg; is used for the structural analysis and optimization.

This interactive workshop uses extensively the [MATLAB&reg;](https://www.mathworks.com/products/matlab.html) [Live&reg; Editor](https://de.mathworks.com/products/matlab/live-editor.html), the [Partial Differential Equation Toolbox&trade;](https://de.mathworks.com/products/pde.html), and the [Global Optimization Toolbox&trade;](https://de.mathworks.com/products/global-optimization.html) for the development and the presentation. More specifically, the [Visualize PDE Results Live Task](https://www.mathworks.com/help/pde/ug/visualizepderesults.html) is used for the visualization of the von Mises stresses and the [Optimize Live Task](https://www.mathworks.com/help/matlab/math/optimize-live-editor-matlab.html) is used for the shape optimization for strength.

## Owner/s
Andreas Apostolatos, PhD ([`aapostol@mathworks.com`](mailto:aapostol@mathworks.com))\
María Elena Gavilán Alfonso ([`mgavilan@mathworks.com`](mailto:mgavilan@mathworks.com))

## Contents
The repository contains the following Live Scripts and folders:

- **``Engineering-Design-Optimization-using-MATLAB-and-Python.prj``**\
This is the MATLAB&reg; project file which sets up all necessary dependencies including the installation of PythonOCC

- **``Main.mlx``**\
This is a reference document that can be used to navigate to the rest of the Live Scripts in the repository

- **``main_unitTests.mlx``**\
This is the Live Script that executes the unit tests

- **``Example1.mlx``**\
This example highlights the necessary workflows for importing standard *Computer-Aided Design* (CAD) file formats (e.g. ``IGES``, ``STEP``-files) in MATLAB&reg;

![Solid swingarm geometry](images/Example%201%20Solid%20Swingarm%20Geometry.png)
<p>&nbsp;</p>

- **``Example2.mlx``**\
This example focuses on the use of the [Partial Differential Equation Toolbox&trade;](https://www.mathworks.com/products/pde.html) for the prediction of the mechanical behavior of a motorcycle swingarm under usual loading conditions. Moreover, this example demonstrates how the cost function for strength can be formulated leveraging appropriate *Application Programming Interfaces* (APIs) from the Partial Differential Equation Toolbox. The [Visualize PDE Results Live Task](https://www.mathworks.com/help/pde/ug/visualizepderesults.html) is used for the visualization of the von Mises stresses across the component

<img src="images/Example%202%20von%20Mises%20Stresses.png" alt="von Mises stresses" width="30%">
<p>&nbsp;</p>

- **``Example3.mlx``**\
This example introduces the MATLAB&reg; PythonOCC Interoperability. Using sliders and other interacting elements of the MATLAB&reg; Live Editor, the example demonstrates how the designer can modify the geometry of the motorcycle swingarm by directly calling PythonOCC APIs from within MATLAB&reg;

<img src="images/Example%203%20Geometry%20Modification.gif" alt="MATLAB&reg; Python&trade; Interoperability" width="75%">
<p>&nbsp;</p>

- **``Example4.mlx``**\
In this example, function [``patternsearch``](https://www.mathworks.com/help/gads/patternsearch.html) through the [Optimize Live Task](https://www.mathworks.com/help/matlab/math/optimize-live-editor-matlab.html) is leveraged to perform shape optimization of the motorcycle swingar. A selected sharp edge is filtered and then the optimization is performed for reduction of the strain energy aiming to lower the local stress concentration and increase structural strength of the component

<img src="images/Optimize%20Live%20Task%20(Edge%202).gif" alt="Optimize Live Task" width="100%">
<p>&nbsp;</p>

- **``Example5.mlx``**\
This example summarizes the complete workflow into a comprehensive MATLAB&reg; App using the MATLAB&reg; App Designer.

<img src="images/Optimize%20MATLAB%20App%20(Edge%202).gif" alt="Swingarm Optimization MATLAB&reg App" width="75%">
<p>&nbsp;</p>

## Concepts
Finite element analysis, [MATLAB&reg; Python&trade; interoperability](https://www.mathworks.com/products/matlab/matlab-and-python.html), modeling via *Computer-Aided Design* (CAD), CAD import, programmatic CAD manipulation, shape optimization for strength, motorcycle swingarm, [Visualize PDE Results Live Task](https://www.mathworks.com/help/pde/ug/visualizepderesults.html), [Optimize Live Task](https://www.mathworks.com/help/matlab/math/optimize-live-editor-matlab.html), [MATLAB&reg; App Designer](https://www.mathworks.com/products/matlab/app-designer.html), [unit-testing](https://www.mathworks.com/help/matlab/matlab_prog/ways-to-write-unit-tests.html), [MATLAB&reg; Projects](https://www.mathworks.com/help/matlab/projects.html), [Git-integration](https://www.mathworks.com/help/matlab/matlab_prog/set-up-git-source-control.html)

## Suggested Audience
All engineering disciplines, such as, civil engineers, mechanical engineers, etc.

## Workflow
Firstly, open the project file ``Engineering-Design-Optimization-using-MATLAB-and-Python-R25a.prj`` to have all the folder dependencies resolved and PythonOCC installed. Then, open Live Script **Main.mlx**, go to Section **Quick guide**, select any of the desirable Live Scripts from the list, and hit Run!

## Unit-testing framework
To interactively run the associated unit tests of this MATLAB&reg; Project, the [MATLAB&reg; Test Manager](https://www.mathworks.com/help/matlab-test/ref/matlabtestmanager-app.html) from the Project Tools in the project toolstrip can be leveraged, see the following screenshot:
<img src="images/MATLAB%20Test%20Manager.png" alt="MATLAB&reg; Test Manager" width="75%">
<p>&nbsp;</p>

Alternatively, the unit tests for this courseware can be executed programmatically by using the following commands in the Command Window of MATLAB&reg;\
``>> suite = matlab.unittest.TestSuite.fromProject("Engineering-Design-Optimization-using-MATLAB-and-Python.prj");``\
``>> run(suite)``

## Release last tested
R2024b

## TODO
- Allow user to select where to download the Miniforge executable, which Python installation to be used, and in which Python installation PythonOCC should be installed
- Allow an option to use Anaconda instead of conda-forge (consider using option 'conda-content-trust' to verify the signatures of the packages prior to installation)

## Revision History

## Acknowledgment
The support of Yann Debray regading the MATLAB&reg; Python&trade; interoperability is kindly acknowledged herein

## License
This open-source project is licensed using a [BSD license](https://en.wikipedia.org/wiki/BSD_licenses), see file ``LICENSE.md``

## Support
Reach out to Andreas Apostolatos, PhD ([`aapostol@mathworks.com`](mailto:aapostol@mathworks.com)) for support with this project

## References
[1] Paviot, T. (2022). "pythonocc". Zenodo. [`https://doi.org/10.5281/zenodo.3605364`](https://doi.org/10.5281/zenodo.3605364)
\
\
\
*Copyright 2025 The MathWorks, Inc.*
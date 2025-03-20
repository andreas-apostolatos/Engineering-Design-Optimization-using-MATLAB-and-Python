%[text] %[text:anchor:T_27db] # Exercise 1: Working with CAD Geometries in MATLAB
%[text] **Introduction**
%[text] In this exercise we will import geometry into MATLAB by bringing the CAD files using the [Partial Differential Equation Toolbox](https://www.mathworks.com/products/pde.html)™. This exercise will help you understand some of the differences between different CAD formats, e.g., IGES- and STEP-file formats, to describe three-dimensional free-form geometries:
%[text] - `IGES`-files may only contain the *Boundary Representation* (B-Rep) of a geometry
%[text] - `STEP`-files can also contain information about the volume of a three-dimensional solid \
%[text] **Whenever you see the icon **![Try this icon](text:image:3e19), **this will indicate the specific steps you should take to complete the section of the exercise. **
%%
%[text] %[text:anchor:H_2c06] ## Import and visualize the geometry
%[text] In this section you will import the geometry file using **importGeometry** and plot the result in MATLAB by using a pde model.
%[text] ![Try this icon](text:image:6914) <u>**Check the documentation for the function**</u> **`importGeometry`**
help importGeometry %[output:4385788a]
%%
%[text] ![Try this icon](text:image:4b51) <u>**Change the value of the dropdown list assigned to fileName and report on what you observe**</u>
% Use the drop-down to select a different option
fileName = fullfile(".", "geometry", "swingarm brep.igs"); %[control:dropdown:9f58]{"position":[12,58]}

[~, ~, fileExt] = fileparts(fileName);
if strcmpi(fileExt, ".igs") || strcmpi(fileExt, ".iges") %[output:group:5b96957e]
    disp("An IGES (or IGS)-file is typically used for the Boundary Representation (B-Rep) " + newline + ... %[output:85bb2b50]
        "of a geometry and thus it does not need to contain a volume that is needed for " + newline + ... %[output:85bb2b50]
        "this application. The motorcycle swingarm of this application is a solid " + newline + ... %[output:85bb2b50]
        "deformable part") %[output:85bb2b50]
else
    % gm = importGeometry(fileName);
    pdegplot(gm, EdgeLabels="off", FaceLabels="off", FaceAlpha=.5)
    xlabel("$X$ (m)","Interpreter","latex")
    ylabel("$Y$ (m)","Interpreter","latex")
    zlabel("$Z$ (m)","Interpreter","latex")
    title("Motorcycle Swingarm")
end %[output:group:5b96957e]
%%
%[text] **When you complete Exercise 1:**
%[text] **Continue to **[**Exercise 2**](file:./Exercise2.mlx)** or back to **[**README**](file:./README.mlx)
%[text] 
%[text] *Copyright 2024 The MathWorks, Inc.*

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline","rightPanelPercent":40}
%---
%[text:image:3e19]
%   data: {"align":"baseline","height":26,"src":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAAB4AAAApCAYAAAAiT5m3AAADOElEQVR42r1XSWgUQRSNGndR3Ii7V\/EmCCp4DaIe1Oh4EMHBwMjsq47Eg+OOJ0VIICAeFAIeXEADHgyoqChE1ASNhISAxH0jg5gxq+\/FX1A009PTM93T8OiuX7\/q1f+\/+tevqqoCTyKRWBmNRo8Cj4GPwF++I5HII7zT8Xh8eZWTTzgcnh6Lxc5j8kFgHMgCT4G7wBPgl8j\/YBGnfT7f1LJJg8HgQrGQE3diAXVciK5DIsi3o7+devh+4Pf755dMmslkpmGih0LaiHa1hf5k6J0T\/TYrfdMHKz8pFjTr1kFWD9ltvJ8Bt\/Dt1d0rYeG4Y7ZJMbAG+A300HLKuHkw2SuxKAe8lQ3Gdjv6llLP4\/FMQfs1MMBQ2SUOyaoPihur0X4BDGEDHVGLYbwhawCG6QG6W6yu43jo+uwSt3IyWLlA2vt09+F7CwlDodAaaZ+Q\/j3inZn0GENil\/gd0Ke1rwEjgUBgDqzYIe4lBiBbkkqlZov7r2hjXtLldom\/0LVa+x7QK9+NGjHduUvkfcAdbUwb0G+XuNtg8WV6QeLXbCDeKzo9QJM2phPosEt8ExijG9nG5NuKJK6VTTeXrofudbvEh2TS49r\/eakQMeQXNV2v9Nfbzc9c8U\/GWv2LKkmYEat+r9c7Q+L9nZvOdhLBhOF86c+MWJ5JkLVIX6jUdM1Jbsgk3NU1RRBPHCzQ2crxZR0U3CBC8saKGO3NCNNGx85kpk4QPLfaXJr8jGPkKs4FfqesJv9kcP1OvFeXa70Z8Ygmz1KWTCYX4fuDqlAQhnUVIWafQfesXjjgF5zlCrGWSBQuyOm1nuEARqGTqRgxKxejrm1iYL+URKPFEktJrGSDpRJ3aYlGYRhFwjK8T+lyle+1yrUsYjMM5ZG9l0tBzk3iYvGfWE6XVWYniyvEci1RgjEpZwP6Itwi7jfppHy31Mz3HSeGNZvw8aOAUs5h0olUqqqPFVIhjlcI34wXsMMuWWhEb76ibwPw1U1ibmCzwm+tdil3HEyfhcrdBhetbrW6pHe5RNxiVeTXukTcVEyevupCjA9YEqfT6XlyGXOKuINnQ1GnEy9y6uJeBuFn3qXxxyzmnP8Amz0wy7TM4YgAAAAASUVORK5CYII=","width":19}
%---
%[text:image:6914]
%   data: {"align":"baseline","height":26,"src":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAAB4AAAApCAYAAAAiT5m3AAADOElEQVR42r1XSWgUQRSNGndR3Ii7V\/EmCCp4DaIe1Oh4EMHBwMjsq47Eg+OOJ0VIICAeFAIeXEADHgyoqChE1ASNhISAxH0jg5gxq+\/FX1A009PTM93T8OiuX7\/q1f+\/+tevqqoCTyKRWBmNRo8Cj4GPwF++I5HII7zT8Xh8eZWTTzgcnh6Lxc5j8kFgHMgCT4G7wBPgl8j\/YBGnfT7f1LJJg8HgQrGQE3diAXVciK5DIsi3o7+devh+4Pf755dMmslkpmGih0LaiHa1hf5k6J0T\/TYrfdMHKz8pFjTr1kFWD9ltvJ8Bt\/Dt1d0rYeG4Y7ZJMbAG+A300HLKuHkw2SuxKAe8lQ3Gdjv6llLP4\/FMQfs1MMBQ2SUOyaoPihur0X4BDGEDHVGLYbwhawCG6QG6W6yu43jo+uwSt3IyWLlA2vt09+F7CwlDodAaaZ+Q\/j3inZn0GENil\/gd0Ke1rwEjgUBgDqzYIe4lBiBbkkqlZov7r2hjXtLldom\/0LVa+x7QK9+NGjHduUvkfcAdbUwb0G+XuNtg8WV6QeLXbCDeKzo9QJM2phPosEt8ExijG9nG5NuKJK6VTTeXrofudbvEh2TS49r\/eakQMeQXNV2v9Nfbzc9c8U\/GWv2LKkmYEat+r9c7Q+L9nZvOdhLBhOF86c+MWJ5JkLVIX6jUdM1Jbsgk3NU1RRBPHCzQ2crxZR0U3CBC8saKGO3NCNNGx85kpk4QPLfaXJr8jGPkKs4FfqesJv9kcP1OvFeXa70Z8Ygmz1KWTCYX4fuDqlAQhnUVIWafQfesXjjgF5zlCrGWSBQuyOm1nuEARqGTqRgxKxejrm1iYL+URKPFEktJrGSDpRJ3aYlGYRhFwjK8T+lyle+1yrUsYjMM5ZG9l0tBzk3iYvGfWE6XVWYniyvEci1RgjEpZwP6Itwi7jfppHy31Mz3HSeGNZvw8aOAUs5h0olUqqqPFVIhjlcI34wXsMMuWWhEb76ibwPw1U1ibmCzwm+tdil3HEyfhcrdBhetbrW6pHe5RNxiVeTXukTcVEyevupCjA9YEqfT6XlyGXOKuINnQ1GnEy9y6uJeBuFn3qXxxyzmnP8Amz0wy7TM4YgAAAAASUVORK5CYII=","width":19}
%---
%[text:image:4b51]
%   data: {"align":"baseline","height":26,"src":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAAB4AAAApCAYAAAAiT5m3AAADOElEQVR42r1XSWgUQRSNGndR3Ii7V\/EmCCp4DaIe1Oh4EMHBwMjsq47Eg+OOJ0VIICAeFAIeXEADHgyoqChE1ASNhISAxH0jg5gxq+\/FX1A009PTM93T8OiuX7\/q1f+\/+tevqqoCTyKRWBmNRo8Cj4GPwF++I5HII7zT8Xh8eZWTTzgcnh6Lxc5j8kFgHMgCT4G7wBPgl8j\/YBGnfT7f1LJJg8HgQrGQE3diAXVciK5DIsi3o7+devh+4Pf755dMmslkpmGih0LaiHa1hf5k6J0T\/TYrfdMHKz8pFjTr1kFWD9ltvJ8Bt\/Dt1d0rYeG4Y7ZJMbAG+A300HLKuHkw2SuxKAe8lQ3Gdjv6llLP4\/FMQfs1MMBQ2SUOyaoPihur0X4BDGEDHVGLYbwhawCG6QG6W6yu43jo+uwSt3IyWLlA2vt09+F7CwlDodAaaZ+Q\/j3inZn0GENil\/gd0Ke1rwEjgUBgDqzYIe4lBiBbkkqlZov7r2hjXtLldom\/0LVa+x7QK9+NGjHduUvkfcAdbUwb0G+XuNtg8WV6QeLXbCDeKzo9QJM2phPosEt8ExijG9nG5NuKJK6VTTeXrofudbvEh2TS49r\/eakQMeQXNV2v9Nfbzc9c8U\/GWv2LKkmYEat+r9c7Q+L9nZvOdhLBhOF86c+MWJ5JkLVIX6jUdM1Jbsgk3NU1RRBPHCzQ2crxZR0U3CBC8saKGO3NCNNGx85kpk4QPLfaXJr8jGPkKs4FfqesJv9kcP1OvFeXa70Z8Ygmz1KWTCYX4fuDqlAQhnUVIWafQfesXjjgF5zlCrGWSBQuyOm1nuEARqGTqRgxKxejrm1iYL+URKPFEktJrGSDpRJ3aYlGYRhFwjK8T+lyle+1yrUsYjMM5ZG9l0tBzk3iYvGfWE6XVWYniyvEci1RgjEpZwP6Itwi7jfppHy31Mz3HSeGNZvw8aOAUs5h0olUqqqPFVIhjlcI34wXsMMuWWhEb76ibwPw1U1ibmCzwm+tdil3HEyfhcrdBhetbrW6pHe5RNxiVeTXukTcVEyevupCjA9YEqfT6XlyGXOKuINnQ1GnEy9y6uJeBuFn3qXxxyzmnP8Amz0wy7TM4YgAAAAASUVORK5CYII=","width":19}
%---
%[control:dropdown:9f58]
%   data: {"defaultValue":"fullfile(\".\", \"geometry\", \"swingarm brep.igs\")","itemLabels":["B-Rep","Solid"],"items":["fullfile(\".\", \"geometry\", \"swingarm brep.igs\")","fullfile(\".\", \"geometry\", \"swingarm solid.step\")"],"label":"fileName","run":"Section"}
%---
%[output:4385788a]
%   data: {"dataType":"text","outputData":{"text":" <strong>importGeometry<\/strong> - Import geometry from STL or STEP file\n    This MATLAB function creates a geometry object from the specified STL or\n    STEP geometry file.\n\n    Syntax\n      gm = <strong>importGeometry<\/strong>(geometryfile)\n\n      gm = <strong>importGeometry<\/strong>(model,geometryfile)\n\n      <strong>importGeometry<\/strong>(model,___)\n      ___ = <strong>importGeometry<\/strong>(___,Name=Value)\n\n    Input Arguments\n      <a href=\"matlab:web('C:\\Program Files\\MATLAB\\R2025a\\help\/pde\/ug\/pde.pdemodel.importgeometry.html#bulkov_-1_sep_mw_c7b473f3-2ae0-476d-9c3e-96311b90ed6f')\">model<\/a> - Model container\n        PDEModel object\n      <a href=\"matlab:web('C:\\Program Files\\MATLAB\\R2025a\\help\/pde\/ug\/pde.pdemodel.importgeometry.html#bulkov_-1-geometryfile')\">geometryfile<\/a> - Path to STL or STEP file\n        string scalar | character vector\n\n    Name-Value Arguments\n      <a href=\"matlab:web('C:\\Program Files\\MATLAB\\R2025a\\help\/pde\/ug\/pde.pdemodel.importgeometry.html#mw_69ed8777-6689-44b8-9ad2-1c75a2917d81')\">AllowSelfIntersections<\/a> - Indicator to allow import of self-intersecting geometry from STL or STEP file\n        true or 1 (default) | falseor 0\n      <a href=\"matlab:web('C:\\Program Files\\MATLAB\\R2025a\\help\/pde\/ug\/pde.pdemodel.importgeometry.html#mw_2a05354b-0028-41f6-8f35-cfba48513530')\">FeatureAngle<\/a> - Threshold for dihedral angle between adjacent triangles to indicate edge between separate faces\n        44 (default) | number between 10 and 90\n      <a href=\"matlab:web('C:\\Program Files\\MATLAB\\R2025a\\help\/pde\/ug\/pde.pdemodel.importgeometry.html#mw_fc10baab-78b8-4945-ab02-c98a7f46d24f')\">MaxRelativeDeviation<\/a> - Relative sag\n        1 (default) | number in the range [0.1, 10]\n\n    Output Arguments\n      <a href=\"matlab:web('C:\\Program Files\\MATLAB\\R2025a\\help\/pde\/ug\/pde.pdemodel.importgeometry.html#bulkov_-1-gd')\">gm<\/a> - Geometry\n        DiscreteGeometry object\n\n    Examples\n      <a href=\"matlab:openExample('pde\/ImportGeometryIntoPDEContainerExample')\">Import 3-D Geometry from STL File Without Creating Model<\/a>\n      <a href=\"matlab:openExample('pde\/ImportPlanarGeometryIntoPDEContainerExample')\">Import Planar Geometry from STL File into Model<\/a>\n      <a href=\"matlab:openExample('pde\/Import3DGeometryFromSTEPFileExample')\">Import 3-D Geometry from STEP File<\/a>\n\n    See also <a href=\"matlab:help geometryFromMesh -displayBanner\">geometryFromMesh<\/a>, <a href=\"matlab:help pdegplot -displayBanner\">pdegplot<\/a>, <a href=\"matlab:help pde.DiscreteGeometry -displayBanner\">DiscreteGeometry<\/a>, <a href=\"matlab:help pde.PDEModel -displayBanner\">PDEModel<\/a>\n\n    Introduced in Partial Differential Equation Toolbox in R2015a\n    <a href=\"matlab:doc importGeometry\">Documentation for importGeometry<\/a>\n\n","truncated":false}}
%---
%[output:85bb2b50]
%   data: {"dataType":"text","outputData":{"text":"An IGES (or IGS)-file is typically used for the Boundary Representation (B-Rep) \nof a geometry and thus it does not need to contain a volume that is needed for \nthis application. The motorcycle swingarm of this application is a solid \ndeformable part\n","truncated":false}}
%---

function checkProblemDimensions(femMatrices,dispVct)
%CHECKPROBLEMDIMENSIONS Verification whether the stiffness matrix and the 
% displacement vector have the same dimensions
if size(femMatrices.K) ~= size(dispVct)
    error("Size mismatch for the stiffness matrix and the displacement vector. " + ...
        "Please rerun Code Section '3.) Set Material Properties, Apply Boundary " + ...
        "Conditions and Solve the Structural Problem' ")
end
end
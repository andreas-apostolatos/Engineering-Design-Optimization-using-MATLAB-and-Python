function displaySelection(edgeID)
%DISPLAYSELECTION It displays the selected edge
switch edgeID
    case 34
        edge = 1;
    case 11
        edge = 2;
    case 3
        edge = 3;
    otherwise
        error("Edge ID %i does not correspond to any of the three edges", EdgeID)
end
    disp("Selected edge " + edge)
end
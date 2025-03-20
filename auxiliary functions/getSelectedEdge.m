function edge = getSelectedEdge(shape, noCrv)
    explEdges = py.OCC.Core.TopExp.TopExp_Explorer(shape, py.OCC.Core.TopAbs.TopAbs_EDGE);
    explEdges.ReInit()
    cntEdge = 1;
    edge = py.None;
    while explEdges.More()
        if cntEdge == noCrv
            edge = explEdges.Current;
            break
        end
        cntEdge = cntEdge + 1;
        explEdges.Next()
    end
    if isequal(edge, py.None)
        error("Curve with ID %d was not found in the curve explorer", noCrv)
    end
end
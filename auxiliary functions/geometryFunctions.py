# getDesignVariables.py
# Authors : 

# import numpy as np
import os
import warnings
from OCC.Core.STEPControl import STEPControl_Reader
from OCC.Core.IGESControl import IGESControl_Reader
from OCC.Core.TopExp import TopExp_Explorer
from OCC.Core.TopAbs import TopAbs_COMPOUND, TopAbs_SOLID, TopAbs_FACE, TopAbs_EDGE, TopAbs_VERTEX, TopAbs_WIRE
from OCC.Core.TopoDS import topods, topods_Face, TopoDS_Compound
from OCC.Core.BRepCheck import BRepCheck_Analyzer
from OCC.Core.BRepBuilderAPI import BRepBuilderAPI_Copy, BRepBuilderAPI_Sewing
from OCC.Core.ShapeFix import ShapeFix_Shape, ShapeFix_Face
from OCC.Core.BRepBuilderAPI import BRepBuilderAPI_MakeWire, BRepBuilderAPI_MakeSolid
from OCC.Core.GProp import GProp_GProps
from OCC.Core.BRepGProp import brepgprop
from OCC.Core.BRep import BRep_Tool, BRep_Builder
from OCC.Core.gp import gp_Pnt, gp_Vec
from OCC.Core.BRepAdaptor import BRepAdaptor_Curve, BRepAdaptor_Surface
from OCC.Core.GeomAbs import GeomAbs_BSplineSurface
from OCC.Core.GeomAPI import GeomAPI_ProjectPointOnCurve, GeomAPI_ProjectPointOnSurf
from OCC.Core.GCPnts import GCPnts_AbscissaPoint, GCPnts_UniformAbscissa
from OCC.Core.TColgp import TColgp_Array1OfPnt
from OCC.Core.GeomLProp import GeomLProp_SLProps
from OCC.Core import ShapeAnalysis
from OCC.Core.Geom2d import Geom2d_TrimmedCurve
from OCC.Core import Geom2dConvert
from OCC.Core.STEPControl import STEPControl_Writer, STEPControl_ManifoldSolidBrep
from OCC.Core.IGESControl import IGESControl_Writer
from OCC.Core.BRepBuilderAPI import BRepBuilderAPI_NurbsConvert, BRepBuilderAPI_MakeEdge, BRepBuilderAPI_MakeFace
from OCC.Core.IFSelect import IFSelect_RetDone
from OCC.Display.SimpleGui import *
from OCC.Display.backend import *
from OCC.Core.AIS import AIS_InteractiveObject
from math import sqrt
import numpy as np
# import wx

from OCC.Core.BRepExtrema import BRepExtrema_DistShapeShape

class MyApp:
    def __init__(self):
        self.baseShape = None
        self.updatedShape = None
        self.nurbsShape = None
        self.selectedFaces = []
        self.selectedEdges = []
        self.selectedVertices = []
        self.pointCoords = None
        self.facesAndNormalsPerEdge = None
        self.tol = 1e-6
        self.numDesignVariables = None
        self.normalConstraint = True
        self.groupConstraint = True
        self.verbose = 0

    def initializeGUI(self):
        self.display, self.start_display, self.add_menu, self.add_function_to_menu = init_display('wx')

        # Create the "File" menu
        self.add_menu('File')
        # self.add_function_to_menu('File', self.New)
        self.add_function_to_menu('File', self.Clean)
        self.add_function_to_menu('File', self.Exit)

        # Create the "Selection" menu
        self.add_menu('Selection')
        self.add_function_to_menu('Selection', self.Edge)
        self.add_function_to_menu('Selection', self.Face)
        self.add_function_to_menu('Selection', self.Vertex)
        self.add_function_to_menu('Selection', self.Neutral)

        if not os.path.exists('metadata'):
            os.makedirs('metadata')

        self.display._select_callbacks.append(self.onSelect)

    def Clean(self, event=None):
        self.display.EraseAll()
    
    def Exit(self, event=None):
        self.getDataDesignVariables(self.verbose)
        # wx.GetTopLevelWindows()[0].Close()
    
    def Neutral(self, event=None):
        self.display.SetSelectionModeNeutral()
    
    def Edge(self, event=None):
        self.display.SetSelectionModeEdge()
    
    def Face(self, event=None):
        self.display.SetSelectionModeFace()
    
    def Vertex(self, event=None):
        self.display.SetSelectionModeVertex()
    
    def onSelect(self, selectedShape, x, y):
        for shape in selectedShape:
            if shape.ShapeType() == TopAbs_FACE:
                face = topods.Face(shape)
                self.selectedFaces.append(face)
            elif shape.ShapeType() == TopAbs_EDGE:
                edge = topods.Edge(shape)
                self.selectedEdges.append(edge)
            elif shape.ShapeType() == TopAbs_VERTEX:
                vertex = topods.Vertex(shape)
                self.selectedVertices.append(vertex)
            # else:
                # raise ValueError("Selected shape is neither a face, an edge, nor a vertex")
    
    def displayShape(self, baseShape):

        if self.nurbsShape is not None:
            self.display.DisplayShape(self.nurbsShape, update=True)
        else:
            raise ValueError("The base shape has not yet been converted to NURBS")
    
    # def openFileDialog(self, event=None):
        # with wx.FileDialog(None, "Open IGES or STEP file",
        #                    wildcard="IGES files (*.iges;*.igs)|*.iges;*.igs|STEP files (*.step;*.stp)|*.step;*.stp",
        #                    style=wx.FD_OPEN | wx.FD_FILE_MUST_EXIST) as fileDialog:
        #     if fileDialog.ShowModal() == wx.ID_CANCEL:
        #         return None
        #     return fileDialog.GetPath()
    
    # def New(self, event=None):
        # filePath = self.openFileDialog()
        # if filePath is None:
        #     wx.MessageBox("No file selected.", "Error", wx.OK | wx.ICON_ERROR)
        #     return
        # else:
        #     self.baseShape = readGeometryFile(filePath)
        #     self.convertBaseShapeToNURBS()
        #     copier = BRepBuilderAPI_Copy(self.baseShape)
        #     self.displayShape(copier.Shape())
        #     if self.baseShape is None:
        #         wx.MessageBox("Invalid geometry file.", "Error", wx.OK | wx.ICON_ERROR)

    def readGeometryFile(self, filePath):
        self.baseShape = readGeometryFile(filePath)
    
    def convertBaseShapeToNURBS(self):
        nurbsConverter = BRepBuilderAPI_NurbsConvert(self.baseShape, True);
        self.nurbsShape = nurbsConverter.Shape();

    def getDataDesignVariables(self, verbose):
        """
        Creates the matrix self.pointCoords containing the following
        information per Control Point associated with design variables:
        [faceID, groupID, ξ-face index, η-face index, coincidenceID, X, Y, Z, nX, nY, nZ]

        Args:
        self (MyApp): Object of the class MyApp
    
        Example:
            >>> my_app_instance.getDataDesignVariables()
        """

        # Log information in the console
        if verbose:
            print(f" Selected {len(self.selectedFaces)} faces, {len(self.selectedEdges)} edges, and {len(self.selectedVertices)} vertices.")

        # Initialize output
        self.pointCoords = []

        if self.baseShape is not None:
            # Check input
            if self.baseShape.ShapeType() != TopAbs_COMPOUND and self.baseShape.ShapeType() != TopAbs_FACE:
                raise ValueError("The underlying shape is neither a compound, nor a face")

            # Get the face explorer containing all faces of the compound geometry
            if self.nurbsShape is None:
                self.convertBaseShapeToNURBS()
            topExplFaces = TopExp_Explorer(self.nurbsShape, TopAbs_FACE);
            
            # Initiaze point map ID to identify points that share the same coordinates in three-dimensional space
            point_id_map = {}
            current_id = 0

            # Initialize surface counter
            cntSurface = int(1)

            # Loop over all the faces in the compound
            while topExplFaces.More():
                # Convert the current surface into a TopoDS_Face object
                topoFace = topods.Face(topExplFaces.Current())

                # Convert the TopoDS_Face object to a Geom_BSplineSurface object
                bRepAdaptorSurf = BRepAdaptor_Surface(topoFace, True);

                # Verify whether the object type is a GeomAbs_BSplineSurface type
                if bRepAdaptorSurf.GetType() != int(GeomAbs_BSplineSurface):
                    raise ValueError("The face was not converted to a GeomAbs_BSplineSurface")
                geomBSplineSurf = bRepAdaptorSurf.BSpline();

                # Get all control points of the TopoDS_Face
                controlPointsSurf = geomBSplineSurf.Poles();
                if not controlPointsSurf:
                    raise ValueError("The face appears having no Control Points")

                # Get the number of Control Points along the ξ- and η- directions
                numCPsXi = geomBSplineSurf.NbUPoles()
                numCPsEta = geomBSplineSurf.NbVPoles()

                # Loop over all the Control Points of the TopoDS_Face and check whether these define the desirable design variables
                for ii in range(1, numCPsXi + int(1)):
                    for jj in range(1, numCPsEta + int(1)):
                        cp = controlPointsSurf.Value(ii, jj)

                        # initialize the curve counter
                        cntCurve = int(1)

                        # Loop over all the selected curves
                        for curve in self.selectedEdges:
                            # Verify that the selected object is an edge
                            if curve.ShapeType() == TopAbs_EDGE:
                                geomCurve, first, last = BRep_Tool.Curve(curve)
                            else:
                                raise ValueError("Selected object is not an edge")

                            # create a projector object
                            curveProjector = GeomAPI_ProjectPointOnCurve(cp, geomCurve)

                            # check whether the projection was successful
                            if curveProjector.NbPoints() > 0:
                                # Get the distance to the closest point on the curve
                                distance = curveProjector.LowerDistance()

                                # Check if the distance is smaller than the selected tolerance and record the control point data
                                if distance <= self.tol:
                                    # Create a tuple of the point's coordinates
                                    point_coords = (cp.X(), cp.Y(), cp.Z())

                                    # Check whether this point is close to any existing point in the map
                                    found_id = None
                                    for existing_coords, existing_id in point_id_map.items():
                                        if euclidean_distance(point_coords, existing_coords) <= self.tol:
                                            found_id = existing_id
                                            break

                                    # If no close point is found, assign a new ID
                                    if found_id is None:
                                        found_id = current_id
                                        point_id_map[point_coords] = current_id
                                        current_id += 1

                                    # Project the point on the face
                                    surfaceProjector = GeomAPI_ProjectPointOnSurf(cp, geomBSplineSurf)

                                    # Check whether the curve is on the surface
                                    numPts = 10
                                    IsCurSur = isCurveOnSurface(geomCurve, first, last, geomBSplineSurf, numPts, self.tol)

                                    # Check if projection succeeds
                                    if surfaceProjector.NbPoints() > 0:
                                        # Get the parameters (ξ, η) on the surface
                                        xi, eta = surfaceProjector.LowerDistanceParameters()

                                        # Get the coordinates of the closest point
                                        pntProj = surfaceProjector.NearestPoint()

                                        # Get the surface normal of the current face at this location
                                        if IsCurSur:
                                            props = GeomLProp_SLProps(geomBSplineSurf, xi, eta, 1, self.tol)
                                            faceNormal = props.Normal()
                                            faceNormalX = faceNormal.X()
                                            faceNormalY = faceNormal.Y()
                                            faceNormalZ = faceNormal.Z()
                                        else:
                                            faceNormalX = float('nan')
                                            faceNormalY = float('nan')
                                            faceNormalZ = float('nan')

                                        # Append the surface id, ii, jj, and unique ID to the matrix
                                        self.pointCoords.append([cntSurface, cntCurve, ii, jj, found_id, cp.X(), cp.Y(), cp.Z(), faceNormalX, faceNormalY, faceNormalZ])
                            
                            # Update the selected curves counter
                            cntCurve += int(1)

                topExplFaces.Next()
                cntSurface += int(1)

            # Average the normal vectors based on the control point association
            self.averageNormalVectors()


    def getNormalsOnFacesAdjacentToSelectedEdges(self, shape):
        # Check input
        if shape.ShapeType() != TopAbs_COMPOUND and shape.ShapeType() != TopAbs_FACE and shape.ShapeType() != TopAbs_SOLID:
            raise ValueError("Provided shape is neither a TopAbsCompound, a TopAbs_Shell, nor a TopAbs_Solid")
        if not self.pointCoords:
            raise ValueError("Array myApp.pointCoords should be first computed using function myApp.getDataDesignVariables before calling function myApp.getNormalsOnFacesAdjacentToSelectedEdges")

        # Initialize output
        normalsOnFacesAdjacentToSelectedEdges = []

        # The following lines of code have the code crash
        # nurbsConverter = BRepBuilderAPI_NurbsConvert(shape, True);
        # nurbsShape = nurbsConverter.Shape();

        # Get all objects in the shape that are of type TopAbs_FACE
        topExplFaces = TopExp_Explorer(shape, TopAbs_FACE);

        # Loop over all the faces in the shape
        cntFace = int(1)
        while topExplFaces.More():
            # Check whether there are design variables on that face
            designVars = [designVar for designVar in self.pointCoords if designVar[0] == cntFace]

            # Check whether control points acting as design variables are found and if yes proceed
            if designVars:
                # Get the current TopAbs_Face
                topoFace = topods.Face(topExplFaces.Current())

                # Convert the TopoDS_Face object to a Geom_BSplineSurface object
                bRepAdaptorSurf = BRepAdaptor_Surface(topoFace, True);

                # Verify whether the object type is a GeomAbs_BSplineSurface type
                if bRepAdaptorSurf.GetType() != int(GeomAbs_BSplineSurface):
                    raise ValueError("The face was not converted to a GeomAbs_BSplineSurface")
                geomBSplineSurf = bRepAdaptorSurf.BSpline();

                # Get all control points of the TopoDS_Face
                controlPointsSurf = geomBSplineSurf.Poles();
                if not controlPointsSurf:
                    raise ValueError("The face appears having no Control Points")

                # Loop over all control points belonging to that surface
                for designVar in designVars:
                    # Get the coordinates of the Control Point
                    cp = controlPointsSurf.Value(designVar[2], designVar[3])

                    # Project the control point the face
                    surfaceProjector = GeomAPI_ProjectPointOnSurf(cp, geomBSplineSurf)

                    # Get the coordinates of the averaged normal vector
                    coordsAverNormalVct = [self.pointCoords[8], self.pointCoords[9], self.pointCoords[10]]

                    # Check if projection succeeds
                    if surfaceProjector.NbPoints() > 0 and all(not is_nan(coord) for coord in coordsAverNormalVct):
                        # Get the parameters (ξ, η) on the surface
                        xi, eta = surfaceProjector.LowerDistanceParameters()

                        # Get the coordinates of the closest point
                        pntProj = surfaceProjector.NearestPoint()

                        # Get the surface normal of the current face at this location
                        props = GeomLProp_SLProps(geomBSplineSurf, xi, eta, 1, self.tol)
                        faceNormal = props.Normal()
                        faceNormalX = faceNormal.X()
                        faceNormalY = faceNormal.Y()
                        faceNormalZ = faceNormal.Z()
                        normalsOnFacesAdjacentToSelectedEdges.append([cntFace, designVar[1], designVar[2], designVar[3], designVar[4], faceNormalX, faceNormalY, faceNormalZ])
                    else:
                        warnings.warn("Control Point ({designVar[2]}, {designVar[3]}) with coordinates ({designVar[5]}, {designVar[6]}, {designVar[7]}) could not be projected on its surface with id {cntFace}", UserWarning)
                        normalsOnFacesAdjacentToSelectedEdges.append([cntFace, designVar[1], designVar[2], designVar[3], designVar[4], float('nan'), float('nan'), float('nan')])

            # Proceed to the next TopAbs_Face
            topExplFaces.Next()
            cntFace += int(1)

        return normalsOnFacesAdjacentToSelectedEdges


    def averageNormalVectors(self):
        """
        Averages the normal vectors provided for each control point based 
        on the geometric entity group they belong to. It uses the property 
        self.pointCoords for this purpose which already contains the 
        information of the normal vectors per geometric entity group
    
        Args:
        self (MyApp): Object of the class MyApp
    
        Example:
            >>> my_app_instance.averageNormalVectors()
        """
        # Check input
        if self.pointCoords == []:
            warnings.warn("No design variables selected.", UserWarning)
        
        # Extract unique association numbers, excluding NaN
        unique_assoc = set(row[4] for row in self.pointCoords if not is_nan(row[4]))
    
        for assoc in unique_assoc:
            # Find indices of rows with the same association number
            indices = [i for i, row in enumerate(self.pointCoords) if row[4] == assoc]
            
            # Collect valid normals
            valid_normals = []
            for idx in indices:
                normal = self.pointCoords[idx][-3:]
                if not any(is_nan(value) for value in normal):
                    valid_normals.append(normal)
            
            # If there are valid normals, compute the average
            if valid_normals:
                avg_normal = [sum(x) / len(valid_normals) for x in zip(*valid_normals)]
                
                # Update the normals for all rows with this association number
                for idx in indices:
                    if not any(is_nan(value) for value in self.pointCoords[idx][-3:]):
                        self.pointCoords[idx][-3:] = avg_normal

        # Group data by the fifth column
        groups = {}
        for row in self.pointCoords:
            group_id = row[4]
            if group_id not in groups:
                groups[group_id] = []
            groups[group_id].append(row)
        
        # Process each group, compute the averaged normal vector and assign the values in the point coordinate array
        for group_id, rows in groups.items():
            # Collect non-NaN normal vectors
            normals = [row[8:11] for row in rows if not (is_nan(row[8]) or is_nan(row[9]) or is_nan(row[10]))]
        
            # Calculate the average of the normal vectors
            if not normals:
                raise ValueError(f"Group {group_id} does not contain any non-NaN normal vectors.")
            
            # Compute the average of the normal vectors for the given group
            avg_normals = [sum(coords) / len(normals) for coords in zip(*normals)]
                
            # Replace the normal vectors in each row of the group with the average
            for row in rows:
                if is_nan(row[8]):
                    row[8:11] = avg_normals


    def updateShape(self, d):
        """
        Updates the shape using a given displacement field
    
        Args:
        self (MyApp): Object of the class MyApp
        d (Python array): Displacement vector

        Returns:
           Updates the geometry using the provided displacement vector and stores the result in self.updatedShape
    
        Example:
            >>> my_app_instance.updateShape(py.list([1; 2; ...]))
        """
        # Check input
        if self.baseShape is None:
            raise ValueError("Cannot update the shape because the base shape is None")
        if self.nurbsShape is None:
            self.convertBaseShapeToNURBS()
        if self.pointCoords == []:
            warnings.warn("No design variables selected.", UserWarning)

        # Check compatibility of design variables
        if self.numDesignVariables is None:
            raise ValueError("The number of design variables has not been yet computed")

        # Check the input vector
        if not isinstance(d, list):
            raise ValueError("Input array 'd' must be a Python list")
        else:
            if not all(isinstance(x, (int, float)) for x in d):
                raise ValueError("Input array 'd' must contain numeric values")
            else:
                if len(d) != self.numDesignVariables:
                    raise ValueError(f"Input array 'd' must contain '{self.numDesignVariables}' numeric values")

        # Initialize a TopoDS_Compound
        self.updatedShape = TopoDS_Compound();
        compoundBuilderMod = BRep_Builder();
        compoundBuilderMod.MakeCompound(self.updatedShape);

        # Get the face explorer containing all faces of the compound geometry
        topExplFaces = TopExp_Explorer(self.nurbsShape, TopAbs_FACE);
            
        # Initialize surface counter
        cntSurface = int(0)

        # Loop over all the faces in the compound
        while topExplFaces.More():
            # Convert the current surface into a TopoDS_Face object
            topoFace = topods.Face(topExplFaces.Current())

            # Update the face and the counter of the faces
            topExplFaces.Next()
            cntSurface += int(1)

            # Check if the surface contains Control Points that need to be modified
            idsRows = [row[0] == cntSurface for row in self.pointCoords]
            if any(element for element in idsRows):
                # Convert the TopoDS_Face object to a Geom_BSplineSurface object
                bRepAdaptorSurf = BRepAdaptor_Surface(topoFace, True);

                # Get the object type
                surfaceType = bRepAdaptorSurf.GetType();

                # Verify whether the object type is a GeomAbs_BSplineSurface type
                if surfaceType != int(GeomAbs_BSplineSurface):
                    raise ValueError("The face was not converted to a GeomAbs_BSplineSurface")
                geomBSplineSurf = bRepAdaptorSurf.BSpline();

                # Get all control points of the TopoDS_Face
                controlPointsSurf = geomBSplineSurf.Poles();
                if not controlPointsSurf:
                    raise ValueError("The face appears having no Control Points")

                # Get the number of Control Points along the ξ- and η- directions
                numCPsXi = geomBSplineSurf.NbUPoles()
                numCPsEta = geomBSplineSurf.NbVPoles()

                # Create a dictionary to track design variables for each group id
                groupDesignVars = {}
                usedDesignVars = 0

                # Use the mask to filter the rows
                rows = [row for i, row in enumerate(self.pointCoords) if idsRows[i]]

                # Loop over all the control points in the array
                for row in rows:
                    groupId = row[1]
                    coincidenceId = row[4]
                    groupKey = (groupId, coincidenceId)

                    if self.groupConstraint:
                        if groupId not in groupDesignVars:
                            if self.normalConstraint:
                                groupDesignVars[groupId] = d[usedDesignVars]
                                usedDesignVars += 1
                            else:
                                groupDesignVars[groupId] = d[usedDesignVars:usedDesignVars + 3]
                                usedDesignVars += 3
                    else:
                        if groupKey not in groupDesignVars:
                            if self.normalConstraint:
                                groupDesignVars[groupKey] = d[usedDesignVars]
                                usedDesignVars += 1
                            else:
                                groupDesignVars[groupKey] = d[usedDesignVars:usedDesignVars + 3]
                                usedDesignVars += 3

                    if self.normalConstraint:
                        lambdaVal = groupDesignVars[groupId if self.groupConstraint else groupKey]
                        normalVct = row[8:11]  # Assuming these are the normal vector indices
                        disp = [lambdaVal * n for n in normalVct]
                    else:
                        disp = groupDesignVars[groupId if self.groupConstraint else groupKey]

                    # Get the initial coordinates of the Control Points
                    initialCoords = row[5:8]

                    # Update the control point coordinates using the provided design variables
                    updatedCoords = [initialCoords[j] + disp[j] for j in range(3)]

                    # Update the control point coordinates
                    geomBSplineSurf.SetPole(int(row[2]), int(row[3]), gp_Pnt(*updatedCoords))

                    # Get the outer wire of the current TopoDS_Face
                    outerWire = ShapeAnalysis.shapeanalysis.OuterWire(topoFace);

                    # Initialize the Explorer for all Wires in the TopoDS_Face
                    faceWireExplorer = TopExp_Explorer(topoFace, TopAbs_WIRE)
                    
                    # Projection failed
                    isSuccessful = True
                    
                    # Loop over all wires in the TopoDS_Face
                    while faceWireExplorer.More():
                        # Get the current wire in the TopoDS_Face
                        currentFaceWire = faceWireExplorer.Current()
                    
                        # Check whether the current wire is the outer wire
                        isInner = True
                        if currentFaceWire.IsEqual(outerWire):
                            isInner = False
                    
                        # Initialize the wire builder to reconstruct the wires for the modified surface
                        wireBuilder = BRepBuilderAPI_MakeWire()
                    
                        # Initialize the edge explorer for the current wire
                        edgeWireExplorer = TopExp_Explorer(currentFaceWire, TopAbs_EDGE)
                    
                        # Loop over all the edges in the current wire
                        while edgeWireExplorer.More():
                            # Get the current edge in the current wire
                            currentEdgeWire = edgeWireExplorer.Current()
                    
                            # Attempt to project the current edge onto the current TopoDS_Face object
                            # curve2d, rangeStart, rangeEnd = BRep_Tool.CurveOnSurface(currentEdgeWire, topoFace)
                            try:
                                curve2d, rangeStart, rangeEnd = BRep_Tool.CurveOnSurface(currentEdgeWire, topoFace)
                            except ValueError as e:
                                warnings.warn(f"Projecting the updated wire when modifying Control Point with index pair ({row[2]}, {row[3]}) of face {row[0]} failed with error message {e}")
                                isSuccessful = False
                                break
                    
                            # Create a trimmed trimming curve using the parameters from the projection of the curve onto the TopoDS_Face object
                            trimmedCurve2d = Geom2d_TrimmedCurve(curve2d, rangeStart, rangeEnd)
                    
                            # Convert the topological TopoDS_Edge object representing the trimming curve into a Geom2d_BSplineCurve
                            bSplineCurve2d = Geom2dConvert.geom2dconvert.CurveToBSplineCurve(trimmedCurve2d)
                    
                            # Make the Geom2d_BSplineCurve non-periodic if it is
                            if bSplineCurve2d.IsPeriodic():
                                fprintf("Found periodic curve")
                                bSplineCurve2d.SetNotPeriodic()
                    
                            # Get the orientation of the trimming curve
                            curveDir = bool((currentFaceWire.Orientation() + currentEdgeWire.Orientation() + 1) % 2)
                    
                            # Reverse the curve depending on its orientation
                            if curveDir:
                                trimmedCurve2d = trimmedCurve2d.Reversed()
                    
                            # Add the trimming curve the wire builder object
                            wireBuilder.Add(BRepBuilderAPI_MakeEdge(trimmedCurve2d, geomBSplineSurf).Edge())
                    
                            # Advance to the next edge in the wire explorer
                            edgeWireExplorer.Next()
                    
                        if isSuccessful:
                            # Update the TopoDS_Face only if all projections were successful
                            topoFace = BRepBuilderAPI_MakeFace(geomBSplineSurf, wireBuilder.Wire()).Face()
                    
                            # Repair the trimmed TopoDS_Face object
                            topoDSFaceFixer = ShapeFix_Face(topoFace)
                            topoDSFaceFixer.Perform()
                            topoFace = topoDSFaceFixer.Face()
                
                        # Check whether the TopoDS_Face object is valid
                        checkAnalyzerFace = BRepCheck_Analyzer(topoFace)
                        if not checkAnalyzerFace.IsValid():
                            raise ValueError("The trimmed TopoDS_Face object is invalid")
                    
                        # Advance to the next wire
                        faceWireExplorer.Next()

            # Add the TopoDS_Face object into the TopoDS_Compound
            compoundBuilderMod.Add(self.updatedShape, topoFace)


    def findSelectedEdges(self):
        # Check input
        if self.selectedEdges is None:
            raise ValueError("No edges have been selected")

        # Initialize output
        selectedEdgeIds = []

        # Create an explorer object for the TopAbs_EDGE objects in the geometry
        explEdges = TopExp_Explorer(self.baseShape, TopAbs_EDGE)

        # Loop over all the TopAbs_Edge objects in the geometry
        cntEdge = int(1)
        while explEdges.More():
            # Get the current edge in the geometry
            edge = explEdges.Current()

            # Loop over all the selected edges in the geometry
            for curve in self.selectedEdges:
                # Verify that the selected object is an edge
                if curve.ShapeType() != TopAbs_EDGE:
                    raise ValueError("Selected object is not an edge")

                # Check whether the current edge is a selected edge
                isEqual = areCurvesEqual(edge, curve, self.tol)
                if isEqual:
                    selectedEdgeIds.append(cntEdge)
                    break
            
            # Update edge counter and go to the next edge in the geometry
            cntEdge += 1
            explEdges.Next()

        return selectedEdgeIds


    def computeNumDesignVariables(self):
        """
        Computes the number of the design variables for the object of the class MyApp
    
        Args:
            self (MyApp): Object of the class MyApp
    
        Example:
            >>> my_app_instance.computeNumDesignVariables()
        """
        # Initialize the number of design variables
        self.numDesignVariables = 0

        # Extract unique group IDs
        uniqueGroups = set(row[1] for row in self.pointCoords)  # Assuming group ID is in the second column
    
        for group in uniqueGroups:
            # Get control points in the current group
            groupPoints = [row for row in self.pointCoords if row[1] == group]
            numCPsGroup = len(groupPoints)
    
            if self.normalConstraint and self.groupConstraint:
                # Only one design variable per group
                self.numDesignVariables += 1
            elif normalConstraint:
                # One design variable per control point in the group (normal movement)
                self.numDesignVariables += numCPsGroup
            elif groupConstraint:
                # Three design variables per group (shared displacement vector)
                self.numDesignVariables += 3
            else:
                # Three design variables per control point
                self.numDesignVariables += 3*numCPsGroup


    def displayGUI(self):
        """
        Starts the PythonOCC GUI
    
        Args:
            self (MyApp): Object of the class MyApp
    
        Returns:
            Starts the PythonOCC GUI
    
        Example:
            >>> my_app_instance.displayGUI()
        """

        self.start_display()


def readGeometryFile(filePath):
    """
    Read-in a geometry file (IGS, IGES, STP, or STEP) and return the TopoDS_Compound object

    Args:
        file_path (str): Path to the CAD model file.

    Returns:
        baseShape: The base shape TopoDS_Compound

    Example:
        >>> readGeometryFile('./cadModels/swingarm.igs')
        result = 
        Python TopoDS_Compound with properties:

        thisown: 1
        this: [1×1 py.SwigPyObject]

        <class 'TopoDS_Compound'>
    """

    # Extract the file extension
    fileExt = os.path.splitext(filePath)[1]

    # Check if the file exists
    if not os.path.exists(filePath):
        raise FileNotFoundError(f"File {filePath} not found")

    # Read the geometry file using PythonOCC
    if fileExt.lower() in [".step", ".stp"]:
        reader = STEPControl_Reader()
        status = reader.ReadFile(filePath)
        if not status:
            raise ValueError("Failed to read STEP-file.")
        reader.TransferRoot()
        baseShape = reader.Shape()
    elif fileExt.lower() in [".iges", ".igs"]:
        reader = IGESControl_Reader()
        status = reader.ReadFile(filePath)
        if not status:
            raise ValueError("Failed to read IGES-file.")
        reader.TransferRoots()
        baseShape = reader.OneShape()
    else:
        raise ValueError("File should have an IGES or a STEP extension")

    # Check whether the imported geometry is valid
    baseShape = fixShape(baseShape)

    return baseShape


def createSolidFromBRepCompound(shape):
    """
    Creates a solid shape (TopoDS_Solid) from a BRep geometry description stored in a TopoDS_Compound object

    Args:
        shape (TopoDS_Compound): PythonOCC object of TopoDS_Compound type

    Returns:
       solid (TopoDS_Solid): The solid shape
        mass (double): The mass of the solid geometry

    Example:
        >>> createSolidFromBRepFile(shape)
        result = 
        Python tuple with values:

        (<class 'TopoDS_Solid'>, 2564641.4258147487)
    """

    # Sew the base shape to obtain an object of TopoDS_Shell
    sewnShape = sewGeometry(shape)

    # Create a solid (TopoDS_Solid)
    solid = createSolid(sewnShape)

    # Compute the mass of the solid geometry
    mass = computeMassFromSolid(solid)

    # Return the TopoDS_Solid PythonOCC type and its mass
    return solid, mass


def createSolidFromBRepFile(filePath):
    """
    Creates a solid shape (TopoDS_Solid) from a BRep geometry description stored in a STEP- or IGES-file

    Args:
        filePath (str): File path

    Returns:
       solid (TopoDS_Solid): The solid shape
        mass (double): The mass of the solid geometry

    Example:
        >>> createSolidFromBRepFile('./cadModels/swingarm.igs')
        result = 
        Python tuple with values:

        (<class 'TopoDS_Solid'>, 2564641.4258147487)
    """
    # Read-in the base shape from the provided geometry file
    shape = readGeometryFile(filePath)

    # Sew the base shape to obtain an object of TopoDS_Shell
    solid, mass = createSolidFromBRepCompound(shape)

    # Return the TopoDS_Solid PythonOCC type and its mass
    return solid, mass


def writeGeometryToFile(fileName, shape):
    """
    Writes a geometry to a STEP- or an IGES-file

    Args:
        filePath (str): File path
        shape (TopoDS_Compound, TopoDS_Face, TopoDS_Solid, etc.): Geometry object

    Returns:
       Writes geometry to a STEP- or an IGES-file

    Example:
        >>> writeGeometryToFile('./cadModels/swingarm.igs', solidShape)
    """

    # Determine the file extension
    _, fileExtension = os.path.splitext(fileName)
    
    if fileExtension.lower() in ('.step', '.stp'):
        # STEP file handling
        stepWriterMod = STEPControl_Writer()
        if shape.ShapeType() == TopAbs_SOLID:
            transferStatusMod = stepWriterMod.Transfer(shape, STEPControl_ManifoldSolidBrep)
            expectedStatusMod = IFSelect_RetDone
            if not transferStatusMod == expectedStatusMod:
                warnings.warn("Failed to transfer the solid to the STEP writer.", UserWarning)

        status = stepWriterMod.Write(fileName)
        if not status:
            raise ValueError("Failed writing a STEP-file")
    
    elif fileExtension.lower() in ('.iges', '.igs'):
        # IGES file handling
        igesWriter = IGESControl_Writer()
        topExplFaces = TopExp_Explorer(shape, TopAbs_FACE)
    
        while topExplFaces.More():
            face = topExplFaces.Current();
            status = igesWriter.AddShape(face)
            if not status:
                raise ValueError("Adding a TopoDS_Face in the IGES writer failed")
            topExplFaces.Next()
    
        status = igesWriter.Write(fileName)
        if not status:
            raise ValueError("Failed writing an IGES-file")

    else:
        raise ValueError("Unsupported file extension.")


def computeMassFromSolid(solidShape):
    """
    Returns the mass from a solid type TopoDS_Solid in PythonOCC

    Args:
        solidShape (TopoDS_Solid): Solid geometry in PythonOCC

    Returns:
        mass (double): The mass of the solid geometry

    Example:
        >>> computeMassFromSolid('./cadModels/swingarm.igs')
        mass = 2.5646e+06
    """

    # Check input
    if solidShape.ShapeType() != TopAbs_SOLID:
        raise ValueError("The input shape is not a TopoDS_Solid.")

    # Compute the mass of the solid geometry
    solidProps = GProp_GProps();
    brepgprop.VolumeProperties(solidShape, solidProps)
    mass = solidProps.Mass()
    if mass < 0:
        solidShape.Reverse()
        brepgprop.VolumeProperties(solidShape, solidProps)
        mass = solidProps.Mass()

    return mass


# Sew a geometry to obtain a TopoDS_Shell
def sewGeometry(baseShape):
    """
    Sews a PythonOCC geometry object (e.g. TopoDS_Compound) to a TopoDS_Shell type object

    Args:
        baseShape (e.g. TopoDS_Compound): PythonOCC geometry object

    Returns:
        sewedShape (TopoDS_Shell): The sewed geometry

    Example:
        >>> sewGeometry()
        result = 
        pySewedShape = 
        Python TopoDS_Shell with properties:

        thisown: 1
        this: [1×1 py.SwigPyObject]

        <class 'TopoDS_Shell'>
    """

    # Sew the input geometry
    sewing = BRepBuilderAPI_Sewing()
    sewing.Add(baseShape)
    sewing.Perform()
    sewnShape = sewing.SewedShape()

    # Check whether the sewn geometry is valid
    sewnShape = fixShape(sewnShape)

    return sewnShape


# Create a solid (TopoDS_Solid) from a shell (TopoDS_Shell) geometry
def createSolid(shellShape):
    """
    Creates a solid (TopoDS_Solid) from a shell (TopoDS_Shell) geometry

    Args:
        shellShape (TopoDS_Shell): PythonOCC TopoDS_Shell object

    Returns:
        solidShape (TopoDS_Solid): PythonmOCC TopoDS_Solid object

    Example:
        >>> createSolid()
        result = 
        Python TopoDS_Solid with properties:

        thisown: 1
        this: [1×1 py.SwigPyObject]

        <class 'TopoDS_Solid'>
    """

    # Create the solid geometry
    solidMaker = BRepBuilderAPI_MakeSolid(shellShape)
    solidShape = solidMaker.Solid()

    # Check whether the solid geometry is valid
    solidShape = fixShape(solidShape)

    return solidShape


# Fix shape
def fixShape(shape):
    """
    Fixes shape

    Args:
        shape (e.g. TopoDS_Compound, TopoDS_Shell, etc.): PythonOCC geometry object

    Returns:
        fixedShape (e.g. TopoDS_Compound, TopoDS_Shell, etc.): The fixed geometry object

    Example:
        >>> fixShape(shape)
        result = 
        fixedShape = 
        Python TopoDS_Shell with properties:

        thisown: 1
        this: [1×1 py.SwigPyObject]

        <class 'TopoDS_Shell'>
    """

    shapeAnalyzer = BRepCheck_Analyzer(shape)
    if not shapeAnalyzer.IsValid():
        warnings.warn("Geometry is invalid", UserWarning)
        shapeFixer = ShapeFix_Shape(shape)
        shapeFixer.Perform()
        shape = shapeFixer.Shape()
        shapeAnalyzer = BRepCheck_Analyzer(shape)
        if not shapeAnalyzer.IsValid():
            raise ValueError("Geometry is invalid also after fixing it")
    
    return shape

def isCurveOnSurface(geomCurve, first, last, geomSurface, numPts, tol):
    # Calculate the parameter step for sampling points
    param_step = (last - first) / (numPts - 1)

    # Iterate over n points along the curve
    for i in range(numPts):
        # Calculate the parameter for the current point
        param = first + i * param_step
        
        # Get the point on the curve at the current parameter
        point_on_curve = geomCurve.Value(param)
        
        # Project this point onto the surface
        surface_projector = GeomAPI_ProjectPointOnSurf(point_on_curve, geomSurface)

        # Check if the projection is successful and within tolerance
        if surface_projector.NbPoints() == 0 or surface_projector.LowerDistance() > tol:
            return False  # If any point fails, the curve does not lie on the surface

    return True  # All points are successfully projected within tolerance

## Auxiliary functions

# Function to check whether two curves are equal
def areCurvesEqual(edge1, edge2, tol):
    # Extract the underlying curves
    curve1, first1, last1 = BRep_Tool.Curve(edge1)
    curve2, first2, last2 = BRep_Tool.Curve(edge2)

    # Check if the curve types are the same
    # print(curve1.DynamicType())
    # print(curve2.DynamicType())
    # if curve1.DynamicType() != curve2.DynamicType():
    #     print("really???")
    #     return False

    # Check if the lengths are approximately equal
    len1 = computeCurveLength(edge1)
    len2 = computeCurveLength(edge2)
    if abs(len1 - len2) > tol:
        return False

    # Check if the endpoints and one midpoint are approximately equal
    pnt1_start = curve1.Value(first1)
    pnt1_end = curve1.Value(last1)
    pnt1_mid = curve1.Value((first1 + last1)/2.0)
    pnt2_start = curve2.Value(first2)
    pnt2_end = curve2.Value(last2)
    pnt2_mid = curve2.Value((first2 + last2)/2.0)

    # print(" ")
    # print(pnt1_start.Distance(pnt2_start))
    # print(pnt1_end.Distance(pnt2_end))
    # print(pnt1_mid.Distance(pnt2_mid))
    # print(" ")

    if (pnt1_start.Distance(pnt2_start) > tol or
        pnt1_end.Distance(pnt2_end) > tol or 
        pnt1_mid.Distance(pnt2_mid) > tol):
        return False

    return True

def computeCurveLength(edge):
    # Adapt the edge to a 3D curve
    curveAdaptor = BRepAdaptor_Curve(edge)

    # Get the first and last parameters of the curve
    paramStart = curveAdaptor.FirstParameter()
    paramEnd = curveAdaptor.LastParameter()
    
    # Calculate the length of the curve using the adaptor
    Len = GCPnts_AbscissaPoint.Length(curveAdaptor, paramStart, paramEnd)
    
    return Len


# Function to visualize a compound geometry
def visualize(shape):
    # Initialize the display
    display, start_display, add_menu, add_function_to_menu = init_display()

    # Display the compound
    display.DisplayShape(shape, update=True)

    # Start the viewer
    start_display()

# Function to calculate the Euclidean distance between two points in three-dimensional space
def euclidean_distance(pnt1, pnt2):
    return sqrt((pnt1[0] - pnt2[0])**2 + (pnt1[1] - pnt2[1])**2 + (pnt1[2] - pnt2[2])**2)

# Function to check if a number is NaN
def is_nan(num):
    return num != num

# Function to check if the last three elements are NaN
def has_nan(values):
    return any(v is None for v in values)
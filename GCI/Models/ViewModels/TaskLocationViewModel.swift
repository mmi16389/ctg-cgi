//
//  TaskLocationViewModel.swift
//  GCI
//
//  Created by Florian ALONSO on 4/25/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation
import ArcGIS

class TaskLocationViewModel {
    
    let srid: Int
    let point: AGSPoint
    let address: String
    let comment: String
    
    var pointAsString: String {
        return self.point.wktString
    }
    
    init(srid: Int, point: AGSPoint, address: String, comment: String = "") {
        self.srid = srid
        self.point = point
        self.address = address
        self.comment = comment
    }
    
    func extendForCluster(forZoomLevel zoomLevel: Double, andSpacialReference spacialReference: AGSSpatialReference) -> AGSPolygon {
        guard let projectedPoint = AGSGeometryEngine.projectGeometry(point, to: spacialReference) as? AGSPoint else {
            return AGSPolygon(points: [])
        }
        
        let zoomMultiplied = zoomLevel * 33 // Ask quentin for this magic
        var pointList = [AGSPoint]()
        
        pointList.append(AGSPoint(x: projectedPoint.x - zoomMultiplied, y: projectedPoint.y - zoomMultiplied, spatialReference: spacialReference)) // Top left
        pointList.append(AGSPoint(x: projectedPoint.x + zoomMultiplied, y: projectedPoint.y - zoomMultiplied, spatialReference: spacialReference)) // Top right
        pointList.append(AGSPoint(x: projectedPoint.x + zoomMultiplied, y: projectedPoint.y + zoomMultiplied, spatialReference: spacialReference)) // Bottom Right
        pointList.append(AGSPoint(x: projectedPoint.x - zoomMultiplied, y: projectedPoint.y + zoomMultiplied, spatialReference: spacialReference)) // Bottom left
        pointList.append(AGSPoint(x: projectedPoint.x - zoomMultiplied, y: projectedPoint.y - zoomMultiplied, spatialReference: spacialReference)) // Top left
        
        return AGSPolygon(points: pointList)
    }
    
    func distanceInMeters(fromPoint referencePoint: AGSPoint) -> Double? {
        guard let currentSpacial = self.point.spatialReference,
         let referenceSpacial = referencePoint.spatialReference else {
            return nil
        }
        let toUsePoint: AGSPoint
        if currentSpacial.wkid != referenceSpacial.wkid {
            if let projectedPoint = AGSGeometryEngine.projectGeometry(referencePoint, to: currentSpacial) as? AGSPoint {
                toUsePoint = projectedPoint
            } else {
                return nil // Cannot project
            }
        } else {
            toUsePoint = referencePoint
        }
        
        let linearUnit = AGSLinearUnit(unitID: .meters)!
        let azimuthUnit = AGSAngularUnit(unitID: .degrees)!
        let curveType = AGSGeodeticCurveType.normalSection
        let result = AGSGeometryEngine.geodeticDistanceBetweenPoint1(self.point, point2: toUsePoint, distanceUnit: linearUnit, azimuthUnit: azimuthUnit, curveType: curveType)
        return result?.distance
    }
}

extension TaskLocationViewModel: Convertible {
    
    static func from(db: TaskLocation) -> TaskLocationViewModel? {
        guard let address = db.address, let parsedPoint = db.point?.wktPoint else {
            return nil
        }
        
        let point = parsedPoint.toArcGis(withSrid: Int(db.srid))
        
        return TaskLocationViewModel(srid: Int(db.srid),
                                     point: point,
                                     address: address,
                                     comment: db.comment ?? "")
    }
}

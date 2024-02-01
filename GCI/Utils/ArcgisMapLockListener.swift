//
//  ArcgisMapLockListener.swift
//  GCI
//
//  Created by Anthony Chollet on 12/06/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation
import ArcGIS

class ArcgisMapLockListener {
    
    private var mapPolygonContainer: AGSPolygon?
    private let BUFFER_DISTANCE = 5.0
    private var lastValidViewPoint: AGSViewpoint?
    private var workItem: DispatchWorkItem?
    
    init(mapView: AGSMapView) {
        mapPolygonContainer = AppDynamicConfiguration.current()?.mapBoundPolygon
        let point = AGSPoint(x: 5.060443, y: 47.319876, spatialReference: AGSSpatialReference.wgs84())
        
        guard let mapPolygonContainer = mapPolygonContainer,
            let linearUnitMetter = AGSLinearUnit(unitID: .kilometers),
            let angularUnit = AGSAngularUnit(unitID: .degrees),
            let maxPointX = AGSGeometryEngine.geodeticMove([point], distance: BUFFER_DISTANCE, distanceUnit: linearUnitMetter, azimuth: 90.0, azimuthUnit: angularUnit, curveType: .normalSection)?.first,
            let distanceInDegree = AGSGeometryEngine.geodeticDistanceBetweenPoint1(point, point2: maxPointX, distanceUnit: linearUnitMetter, azimuthUnit: angularUnit, curveType: .normalSection)?.distance
            else {
                return
        }
        
        self.mapPolygonContainer = AGSGeometryEngine.bufferGeometry(mapPolygonContainer, byDistance: distanceInDegree)
        self.lastValidViewPoint = mapView.currentViewpoint(with: .centerAndScale)
    }
    
    func viewPointChanged(mapView: AGSMapView) {
        guard let mapPolygonContainer = mapPolygonContainer, let spatialRefrence = mapPolygonContainer.spatialReference else { return }
        let viewPoint = mapView.currentViewpoint(with: .centerAndScale)
        guard var geometry = viewPoint?.targetGeometry else { return }
        
        if spatialRefrence.wkid != geometry.spatialReference?.wkid {
            guard let newGeometry = AGSGeometryEngine.projectGeometry(geometry, to: spatialRefrence) else { return }
            geometry = newGeometry
        }
        
        if AGSGeometryEngine.geometry(mapPolygonContainer, contains: geometry) {
            lastValidViewPoint = viewPoint
        } else {
            if let lastValidViewPoint = lastValidViewPoint {
                
                workItem?.cancel()
                workItem = DispatchWorkItem {
                    mapView.setViewpoint(lastValidViewPoint)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.20, execute: workItem!)
            }
        }
    }
    
}

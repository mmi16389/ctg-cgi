//
//  MapManager.swift
//  GCI
//
//  Created by Anthony Chollet on 18/06/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation
import UIKit
import ArcGIS

class MapManager: NSObject {
    
    typealias NearTask = (_ taskList: [TaskViewModel]?) -> Void
    
    func getListOfTaskArroundPoint(withScreenPoint screenPoint: CGPoint, onMapView mapview: AGSMapView, inTaskOverlay taskOverlay: AGSGraphicsOverlay, completion: @escaping NearTask) {
        
        //create polygon corner
        let corner1 = mapview.screen(toLocation: CGPoint(x: screenPoint.x - 30, y: screenPoint.y - 30))
        let corner2 = mapview.screen(toLocation: CGPoint(x: screenPoint.x + 30, y: screenPoint.y + 30))
        
        guard let srid = AppDynamicConfiguration.current()?.mapProjection,
            let spatialRef = AGSSpatialReference(wkid: srid),
            let cornerLeft = AGSGeometryEngine.projectGeometry(corner1, to: spatialRef),
            let cornerRight = AGSGeometryEngine.projectGeometry(corner2, to: spatialRef)
            else {
                completion(nil)
                return
        }
        
        let enveloppe = AGSEnvelope(xMin: cornerLeft.extent.xMin, yMin: cornerLeft.extent.yMin, xMax: cornerRight.extent.xMax, yMax: cornerRight.extent.yMax, spatialReference: spatialRef)
        
        var arrayOfTask = [TaskViewModel]()
        for graphic in taskOverlay.graphics {
            if let graphic = graphic as? AGSGraphic, let geometry = graphic.geometry, AGSGeometryEngine.geometry(enveloppe, contains: geometry), let currentTasks = graphic.attributes["task"] as? [TaskViewModel] {
                for task in currentTasks {
                    arrayOfTask.append(task)
                }
            }
        }
        
        completion(arrayOfTask)
    }
    
}

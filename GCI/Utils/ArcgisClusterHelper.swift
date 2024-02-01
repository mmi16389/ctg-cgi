//
//  ArcgisClusterLayer.swift
//  GCI
//
//  Created by Anthony Chollet on 01/07/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation
import ArcGIS

protocol ArcgisClusterLayerDelegate: class {
    func didUnselectMarker()
}

class ClusterData {
    var taskList = [TaskViewModel]()
    private var polygonList = [AGSPolygon]()
    
    var center: AGSPoint {
        let spacialReference = AGSSpatialReference(wkid: AppDynamicConfiguration.current()?.mapProjection ?? 3857)
        
        var sumX = 0.0
        var sumY = 0.0
        var count = 0.0
        
        taskList.forEach {
            guard let location = $0.location else {
                return
            }
            sumX += location.point.x
            sumY += location.point.y
            count += 1.0
        }
        
        return AGSPoint(x: sumX/count, y: sumY/count, spatialReference: spacialReference)
    }
    
    init(forTask task: TaskViewModel, withPolygon polygon: AGSPolygon) {
        taskList.append(task)
        polygonList.append(polygon)
    }
    
    func add(task: TaskViewModel, withPolygon polygon: AGSPolygon) {
        taskList.append(task)
        polygonList.append(polygon)
    }
    
    func contain(thisPoint point: AGSPoint) -> Bool {
        return polygonList.contains {
            ArcgisHelper.pointInPolygon(withPoint: point, inPolygon: $0)
        }
    }
    
}

class ArcgisClusterHelper {
    private var mapView: AGSMapView?
    private var clusterDataList = [ClusterData]()
    private var clusterResolution: Double = 0
    private var clusterGraphics = [AGSGraphic]()
    weak var delegate: ArcgisClusterLayerDelegate?
    
    init(mapview: AGSMapView) {
        self.mapView = mapview
        recalculateMapResolution()
    }
    
    private func recalculateMapResolution() {
        if let visibleArea = self.mapView?.visibleArea, let mapWith = mapView?.width {
            self.clusterResolution = visibleArea.extent.width / Double(mapWith)
        } else {
            self.clusterResolution = 30
        }
    }
    
    func defineCluster(fromListOfTask listOfTask: [TaskViewModel]) -> [ClusterData] {
        guard let spatial = mapView?.spatialReference else {
            return clusterDataList
        }
        recalculateMapResolution()
        
        clusterDataList.removeAll()
        
        listOfTask.forEach { (task) in
            guard let taskLocation = task.location else {
                return
            }
            
            let clusterValidForThisTaskOpt = clusterDataList.first { (clusterData) -> Bool in
                clusterData.contain(thisPoint: taskLocation.point)
            }
            
            let extendOfLocation = taskLocation.extendForCluster(forZoomLevel: clusterResolution, andSpacialReference: spatial)
            
            if let clusterValidForThisTask = clusterValidForThisTaskOpt {
                // Found so adding to it
                clusterValidForThisTask.add(task: task, withPolygon: extendOfLocation)
            } else {
                // Not found need to create
                let newClusterData = ClusterData(forTask: task, withPolygon: extendOfLocation)
                clusterDataList.append(newClusterData)
            }
        }
        return clusterDataList
    }
}

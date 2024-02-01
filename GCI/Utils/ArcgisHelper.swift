//
//  ArcgisHelper.swift
//  GCI
//
//  Created by Anthony Chollet on 20/05/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import UIKit
import ArcGIS

struct ViewPointChangedActions {
    typealias Action = () -> Void
    var action: Action?
}

class ArcgisHelper: NSObject {
    
    typealias CompletionPatrimony = (_ table: AGSServiceFeatureTable) -> Void
    
    static func initMap(withMapView mapView: AGSMapView) -> ViewPointChangedActions? {
        if !NetworkReachabilityHelper.isReachable() {
            let path = FileManager.default.getDocumentsDirectoryURL().appendingPathComponent("Map").appendingPathComponent("mapoffline.tpk")
            if FileManager.default.fileExists(atPath: path.path) {
                let tileCache = AGSTileCache(fileURL: path)
                let layer = AGSArcGISTiledLayer(tileCache: tileCache)
                mapView.map = AGSMap(basemap: AGSBasemap(baseLayer: layer))
            } else {
                return nil
            }
        } else if AppDynamicConfiguration.current()?.mapBaseKey == Constant.Map.BaseMap.none.rawValue {
            let baseMap = AGSBasemap()
            mapView.map = AGSMap(basemap: baseMap)
        } else {
            if let config = AppDynamicConfiguration.current(), let mapBaseEnum = Constant.Map.BaseMap(rawValue: config.mapBaseKey), let mapBase = mapBaseEnum.arcgis {
                mapView.map = AGSMap(basemapType: mapBase, latitude: 0, longitude: 0, levelOfDetail: 16)
            }
        }
        
        if let config = AppDynamicConfiguration.current(), !config.mapLayerUrl.isEmpty, let urlLayer = URL(string: config.mapLayerUrl) {
            let layer = AGSArcGISTiledLayer(url: urlLayer)
            
            mapView.map?.operationalLayers.add(layer)
            
            let locker = ArcgisMapLockListener(mapView: mapView)
            return ViewPointChangedActions {
                locker.viewPointChanged(mapView: mapView)
            }
        } else {
            return nil
        }
    }
    
    static func addMarker(withMapView mapView: AGSMapView, forTask task: TaskViewModel, isZoomActive isZoom: Bool, onGraphicOverlay graphicsOverlay: AGSGraphicsOverlay = AGSGraphicsOverlay(), withMarkerIcon icon: UIImage = UIImage(named: "ico_location_map_details_DI")!, isSelected: Bool = false) {
        if !mapView.graphicsOverlays.contains(graphicsOverlay) {
            mapView.graphicsOverlays.add(graphicsOverlay)
        }

        let marker = AGSPictureMarkerSymbol(image: icon)
        if isSelected {
            marker.width = 39
            marker.height = 50
            marker.offsetY = 25
        } else {
            marker.width = 27
            marker.height = 38
            marker.offsetY = 19
        }
        if let location = task.location, let config = AppDynamicConfiguration.current() {
            let graphic = AGSGraphic(geometry: location.point, symbol: marker, attributes: nil)
            graphic.attributes.setValue([task], forKey: "task")
            graphicsOverlay.graphics.addObjects(from: [graphic])
            DispatchQueue.main.async {
                mapView.isAttributionTextVisible = false
            }
            
            if let linearUnitMeters = AGSLinearUnit(unitID: .meters), isZoom {
                if let mapPointX = AGSGeometryEngine.geodeticMove([location.point], distance: 60, distanceUnit: linearUnitMeters, azimuth: 180, azimuthUnit: .degrees(), curveType: .normalSection) {
                    let mapZoom = config.mapZoom
                    let viewPoint = AGSViewpoint(center: mapPointX.first!, scale: Double(mapZoom))
                    mapView.setViewpoint(viewPoint)
                }
            }
        }
    }
    
    static func addMarker(withMapView mapView: AGSMapView, onGraphicOverlay graphicsOverlay: AGSGraphicsOverlay, atLocation point: AGSPoint, isZoomActive isZoom: Bool, withMarkerIcon icon: UIImage = UIImage(named: "ico_location_map_details_DI")!, isSelected: Bool = false) {
        if !mapView.graphicsOverlays.contains(graphicsOverlay) {
            mapView.graphicsOverlays.add(graphicsOverlay)
        }
        
        let marker = AGSPictureMarkerSymbol(image: icon)
        if isSelected {
            marker.width = 39
            marker.height = 50
            marker.offsetY = 25
        } else {
            marker.width = 27
            marker.height = 38
            marker.offsetY = 19
        }
        let graphic = AGSGraphic(geometry: point, symbol: marker, attributes: nil)
        graphicsOverlay.graphics.addObjects(from: [graphic])
        DispatchQueue.main.async {
            mapView.isAttributionTextVisible = false
        }
        
        if let linearUnitMeters = AGSLinearUnit(unitID: .meters), let mapZoom = AppDynamicConfiguration.current()?.mapZoom, isZoom {
            if let mapPointX = AGSGeometryEngine.geodeticMove([point], distance: 60, distanceUnit: linearUnitMeters, azimuth: 180, azimuthUnit: .degrees(), curveType: .normalSection) {
                let viewPoint = AGSViewpoint(center: mapPointX.first!, scale: Double(mapZoom))
                mapView.setViewpoint(viewPoint)
            }
        }
    }
    
    static func addClusterMarker(withMapView mapView: AGSMapView, onGraphicOverlay graphicsOverlay: AGSGraphicsOverlay, atLocation point: AGSPoint, listOfTasks: [TaskViewModel], withMarkerIcon icon: UIImage = UIImage(named: "ico_location_map_details_di_full")!, isSelected: Bool = false) {
        if !mapView.graphicsOverlays.contains(graphicsOverlay) {
            mapView.graphicsOverlays.add(graphicsOverlay)
        }
        
        let marker = AGSPictureMarkerSymbol(image: icon.addText(drawText: "\(listOfTasks.count)" as NSString))
        if isSelected {
            marker.width = 39
            marker.height = 50
            marker.offsetY = 25
        } else {
            marker.width = 27
            marker.height = 38
            marker.offsetY = 19
        }
        let graphic = AGSGraphic(geometry: point, symbol: marker, attributes: nil)
        graphicsOverlay.graphics.addObjects(from: [graphic])
        graphic.attributes.setValue(listOfTasks, forKey: "task")
        DispatchQueue.main.async {
            mapView.isAttributionTextVisible = false
        }
    }
    
    static func pointInPolygon(withPoint point: AGSPoint, inPolygon polygon: AGSPolygon) -> Bool {
        guard let spacialRef = polygon.spatialReference else {
            return false
        }
        if let geometry = AGSGeometryEngine.projectGeometry(point, to: spacialRef) {
            return AGSGeometryEngine.geometry(polygon, contains: geometry)
        } else {
            return false
        }
    }
    
    static func addLayerZone(withMapView mapView: AGSMapView, zoneViewModelList: [DomainZoneLinkViewModel], onGraphicOverlay graphicsOverlay: AGSGraphicsOverlay = AGSGraphicsOverlay()) -> ViewPointChangedActions {
        if !mapView.graphicsOverlays.contains(graphicsOverlay) {
            mapView.graphicsOverlays.add(graphicsOverlay)
        }
        
        for zoneViewModel in zoneViewModelList {
            let polygonOutlineSymbol = AGSSimpleLineSymbol(style: .solid, color: zoneViewModel.zone.colorWithAlpha, width: 1.0)
            let polygonSymbol = AGSSimpleFillSymbol(style: .solid, color: zoneViewModel.zone.colorWithAlpha, outline: polygonOutlineSymbol)
            let polygonGraphic = AGSGraphic(geometry: zoneViewModel.zone.polygon, symbol: polygonSymbol, attributes: nil)
            graphicsOverlay.graphics.add(polygonGraphic)
        }
        
        return ViewPointChangedActions {
            guard let zoomMinimum = AppDynamicConfiguration.current()?.mapZoneMinimalZoom else {
                return
            }
            if Double(zoomMinimum) <= mapView.mapScale {
                graphicsOverlay.isVisible = true
            } else {
                graphicsOverlay.isVisible = false
            }
        }
    }
    
    static func addLayerPatrimony(withMapView mapView: AGSMapView, domainID: Int64, completion: @escaping CompletionPatrimony) {
        if let config = AppDynamicConfiguration.current(), let urlWithProxy = URL(string: config.mapProxyUrl  + "?" + config.mapDataUrl) {
            let patrimonyLayer = AGSArcGISMapImageLayer(url: urlWithProxy)
            patrimonyLayer.load { (error) in
                for layer in patrimonyLayer.mapImageSublayers {
                    if let layer = layer as? AGSArcGISMapImageSublayer {
                        if layer.sublayerID == 0 {
                            layer.definitionExpression = "ID_DOMAINE = + \(domainID)"
                            
                            if let url = URL(string: "\(urlWithProxy)/\(layer.sublayerID)") {
                                let table = AGSServiceFeatureTable(url: url)
                                table.definitionExpression = "ID_DOMAINE = + \(domainID)"
                                completion(table)
                            }
                        } else {
                            layer.isVisible = false
                        }
                    }
                }
            }
            
            mapView.map?.operationalLayers.add(patrimonyLayer)
        }
    }
}

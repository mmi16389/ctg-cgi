//
//  WKTUtils.swift
//  GCI
//
//  Created by Florian ALONSO on 5/8/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation
import ArcGIS

protocol WKTPointProtocol {
    var x: Double { get }
    var y: Double { get }
    
    func toArcGis(withSrid srid: Int) -> AGSPoint
}

struct WKTPoint: WKTPointProtocol {
    let x: Double
    let y: Double
    
    func toArcGis(withSrid srid: Int) -> AGSPoint {
        let spacialReference = AGSSpatialReference(wkid: srid)
        return AGSPoint(x: self.x, y: self.y, spatialReference: spacialReference)
    }
}

extension String {
    
    var wktPoint: WKTPoint? {
        let regex = "POINT ?\\( *(-?\\d*\\.?\\d*) +(-?\\d*\\.?\\d*) *\\)"
        let regexGroups = self.ranges(for: regex)
        
        guard let xStringRange = regexGroups[safe: 1], let yStringRange = regexGroups[safe: 2] else {
            return nil
        }
       
        let xString = String(self[xStringRange])
        let yString = String(self[yStringRange])
        
        guard let xDouble = Double(xString), let yDouble = Double(yString) else {
            return nil
        }
       
        return WKTPoint(x: xDouble, y: yDouble)
    }
    
    var wktPolygon: [WKTPoint]? {
        guard self.starts(with: "POLYGON") else {
            return nil
        }
        var coordinatesString = self.replacingOccurrences(of: "POLYGON", with: "").trimmingCharacters(in: .whitespaces)
        
        guard coordinatesString.starts(with: "(") else {
            return nil
        }
        coordinatesString = coordinatesString.replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "")
        
        let allCoordinatesList = coordinatesString.split(separator: ",")
        let pointsList = allCoordinatesList.compactMap { "POINT (\($0))".wktPoint }
        return pointsList.isEmpty ? nil : pointsList
    }
}

extension AGSPoint {
    
    var wktString: String {
        return String(format: "POINT(%f %f)", self.x, self.y)
    }
}

extension AGSPolygon {
    
    var wktString: String {
        guard let pointsAsString = self.parts.array().first?.pointEnumerator().allObjects?.compactMap({ (pointOpt) -> String? in
            guard let point = pointOpt as? AGSPoint else {
                return nil
            }
            return String(format: "%f %f", point.x, point.y)
        }) else {
            return "POLYGON(())"
        }
        
        return String(format: "POLYGON((%@))", pointsAsString.joined(separator: ","))
    }
}

extension Array where Element: WKTPointProtocol {
    
    func toArcGisPointList(withSrid srid: Int) -> [AGSPoint] {
        return self.map {
            return $0.toArcGis(withSrid: srid)
        }
    }
    
    func toPolygon(withSrid srid: Int) -> AGSPolygon {
        return AGSPolygon(points: self.toArcGisPointList(withSrid: srid))
    }
}

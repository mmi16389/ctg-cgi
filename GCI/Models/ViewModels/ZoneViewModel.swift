//
//  ZoneViewModel.swift
//  GCI
//
//  Created by Florian ALONSO on 4/24/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import UIKit
import ArcGIS

class ZoneViewModel {
    let id: Int
    let name: String
    let srid: Int
    let colorHexa: String
    let wkt: String
    var polygon: AGSPolygon? {
        return wkt.wktPolygon?.toPolygon(withSrid: srid)
    }
    
    var color: UIColor {
        return UIColor(hex: colorHexa)
    }
    
    var colorWithAlpha: UIColor {
        return self.color.withAlphaComponent(0.5)
    }
    
    init(id: Int, name: String, srid: Int32, colorHexa: String, wkt: String) {
        self.id = id
        self.name = name
        self.srid = Int(srid)
        self.colorHexa = colorHexa
        self.wkt = wkt
    }
}

extension ZoneViewModel: Convertible {
    
    static func from(db: Zone) -> ZoneViewModel? {
        guard let name = db.name,
            let colorHexa = db.colorHexa,
            let wkt = db.wkt else {
                return nil
        }
        
        return ZoneViewModel(id: Int(db.id),
                             name: name,
                             srid: db.srid,
                             colorHexa: colorHexa,
                             wkt: wkt)
    }
}

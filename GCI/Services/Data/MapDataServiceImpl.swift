//
//  MapDataServiceImpl.swift
//  GCI
//
//  Created by Anthony Chollet on 07/06/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation
import ArcGIS

class MapDataServiceImpl: NSObject, MapDataService {
    
    var internalApiService: MapAPIService?
    
    func apiService() -> MapAPIService {
        if internalApiService == nil {
            self.internalApiService = MapAPIServiceImpl()
        }
        return internalApiService!
    }
    
    func getAddressFromPoint(withAGSPoint agsPoint: AGSPoint, completion: @escaping Callback) {
        
        guard let spatial = AGSSpatialReference(wkid: 3857), let newPoint = AGSGeometryEngine.projectGeometry(agsPoint, to: spatial) as? AGSPoint else {
            
            completion(.failed(.error))
            return
        }
        
        apiService().getAddress(fromX: newPoint.x, andY: newPoint.y) { (jsonOpt, requestStatus) in
         
            if requestStatus == .noInternet {
                DispatchQueue.main.async {
                    completion(.failed(.noNetwork))
                }
                return
            } else if requestStatus == .success {
                let addressJSON = jsonOpt?["address"]
                completion(.value(AGSAddressViewModel.from(db: addressJSON)))
            }
        }
    }
}

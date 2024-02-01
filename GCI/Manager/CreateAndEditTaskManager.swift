//
//  CreateAndEditTaskManager.swift
//  GCI
//
//  Created by Anthony Chollet on 04/06/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation
import UIKit
import ArcGIS

class CreateAndEditTaskManager: NSObject {
    
    typealias AddressToAGSPointCompletion = (_ address: [AGSGeocodeResult]?, _ error: ViewModelError?) -> Void
    typealias NearPatrimony = (_ patrimonyList: [TaskPatrimonyViewModel]?) -> Void
    typealias CreatedtaskCompletion = (_ succes: Bool, _ error: ViewModelError?) -> Void
    typealias UpdatedtaskCompletion = (_ succes: Bool, _ error: ViewModelError?) -> Void
    typealias AGSPointToAddressCompletion = (_ address: String?, _ error: ViewModelError?) -> Void
    typealias InterventionViewModelCompletionHandler = (_ interventionsTypes: [InterventionTypeViewModel]?, _ error: ViewModelError?) -> Void
    typealias DomainViewModelCompletionHandler = (_ domainList: [DomainViewModel]?, _ error: ViewModelError?) -> Void
    typealias ServicesViewModelCompletionHandler = (_ servicesList: [ServiceViewModel]?, _ error: ViewModelError?) -> Void
    var internalReferentialDataService: ReferentialDataService?
    var internalMapDataService: MapDataService?
    var internalTaskDataservice: TaskDataService?
    var onlineLocator: AGSLocatorTask!
    
    func referencialDataService() -> ReferentialDataService {
        if internalReferentialDataService == nil {
            internalReferentialDataService = ReferentialDataServiceImpl()
        }
        return internalReferentialDataService!
    }
    
    func mapDataService() -> MapDataService {
        if internalMapDataService == nil {
            internalMapDataService = MapDataServiceImpl()
        }
        return internalMapDataService!
    }
    
    func taskDataService() -> TaskDataService {
        if internalTaskDataservice == nil {
            internalTaskDataservice = TaskDataServiceImpl()
        }
        return internalTaskDataservice!
    }
    
    func createTask(withCreatedTask createdTask: CreatedTaskViewModel, completionHandler: @escaping CreatedtaskCompletion) {
        self.taskDataService().add(fromCreatedTask: createdTask) { (result) in
            switch result {
                
            case .value:
                completionHandler(true, nil)
            case .failed(let error):
                switch error {
                case .noNetwork:
                    completionHandler(true, nil)
                default:
                    completionHandler(false, error)
                }
            }
        }
    }
    
    func createTaskWithoutSynch(withCreatedTask createdTask: CreatedTaskViewModel, completionHandler: @escaping CreatedtaskCompletion) {
        self.taskDataService().addWithoutAutoSync(fromCreatedTask: createdTask) { (result) in
            switch result {
                
            case .value:
                completionHandler(true, nil)
            case .failed(let error):
                switch error {
                case .noNetwork:
                    completionHandler(true, nil)
                default:
                    completionHandler(false, error)
                }
            }
        }
    }
    
    func updateTask(withUpdatedTask task: TaskViewModel, completionHandler: @escaping UpdatedtaskCompletion) {
        self.taskDataService().update(task: task) { (result) in
            switch result {
                
            case .value:
                completionHandler(true, nil)
            case .failed(let error):
                switch error {
                case .noNetwork:
                    completionHandler(true, nil)
                default:
                    completionHandler(false, error)
                }
            }
        }
    }
    
    func getAllInterventionType(forNewTask: Bool, completionHandler: @escaping InterventionViewModelCompletionHandler) {
        referencialDataService().allInterventionTypes(forNewTask: forNewTask) { (result) in
            switch result {
                
            case .value(let interventionsTypes):
                completionHandler(interventionsTypes, nil)
            case .failed(let error):
                completionHandler(nil, error)
            }
        }
    }
    
    func getAllDomain(forNewTask: Bool, completionHandler: @escaping DomainViewModelCompletionHandler) {
        referencialDataService().allDomains(forNewTask: forNewTask) { (result) in
            switch result {
            case .value(let domainList):
                completionHandler(domainList, nil)
            case .failed(let error):
                completionHandler(nil, error)
            }
        }
    }
    
    func getAllServices(completionHandler: @escaping ServicesViewModelCompletionHandler) {
        referencialDataService().allServices { (result) in
            switch result {
            case .value(let serviceList):
                completionHandler(serviceList, nil)
            case .failed(let error):
                completionHandler(nil, error)
            }
        }
    }
    
    func getAvailableServices(forUpdatedTask task: TaskViewModel, completionHandler: @escaping ServicesViewModelCompletionHandler) {
        taskDataService().availableServices(forTask: task) { (result) in
            switch result {
            case .value(let serviceList):
                completionHandler(serviceList, nil)
            case .failed(let error):
                completionHandler(nil, error)
            }
        }
    }
    
    func getFullAddress(fromAddress address: String, city: String, longLabel: String) -> String {
        var addressToDisplay = ""
        if !address.isEmpty, !city.isEmpty {
            addressToDisplay = "\(address), \(city)"
        } else {
            addressToDisplay = longLabel
        }
        
        return addressToDisplay
    }
    
    func getAddressFromPoint(point: AGSPoint, completion: @escaping AGSPointToAddressCompletion) {
        if !NetworkReachabilityHelper.isReachable() {
            completion(nil, .noNetwork)
            return
        }
        
        mapDataService().getAddressFromPoint(withAGSPoint: point) { (result) in
            switch result {
                
            case .value(let addressViewModel):
                completion(self.getFullAddress(fromAddress: addressViewModel?.address ?? "", city: addressViewModel?.city ?? "", longLabel: addressViewModel?.longLabel ?? ""), nil)
            case .failed(let error):
                    switch error {
                    case .noNetwork:
                        completion(nil, .noNetwork)
                    default:
                        completion(nil, .error)
                }
            }
        }
    }
    
    func getPointFromAddress(address: String, completion: @escaping AddressToAGSPointCompletion) {
        if let url = URL(string: Constant.Map.mapGeocoderUrl) {
            onlineLocator = AGSLocatorTask(url: url)
            let geocodeParameters = AGSGeocodeParameters()
            geocodeParameters.categories.append("Address")
            geocodeParameters.resultAttributeNames.append("Address")
            geocodeParameters.resultAttributeNames.append("City")
            geocodeParameters.resultAttributeNames.append("LongLabel")
            
            geocodeParameters.searchArea = AppDynamicConfiguration.current()?.mapBoundPolygon
            
            onlineLocator.geocode(withSearchText: address, parameters: geocodeParameters) { (result, error) in
                if let result = result {
                    if result.count > 0 {
                        completion(result, nil)
                    } else {
                        completion(nil, .noAddressFound)
                    }
                } else {
                    completion(nil, .error)
                }
            }
        } else {
            completion(nil, .error)
        }
    }
    
    func getPatrimonyListAroundPoint(withPoint point: AGSPoint, inTable table: AGSServiceFeatureTable, domainID: Int64, completion: @escaping NearPatrimony) {

        guard let srid = AppDynamicConfiguration.current()?.mapProjection,
            let spatialRef = AGSSpatialReference(wkid: srid),
            let pointToGoodSpatial = AGSGeometryEngine.projectGeometry(point, to: spatialRef) as? AGSPoint,
            let maxPointX = AGSGeometryEngine.geodeticMove([pointToGoodSpatial], distance: 80.0, distanceUnit: .meters(), azimuth: 90.0, azimuthUnit: .degrees(), curveType: .normalSection)?.first,
            let distanceInDegree = AGSGeometryEngine.geodeticDistanceBetweenPoint1(pointToGoodSpatial, point2: maxPointX, distanceUnit: .meters(), azimuthUnit: .degrees(), curveType: .normalSection)?.distance
            else {
                completion(nil)
                return
        }
        
        let query = AGSQueryParameters()
        query.whereClause = "ID_DOMAINE = \(domainID)"
        query.spatialRelationship = AGSSpatialRelationship.contains
        query.geometry = AGSEnvelope(center: pointToGoodSpatial, width: distanceInDegree, height: distanceInDegree).toBuilder().toGeometry()
        table.queryFeatures(with: query) { (result, error) in
            if let result = result {
                var listOfPatrimony = [TaskPatrimonyViewModel]()
                
                let patrimonyMax = result.featureEnumerator().allObjects.count
                var currentNumberPatrimonyFinished = 0
                for item in result.featureEnumerator().allObjects {
                    
                    TaskPatrimonyViewModel.from(feature: item, completion: { (patrimony) in
                        if let patrimony = patrimony {
                            if let patrimonyPoint = item.geometry?.extent.center, let spatialref = point.spatialReference, let patrimonyPointOnSpatialRef = AGSGeometryEngine.projectGeometry(patrimonyPoint, to: spatialref) as? AGSPoint {
                                let distanceFromPoint =  AGSGeometryEngine.geodeticDistanceBetweenPoint1(point, point2: patrimonyPointOnSpatialRef, distanceUnit: .meters(), azimuthUnit: .degrees(), curveType: .normalSection)?.distance
                                patrimony.distance = Int(distanceFromPoint ?? 0)
                            }
                            
                            listOfPatrimony.append(patrimony)
                            currentNumberPatrimonyFinished += 1
                            
                            if currentNumberPatrimonyFinished == patrimonyMax {
                                completion(listOfPatrimony)
                            }
                        } else {
                            completion(nil)
                        }
                    })
                }
                completion(nil)
            } else {
                completion(nil)
            }
        }
    }
    
    func saveImageOnDisk(image: UIImage) -> URL? {
        let imageCompressed = image.resizeAndCompressed()
        if let data = imageCompressed.jpegData(compressionQuality: 1) {
            let fileName = "\(UUID().uuidString).jpg"
            let path = AttachmentViewModel.folder.appendingPathComponent(fileName)
//            do {
                FileManager.default.createFile(atPath: path.path, contents: data, attributes: nil)
//                try data.write(to: path)
                return path
//            } catch let error {
//                print(error)
//                return nil
//            }
        } else {
            return nil
        }
    }
    
    func savePDFOnDisk(originalPath: URL) -> URL? {
        if FileManager.default.fileExists(atPath: originalPath.path) {
            let fileName = "\(UUID().uuidString).pdf"
            var path = AttachmentViewModel.folder
            path.appendPathComponent(fileName)
            do {
                try FileManager.default.copyItem(at: originalPath, to: path)
            } catch let error {
                print(error)
                return nil
            }
            return path
        } else {
            return nil
        }
    }
}

//
//  ArcgisMapOfflineHelper.swift
//  GCI
//
//  Created by Anthony Chollet on 21/06/2019.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation
import ArcGIS

protocol ArcgisMapOfflineHelperDelegate: class {
    func getDownloadProgress(percent: Double)
    func failToLoadMap(error: Error?)
    func successToLoadMap()
}

class ArcgisMapOfflineHelper {
    
    weak var delegate: ArcgisMapOfflineHelperDelegate?
    typealias PrepareDownloadMapCompletion = (_ success: Bool, _ messageToDisplay: String, _ exportTileCacheTask: AGSExportTileCacheTask?, _ exportParameter: AGSExportTileCacheParameters?, _ error: ViewModelError?) -> Void
    
    var exportTileCacheTask: AGSExportTileCacheTask?
    var estimateSize: AGSEstimateTileCacheSizeJob?
    var job: AGSExportTileCacheJob?
    
    static var haveOfflineMap: Bool {
        let path = FileManager.default.getDocumentsDirectoryURL().appendingPathComponent("Map").appendingPathComponent("mapoffline.tpk")

        return FileManager.default.fileExists(atPath: path.path)
    }
    
    static var isOutdatedMap: Bool {
        if let lastModificationDate = lastModificationDate {
            return AppDynamicConfiguration.current()?.mapUpdatedDate.compare(lastModificationDate) == ComparisonResult.orderedDescending ? true : false
        } else {
            return true
        }
    }
    
    private static var lastModificationDate: Date? {
        do {
            let path = FileManager.default.getDocumentsDirectoryURL().appendingPathComponent("Map").appendingPathComponent("mapoffline.tpk")
            let attr = try FileManager.default.attributesOfItem(atPath: path.path)
            return attr[FileAttributeKey.modificationDate] as? Date
        } catch {
            return nil
        }
    }
    
    func prepareDownloadMap(completion: @escaping PrepareDownloadMapCompletion) {
        guard NetworkReachabilityHelper.isReachable() else {
            completion(false, "", nil, nil, .noNetwork)
            return
        }
        
        guard let mapPolygonContainer = AppDynamicConfiguration.current()?.mapBoundPolygon,
            let exportUrlString = AppDynamicConfiguration.current()?.mapExportUrl,
            let exportURL = URL(string: exportUrlString) else {
                completion(false, "", nil, nil, .error)
                return
        }
        
        exportTileCacheTask = AGSExportTileCacheTask(url: exportURL)
        if let exportTileCacheTask = exportTileCacheTask {
            exportTileCacheTask.credential = AGSCredential(user: AppDynamicMapConfiguration.current()?.user ?? "", password: AppDynamicMapConfiguration.current()?.password ?? "")
            exportTileCacheTask.load { (error) in
                guard error == nil else {
                    completion(false, "", nil, nil, .notRightUsername)
                    return
                }
                
                if exportTileCacheTask.loadStatus == .loaded {
                    exportTileCacheTask.exportTileCacheParameters(withAreaOfInterest: mapPolygonContainer, minScale: 288895.277144, maxScale: 2256.994353, completion: { (exportParameter, error) in
                        guard let exportParameter = exportParameter, error == nil else {
                            completion(false, "", nil, nil, .error)
                            return
                        }
                        
                        self.estimateSize = exportTileCacheTask.estimateTileCacheSizeJob(with: exportParameter)
                        if let estimateSize = self.estimateSize {
                            estimateSize.start(statusHandler: nil) { (result, error) in
                                if let result = result {
                                    completion(true, "popup_map_download_warning_content".localized(arguments: String(result.fileSize)), exportTileCacheTask, exportParameter, nil)
                                } else {
                                    completion(true, "popup_map_download_warning_no_size_content".localized, exportTileCacheTask, exportParameter, nil)
                                }
                            }
                        }
                    })
                } else if exportTileCacheTask.loadStatus == .failedToLoad {
                    completion(false, "", nil, nil, .error)
                }
            }
        }
    }
    
    func downloadMap(exportTileCacheTask: AGSExportTileCacheTask, exportParameter: AGSExportTileCacheParameters) {
        let path = FileManager.default.getDocumentsDirectoryURL().appendingPathComponent("Map")
        if !FileManager.default.fileExists(atPath: path.path) {
            try? FileManager.default.createDirectory(atPath: path.path, withIntermediateDirectories: true, attributes: nil)
        }
        
        let filePath = path.appendingPathComponent("mapoffline.tpk")
        if FileManager.default.fileExists(atPath: filePath.path) {
            try? FileManager.default.removeItem(at: filePath)
        }
        
        job = exportTileCacheTask.exportTileCacheJob(with: exportParameter, downloadFileURL: filePath)
        if let job = job {
            job.start(statusHandler: { (status) in
//                print(status.rawValue)
            }) { (agsTileCache, error) in
                if job.status == .succeeded {
                    self.delegate?.successToLoadMap()
                } else {
                    if let error = error {
                        self.delegate?.failToLoadMap(error: error)
                    } else {
                        self.delegate?.failToLoadMap(error: nil)
                    }
                }
            }
            
            job.progress.setProgressHandler { (progress) in
                //progress bar
                self.delegate?.getDownloadProgress(percent: progress.fractionCompleted)
            }
        }
    }
}

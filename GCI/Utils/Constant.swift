//
//  Constant.swift
//  GCI
//
//  Created by Florian ALONSO on 3/11/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation
import ArcGIS

enum Constant {
    
    static var haveToRefresh = false
    static var haveToRefreshFilterDashboard = false
    static var haveToRefreshFilterListTask = false
    
    enum Prefilled {
        static let activationCode: String = {
            #if DEBUG
                #if INTEGRATIONQA
                return "7a066b6f-775b-4e72-bbaa-64c01c3a9d25"
                #elseif PREPROD
                return "7a066b6f-775b-4e72-bbaa-64c01c3a9d25"
                #elseif PROD
                return "7a066b6f-775b-4e72-bbaa-64c01c3a9d25"
                #else
                return "" // Should be kept empty for security
                #endif
            #else
            return "" // Should be kept empty for security
            #endif
        }()
        static let login: String = {
            #if DEBUG
                #if INTEGRATIONQA
                if Constant.API.useBasicAuth {
                    return "NeoPixl"
                } else {
                    return "admfonctionnel.test@musesoftware.int"
                }
                #elseif PREPROD
                return "dnevot@ondijon.local"
                #elseif PROD
                return ""
                #else
                return "" // Should be kept empty for security
                #endif
            #else
            return "" // Should be kept empty for security
            #endif
        }()
        static let password: String = {
            #if DEBUG
                #if INTEGRATIONQA
                if Constant.API.useBasicAuth {
                    return "password"
                } else {
                    return ":a4>5{:M83AJ4s#"
                }
                #elseif PREPROD
                return "Ctg2035Test!"
                #elseif PROD
                return ""
                #else
                return "" // Should be kept empty for security
                #endif
            #else
            return "" // Should be kept empty for security
            #endif
        }()
    }
    
    enum AppCenter {
        static let secret: String = {
            #if INTEGRATIONQA
            return "2f5e4cff-672a-4928-9ff3-c12295ce6169"
            #elseif PREPROD
            return "ca2aa1c3-2778-48fd-8972-691342b99b56"
            #elseif PROD
            return "b28e0acd-9737-4adb-a08a-a8813fe76547"
            #else
            return "" //TODO : STORE ?
            #endif
        }()
    }
    
    enum Notification {
        
        enum Tags {
            static let user = "iduser:"
            static let token = "token:"
        }
        
        enum Code: Int {
            case general = 1
            case myTask = 2
            case myFavorite = 3
        }
    }
    
    enum API {
        static let baseUrl: String = {
            #if INTEGRATIONQA
            return "https://int.musesoftware.citegestion.fr/pf/dm/gmo/api/v1"
            #elseif PREPROD
            return "https://muse-pp.ondijon.fr/pf/gmo/api/v1"
            #else
            return "https://muse.ondijon.fr/pf/gmo/api/v1"
            #endif
        }()
        
        static let mockFileUrl: Bool = {
            return false
        }()
        
        static let useBasicAuth: Bool = {
            return false
        }()
        
        enum HeadersName {
            static let apiKey = "X-ApiKey"
            static let mapProjection = "X-Map-Preferred-Projection"
            static let correlationId = "X-Correlation-ID"
            static let authorization = "Authorization"
            static let ifRange = "If-Range"
            static let lastModified = "Last-Modified"
            static let ifModifiedSince = "If-Modified-Since"
        }
        
        enum EndPoint {
            private static let configurationPart = "/configuration"
            private static let configurationMapPart = "/mapSecureConfiguration"
            private static let taskPart = "/task"
            private static let referentialPart = "/referential"
            private static let favoritePart = "/favorite"
            private static let workflowNextPart = "/workflow/next"
            private static let stepsPart = "/steps"
            private static let assignablePart = "/assignable"
            private static let changeServicePart = "/transferService"
            private static let servicePart = "/service"
            private static let userPart = "/user"
            private static let notificationPart = "/notification"
            private static let notificationTokenPart = "/token"
            private static let filePart = "/file"
            private static let workflowCancelPart = "/workflow/cancel"
            private static let workflowUndoPart = "/workflow/undo"
            private static let workflowRejectPart = "/workflow/reject"
            
            private static var baseUrlDynamic: String {
                guard let configuration = AppDynamicConfiguration.current() else {
                    return Constant.API.baseUrl
                }
                
                if configuration.apiUrl.hasSuffix("/") {
                    return String(configuration.apiUrl.dropLast())
                }
                return configuration.apiUrl
            }
            
            static var login: String {
                guard let configuration = AppDynamicConfiguration.current() else {
                    return Constant.API.baseUrl
                }
                
                if configuration.loginUrl.hasSuffix("/") {
                    return String(configuration.loginUrl.dropLast())
                }
                return configuration.loginUrl
            }
            
            static var refresh: String {
                guard let configuration = AppDynamicConfiguration.current() else {
                    return Constant.API.baseUrl
                }
                
                if configuration.refreshUrl.hasSuffix("/") {
                    return String(configuration.refreshUrl.dropLast())
                }
                return configuration.refreshUrl
            }
            
            static let configuration: String = {
                return "\(Constant.API.baseUrl)\(Constant.API.EndPoint.configurationPart)"
            }()
            
            static var configurationMap: String {
                return "\(Constant.API.EndPoint.baseUrlDynamic)\(Constant.API.EndPoint.configurationMapPart)"
            }
            
            static var tasks: String {
                return "\(Constant.API.EndPoint.baseUrlDynamic)\(Constant.API.EndPoint.taskPart)"
            }
            
            static var steps: String {
                return "\(Constant.API.EndPoint.baseUrlDynamic)\(Constant.API.EndPoint.taskPart)/\(Constant.API.EndPoint.taskPart)"
            }
            
            static var file: String {
                return "\(Constant.API.EndPoint.baseUrlDynamic)\(Constant.API.EndPoint.filePart)"
            }
            
            static func task(byId id: Int) -> String {
                return "\(Constant.API.EndPoint.baseUrlDynamic)\(Constant.API.EndPoint.taskPart)/\(id)"
            }
            
            static func steps(byId id: Int) -> String {
                return "\(Constant.API.EndPoint.baseUrlDynamic)\(Constant.API.EndPoint.taskPart)/\(id)\(Constant.API.EndPoint.stepsPart)"
            }
            
            static func editSteps(byTaskId taskId: Int, stepId: Int) -> String {
                return "\(Constant.API.EndPoint.baseUrlDynamic)\(Constant.API.EndPoint.taskPart)/\(taskId)\(Constant.API.EndPoint.stepsPart)/\(stepId)"
            }
            
            static func taskAssignable(byId id: Int) -> String {
                return "\(Constant.API.EndPoint.baseUrlDynamic)\(Constant.API.EndPoint.taskPart)/\(id)\(Constant.API.EndPoint.assignablePart)"
            }
            
            static func taskServices(byId id: Int) -> String {
                return "\(Constant.API.EndPoint.baseUrlDynamic)\(Constant.API.EndPoint.taskPart)/\(id)\(Constant.API.EndPoint.servicePart)"
            }
            
            static func taskServiceChange(byId id: Int) -> String {
                return "\(Constant.API.EndPoint.baseUrlDynamic)\(Constant.API.EndPoint.taskPart)/\(id)\(Constant.API.EndPoint.changeServicePart)"
            }
            
            static func workflowNext(forTaskId id: Int) -> String {
                return "\(task(byId: id))/\(Constant.API.EndPoint.workflowNextPart)"
            }
            
            static func workflowReject(forTaskId id: Int) -> String {
                return "\(task(byId: id))/\(Constant.API.EndPoint.workflowRejectPart)"
            }
            
            static func workflowCancel(forTaskId id: Int) -> String {
                return "\(task(byId: id))/\(Constant.API.EndPoint.workflowCancelPart)"
            }
            
            static func workflowUndo(forTaskId id: Int) -> String {
                return "\(task(byId: id))/\(Constant.API.EndPoint.workflowUndoPart)"
            }
            
            static var referential: String {
                return "\(Constant.API.EndPoint.baseUrlDynamic)\(Constant.API.EndPoint.referentialPart)"
            }
            
            static var user: String {
                return "\(Constant.API.EndPoint.baseUrlDynamic)\(Constant.API.EndPoint.userPart)"
            }
            
            static func file(byUUID uuid: String) -> String {
                return "\(Constant.API.EndPoint.baseUrlDynamic)\(Constant.API.EndPoint.filePart)/\(uuid)"
            }
            
            static func favorite(byTaskId id: Int) -> String {
                return "\(Constant.API.EndPoint.baseUrlDynamic)\(Constant.API.EndPoint.favoritePart)/\(id)"
            }
            
            static var favorite: String {
                return "\(Constant.API.EndPoint.baseUrlDynamic)\(Constant.API.EndPoint.favoritePart)"
            }
            
            static func notification(withToken id: String) -> String {
                return "\(Constant.API.EndPoint.baseUrlDynamic)\(Constant.API.EndPoint.notificationPart)\(Constant.API.EndPoint.notificationTokenPart)/\(id)"
            }
            
            static var notification: String {
                return "\(Constant.API.EndPoint.baseUrlDynamic)\(Constant.API.EndPoint.notificationPart)"
            }
        }
        
        enum OAuth {
            static let oAuthClientScope = "openid"
            static let grantTypePassword = "password"
            static let grantTypeRefresh = "refresh_token"
        }
        
        enum Durations {
            static let timoutMs: TimeInterval = 60000
            static let fetchDelayConfiguration: TimeInterval = 600000 // 10hours
            static let fetchDelayUser: TimeInterval = 600 // 10hours
            static let fetchDelayTasks: TimeInterval = 300 // 5min
            static let fetchDelayNotification: TimeInterval = 1 // 5min
            static let fetchDelayLocalisation: TimeInterval = 600 // 10min
            static let fetchDelayFavorite: TimeInterval = {
                #if DEBUG
                return 1
                #else
                return 300 // 5min
                #endif
            }()
        }
        
    }
    
    enum Map {
        static let mapGeocoderUrl = "https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer"
        static let mapReverseGeocoderUrl = "/reverseGeocode?f=json&featureTypes=PointAddress,StreetName,Locality,StreetAddress&forStorage=0&distance=5000&returnIntersection=0&location=%7B%22x%22:{PointX},%22y%22:{PointY},%22spatialReference%22:%7B%22wkid%22:102100,%22latestWkid%22:3857%7D%7D"
        static let defaultProjection = 4326
        static let defaultZoom = 7000
        static let defaultZoneMinimalZoom = 9028
        static let mapClusterTolerance = 10.0
        
        enum BaseMap: String {
            case none = "NONE"
            case darkGrayCanvasVector = "DARK_GRAY_CANVAS_VECTOR"
            case imagery = "IMAGERY"
            case imageryWithLabels = "IMAGERY_WITH_LABELS"
            case imageryWithLabelsVector = "IMAGERY_WITH_LABELS_VECTOR"
            case lightGrayCanvas = "LIGHT_GRAY_CANVAS"
            case lightGrayCanvasVector = "LIGHT_GRAY_CANVAS_VECTOR"
            case nationalGeographic = "NATIONAL_GEOGRAPHIC"
            case navigationVector = "NAVIGATION_VECTOR"
            case oceans = "OCEANS"
            case openStreetMap = "OPEN_STREET_MAP"
            case streets = "STREETS"
            case streetsNightVector = "STREETS_NIGHT_VECTOR"
            case streetsWithReliefVector = "STREETS_WITH_RELIEF_VECTOR"
            case streetsVector = "STREETS_VECTOR"
            case topographic = "TOPOGRAPHIC"
            case terrainWithLabels = "TERRAIN_WITH_LABELS"
            case terrainWithLabelsVector = "TERRAIN_WITH_LABELS_VECTOR"
            case topographicVector = "TOPOGRAPHIC_VECTOR"
            
            var arcgis: AGSBasemapType? {
                switch self {
                case .darkGrayCanvasVector:
                    return .darkGrayCanvasVector
                case .imagery:
                    return .imagery
                case .imageryWithLabels:
                    return .imageryWithLabels
                case .imageryWithLabelsVector:
                    return .imageryWithLabelsVector
                case .lightGrayCanvas:
                    return .lightGrayCanvas
                case .lightGrayCanvasVector:
                    return .lightGrayCanvasVector
                case .nationalGeographic:
                    return .nationalGeographic
                case .navigationVector:
                    return .navigationVector
                case .oceans:
                    return .oceans
                case .openStreetMap:
                    return .openStreetMap
                case .streets:
                    return .streets
                case .streetsNightVector:
                    return .streetsNightVector
                case .streetsWithReliefVector:
                    return .streetsWithReliefVector
                case .streetsVector:
                    return .streetsVector
                case .topographic:
                    return .topographic
                case .terrainWithLabels:
                    return .terrainWithLabels
                case .terrainWithLabelsVector:
                    return .terrainWithLabelsVector
                case .topographicVector:
                    return .topographicVector
                default:
                    return nil
                }
            }
        }
    }
}

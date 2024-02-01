//
//  DateHelper.swift
//  GCI
//
//  Created by Florian ALONSO on 3/11/19.
//  Copyright © 2019 Citegestion. All rights reserved.
//

import Foundation

struct DateHelper {
    // 1500996359910
    static func timestampMilliToLocalDate(_ valueMiliDouble: Double) -> Date {
        let valueSec = valueMiliDouble / 1000
        return Date(timeIntervalSince1970: valueSec)
    }
    static func localDateToTimestampMilli(_ date: Date) -> Double {
        let timestampSec = date.timeIntervalSince1970
        return timestampSec * 1000.0
    }
    
    // 2015-10-21T07:28:51+01:00
    static let requestDateFormater: DateFormatter = {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return dateFormater
    }()
    
    //Wed, 21 Oct 2015 07:28:00 GMT
    static let ifRangeDateFormater: DateFormatter = {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "E, dd MMM yyyy HH:mm:ss 'GMT'"
        dateFormater.timeZone = TimeZone(identifier: "GMT")
        dateFormater.locale = Locale(identifier: "en_US")
        return dateFormater
    }()
}

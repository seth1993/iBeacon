/*
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
//  ibeacons.swift
//  iBeacon
//
//  Created by Seth Bailey on 9/21/18.
//  Copyright © 2018 Seth Bailey. All rights reserved.
//

import Foundation
import CoreLocation


struct ItemConstant {
    static let nameKey = "name"
    static let uuidKey = "uuid"
    static let majorKey = "major"
    static let minorKey = "minor"
    static let throwKey = "throwsValue"
}

class IBeaconItem: NSObject, NSCoding {
    let name: String
    let uuid: UUID
    let majorValue: CLBeaconMajorValue
    let minorValue: CLBeaconMinorValue
    var beacon: CLBeacon?
    let throwsValue: Int
    
    
    init(name: String, uuid: UUID, majorValue: Int, minorValue: Int, throwsValue: Int) {
        self.name = name
        self.uuid = uuid
        self.majorValue = CLBeaconMajorValue(majorValue)
        self.minorValue = CLBeaconMinorValue(minorValue)
        self.throwsValue = throwsValue
    }
    
    required init(coder aDecoder: NSCoder) {
        let aName = aDecoder.decodeObject(forKey: ItemConstant.nameKey) as? String
        name = aName ?? ""
        
        let aUUID = aDecoder.decodeObject(forKey: ItemConstant.uuidKey) as? UUID
        uuid = aUUID ?? UUID()
        
        majorValue = UInt16(aDecoder.decodeInteger(forKey: ItemConstant.majorKey))
        minorValue = UInt16(aDecoder.decodeInteger(forKey: ItemConstant.minorKey))
        throwsValue = Int(aDecoder.decodeInteger(forKey: ItemConstant.throwKey))
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: ItemConstant.nameKey)
        aCoder.encode(uuid, forKey: ItemConstant.uuidKey)
        aCoder.encode(Int(majorValue), forKey: ItemConstant.majorKey)
        aCoder.encode(Int(minorValue), forKey: ItemConstant.minorKey)
        aCoder.encode(Int(throwsValue), forKey: ItemConstant.throwKey)
    }
    
    func asBeaconRegion() -> CLBeaconRegion {
        return CLBeaconRegion(proximityUUID: uuid,
                              major: majorValue,
                              minor: minorValue,
                              identifier: name)
    }
    
    func nameForProximity(_ proximity: CLProximity) -> String {
        switch proximity {
        case .unknown:
            return "Unknown"
        case .immediate:
            return "Less than 15' away"
        case .near:
            return "Less than 3' away"
        case .far:
            return "Over 20' away"
        }
    }
    
    func locationString() -> String {
        guard let beacon = beacon else { return "iBeacon not found" }
        let proximity = nameForProximity(beacon.proximity)
        let accuracy = String(format: "%.2f", beacon.accuracy)
        
        var location = "Location: \(proximity)"
        if beacon.proximity != .unknown {
            location += " (approx. \(accuracy)m)"
        }
        
        return location
    }
    
}


func ==(item: IBeaconItem, beacon: CLBeacon) -> Bool {
    return ((beacon.proximityUUID.uuidString == item.uuid.uuidString)
        && (Int(beacon.major) == Int(item.majorValue))
        && (Int(beacon.minor) == Int(item.minorValue)))
}

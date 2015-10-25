//
//  PhoneCaseDevice.swift
//  Blagaprint
//
//  Created by Иван Магда on 25.10.15.
//  Copyright © 2015 Blagaprint. All rights reserved.
//

import Foundation

/// Supported phone case company.
private let AppleInc = "Apple"
/// Supported phone case company.
private let SamsungInc = "Samsung"

/// Supported device.
private let IPhone = "iPhone"
/// Supported device.
private let GalaxyS = "Galaxy S"

struct Device {
    // MARK: - Properties
    let name: String
    let manufacturer: String
    
    // MARK: - Methods
    func descriptionFromDevice() -> String {
        return "\(manufacturer) \(name)"
    }
    
    // MARK: - Supported Phone Case Devices
    
    static func iPhone4() -> Device {
        return Device(name: "\(IPhone) 4/4S", manufacturer: AppleInc)
    }
    
    static func iPhone5() -> Device {
        return Device(name: "\(IPhone) 5/5S", manufacturer: AppleInc)
    }
    
    static func iPhone6() -> Device {
        return Device(name: "\(IPhone) 6/6S", manufacturer: AppleInc)
    }
    
    static func iPhone6Plus() -> Device {
        return Device(name: "\(IPhone) 6/6S Plus", manufacturer: AppleInc)
    }
    
    static func galaxyS3() -> Device {
        return Device(name: "\(GalaxyS)3", manufacturer: SamsungInc)
    }
    
    static func galaxyS4() -> Device {
        return Device(name: "\(GalaxyS)4", manufacturer: SamsungInc)
    }
    
    static func galaxyS4Mini() -> Device {
        return Device(name: "\(GalaxyS)4 Mini", manufacturer: SamsungInc)
    }
    
    static func galaxyS5() -> Device {
        return Device(name: "\(GalaxyS)5", manufacturer: SamsungInc)
    }
    
    static func galaxyS5Mini() -> Device {
        return Device(name: "\(GalaxyS)5 Mini", manufacturer: SamsungInc)
    }
    
    static func allDevices() -> [Device] {
        return [iPhone4(), iPhone5(), iPhone6(), iPhone6Plus(), galaxyS3(), galaxyS4(), galaxyS4Mini(), galaxyS5(), galaxyS5Mini()]
    }
}
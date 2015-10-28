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
/// Supported device.
private let Galaxy = "Galaxy"

struct Device {
    // MARK: - Properties
    let name: String
    let manufacturer: String
    
    // MARK: - Methods
    
    func descriptionFromDevice() -> String {
        return "\(manufacturer) \(name)"
    }
    
    static func companies() -> [String] {
        return [AppleInc, SamsungInc]
    }
    
    static func numberOfCompanies() -> Int {
        return companies().count
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
    
    static func galaxyA3() -> Device {
        return Device(name: "\(Galaxy) A3", manufacturer: SamsungInc)
    }
    
    static func galaxyA5() -> Device {
        return Device(name: "\(Galaxy) A5", manufacturer: SamsungInc)
    }
    
    static func galaxyA7() -> Device {
        return Device(name: "\(Galaxy) A7", manufacturer: SamsungInc)
    }
    
    static func allDevices() -> [Device] {
        return [iPhone4(), iPhone5(), iPhone6(), iPhone6Plus(), galaxyS3(), galaxyS4Mini(), galaxyS4(), galaxyS5Mini(), galaxyS5(), galaxyA3(), galaxyA5(), galaxyA7()]
    }
}
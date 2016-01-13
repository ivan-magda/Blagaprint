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
/// Supported phone case company.
private let SonyInc = "Sony"
/// Supported phone case company.
private let XiaomiInc = "Xiaomi"
/// Supported phone case company.
private let LenovoInc = "Lenovo"

/// Supported device.
private let IPhone = "iPhone"
/// Supported device.
private let Galaxy = "Galaxy"
/// Supported device.
private let Xperia = "Xperia"

struct Device {
    //--------------------------------------
    // MARK: - Properties
    //--------------------------------------
    
    let name: String
    let manufacturer: String
    
    //--------------------------------------
    // MARK: - Methods
    //--------------------------------------
    
    func descriptionFromDevice() -> String {
        return "\(manufacturer) \(name)"
    }
    
    static func companies() -> [String] {
        return [AppleInc, SamsungInc, SonyInc, XiaomiInc, LenovoInc]
    }
    
    static func numberOfCompanies() -> Int {
        return companies().count
    }
    
    //--------------------------------------
    // MARK: - Supported Phone Case Devices
    //--------------------------------------
    
    static func allDevices() -> [Device] {
        return [iPhone4(), iPhone5(), iPhone6(), iPhone6Plus(), galaxyS3(), galaxyS4(), galaxyS4Mini(), galaxyS5(), galaxyS5Mini(), galaxyS6(), galaxyS6Edge(), galaxyA3(), galaxyA5(), galaxyA7(), galaxyNote2(), galaxyNote3(), galaxyNote4(), sonyXperiaZ1(), sonyXperiaZ1Compact(), sonyXperiaZ2(), sonyXperiaZ2Compact(), sonyXperiaZ3(), sonyXperiaZ3Compact(), xiaomiMi4(), lenovoS850()]
    }
    
    //--------------------------------------
    // MARK: Apple
    //--------------------------------------
    
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
    
    //--------------------------------------
    // MARK: Samsung
    //--------------------------------------
    
    static func galaxyS3() -> Device {
        return Device(name: "\(Galaxy) S3", manufacturer: SamsungInc)
    }
    
    static func galaxyS4() -> Device {
        return Device(name: "\(Galaxy) S4", manufacturer: SamsungInc)
    }
    
    static func galaxyS4Mini() -> Device {
        return Device(name: "\(Galaxy) S4 Mini", manufacturer: SamsungInc)
    }
    
    static func galaxyS5() -> Device {
        return Device(name: "\(Galaxy) S5", manufacturer: SamsungInc)
    }
    
    static func galaxyS5Mini() -> Device {
        return Device(name: "\(Galaxy) S5 Mini", manufacturer: SamsungInc)
    }
    
    static func galaxyS6() -> Device {
        return Device(name: "\(Galaxy) S6", manufacturer: SamsungInc)
    }
    
    static func galaxyS6Edge() -> Device {
        return Device(name: "\(Galaxy) S6 Edge", manufacturer: SamsungInc)
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
    
    static func galaxyNote2() -> Device {
        return Device(name: "\(Galaxy) Note 2", manufacturer: SamsungInc)
    }
    
    static func galaxyNote3() -> Device {
        return Device(name: "\(Galaxy) Note 3", manufacturer: SamsungInc)
    }
    
    static func galaxyNote4() -> Device {
        return Device(name: "\(Galaxy) Note 4", manufacturer: SamsungInc)
    }
    
    //--------------------------------------
    // MARK: Sony
    //--------------------------------------

    static func sonyXperiaZ1() -> Device {
        return Device(name: "\(Xperia) Z1", manufacturer: SonyInc)
    }
    
    static func sonyXperiaZ2() -> Device {
        return Device(name: "\(Xperia) Z2", manufacturer: SonyInc)
    }
    
    static func sonyXperiaZ3() -> Device {
        return Device(name: "\(Xperia) Z3", manufacturer: SonyInc)
    }
    
    static func sonyXperiaZ1Compact() -> Device {
        return Device(name: "\(Xperia) Z1 Compact", manufacturer: SonyInc)
    }
    
    static func sonyXperiaZ2Compact() -> Device {
        return Device(name: "\(Xperia) Z2 Compact", manufacturer: SonyInc)
    }
    
    static func sonyXperiaZ3Compact() -> Device {
        return Device(name: "\(Xperia) Z3 Compact", manufacturer: SonyInc)
    }

    //--------------------------------------
    // MARK: Xiaomi
    //--------------------------------------
    
    static func xiaomiMi4() -> Device {
        return Device(name: "Mi4", manufacturer: XiaomiInc)
    }
    
    //--------------------------------------
    // MARK: Lenovo
    //--------------------------------------
    
    static func lenovoS850() -> Device {
        return Device(name: "S850", manufacturer: LenovoInc)
    }
}
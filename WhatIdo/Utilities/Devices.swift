//
//  Devices.swift
//  WhatIdo
//
//  Created by eytsam elahi on 29/04/2025.
//


import Foundation
import UIKit

enum Devices {
    case promax
    case pro
    case base
}

extension UIScreen {
    static let isNarrowDevice: Bool = {
        let device = UIDevice()
        let deviceIdiom = device.userInterfaceIdiom
        if deviceIdiom == .phone {
            let height = UIScreen.main.nativeBounds.height
            switch height {
            case 1136:
                print("iPhone 5 or 5S or 5C")
                return true
            case 1334:
                print("iPhone 6/6S/7/8")
                return true
            case 1920, 2208:
                print("iPhone 6+/6S+/7+/8+")
                return true
            case 2436:
                print("iPhone X/XS/11 Pro")
                return false
            case 2688:
                print("iPhone XS Max/11 Pro Max")
                return false
            case 1792:
                print("iPhone XR/11")
                return false
            case 2340:
                print("iPhone 12 mini")
                return true
            case 2532:
                print("iPhone 12/12 Pro/13/13 Pro/14")
                return false
            case 2778:
                print("iPhone 12 Pro Max/13 Pro Max/14 Plus")
                return false
            case 2796:
                print("iPhone 14 Pro Max, iPhone 15 Pro Max")
                return false
            case 2556:
                print("iPhone 14 Pro")
                return false
            case 2500:
                print("iPhone 15")
                return false
            default:
                return false
            }
        } else {
            return false
        }
    }()

    static var deviceSizeType: Devices {
        let device = UIDevice()
        if device.userInterfaceIdiom == .phone {
            let height = UIScreen.main.nativeBounds.height
            switch height {
            case 2400...2580:
                return .pro
            case 2600...2800:
                return .promax
            case 1334...2350:
                return .base
            default:
                return .base
            }
        } else {
            return .base
        }
    }
}

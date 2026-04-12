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
            case 1136: return true           // iPhone 5/5S/5C
            case 1334: return true           // iPhone 6/6S/7/8
            case 1920, 2208: return true     // iPhone 6+/6S+/7+/8+
            case 2436: return false          // iPhone X/XS/11 Pro
            case 2688: return false          // iPhone XS Max/11 Pro Max
            case 1792: return false          // iPhone XR/11
            case 2340: return true           // iPhone 12 mini
            case 2532: return false          // iPhone 12/12 Pro/13/13 Pro/14
            case 2778: return false          // iPhone 12 Pro Max/13 Pro Max/14 Plus
            case 2796: return false          // iPhone 14 Pro Max/15 Pro Max
            case 2556: return false          // iPhone 14 Pro
            case 2500: return false          // iPhone 15
            default: return false
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

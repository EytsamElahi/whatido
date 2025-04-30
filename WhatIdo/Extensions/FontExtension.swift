//
//  FontExtension.swift
//  WhatIdo
//
//  Created by eytsam elahi on 29/04/2025.
//

import UIKit
import SwiftUI

enum FontType: String {
    case thin = "Thin"
    case medium = "Medium"
    case regular = "Regular"
    case black = "Black"
    case semiBold = "SemiBold"
    case bold = "Bold"
    case light = "Light"
    case extraBold = "ExtraBold"
}
enum FontFamily: String {
    case quicksand = "Quicksand"
    case inter = "Inter"
}

//Custom font size
enum FontSize {
    case x8
    case x10
    case x12
    case x14
    case x16
    case x18
    case x20
    case x22
    case x24
    case x26
    case x28
    case x30
    case x34
    case x50

    var isNarrow: Bool {
        return UIScreen.isNarrowDevice
    }

    var value: CGFloat {
        switch self {
        case .x8:
            isNarrow ? 7.0 : 8.0
        case .x10:
            isNarrow ? 9.0 : 10.0
        case .x12:
            isNarrow ? 10.0 : 12.0
        case .x14:
            isNarrow ? 12.0 : 14.0
        case .x16:
            isNarrow ? 13.0 : 16.0
        case .x18:
            isNarrow ? 15.0 : 18.0
        case .x20:
            isNarrow ? 16.0 : 20.0
        case .x22:
            isNarrow ? 18.0 : 22.0
        case .x24:
            isNarrow ? 20.0 : 24.0
        case .x26:
            isNarrow ? 22.0 : 26.0
        case .x28:
            isNarrow ? 24.0 : 28.0
        case .x30:
            isNarrow ? 25.0 : 30.0
        case .x34:
            isNarrow ? 28.0 : 34.0
        case .x50:
            isNarrow ? 38.0 : 50.0
        }
    }

}

//Set Custom font and size
extension Font {
    static func customFont(family: FontFamily? = nil, name: FontType, size: FontSize) -> Font {
        return Font.custom("\(family ?? FontFamily.quicksand)-\(name.rawValue)", size: size.value)
    }
}

//
//  ViewExtension.swift
//  WhatIdo
//
//  Created by eytsam elahi on 30/04/2025.
//

import SwiftUI
import UIKit

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
     func hideKeyboardOnTapAround() -> some View {
        return self.onTapGesture {
            hideKeyboard()
        }
    }
}

struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

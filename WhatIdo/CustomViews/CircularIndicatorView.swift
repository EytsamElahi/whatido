//
//  CircularIndicatorView.swift
//  WhatIdo
//
//  Created by eytsam elahi on 17/05/2025.
//

import SwiftUI

struct CircularLoadingIndicator: View {
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 6)

            Circle()
                .trim(from: 0, to: 0.3)
                .stroke(
                    AngularGradient(gradient: Gradient(colors: [.appPrimaryColor]), center: .center),
                    style: StrokeStyle(lineWidth: 6, lineCap: .round)
                )
                .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false), value: isAnimating)
        }
        .frame(width: 25, height: 25)
        .onAppear {
            isAnimating = true
        }
    }
}

#Preview {
    CircularLoadingIndicator()
}

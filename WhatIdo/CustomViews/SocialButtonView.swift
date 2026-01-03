//
//  SocialButtonView.swift
//  WhatIdo
//
//  Created by eytsam elahi on 31/12/2025.
//

import SwiftUI

struct SocialButtonView: View {
    var image : ImageResource = .apple
    var title : String = "Sign up with Apple"
    var backgroundColor : Color = .white
    var fontColor: Color = .black
    var imageWidth: Double = 20.0
    var imageHeight: Double = 20.0
    var cornerRadius: Double? = nil
    var height: Double? = nil
    var action : (() -> Void)? = nil

    var body: some View {
        Button(action: {
            action?()
        }, label: {
            HStack {
                Image(image)
                    .resizable()
                    .frame(width: imageWidth,height: imageHeight)
                Text(title)
                    .font(.customFont(family: .quicksand, name: .bold, size: .x14))
                    .foregroundStyle(fontColor)
               
            }
            .frame(maxWidth: .infinity)
            .frame(maxHeight: .infinity)
        })
        .background(backgroundColor)
        .frame(height: height ?? 40)
        .cornerRadius(cornerRadius ?? 20)
    }
}

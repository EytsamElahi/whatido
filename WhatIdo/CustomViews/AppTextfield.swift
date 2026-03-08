//
//  AppTextfield.swift
//  WhatIdo
//
//  Created by eytsam elahi on 30/04/2025.
//

import SwiftUI

//struct AppTextfield: View {
//    @Binding var inputText: String
//    var placeHolder: String
//    var keyboardType: UIKeyboardType = .default
//    var body: some View {
//        ZStack(content: {
//            RoundedRectangle(cornerRadius: 10)
//                .stroke(Color.gray, lineWidth: 1)
//            TextField(text: $inputText) {
//                Text(placeHolder)
//                    .font(.customFont(name: .regular, size: .x16))
//            }
//            .keyboardType(keyboardType)
//            .font(.customFont(name: .medium, size: .x16))
//            .frame(maxHeight: .infinity)
//            .frame(maxWidth: .infinity)
//            .padding(10)
//        })
//    }
//}

struct AppTextfield: View {
  @Binding var inputText: String
  var placeHolder: String
  var keyboardType: UIKeyboardType = .default
  var maxLength: Int? = nil
  var leadingIcon: String? = nil
  var trailingIcon: String? = nil
  var isFocused: FocusState<Bool>.Binding?
  var enableKeyboardAdaptive: Bool = false

  var body: some View {
    ZStack(alignment: .leading) {
      // Dark Background Pill
      RoundedRectangle(cornerRadius: 12)
        .fill(Color.white.opacity(0.08)) // Subtle fill

      HStack {
        if let leadingIcon = leadingIcon {
          Image(systemName: leadingIcon)
            .font(.caption)
            .foregroundColor(.black)
            .frame(width: 30, height: 30)
            .background(Color.appPrimaryColor)
            .clipShape(Circle())
            .animation(.spring(), value: leadingIcon)
            .padding(.leading, 10)
        }
        ZStack(alignment: .leading) {
          // Placeholder Logic
          if inputText.isEmpty {
            Text(placeHolder)
              .font(.customFont(name: .regular, size: .x16))
              .foregroundColor(Color.white.opacity(0.3))
              .fixedSize(horizontal: true, vertical: false)
              .allowsHitTesting(false)
              .padding(.leading, 15)
          }

          textField
        }
      }
    }
    .modifier(KeyboardAdaptiveOptional(enabled: enableKeyboardAdaptive))
  }

  @ViewBuilder
  private var textField: some View {
    if let focusBinding = isFocused {
      TextField("", text: $inputText)
        .font(.customFont(name: .medium, size: .x16))
        .foregroundColor(.white)
        .padding(.horizontal, 15)
        .keyboardType(keyboardType)
        .tint(Color.appPrimaryColor)
        .focused(focusBinding)
        .limitInputLength($inputText, maxLength: maxLength ?? 200)
    } else {
      TextField("", text: $inputText)
        .font(.customFont(name: .medium, size: .x16))
        .foregroundColor(.white)
        .padding(.horizontal, 15)
        .keyboardType(keyboardType)
        .tint(Color.appPrimaryColor)
        .limitInputLength($inputText, maxLength: maxLength ?? 200)
    }
  }
}

// MARK: - Optional Keyboard Adaptive Modifier
private struct KeyboardAdaptiveOptional: ViewModifier {
  let enabled: Bool

  func body(content: Content) -> some View {
    if enabled {
      content.keyboardAdaptive()
    } else {
      content
    }
  }
}

#Preview {
  AppTextfield(inputText: .constant(""), placeHolder: "Spending")
}

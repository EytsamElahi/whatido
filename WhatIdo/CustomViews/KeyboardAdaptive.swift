//
//  KeyboardAdaptive.swift
//  WhatIdo
//
//  Created by Claude on 31/01/2026.
//

import SwiftUI
import Combine

// MARK: - Keyboard Height Publisher
extension Publishers {
  static var keyboardHeight: AnyPublisher<CGFloat, Never> {
    let willShow = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
      .map { notification -> CGFloat in
        (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0
      }

    let willHide = NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
      .map { _ -> CGFloat in 0 }

    return MergeMany(willShow, willHide)
      .eraseToAnyPublisher()
  }
}

// MARK: - Keyboard Responsive Modifier
struct KeyboardAdaptive: ViewModifier {
  @State private var keyboardHeight: CGFloat = 0
  @State private var viewFrame: CGRect = .zero
  let additionalPadding: CGFloat

  init(additionalPadding: CGFloat = 20) {
    self.additionalPadding = additionalPadding
  }

  func body(content: Content) -> some View {
    content
      .background(
        GeometryReader { geometry in
          Color.clear
            .onAppear {
              viewFrame = geometry.frame(in: .global)
            }
            .onChange(of: geometry.frame(in: .global)) { newFrame in
              viewFrame = newFrame
            }
        }
      )
      .offset(y: calculateOffset())
      .animation(.easeOut(duration: 0.25), value: keyboardHeight)
      .onReceive(Publishers.keyboardHeight) { height in
        keyboardHeight = height
      }
  }

  private func calculateOffset() -> CGFloat {
    guard keyboardHeight > 0 else { return 0 }

    let screenHeight = UIScreen.main.bounds.height
    let keyboardTop = screenHeight - keyboardHeight
    let viewBottom = viewFrame.maxY

    // If the view is covered by keyboard, slide it up
    if viewBottom > keyboardTop {
      let overlap = viewBottom - keyboardTop + additionalPadding
      return -overlap
    }

    return 0
  }
}

// MARK: - View Extension
extension View {
  func keyboardAdaptive(additionalPadding: CGFloat = 20) -> some View {
    modifier(KeyboardAdaptive(additionalPadding: additionalPadding))
  }
}

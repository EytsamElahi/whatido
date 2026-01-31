//
//  FlexibleBottomSheet.swift
//  WhatIdo
//
//  Created by Claude on 31/01/2026.
//

import SwiftUI

// MARK: - Height Preference Key
struct ContentHeightKey: PreferenceKey {
  static var defaultValue: CGFloat = 0
  static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
    value = max(value, nextValue())
  }
}

// MARK: - Flexible Bottom Sheet
struct FlexibleBottomSheet<Content: View>: View {
  @Binding var isPresented: Bool
  let minHeight: CGFloat
  let maxHeight: CGFloat
  let interactiveDismissDisabled: Bool
  let content: () -> Content

  @State private var contentHeight: CGFloat = 0
  @State private var dragOffset: CGFloat = 0

  private var calculatedHeight: CGFloat {
    let baseHeight = min(max(contentHeight + 60, minHeight), maxHeight)
    return max(baseHeight - dragOffset, minHeight * 0.5)
  }

  init(
    isPresented: Binding<Bool>,
    minHeight: CGFloat = 200,
    maxHeight: CGFloat = UIScreen.main.bounds.height * 0.9,
    interactiveDismissDisabled: Bool = false,
    @ViewBuilder content: @escaping () -> Content
  ) {
    self._isPresented = isPresented
    self.minHeight = minHeight
    self.maxHeight = maxHeight
    self.interactiveDismissDisabled = interactiveDismissDisabled
    self.content = content
  }

  var body: some View {
    ZStack(alignment: .bottom) {
      // Dimmed background
      if isPresented {
        Color.black.opacity(0.4)
          .ignoresSafeArea()
          .onTapGesture {
            hideKeyboard()
            if !interactiveDismissDisabled {
              dismissSheet()
            }
          }
          .transition(.opacity)
      }

      // Sheet container - only render content when presented
      if isPresented {
        VStack(spacing: 0) {
          // Drag indicator
          dragIndicator
            .padding(.top, 8)
            .padding(.bottom, 4)

          // Content with height measurement
          ScrollView {
            content()
              .background(
                GeometryReader { contentGeometry in
                  Color.clear.preference(
                    key: ContentHeightKey.self,
                    value: contentGeometry.size.height
                  )
                }
              )
          }
          .scrollDisabled(contentHeight + 60 <= calculatedHeight)
        }
        .frame(height: calculatedHeight)
        .frame(maxWidth: .infinity)
        .background(Color.cardBackground)
        .clipShape(RoundedCorner(radius: 24, corners: [.topLeft, .topRight]))
        .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: -5)
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .gesture(dragGesture)
        .onPreferenceChange(ContentHeightKey.self) { height in
          withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            contentHeight = height
          }
        }
        .transition(.move(edge: .bottom))
      }
    }
    .animation(.spring(response: 0.35, dampingFraction: 0.8), value: isPresented)
    .onChange(of: isPresented) { presented in
      if !presented {
        // Reset state when dismissed
        contentHeight = 0
        dragOffset = 0
      }
    }
  }

  // MARK: - Drag Indicator
  private var dragIndicator: some View {
    Capsule()
      .fill(Color.white.opacity(0.3))
      .frame(width: 36, height: 4)
  }

  // MARK: - Drag Gesture
  private var dragGesture: some Gesture {
    DragGesture()
      .onChanged { value in
        guard !interactiveDismissDisabled else { return }
        let translation = value.translation.height
        if translation > 0 {
          dragOffset = translation
        }
      }
      .onEnded { value in
        guard !interactiveDismissDisabled else {
          withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            dragOffset = 0
          }
          return
        }
        let velocity = value.predictedEndTranslation.height - value.translation.height
        if value.translation.height > 100 || velocity > 500 {
          hideKeyboard()
          dismissSheet()
        } else {
          withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            dragOffset = 0
          }
        }
      }
  }

  private func dismissSheet() {
    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
      dragOffset = 0
      isPresented = false
    }
  }

  private func hideKeyboard() {
    UIApplication.shared.sendAction(
      #selector(UIResponder.resignFirstResponder),
      to: nil,
      from: nil,
      for: nil
    )
  }
}

// MARK: - Rounded Corner Helper
struct RoundedCorner: Shape {
  var radius: CGFloat = .infinity
  var corners: UIRectCorner = .allCorners

  func path(in rect: CGRect) -> Path {
    let path = UIBezierPath(
      roundedRect: rect,
      byRoundingCorners: corners,
      cornerRadii: CGSize(width: radius, height: radius)
    )
    return Path(path.cgPath)
  }
}

// MARK: - View Extension for Easy Usage
extension View {
  func flexibleSheet<Content: View>(
    isPresented: Binding<Bool>,
    minHeight: CGFloat = 200,
    maxHeight: CGFloat = UIScreen.main.bounds.height * 0.9,
    interactiveDismissDisabled: Bool = false,
    @ViewBuilder content: @escaping () -> Content
  ) -> some View {
    ZStack {
      self

      FlexibleBottomSheet(
        isPresented: isPresented,
        minHeight: minHeight,
        maxHeight: maxHeight,
        interactiveDismissDisabled: interactiveDismissDisabled,
        content: content
      )
    }
  }
}

#Preview {
  struct PreviewWrapper: View {
    @State private var showSheet = true

    var body: some View {
      ZStack {
        Color.appBackground.ignoresSafeArea()

        Button("Show Sheet") {
          showSheet = true
        }
        .foregroundStyle(.white)
      }
      .flexibleSheet(isPresented: $showSheet) {
        VStack(spacing: 20) {
          Text("Flexible Content")
            .font(.title)
            .foregroundStyle(.white)

          Text("This sheet adjusts to content")
            .foregroundStyle(.gray)
        }
        .padding(20)
      }
    }
  }

  return PreviewWrapper()
}

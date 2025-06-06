//
//  PieChart.swift
//  WhatIdo
//
//  Created by eytsam elahi on 03/06/2025.
//

import Foundation
import SwiftUI

enum PieColor: Int {
    case red = 1
    case blue = 2
    case orange = 3
    case purple = 4
    case green = 5
    case yellow = 6
    case indigo = 7
    case teal = 8
    case mint = 9
    case brown = 10
    case cyan = 11

    var color: Color {
        switch self {
        case .red:
            return .red
        case .blue:
            return .blue
        case .orange:
            return .orange
        case .purple:
            return .purple
        case .green:
            return .green
        case .yellow:
            return .yellow
        case .indigo:
            return .indigo
        case .teal:
            return .teal
        case .mint:
            return .mint
        case .brown:
            return .brown
        case .cyan:
            return .cyan
        }
    }
}
struct PieChartModel: Identifiable {
    let id: Int
    let name: String
    var value: Double
    let color: Color

    init(id: Int, name: String, value: Double) {
        self.id = id
        self.name = name
        self.value = value
        let color: PieColor = PieColor(rawValue: id) ?? .blue
        self.color = color.color
    }

}

struct PieSlice: Shape {
    let startAngle: Angle
    let endAngle: Angle

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2

        path.move(to: center)
        path.addArc(center: center,
                    radius: radius,
                    startAngle: startAngle,
                    endAngle: endAngle,
                    clockwise: false)
        return path
    }
}

struct PieChart: View {
    let categories: [PieChartModel]

    var total: Double {
        categories.map { $0.value }.reduce(0, +)
    }

    var angles: [(start: Angle, end: Angle)] {
        var angles: [(Angle, Angle)] = []
        var currentAngle = Angle(degrees: 0)

        for category in categories {
            let degrees = category.value / total * 360
            let nextAngle = currentAngle + Angle(degrees: degrees)
            angles.append((currentAngle, nextAngle))
            currentAngle = nextAngle
        }
        return angles
    }

    var body: some View {
        ZStack {
            ForEach(Array(categories.enumerated()), id: \.1.id) { index, category in
                PieSlice(startAngle: angles[index].start, endAngle: angles[index].end)
                    .fill(category.color)
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

struct PieChartView: View {
    let data: [PieChartModel]
    var total: Double {
        data.map(\.self.value).reduce(0, +)
    }
    var body: some View {
        HStack(spacing: 10) {
            PieChart(categories: data)
                .frame(width: 250, height: 250)

            // Optional legend
            VStack(alignment: .leading, spacing: 15) {
                ForEach(data) { item in
                    HStack {
                        Circle()
                            .fill(item.color)
                            .frame(width: 10, height: 10)
                        Text("\(item.name): \(String(format: "%.0f", Helper.getPercentage(divisor: total, dividend: item.value)))%")
                            .font(.customFont(name: .medium, size: .x12))
                    }
                }
            }
        }
        .padding()
    }
}

#Preview{
    PieChartView(data: [])
}

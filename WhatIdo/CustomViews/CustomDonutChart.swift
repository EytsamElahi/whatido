//
//  CustomDonutChart.swift
//  WhatIdo
//
//  Created by Antigravity on 27/01/2026.
//

import SwiftUI

struct CustomDonutChart: View {
    let data: [SpendingTypeChartData]
    let innerRadiusRatio: CGFloat = 0.65 // Matches original design
    
    private var total: Double {
        data.reduce(0) { $0 + $1.totalAmount }
    }
    
    var body: some View {
        GeometryReader { geometry in
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            let outerRadius = min(geometry.size.width, geometry.size.height) / 2
            let innerRadius = outerRadius * innerRadiusRatio
            
            ZStack {
                if total > 0 {
                    ForEach(Array(data.enumerated()), id: \.offset) { index, item in
                        DonutSlice(
                            startAngle: startAngle(for: index),
                            endAngle: endAngle(for: index),
                            innerRadius: innerRadius,
                            outerRadius: outerRadius
                        )
                        .fill(item.color)
                    }
                } else {
                    // Placeholder circle if no data
                    Circle()
                        .stroke(Color.gray.opacity(0.1), lineWidth: outerRadius - innerRadius)
                        .frame(width: outerRadius * 2, height: outerRadius * 2)
                }
            }
            .position(center)
        }
        .aspectRatio(1, contentMode: .fit)
    }
    
    private func startAngle(for index: Int) -> Angle {
        let previousTotal = data.prefix(index).reduce(0) { $0 + $1.totalAmount }
        return .degrees((previousTotal / total) * 360 - 90)
    }
    
    private func endAngle(for index: Int) -> Angle {
        let currentTotal = data.prefix(index + 1).reduce(0) { $0 + $1.totalAmount }
        return .degrees((currentTotal / total) * 360 - 90)
    }
}

struct DonutSlice: Shape {
    let startAngle: Angle
    let endAngle: Angle
    let innerRadius: CGFloat
    let outerRadius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        
        path.addArc(
            center: center,
            radius: outerRadius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: false
        )
        
        path.addArc(
            center: center,
            radius: innerRadius,
            startAngle: endAngle,
            endAngle: startAngle,
            clockwise: true
        )
        
        path.closeSubpath()
        return path
    }
}

#Preview {
    CustomDonutChart(data: [
        SpendingTypeChartData(spendingName: "Food", icon: "carrot", totalAmount: 100, color: .orange, transactions: []),
        SpendingTypeChartData(spendingName: "Rent", icon: "house", totalAmount: 200, color: .blue, transactions: []),
        SpendingTypeChartData(spendingName: "Travel", icon: "airplane", totalAmount: 50, color: .green, transactions: [])
    ])
    .frame(width: 300, height: 300)
    .padding()
    .background(Color.black)
}

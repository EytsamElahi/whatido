//
//  SpendingDetail.swift
//  WhatIdo
//
//  Created by eytsam elahi on 06/06/2025.
//

import SwiftUI

struct SpendingDetail: View {
    @StateObject var viewModel: SpendingDetailViewModel
    var body: some View {
        VStack {
            if let data = viewModel.pieChartData {
                PieChartView(data: data)
            }
        }.onAppear {
            viewModel.generatePieChartData()
        }
    }
}

#Preview {
    SpendingDetail(viewModel: SpendingDetailViewModel(spendingService: WhatISpendServiceStub()))
}

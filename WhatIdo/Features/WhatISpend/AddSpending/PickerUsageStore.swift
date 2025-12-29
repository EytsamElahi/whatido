//
//  PickerUsageStore.swift
//  WhatIdo
//
//  Created by eytsam elahi on 08/12/2025.
//

import SwiftUI

@MainActor
final class PickerUsageStore: ObservableObject {
    @SwiftUI.AppStorage("spendingTypeUsageCounts_v1") private var raw: Data = Data()
    @Published private(set) var counts: [String: Int] = [:]

    init() { load() }

    func record(_ value: String) {
        guard !value.isEmpty else { return }
        counts[value, default: 0] += 1
        persist()
    }

    func count(for value: String) -> Int {
        counts[value, default: 0]
    }

    private func load() {
        guard !raw.isEmpty else { return }
        if let decoded = try? JSONDecoder().decode([String: Int].self, from: raw) {
            counts = decoded
        }
    }

    private func persist() {
        if let encoded = try? JSONEncoder().encode(counts) {
            raw = encoded
        }
    }
}

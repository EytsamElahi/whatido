//
//  WhatISpendService.swift
//  WhatIdo
//
//  Created by eytsam elahi on 14/05/2025.
//

import Foundation

protocol WhatISpendServiceType {
    func getAllSpendings()
    func addNewSpending(_ spending: Spending) async throws
    func editSpending()
    func deleteSpending()
}

final class WhatISpendService: WhatISpendServiceType, FirebaseService {

    func getAllSpendings() {

    }
    
    func addNewSpending(_ spending: Spending) async throws {
        do {
            let endpoint = FirestoreEndpoints.createSpending
            try await post(data: spending, endpoint: endpoint)
        } catch {
            debugPrint("Error in posting data", error.localizedDescription)
        }
    }
    
    func editSpending() {
        debugPrint("")
    }
    
    func deleteSpending() {
        debugPrint("")
    }

}

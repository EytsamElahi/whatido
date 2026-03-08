//
//  CurrencyService.swift
//  WhatIdo
//
//  Created by Antigravity on 2026-01-23.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class CurrencyService: ObservableObject {
    static let shared = CurrencyService()
    
    @Published var rates: [String: Double] = [:]
    private var lastUpdate: TimeInterval = 0
    private let db = Firestore.firestore()
    
    private init() {
        // Load some initial rates to avoid zeros before firestore loads
        self.rates = CurrencyConfig.fallbackRates
    }
    
    func loadRates() {
        db.collection("config").document("exchange_rates").addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching exchange rates from Firestore: \(error.localizedDescription)")
                return
            }
            
            guard let snapshot = snapshot, snapshot.exists else {
                print("Exchange rates document does not exist. Seeding initial data...")
                self.fetchFromAPIAndUpdateFirestore()
                return
            }
            
            if let data = snapshot.data() {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: data)
                    let model = try JSONDecoder().decode(ExchangeRatesModel.self, from: jsonData)
                    self.rates = model.conversion_rates
                    self.lastUpdate = model.time_last_update_unix
                    print("Rates loaded successfully from Firestore. Count: \(self.rates.count)")
                } catch {
                    print("Error decoding exchange rates: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func performAdminCheck() {
        guard let currentUser = Auth.auth().currentUser, currentUser.uid == Constants.adminUid else {
            return
        }
        
        let now = Date().timeIntervalSince1970
        if (now - lastUpdate) > 86400 { // 24 hours
            print("Admin detected and rates expired. Fetching from API...")
            fetchFromAPIAndUpdateFirestore()
        }
    }
    
    private func fetchFromAPIAndUpdateFirestore() {
        guard let url = URL(string: Constants.exchangeRateApiUrl) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                print("Error fetching from API: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else { return }
            
            do {
                let model = try JSONDecoder().decode(ExchangeRatesModel.self, from: data)
                self?.updateFirestore(with: model)
            } catch {
                print("Error decoding API response: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    private func updateFirestore(with model: ExchangeRatesModel) {
        do {
            let jsonData = try JSONEncoder().encode(model)
            if let dict = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
                db.collection("config").document("exchange_rates").setData(dict) { error in
                    if let error = error {
                        print("Error updating Firestore: \(error.localizedDescription)")
                    } else {
                        print("Rates updated successfully in Firestore.")
                    }
                }
            }
        } catch {
            print("Error preparing data for Firestore: \(error.localizedDescription)")
        }
    }
    
    private func seedInitialData() {
        let jsonPayload = """
        {
         "base_code":"USD",
         "time_last_update_unix":1769126401,
         "conversion_rates":{
          "USD":1, "AED":3.6725, "AFN":65.9168, "ALL":82.3885, "AMD":378.8191, "ANG":1.7900, "AOA":922.1930, "ARS":1452.2500, "AUD":1.4653, "AWG":1.7900, "AZN":1.6989, "BAM":1.6669, "BBD":2.0000, "BDT":122.2858, "BGN":1.6129, "BHD":0.3760, "BIF":2967.6512, "BMD":1.0000, "BND":1.2825, "BOB":6.9168, "BRL":5.3114, "BSD":1.0000, "BTN":91.6290, "BWP":13.5987, "BYN":2.8543, "BZD":2.0000, "CAD":1.3796, "CDF":2172.7427, "CHF":0.7910, "CLF":0.02212, "CLP":874.3281, "CNH":6.9685, "CNY":6.9807, "COP":3672.1417, "CRC":491.8061, "CUP":24.0000, "CVE":93.9765, "CZK":20.7186, "DJF":177.7210, "DKK":6.3642, "DOP":62.9983, "DZD":129.7534, "EGP":47.1269, "ERN":15.0000, "ETB":154.4989, "EUR":0.8523, "FJD":2.2631, "FKP":0.7424, "FOK":6.3639, "GBP":0.7426, "GEL":2.6934, "GGP":0.7424, "GHS":10.8944, "GIP":0.7424, "GMD":74.0110, "GNF":8750.9900, "GTQ":7.6671, "GYD":209.1750, "HKD":7.7975, "HNL":26.3596, "HRK":6.4215, "HTG":130.8908, "HUF":326.0965, "IDR":16853.1411, "ILS":3.1404, "IMP":0.7424, "INR":91.6291, "IQD":1310.9058, "IRR":266292.4570, "ISK":124.7972, "JEP":0.7424, "JMD":157.2400, "JOD":0.7090, "JPY":158.4801, "KES":129.0004, "KGS":87.4169, "KHR":4022.0337, "KID":1.4653, "KMF":419.2934, "KRW":1465.8480, "KWD":0.3069, "KYD":0.8333, "KZT":505.6311, "LAK":21677.8553, "LBP":89500.0000, "LKR":309.4403, "LRD":184.3876, "LSL":16.1627, "LYD":6.3586, "MAD":9.1707, "MDL":16.9902, "MGA":4593.4078, "MKD":52.5445, "MMK":2100.4366, "MNT":3569.7200, "MOP":8.0314, "MRU":39.9702, "MUR":46.0429, "MVR":15.4344, "MWK":1741.9701, "MXN":17.4731, "MYR":4.0403, "MZN":63.7804, "NAD":16.1627, "NGN":1420.3537, "NIO":36.7638, "NOK":9.8677, "NPR":146.6065, "NZD":1.6944, "OMR":0.3845, "PAB":1.0000, "PEN":3.3545, "PGK":4.2706, "PHP":59.1165, "PKR":279.9880, "PLN":3.5839, "PYG":6712.3819, "QAR":3.6400, "RON":4.3531, "RSD":100.1958, "RUB":75.9682, "RWF":1459.8712, "SAR":3.7500, "SBD":8.0120, "SCR":14.0398, "SDG":511.4191, "SEK":9.0309, "SGD":1.2821, "SHP":0.7424, "SLE":23.6446, "SLL":23644.5701, "SOS":570.2583, "SRD":38.2898, "SSP":4661.1216, "STN":20.8808, "SYP":112.9105, "SZL":16.1627, "THB":31.3037, "TJS":9.3040, "TMT":3.4988, "TND":2.8770, "TOP":2.3829, "TRY":43.3406, "TTD":6.7715, "TVD":1.4653, "TWD":31.6184, "TZS":2521.7132, "UAH":43.1518, "UGX":3487.6402, "UYU":38.3355, "UZS":12143.7647, "VES":352.7063, "VND":26142.5617, "VUV":120.1016, "WST":2.7322, "XAF":559.0579, "XCD":2.7000, "XCG":1.7900, "XDR":0.7289, "XOF":559.0579, "XPF":101.7041, "YER":238.1456, "ZAR":16.1563, "ZMW":20.2387, "ZWG":25.5902, "ZWL":25.5902
         }
        }
        """
        guard let data = jsonPayload.data(using: .utf8) else { return }
        do {
            let model = try JSONDecoder().decode(ExchangeRatesModel.self, from: data)
            updateFirestore(with: model)
        } catch {
            print("Error seeding initial data: \(error.localizedDescription)")
        }
    }
}

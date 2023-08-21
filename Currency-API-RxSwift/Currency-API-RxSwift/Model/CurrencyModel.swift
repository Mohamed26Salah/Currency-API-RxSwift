//
//  CurrencyModel.swift
//  Currency-API-RxSwift
//
//  Created by Mohamed Salah on 20/08/2023.
//

import Foundation
import OptionallyDecodable

// MARK: - DecodeScene
struct Currency: Codable {
    var success: Bool
//    var timestamp: Date
    var base: String
    var date: String
    var rates: [String: Double]

    enum CodingKeys: String, CodingKey {
        case success = "success"
//        case timestamp = "timestamp"
        case base = "base"
        case date = "date"
        case rates = "rates"
    }
    
    // Custom date decoding strategy
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        success = try container.decode(Bool.self, forKey: .success)
        base = try container.decode(String.self, forKey: .base)
        date = try container.decode(String.self, forKey: .date)
        rates = try container.decode([String: Double].self, forKey: .rates)
        
        // Decode timestamp as an integer and convert it to Date
//        let timestampInt = try container.decode(Int.self, forKey: .timestamp)
//        timestamp = Date(timeIntervalSince1970: TimeInterval(timestampInt))
    }
}

extension Currency {
    
    func convertCurrency(amount: Double, from sourceCurrency: String, to targetCurrency: String) -> Double {
        guard let exchangeRateFromSourceToBase = rates[sourceCurrency] else {
            return 0
        }
        
        guard let exchangeRateFromTargetToBase = rates[targetCurrency] else {
            return 0
        }
        
        let valueInBaseCurrency = amount / exchangeRateFromSourceToBase // Convert to base currency
        
        return valueInBaseCurrency * exchangeRateFromTargetToBase // Convert to target currency
    }
    func convertAllCurrencies(amount: Double, from sourceCurrency: String) -> [String:Double]? {
        var newCurrencyDictionary = [String: Double]()
        for currency in rates {
            newCurrencyDictionary[currency.key] = convertCurrency(amount: amount, from: sourceCurrency, to: currency.key)
        }
        return newCurrencyDictionary
    }

}

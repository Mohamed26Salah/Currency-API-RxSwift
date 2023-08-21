//
//  CurrencyViewModel.swift
//  Currency-API-RxSwift
//
//  Created by Mohamed Salah on 20/08/2023.
//

import Foundation
import RxSwift
import RxRelay
class CurrencyViewModel {
    private let apiClient: APIClient
    private let disposeBag = DisposeBag()
    var currencyModel: Currency?
    
    // In
    var fromCurrencyRelay = BehaviorRelay<String>(value: "EUR")
    var toCurrencyRelay = BehaviorRelay<String>(value: "EGP")
//    var fromCurrencyRelay = PublishRelay<String>.init()
//    var toCurrencyRelay = PublishRelay<String>.init()
    var fromAmountRelay = PublishRelay<Double>.init()
    var toAmountRelay = PublishRelay<Double>.init()
    //Out
    var toCurrencyOutPutRelay = PublishRelay<String>.init()
    var fromCurrencyOutPutRelay = PublishRelay<String>.init()
    var placeholderOutputRelay = PublishRelay<String>.init()
    var CurrencyRates = BehaviorRelay<[String:Double]>(value: ["EUR":0.0])
    
    var errorMessageSubject = PublishSubject<String>()

    init() {
        self.apiClient = APIClient()
        setupBinding()
    }
    func fetchCurrency() {
        apiClient.fetchGlobal(parsingType: Currency.self, url: APIClient.EndPoint.rates.stringToUrl)
            .subscribe(onNext: { Currency in
                self.currencyModel = Currency
//                self.fromCurrencyRelay.accept(Currency.base)
//                self.toCurrencyRelay.accept(Currency.base)
                self.fromCurrencyOutPutRelay.accept("1.0")
                self.toCurrencyOutPutRelay.accept(String.init(Currency.convertCurrency(amount: 1, from: "EUR", to: "EGP")))
                self.CurrencyRates.accept(Currency.rates)
            }, onError: { error in
                print(error)
                self.errorMessageSubject.onNext(error.localizedDescription)
            })
            .disposed(by: disposeBag)
    }
    private func setupBinding() {
        //combineLatest waits for all the source observables to emit at least one value before it starts combining them and emitting combined results.
        let fromObserable = Observable.combineLatest(fromAmountRelay, fromCurrencyRelay, toCurrencyRelay)
        fromObserable.subscribe(onNext: { [weak self] (amount, from, to) in
            guard let self = self, let model = self.currencyModel else { return }
            let convertedAmount = model.convertCurrency(amount: amount, from: from, to: to)
            self.toCurrencyOutPutRelay.accept(String.init(convertedAmount))
            if let newCurrenciesValue = model.convertAllCurrencies(amount: amount, from: from) {
                self.CurrencyRates.accept(newCurrenciesValue)
            }
        }).disposed(by: disposeBag)
        
        let toObserable = Observable.combineLatest(toAmountRelay, toCurrencyRelay, fromCurrencyRelay)
        toObserable.subscribe(onNext: { [weak self] (amount, from, to) in
            guard let self = self, let model = self.currencyModel else { return }
            let convertedAmount = model.convertCurrency(amount: amount, from: from, to: to)
            self.fromCurrencyOutPutRelay.accept(String.init(convertedAmount))
            if let newCurrenciesValue = model.convertAllCurrencies(amount: amount, from: from) {
                self.CurrencyRates.accept(newCurrenciesValue)
            }
        }).disposed(by: disposeBag)
        
        Observable.combineLatest(fromCurrencyRelay, toCurrencyRelay).subscribe(onNext: { [weak self] (from, to) in
            guard let self = self, let model = self.currencyModel else { return }
            let amount = model.convertCurrency(amount: 1, from: from, to: to)
            self.placeholderOutputRelay.accept(String.init(amount))
        }).disposed(by: disposeBag)
    }
}

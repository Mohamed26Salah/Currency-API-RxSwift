//
//  CurrencyViewController.swift
//  Currency-API-RxSwift
//
//  Created by Mohamed Salah on 20/08/2023.
//

import UIKit
import RxSwift
import RxCocoa
import RxRelay

class CurrencyViewController: UIViewController {
    
    var currency = CurrencyViewModel()
    let disposeBag = DisposeBag()
    @IBOutlet weak var fromCurrency: UILabel!
    @IBOutlet weak var toCurrency: UILabel!
    @IBOutlet weak var fromCurrencyTextField: UITextField!
    @IBOutlet weak var toCurrencyTextField: UITextField!
    @IBOutlet weak var currencyTableView: UITableView!
    @IBOutlet weak var fromButton: UIButton!
    @IBOutlet weak var toButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currencyTableView.register(UINib(nibName: "CurrencyTableViewCell", bundle: nil), forCellReuseIdentifier: "CurrencyTableViewCell")
        currency.fetchCurrency()
        showCurrencyResult()
        reactiveAlert()
        fromCurrencyTextField.placeholder = "1"
        bindViewModelToViews()
        bindViewsToViewModel()
        
    }
    
    @IBAction func fromButtonTapped(_ sender: UIButton) {
        let source = currency.currencyModel?.rates.map(\.key) ?? []
        selectItem(title: "Select Currency", source: source) { currencyCode in
            self.currency.fromCurrencyRelay.accept(currencyCode)
            self.currency.fromCurrencyOutPutRelay.accept("1.0") //Can be Enhanced
            self.currency.toCurrencyOutPutRelay.accept(String(self.currency.currencyModel?.convertCurrency(amount: 1, from: currencyCode, to: self.currency.toCurrencyRelay.value) ?? 0.0))
        }
    }
    
    @IBAction func toButtonTapped(_ sender: UIButton) {
        let source = currency.currencyModel?.rates.map(\.key) ?? []
        selectItem(title: "Select Currency", source: source) { currencyCode in
            self.currency.toCurrencyRelay.accept(currencyCode)
            self.currency.fromCurrencyOutPutRelay.accept("1.0")
            self.currency.toCurrencyOutPutRelay.accept(String(self.currency.currencyModel?.convertCurrency(amount: 1, from: self.currency.fromCurrencyRelay.value, to: currencyCode) ?? 0.0))
        }
    }
}
extension CurrencyViewController {

    func bindViewModelToViews() {
        currency.fromCurrencyOutPutRelay.bind(to: fromCurrencyTextField.rx.text).disposed(by: disposeBag)
        currency.toCurrencyOutPutRelay.bind(to: toCurrencyTextField.rx.text).disposed(by: disposeBag)
        currency.fromCurrencyRelay.bind(to: fromCurrency.rx.text).disposed(by: disposeBag)
        currency.toCurrencyRelay.bind(to: toCurrency.rx.text).disposed(by: disposeBag)
        currency.placeholderOutputRelay.bind(to: toCurrencyTextField.rx.placeholder).disposed(by: disposeBag)
        
        //
        currency.fromCurrencyRelay.bind(to: fromButton.rx.title(for: .normal)).disposed(by: disposeBag)
        
        currency.toCurrencyRelay.bind(to: toButton.rx.title(for: .normal)).disposed(by: disposeBag)

    }
    func bindViewsToViewModel() {
//        fromCurrencyTextField.rx
//            .text
//            .orEmpty
//            .distinctUntilChanged()
//            .skip(1)
//            .map { $0.isEmpty ? "0.0" : $0 }
//            .compactMap(Double.init)
//            .bind(to: currency.fromAmountRelay)
//            .disposed(by: disposeBag)
        //Whenever sourceObservable emits an event, withLatestFrom takes the latest value emitted by otherObservable at that moment.
        //withLatest is comining the event with the value
        fromCurrencyTextField.rx.controlEvent(.editingChanged)
            .withLatestFrom(fromCurrencyTextField.rx.text.orEmpty)
            .map { $0.isEmpty ? "0.0" : $0 }
            .distinctUntilChanged()
            .compactMap(Double.init)
            .bind(to: currency.fromAmountRelay)
            .disposed(by: disposeBag)
        toCurrencyTextField.rx.controlEvent(.editingChanged)
            .withLatestFrom(toCurrencyTextField.rx.text.orEmpty)
            .map { $0.isEmpty ? "0.0" : $0 }
            .distinctUntilChanged()
            .compactMap(Double.init)
            .bind(to: currency.toAmountRelay)
            .disposed(by: disposeBag)
//        toCurrencyTextField.rx
//            .text
//            .orEmpty
//            .distinctUntilChanged()
//            .skip(1)
//            .map { $0.isEmpty ? "0.0" : $0 }
//            .compactMap(Double.init)
//            .bind(to: currency.toAmountRelay)
//            .disposed(by: disposeBag)
    }
    func showCurrencyResult() {
        currency.CurrencyRates
            .bind(to: currencyTableView
                .rx
                .items(cellIdentifier: "CurrencyTableViewCell", cellType: CurrencyTableViewCell.self)) {
                    (tv, curr, cell) in
                    cell.currencyNameLabel.text = String(curr.key)
                    cell.currencyPriceLabel.text = String(curr.value)
                }
                .disposed(by: disposeBag)
    }
    func reactiveAlert() {
        currency.errorMessageSubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] errorMessage in
                self?.showAlert(with: errorMessage)
            })
            .disposed(by: disposeBag)
    }
    private func showAlert(with message: String) {
        let alertController = UIAlertController(title: "yala 5roga", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
}

//
//  APIClient.swift
//  Currency-API-RxSwift
//
//  Created by Mohamed Salah on 20/08/2023.
//
import Foundation
import RxSwift
import RxCocoa

class APIClient {
    let disposeBag = DisposeBag()
    private enum Error: Swift.Error {
        case invalidResponse(URLResponse?)
        case invalidJSON(Swift.Error)
    }
    func fetchGlobal<T: Codable>(parsingType: T.Type, url: URL) -> Observable<T> {
        let request = URLRequest(url: url)
        return URLSession.shared.rx.response(request: request)
            .map { result -> Data in
                guard result.response.statusCode == 200 else {
                    print(result.response)
                    throw Error.invalidResponse(result.response)
                }
                return result.data
            }.map { data in
                do {
                    let searchResult = try JSONDecoder().decode(
                        parsingType.self, from: data
                    )
                    return searchResult
                } catch let error {
                    throw Error.invalidJSON(error)
                }
            }
            .observe(on: MainScheduler.instance)
            .asObservable()
    }
}

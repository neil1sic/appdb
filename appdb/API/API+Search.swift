//
//  API+Search.swift
//  appdb
//
//  Created by ned on 11/01/2017.
//  Copyright © 2017 ned. All rights reserved.
//

import Alamofire
import SwiftyJSON
import ObjectMapper

extension API {

    static func search <T>(type: T.Type, order: Order = .all, price: Price = .all, genre: String = "0", dev: String = "0", trackid: String = "0", q: String = "", page: Int = 1, success:@escaping (_ items: [T]) -> Void, fail:@escaping (_ error: String) -> Void) where T: Item {
        let request = Alamofire.request(endpoint, parameters: ["action": Actions.search.rawValue, "type": T.type().rawValue, "order": order.rawValue, "price": price.rawValue, "genre": genre, "dev": dev, "trackid": trackid, "q": q, "page": page, "lang": languageCode], headers: headers)

        quickCheckForErrors(request, completion: { ok, hasError in
            if ok {
                request.responseArray(keyPath: "data") { (response: DataResponse<[T]>) in
                    switch response.result {
                    case .success(let items):
                        success(items)
                    case .failure(let error):
                        fail(error.localizedDescription)
                    }
                }
            } else {
                fail((hasError ?? "Cannot connect").localized())
            }
        })
    }

    static func fastSearch(type: ItemType, query: String, maxResults: Int = 10, success:@escaping (_ results: [String]) -> Void) {
        Alamofire.request(endpoint, parameters: ["action": Actions.search.rawValue,
                                                 "type": type.rawValue,
                                                 "order": Order.all.rawValue,
                                                 "q": query,
                                                 "lang": languageCode,
                                                 "perpage": maxResults], headers: headers)

            .responseJSON { response in
                if let value = response.result.value {
                    let json = JSON(value)
                    let data = json["data"]
                    var results: [String] = []
                    let max = data.count > maxResults ? maxResults : data.count
                    for i in 0..<max { results.append(data[i]["name"].stringValue) }
                    success(results)
                }
            }
    }

    static func quickCheckForErrors(_ request: DataRequest, completion: @escaping (_ ok: Bool, _ hasError: String?) -> Void) {
        request.responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                if !json["success"].boolValue {
                    if !json["errors"].isEmpty {
                        completion(false, json["errors"][0].stringValue)
                    } else {
                        completion(false, "Oops! Something went wrong. Please try again later.".localized())
                    }
                } else {
                    completion(true, nil)
                }
            case .failure(let error):
                completion(false, error.localizedDescription)
            }
        }
    }

    static func getTrending(type: ItemType, order: Order = .all, maxResults: Int = 8, success:@escaping (_ results: [String]) -> Void) {
        Alamofire.request(endpoint, parameters: ["action": Actions.search.rawValue,
                                                 "type": type.rawValue,
                                                 "order": order.rawValue,
                                                 "lang": languageCode,
                                                 "perpage": maxResults], headers: headers)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    let data = json["data"]
                    var results: [String] = []
                    let max = data.count > maxResults ? maxResults : data.count
                    for i in 0..<max { results.append(data[i]["name"].stringValue) }
                    success(results)
                default:
                    break
                }
            }
    }
}

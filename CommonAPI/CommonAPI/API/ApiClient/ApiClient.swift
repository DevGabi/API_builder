//
//  ApiClient.swift
//  CommonAPI
//
//  Created by DevGabi on 2020/08/05.
//  Copyright © 2020 devgabi. All rights reserved.
//

import Foundation
import Alamofire
import RxAlamofire
import RxCocoa
import RxSwift
import NSObject_Rx

typealias RequestCompletion = (Bool, Any?, Error?) -> Void
class ApiClient: HasDisposeBag  {
    private let session: Alamofire.Session = {
        let configuration = URLSessionConfiguration.af.default
        configuration.headers = HTTPHeaders.default // default
        configuration.timeoutIntervalForRequest = 5 // 타임아웃
        return Alamofire.Session.init(configuration: configuration)
    }()
    
    public func send(api: API, responseData: @escaping RequestCompletion) {
        session.rx
            .request(.get, api.request.build(.data))
            .responseDataResponse(api: api)
            .subscribe(onNext: { (dataResponse) in
                let result = api.response.parse!(dataResponse.value)
                if result is Error {
                    responseData(true, nil, result as? Error)
                } else {
                    responseData(true, result, nil)
                }
            }, onError: { (Error) in
                responseData(false, nil, Error)
            })
            .disposed(by: disposeBag)
    }
    
    deinit {
        print("deinit")
    }
}

extension ObservableType where Element: DataRequest {
    func responseDataResponse(api: API) -> Observable<DataResponse<Any, AFError>> {
        return flatMap { (dataRequest) -> Observable<DataResponse<Any, AFError>> in
            switch api.request.responseData {
            case .string:
                return dataRequest.rx
                    .responseString()
                    .flatMap { (arg) -> Observable<DataResponse<Any, AFError>> in
                        let (httpResponse, jsonString) = arg
                        let dataResponse = DataResponse<Any, AFError>(request: dataRequest.request,
                                                                      response: httpResponse,
                                                                      data: nil,
                                                                      metrics: nil,
                                                                      serializationDuration: 5.0,
                                                                      result: .success(jsonString))
                        return Observable.just(dataResponse)
                    }
            case .json:
                    return dataRequest.rx.responseJSON()
            case .data:
                return dataRequest.rx
                    .responseData()
                    .flatMap { (arg) -> Observable<DataResponse<Any, AFError>> in
                        let (httpResponse, jsonString) = arg
                        let dataResponse = DataResponse<Any, AFError>(request: dataRequest.request,
                                                                      response: httpResponse,
                                                                      data: nil,
                                                                      metrics: nil,
                                                                      serializationDuration: 5.0,
                                                                      result: .success(jsonString))
                        return Observable.just(dataResponse)
                }
            }
        }
    }
}
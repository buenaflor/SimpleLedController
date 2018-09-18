//
//  SimpleLedControllerClient.swift
//  SimpleLedController
//
//  Created by Giancarlo Buenaflor on 10.09.18.
//  Copyright © 2018 Giancarlo Buenaflor. All rights reserved.
//

import Endpoints

class SimpleLedControllerClient: Client {
    
    let homeVC = HomeViewController()
    
    lazy var client: AnyClient = {
        
        let baseURL = homeVC.getIpAddress()
        print("url:", homeVC.getIpAddress())
        return AnyClient(baseURL: baseURL)
    }()
    
    func encode<C>(call: C) -> URLRequest where C : Call {
        var request = client.encode(call: call)
        
        request.apply(header: ["Content-Type": "application/json"])
        
        return request
    }
    
    func parse<C>(sessionTaskResult result: URLSessionTaskResult, for call: C) throws -> C.ResponseType.OutputType where C : Call {
        return try client.parse(sessionTaskResult: result, for: call)
    }
}

extension SimpleLedControllerClient {
    
    struct PostSingleColor: Call {
        typealias ResponseType = PostSingleColorResponse
        
        var tag: String
        var body: Body
        
        var request: URLRequestEncodable {
            return Request(.post, tag, body: body)
        }
    }
    
    struct PostLEDPower: Call {
        typealias ResponseType = PostLEDPowerResponse
        
        var tag: String
        var body: Body
        
        var request: URLRequestEncodable {
            return Request(.post, tag, body: body)
        }
    }
    
    struct GetLEDPower: Call {
        typealias ResponseType = GetLEDPowerResponse
        
        var tag: String
        
        var request: URLRequestEncodable {
            return Request(.get, tag)
        }
    }
}

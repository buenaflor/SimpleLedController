//
//  SimpleLedControllerResponse.swift
//  SimpleLedController
//
//  Created by Giancarlo Buenaflor on 10.09.18.
//  Copyright © 2018 Giancarlo Buenaflor. All rights reserved.
//

import Endpoints

struct PostSingleColorResponse: Codable {
    let successful: Bool
}

extension PostSingleColorResponse: ResponseParser {
    static func parse(data: Data, encoding: String.Encoding) throws -> PostSingleColorResponse {
        let response = try JSONDecoder().decode(PostSingleColorResponse.self, from: data)
        return PostSingleColorResponse(successful: response.successful)
    }
}

struct PostLEDPowerResponse: Codable {
    let ledOn: Bool
}

extension PostLEDPowerResponse: ResponseParser {
    static func parse(data: Data, encoding: String.Encoding) throws -> PostLEDPowerResponse {
        
        let response = try JSONDecoder().decode(PostLEDPowerResponse.self, from: data)
        
        return PostLEDPowerResponse(ledOn: response.ledOn)
    }
}

struct GetLEDPowerResponse: Codable {
    let ledOn: Bool
}

extension GetLEDPowerResponse: ResponseParser {
    static func parse(data: Data, encoding: String.Encoding) throws -> GetLEDPowerResponse {
        
        let response = try JSONDecoder().decode(GetLEDPowerResponse.self, from: data)
        
        return GetLEDPowerResponse(ledOn: response.ledOn)
    }
}

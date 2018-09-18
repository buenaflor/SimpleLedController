//
//  SessionManager.swift
//  SimpleLedController
//
//  Created by Giancarlo Buenaflor on 10.09.18.
//  Copyright © 2018 Giancarlo Buenaflor. All rights reserved.
//

import Endpoints

enum ClientType {
    
    case simpleLedControllerClient
    
    var client: Client {
        switch self {
        case .simpleLedControllerClient:
            return SimpleLedControllerClient()
        }
    }
}

class SessionManager {
    static let shared = SessionManager(clientType: .simpleLedControllerClient)
    
    private let defaults = UserDefaults.standard
    
    private let simpleLedControllerSession: Session<SimpleLedControllerClient>
    
    private var clientType: ClientType?
    
    
    init(clientType: ClientType) {
        self.clientType = clientType
        simpleLedControllerSession = {
            let client = SimpleLedControllerClient()
            let session = Session(with: client)
            #if DEBUG
            session.debug = true
            #endif
            
            return session
        }()
    }
    
    @discardableResult
    public func start<C: Call>(call: C, completion: @escaping (Result<C.ResponseType.OutputType>) -> Void) -> URLSessionTask {
        guard let clientType = clientType else { fatalError("ClientType not defined") }
        
        switch clientType {
        case .simpleLedControllerClient:
            let task = simpleLedControllerSession.start(call: call, completion: completion)
            return task
        }
    }
}

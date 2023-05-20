//
//  IAuthorizationRepository.swift
//  rfpr
//
//  Created by poliorang on 16.05.2023.
//

import XCTest
@testable import rfpr

class IAuthorizationRepositoryTests: XCTestCase {

    var authorizationRepository: MockAuthorizationRepository!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        authorizationRepository = MockAuthorizationRepository()
    }

    override func tearDownWithError() throws {
        authorizationRepository = nil
        try super.tearDownWithError()
    }

    func testCreateAuthorization() throws {
        let authorization = Authorization(id: "1", login: "1", password: "1")
        
        XCTAssertEqual(try authorizationRepository.createAuthorization(authorization: authorization), authorization)
    }
    
    func testGetAuthoByLoginPassword() throws {
        let authorization = Authorization(id: "1", login: "a", password: "a")
        
        XCTAssertEqual(try authorizationRepository.getAuthorizationByLoginPassword(authorization: authorization), authorization)
    }
    
    func testGetAuthoByLoginPasswordNil() throws {
        let authorization = Authorization(id: "1", login: "1", password: "1")
        
        XCTAssertEqual(try authorizationRepository.getAuthorizationByLoginPassword(authorization: authorization), nil)
    }
}

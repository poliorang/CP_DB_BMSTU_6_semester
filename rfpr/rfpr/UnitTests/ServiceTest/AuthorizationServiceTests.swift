//
//  AuthorizationServiceTests.swift
//  rfpr
//
//  Created by poliorang on 16.05.2023.
//

import XCTest
@testable import rfpr

class AuthorizationServiceTests: XCTestCase {
    
    var authorizationService: IAuthorizationService!
    var authorizationRepository: IAuthorizationRepository!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        authorizationRepository = MockAuthorizationRepository()
        authorizationService = AuthorizationService(authorizationRepository: authorizationRepository)
    }

    override func tearDownWithError() throws {
        authorizationService = nil
        authorizationRepository = nil
        
        try super.tearDownWithError()
    }
    

    func testCreateAuthorization() throws {
        let authorization = Authorization(id: "1", login: "1", password: "1")
        
        XCTAssertEqual(try authorizationService.createAuthorization(id: "1", login: "1", password: "1"), authorization)
    }
    
    func testCreateAuthorizationNil() throws {
        XCTAssertThrowsError(try authorizationService.createAuthorization(id: "1", login: nil, password: "1"))
    }
    
    func testCreateAuthorizationNil2() throws {
        XCTAssertThrowsError(try authorizationService.createAuthorization(id: "1", login: "1", password: nil))
    }
    
    func testGetAuthoByLoginPassword() throws {
        let authorization = Authorization(id: "1", login: "a", password: "a")
        
        XCTAssertEqual(try authorizationService.getAuthorizationByLoginPassword(authorization: authorization), authorization)
    }
    
    func testGetAuthoByLoginPasswordNil() throws {
        let authorization = Authorization(id: "1", login: "1", password: "1")
        
        XCTAssertThrowsError(try authorizationService.getAuthorizationByLoginPassword(authorization: authorization))
    }
}


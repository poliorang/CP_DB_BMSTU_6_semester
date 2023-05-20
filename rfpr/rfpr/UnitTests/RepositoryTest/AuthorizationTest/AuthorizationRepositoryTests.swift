//
//  AuthorizationRepositoryTests.swift
//  rfpr
//
//  Created by poliorang on 16.05.2023.
//

import XCTest
import RealmSwift
@testable import rfpr

fileprivate var authorizationRepository: AuthorizationRepository!
fileprivate var config = "AuthorizationRepositoryTests"
fileprivate var beforeTestClass: BeforeAuthorizationRepositoryTest!

class AuthorizationRepositoryTests: XCTestCase {
    
    override class func setUp() {
        super.setUp()
        
        do {
            authorizationRepository = try AuthorizationRepository(configRealm: config)
        } catch {
            print("Не удалось открыть Realm: \(config)")
            exit(-1)
        }
        
        // загрузить все данные для тестов
        beforeTestClass = BeforeAuthorizationRepositoryTest()
        
        do {
            try beforeTestClass.setupRepository(config: config)
            try beforeTestClass.createData()
        } catch {
            print("Не удалось загрузить данные: \(config)")
            exit(-1)
        }
    }

    override class func tearDown() {
        authorizationRepository = nil
        beforeTestClass = nil
        super.tearDown()
    }

    
    func testCreateLoot() throws {
        let authorization = Authorization(id: "6442852b2b74d595cb4f0000", login: "c", password: "c")
        var createdAuthorization: Authorization?
        
        XCTAssertNoThrow(createdAuthorization = try authorizationRepository.createAuthorization(authorization: authorization))
        XCTAssertEqual(createdAuthorization, authorization)
    }
    
    func testGetAuthoByLoginPassword() throws {
        let authorization = Authorization(id: "6442852b2b74d595cb4f1111", login: "a", password: "a")
        
        XCTAssertEqual(try authorizationRepository.getAuthorizationByLoginPassword(authorization: authorization), authorization)
    }
    
    func testGetAuthoByLoginPasswordNil() throws {
        let authorization = Authorization(id: "6442852b2b74d595cb4f3333", login: "e", password: "e")
        
        XCTAssertEqual(try authorizationRepository.getAuthorizationByLoginPassword(authorization: authorization), nil)
    }
}

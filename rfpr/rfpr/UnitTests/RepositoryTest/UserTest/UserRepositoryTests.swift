//
//  AuthorizationRepositoryTests.swift
//  rfpr
//
//  Created by poliorang on 16.05.2023.
//

import XCTest
import RealmSwift
@testable import rfpr

fileprivate var userRepository: UserRepository!
fileprivate var config = "AuthorizationRepositoryTests"
fileprivate var beforeTestClass: BeforeUserRepositoryTest!

class UserRepositoryTests: XCTestCase {
    
    override class func setUp() {
        super.setUp()
        
        do {
            userRepository = try UserRepository(configRealm: config)
        } catch {
            print("Не удалось открыть Realm: \(config)")
            exit(-1)
        }
        
        // загрузить все данные для тестов
        beforeTestClass = BeforeUserRepositoryTest()
        
        do {
            try beforeTestClass.setupRepository(config: config)
            try beforeTestClass.createData()
        } catch {
            print("Не удалось загрузить данные: \(config)")
            exit(-1)
        }
    }

    override class func tearDown() {
        userRepository = nil
        beforeTestClass = nil
        super.tearDown()
    }
    
    func testCreateUser() throws {
        let user = User(id: "6442852b2b74d595cb422222", role: Role.referee, authorization: nil)
        
        XCTAssertEqual(try userRepository.createUser(user: user), user)
    }
    
    func testGetUserByAuthorization() throws {
        let authorization = Authorization(id: "6442852b2b74d595cb411117", login: "1", password: "1")
        let user = User(id: "6442852b2b74d595cb411111", role: Role.referee, authorization: authorization)
        
        XCTAssertEqual(try userRepository.getUserByAuthorization(authorization: authorization), user)
    }
    
    func testGetUserByAuthorizationNil() throws {
        let authorization = Authorization(id: "6442852b2b74d595cb411118", login: "2", password: "2")
        
        XCTAssertEqual(try userRepository.getUserByAuthorization(authorization: authorization), nil)
    }
}

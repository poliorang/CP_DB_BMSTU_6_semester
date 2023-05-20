//
//  IUserRepository.swift
//  rfpr
//
//  Created by poliorang on 16.05.2023.
//

import XCTest
@testable import rfpr

class IUserRepositoryTests: XCTestCase {

    var userRepository: MockUserRepository!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        userRepository = MockUserRepository()
    }

    override func tearDownWithError() throws {
        userRepository = nil
        try super.tearDownWithError()
    }

    func testCreateUser() throws {
        let user = User(id: "2", role: Role.participant, authorization: nil)
        
        XCTAssertEqual(try userRepository.createUser(user: user), user)
    }
    
    func testGetUserByAuthorization() throws {
        let authorization = Authorization(id: "1", login: "1", password: "1")
        let user1 = User(id: "1", role: Role.participant, authorization: authorization)
        
        XCTAssertEqual(try userRepository.getUserByAuthorization(authorization: authorization), user1)
    }

}

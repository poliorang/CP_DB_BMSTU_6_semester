//
//  serServiceTests.swift
//  rfpr
//
//  Created by poliorang on 16.05.2023.
//


import XCTest
@testable import rfpr

class UserServiceTests: XCTestCase {
    
    var userService: IUserService!
    var userRepository: IUserRepository!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        userRepository = MockUserRepository()
        userService = UserService(userRepository: userRepository)
    }

    override func tearDownWithError() throws {
        userRepository = nil
        userRepository = nil
        
        try super.tearDownWithError()
    }
    
    func testCreateUser() throws {
        let user = User(id: "2", role: Role.participant, authorization: nil)
        
        XCTAssertEqual(try userService.createUser(id: "2", role: Role.participant, authorization: nil), user)
    }
    
    func testCreateUserNil() throws {
        XCTAssertThrowsError(try userService.createUser(id: "2", role: nil, authorization: nil))
    }
    
    func testGetUserByUser() throws {
        let authorization = Authorization(id: "1", login: "1", password: "1")
        let user1 = User(id: "1", role: Role.participant, authorization: authorization)
        
        XCTAssertEqual(try userService.getUserByAuthorization(authorization: authorization), user1)
    }
}
    

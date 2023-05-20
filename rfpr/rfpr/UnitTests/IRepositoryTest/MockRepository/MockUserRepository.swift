//
//  MockUserRepository.swift
//  rfpr
//
//  Created by poliorang on 16.05.2023.
//


class MockUserRepository: IUserRepository {
    private let authorization = Authorization(id: "1", login: "1", password: "1")
    private var user1 = User(id: "1", role: Role.participant, authorization: nil)
    private let user2 = User(id: "2", role: Role.participant, authorization: nil)
    private var db = [User]()

    func createUser(user: User) throws -> User? {
        db.append(user)
        
        if db.contains(user) == false {
            throw DatabaseError.addError
        }
        
        return user
    }
    
    func getUserByAuthorization(authorization: Authorization) throws -> User? {
        user1.authorization = authorization
        db.append(user1)
        db.append(user2)
        
        for user in db {
            if user.authorization?.login == authorization.login && user.authorization?.password == authorization.password {
                return user
            }
        }
        
        return nil
    }
    
    func updateUser(previousUser: User, newUser: User) throws -> User? { return nil }
    func deleteUser(user: User) throws { }
    func getUsers() throws -> [User]? { return nil }
}
    

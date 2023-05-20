//
//  MockAuthorizationRepository.swift
//  rfpr
//
//  Created by poliorang on 16.05.2023.
//

class MockAuthorizationRepository: IAuthorizationRepository {
    private let authorization1 = Authorization(id: "1", login: "a", password: "a")
    private let authorization2 = Authorization(id: "2", login: "b", password: "b")
    private var db = [Authorization]()
    
    func createAuthorization(authorization: Authorization) throws -> Authorization? {
        db.append(authorization)
        if db.contains(authorization) == false {
            throw DatabaseError.addError
        }
        
        return authorization
    }
    
    func getAuthorizationByLoginPassword(authorization: Authorization) throws -> Authorization? {
        db.append(authorization1)
        db.append(authorization2)
        
        for autho in db {
            if autho.login == authorization.login && autho.password == authorization.password {
                return autho
            }
        }
        
        return nil
    }
    
    func updateAuthorization(previousAuthorization: Authorization, newAuthorization: Authorization) throws -> Authorization? { return nil }
    
    func deleteAuthorization(authorization: Authorization) throws { }
    
    func getAuthorizations() throws -> [Authorization]? { return nil }
}
    

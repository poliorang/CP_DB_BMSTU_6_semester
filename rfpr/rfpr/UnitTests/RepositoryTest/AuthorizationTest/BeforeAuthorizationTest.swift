//
//  BeforeAuthorizationTest.swift
//  rfpr
//
//  Created by poliorang on 16.05.2023.
//

class BeforeAuthorizationRepositoryTest {
    var authorizationRepository: AuthorizationRepository!
    
    func setupRepository(config: String) throws {
        do {
            authorizationRepository = try AuthorizationRepository(configRealm: config)
            try authorizationRepository.realmDeleteAll()
        } catch {
            print("Не удалось открыть Realm: \(config)")
            throw DatabaseError.openError
        }
    }
    
    func createData() throws {
        let authorization1 = Authorization(id: "6442852b2b74d595cb4f1111", login: "a", password: "a")
        let authorization2 = Authorization(id: "6442852b2b74d595cb4f2222", login: "b", password: "b")
        
        do {
            try [authorization1, authorization2].forEach {
                try _ = authorizationRepository.createAuthorization(authorization: $0)
            }
        } catch {
                throw DatabaseError.addError
        }
    }
    
}


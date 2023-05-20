//
//  BeforeUserRepositoryTests.swift
//  rfpr
//
//  Created by poliorang on 16.05.2023.
//

class BeforeUserRepositoryTest {
    var userRepository: UserRepository!
    
    func setupRepository(config: String) throws {
        do {
            userRepository = try UserRepository(configRealm: config)
            try userRepository.realmDeleteAll()
        } catch {
            print("Не удалось открыть Realm: \(config)")
            throw DatabaseError.openError
        }
    }
    
    func createData() throws {
        let authorization = Authorization(id: "6442852b2b74d595cb411117", login: "1", password: "1")
        let user1 = User(id: "6442852b2b74d595cb411111", role: Role.referee, authorization: authorization)
        let user2 = User(id: "6442852b2b74d595cb422222", role: Role.referee, authorization: nil)
        
        do {
            try [user1, user2].forEach {
                try _ = userRepository.createUser(user: $0)
            }
        } catch {
                throw DatabaseError.addError
        }
    }
    
}


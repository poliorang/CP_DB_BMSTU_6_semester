//
//  UserService.swift
//  rfpr
//
//  Created by poliorang on 15.05.2023.
//

class UserService: IUserService {
    
    let userRepository: IUserRepository?
    
    init(userRepository: IUserRepository) {
        self.userRepository = userRepository
    }
    
    func createUser(id: String?, role: Role?, authorization: Authorization?) throws -> User? {
        guard let role = role else {
            throw ParameterError.funcParameterError
        }
        
        // проверка, что юзер с таким логоином уже есть
        if let login = authorization?.login {
            let userWithGettedLogin = try getUserByLogin(login)
            
            if let _ = userWithGettedLogin {
                throw DatabaseError.getError
            }
        }
        
        let user = User(id: id, role: role, authorization: authorization)
        let createdUser: User?
        
        do {
            createdUser = try userRepository?.createUser(user: user)
        } catch {
            throw DatabaseError.addError
        }
        
        guard let createdUser = createdUser else {
            throw DatabaseError.addError
        }
        
        return createdUser
    }
    
    func updateUser(previousUser: User?, newUser: User?) throws -> User? {
        guard let previousUser = previousUser,
              let newUser = newUser else {
            throw ParameterError.funcParameterError
        }
        
        // проверка, что юзер с таким логоином уже есть
        if let login = newUser.authorization?.login {
            let userWithGettedLogin = try getUserByLogin(login)
            
            if let _ = userWithGettedLogin {
                throw DatabaseError.getError
            }
        }
        
        let updatedUser: User?
        do {
            updatedUser = try userRepository?.updateUser(previousUser: previousUser, newUser: newUser)
        } catch DatabaseError.updateError {
            throw DatabaseError.updateError
        }
        
        guard let updatedUser = updatedUser else {
            throw DatabaseError.updateError
        }
        
        return updatedUser
    }
    
    func deleteUser(user: User?) throws {
        guard let user = user else {
            throw ParameterError.funcParameterError
        }
        
        do {
            try userRepository?.deleteUser(user: user)
        } catch DatabaseError.deleteError {
            throw DatabaseError.deleteError
        }
    }
    
    func getAuthorizedUsers() throws -> [User]? {
        var users: [User]?
        do {
            try users = userRepository?.getUsers()
        } catch {
            throw DatabaseError.getError
        }
        
        users = users?.filter( { $0.role != .participant } )
        
        return users
    }
    
    func getUserByAuthorization(authorization: Authorization?) throws -> User? {
        guard let authorization = authorization else {
            throw ParameterError.funcParameterError
        }
        
        let user: User?
        do {
            try user = userRepository?.getUserByAuthorization(authorization: authorization)
        } catch {
            throw DatabaseError.getError
        }
        
        return user
    }
    
    func getUserByLogin(_ login: String) throws -> User? {
        var users: [User]?
        do {
            try users = userRepository?.getUsers()
        } catch {
            throw DatabaseError.getError
        }
        
        let user = users?.filter( { $0.authorization?.login == login } ).first
        
        return user
    }
}

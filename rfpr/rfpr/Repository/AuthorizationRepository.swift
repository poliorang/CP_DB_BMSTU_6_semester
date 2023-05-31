//
//  AuthorizationRepository.swift
//  rfpr
//
//  Created by poliorang on 15.05.2023.
//

import Foundation
import RealmSwift

class AuthorizationRepository: IAuthorizationRepository {
    let realm: Realm!
    var config: Realm.Configuration!
    init(configRealm: String) throws {
        do {
            config = Realm.Configuration.defaultConfiguration
            config.fileURL!.deleteLastPathComponent()
            config.fileURL!.appendPathComponent("\(configRealm).realm")
            
            self.realm = try Realm(configuration: config)
        } catch {
            throw ConnectionError.realmConnectError
        }
    }
    
    func realmDeleteAll() throws {
        do {
            try realm.write {
              realm.deleteAll()
            }
        } catch {
            throw DatabaseError.deleteAllError
        }
    }
    
    func getAuthorization(id: String) throws -> Authorization? {
        let id = try ObjectId.init(string: id)
    
        let findedAuthorization = realm.objects(AuthorizationRealm.self).where {
            $0._id == id
        }.first

        if let findedAuthorization = findedAuthorization {
            return findedAuthorization.convertAuthorizationFromRealm()
        }
        
        return nil
    }
    
    func createAuthorization(authorization: Authorization) throws -> Authorization? {
        let realmAuthorization: AuthorizationRealm
        
        do {
            realmAuthorization = try authorization.convertAuthorizationToRealm(realm)
        } catch {
            throw DatabaseError.addError
        }
        
        do {
            try realm.write {
                realm.add(realmAuthorization)
            }
        } catch {
            throw DatabaseError.addError
        }
        
        let createdAuthorization = try getAuthorizationByLoginPassword(authorization: authorization)
     
        return createdAuthorization
    }
    
    func updateAuthorization(previousAuthorization: Authorization, newAuthorization: Authorization) throws -> Authorization? {
        var newAuthorization = newAuthorization
        newAuthorization.id = nil
        
        let realmPreviousAuthorization = try previousAuthorization.convertAuthorizationToRealm(realm)
        let realmNewAuthorization = try newAuthorization.convertAuthorizationToRealm(realm)
        
        let authorizationFromDB = realm.objects(AuthorizationRealm.self).where {
            $0._id == realmPreviousAuthorization._id
        }.first
        
        guard authorizationFromDB != nil else {
            throw ParameterError.funcParameterError
        }
        
        do {
            try realm.write {
                realmNewAuthorization._id = realmPreviousAuthorization._id
                realm.add(realmNewAuthorization, update: .modified)
            }
        } catch {
            throw DatabaseError.updateError
        }
        
        let updatedAuthorization = try getAuthorization(id: "\(realmNewAuthorization._id)")
        
        return updatedAuthorization
    }
    
    func deleteAuthorization(authorization: Authorization) throws {
        let realmAuthorization = try authorization.convertAuthorizationToRealm(realm)
        
        let authorizationFromDB = realm.objects(AuthorizationRealm.self).where {
            $0._id == realmAuthorization._id
        }.first
        
        guard let authorizationFromDB = authorizationFromDB else {
            throw ParameterError.funcParameterError
        }
        
        do {
            try realm.write {
                realm.delete(authorizationFromDB)
            }
        } catch {
            throw DatabaseError.updateError
        }
    }
    
    func getAuthorizationByLoginPassword(authorization findAuthorization: Authorization) throws -> Authorization? {
        let authorizations = try getAuthorizations()
        
        for authorization in authorizations ?? [] {
            if authorization.password == findAuthorization.password &&
                authorization.login == findAuthorization.login {
                return authorization
            }
        }
        
        return nil
    }
    
    func getAuthorizations() throws -> [Authorization]? {
        let realmAuthorization = realm.objects(AuthorizationRealm.self)
        var authorizations = [Authorization]()
        
        for authorization in realmAuthorization {
            authorizations.append(authorization.convertAuthorizationFromRealm())
        }

        return authorizations.isEmpty ? nil : authorizations
    }
}

extension AuthorizationRepository {
    func getRight(_ user: User?, _ action: Action) -> Bool {
        guard let user = user else { return false }

        switch user.role {
            
        case .participant:
            switch action {
            case .create:
                return false
            case .read:
                return false
            case .update:
                return false
            case .delete:
                return false
            }

        case .referee:
            switch action {
            case .create:
                return false
            case .read:
                return true
            case .update:
                return false
            case .delete:
                return false
            }
        
        case .admin:
            switch action {
            case .create:
                return true
            case .read:
                return true
            case .update:
                return true
            case .delete:
                return true
            }
        }
    }
}

//
//  AuthorizationManager.swift
//  rfpr
//
//  Created by poliorang on 15.05.2023.
//

final class AuthorizationManager {    
    static let shared = AuthorizationManager()
    
    private init() { }
    
    private static var user: User?

    func setUser(_ user: User) {
        AuthorizationManager.user = user
    }
    
    func getUser() -> User? {
        return AuthorizationManager.user
    }
    
    func getRight(_ admin: Bool = false) -> Bool {
        switch getUser()?.role {
            
        case .participant:
            return false
            
        case .referee:
            if admin { return false }
            return true
        
        case .admin:
            return true
        
        default:
            return false
        }
    }
}

//
//  UserModel.swift
//  rfpr
//
//  Created by poliorang on 14.05.2023.
//

enum Role: String {
    case participant = "Участник"
    case referee     = "Судья"
    case admin       = "Администратор"
}
    
enum Action {
    case create
    case read
    case update
    case delete
}

struct User {
    var id: String?
    var role: Role
    var authorization: Authorization?
    
    func getRight(_ admin: Bool = false) -> Bool {
        switch role {
            
        case .participant:
            return false
            
        case .referee:
            if admin { return false }
            return true
            
        case .admin:
            return true
        }
    }
}

extension User: Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        if lhs.id == rhs.id &&
            lhs.role == rhs.role &&
            lhs.authorization == rhs.authorization {
            return true
        }
        
        return false
    }
    
    static func != (lhs: User, rhs: User) -> Bool {
        return !(lhs == rhs)
    }
}

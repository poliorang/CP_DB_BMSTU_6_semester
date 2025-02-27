//
//  CompetitionRepository.swift
//  rfpr
//
//  Created by poliorang on 15.04.2023.
//

import Foundation
import RealmSwift

class CompetitionRepository: ICompetitionRepository, IStepToCompetitionRepository {
    
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
    
    let authorizationManager = AuthorizationManager.shared
    
    func realmDeleteAll() throws {
        do {
            try realm.write {
              realm.deleteAll()
            }
        } catch {
            throw DatabaseError.deleteAllError
        }
    }
    
    func getCompetition(id: String) throws -> Competition? {
        if !getRight(authorizationManager.getUser(), Action.read) {
            throw DatabaseError.rightsError
        }
        
        let id = try ObjectId.init(string: id)
    
        let findedCompetition = realm.objects(CompetitionRealm.self).where {
            $0._id == id
        }.first

        if let findedCompetition = findedCompetition {
            return findedCompetition.convertCompetitionFromRealm()
        }
        
        return nil
    }
    
    func createCompetition(competition: Competition) throws -> Competition? {
        if !getRight(authorizationManager.getUser(), Action.create) {
            throw DatabaseError.rightsError
        }
        
        let realmCompetition: CompetitionRealm
        
        do {
            realmCompetition = try competition.convertCompetitionToRealm(realm)
        } catch {
            throw DatabaseError.addError
        }
        
        do {
            try realm.write {
                realm.add(realmCompetition)
            }
        } catch {
            throw DatabaseError.addError
        }
        
        let createdCompetition = try getCompetition(id: "\(realmCompetition._id)")
        
        return createdCompetition
    }
    
    func deleteCompetition(competition: Competition) throws {
        if !getRight(authorizationManager.getUser(), Action.delete) {
            throw DatabaseError.rightsError
        }
        
        let realmCompetition = try competition.convertCompetitionToRealm(realm)
        
        let competitionsFromDB = realm.objects(CompetitionRealm.self)
        var competitionFromDB: CompetitionRealm? = nil
        
        for competition in competitionsFromDB {
            if competition._id == realmCompetition._id {
                competitionFromDB = competition
                break
            }
        }
        
        guard let competitionFromDB = competitionFromDB else {
            throw ParameterError.funcParameterError
        }
        
        do {
            try realm.write {
                realm.delete(competitionFromDB)
            }
        } catch {
            throw DatabaseError.updateError
        }
    }
    
    func getCompetitions() throws -> [Competition]? {

        let competitionsRealm = realm.objects(CompetitionRealm.self)
        var competitions = [Competition]()
        
        for competition in competitionsRealm {
            competitions.append(competition.convertCompetitionFromRealm())
        }

        return competitions.isEmpty ? nil : competitions
    }
    
    func addStep(step: Step, competition: Competition) throws {
        let realmStep = try step.convertStepToRealm(realm)
        let realmCompetition = try competition.convertCompetitionToRealm(realm)
        
        let stepFromDB = realm.objects(StepRealm.self).where {
            $0._id == realmStep._id
        }.first
        
        guard let stepFromDB = stepFromDB else {
            throw ParameterError.funcParameterError
        }
        
        let competitionsFromDB = realm.objects(CompetitionRealm.self)
        var competitionFromDB: CompetitionRealm? = nil
        
        for competition in competitionsFromDB {
            if competition._id == realmCompetition._id {
                competitionFromDB = competition
                break
            }
        }
        
        guard let competitionFromDB = competitionFromDB else {
            throw ParameterError.funcParameterError
        }
        
        do {
            try realm.write {
                stepFromDB.competition = competitionFromDB
                realm.add(stepFromDB, update: .modified)
            }
        } catch {
            throw DatabaseError.updateError
        }
    }
}

extension CompetitionRepository {
    func getRight(_ user: User?, _ action: Action) -> Bool {
        guard let user = user else { return false }

        switch user.role {
            
        case .participant:
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

        case .referee:
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

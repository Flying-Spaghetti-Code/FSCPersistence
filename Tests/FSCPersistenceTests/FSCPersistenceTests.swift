import XCTest
@testable import FSCPersistence

final class FSCPersistenceTests: XCTestCase {

    func validPersistence() -> FSCPersistence {
        
        clearVersion()
        let config = FSCPersistence.Configuration(version: 1, groupIdentifier: nil)
        let persistence = try! FSCPersistence(withConfiguration: config)

        return persistence
    }
    
    func objectListOfString() -> (key: String, list: [String]) {
        
        return ("kListOfStrings", ["Joao", "Giovanni", "Cortado", "Flying Spaghetti Code"])
    }
    
    func clearVersion() {
        
        UserDefaults.standard.set(0, forKey: "kFSCPersistenceVersion")
    }
    
    func testVersionFailure() throws {
        
        clearVersion()
        let config = FSCPersistence.Configuration(version: 0, groupIdentifier: nil)
        let persistence = try? FSCPersistence(withConfiguration: config)
        XCTAssertNil(persistence)
    }
    
    func testInitialVersionSuccess() throws {
        
        clearVersion()
        let config = FSCPersistence.Configuration(version: 1, groupIdentifier: nil)
        let persistence = try? FSCPersistence(withConfiguration: config)
        XCTAssertNotNil(persistence)
    }
    
    func testSavePrimitivesInSettings() throws {
        
        let persistence = validPersistence()
        let data = objectListOfString()
        try persistence.save(object: data.list, withKey: data.key, intoStorage: .settings)
    }
    
    func testLoadPrimitivesInSettings() throws {
        
        let persistence = validPersistence()
        let data = objectListOfString()
        try persistence.save(object: data.list, withKey: data.key, intoStorage: .settings)
        let savedList = try persistence.load(objectType: [String].self, withKey: data.key, fromStorage: .settings)
        XCTAssertEqual(data.list, savedList)
    }
    
    func testDeletePrimitivesInSettings() throws {
        
        clearVersion()
        let config = FSCPersistence.Configuration(version: 1, groupIdentifier: nil)
        let persistence = try! FSCPersistence(withConfiguration: config)
        let data = objectListOfString()
        try persistence.save(object: data.list, withKey: data.key, intoStorage: .settings)
        persistence.delete(withKey: data.key, fromStorage: .settings)
        let savedList = try? persistence.load(objectType: [String].self, withKey: data.key, fromStorage: .settings)
        XCTAssertNil(savedList)
    }
    
    func testVersionUpdateInSettings() throws {
        
        clearVersion()
        let config = FSCPersistence.Configuration(version: 1, groupIdentifier: nil)
        var persistence = try! FSCPersistence(withConfiguration: config)
        let data = objectListOfString()
        try persistence.save(object: data.list, withKey: data.key, intoStorage: .settings)
        let updatedConfig = FSCPersistence.Configuration(version: 2, groupIdentifier: nil)
        persistence = try! FSCPersistence(withConfiguration: updatedConfig)
        let savedList = try? persistence.load(objectType: [String].self, withKey: data.key, fromStorage: .settings)
        XCTAssertNil(savedList)
    }
    
    func testSavePrimitivesInFiles() throws {
        
        let persistence = validPersistence()
        let data = objectListOfString()
        try persistence.save(object: data.list, withKey: data.key, intoStorage: .settings)
    }
    
    func testLoadPrimitivesInFiles() throws {
        
        let persistence = validPersistence()
        let data = objectListOfString()
        try persistence.save(object: data.list, withKey: data.key, intoStorage: .settings)
        let savedList = try persistence.load(objectType: [String].self, withKey: data.key, fromStorage: .settings)
        XCTAssertEqual(data.list, savedList)
    }
    
    func testDeletePrimitivesInFiles() throws {
        
        clearVersion()
        let config = FSCPersistence.Configuration(version: 1, groupIdentifier: nil)
        let persistence = try! FSCPersistence(withConfiguration: config)
        let data = objectListOfString()
        try persistence.save(object: data.list, withKey: data.key, intoStorage: .settings)
        persistence.delete(withKey: data.key, fromStorage: .settings)
        let savedList = try? persistence.load(objectType: [String].self, withKey: data.key, fromStorage: .settings)
        XCTAssertNil(savedList)
    }
    
    func testVersionUpdateInFiles() throws {
        
        clearVersion()
        let config = FSCPersistence.Configuration(version: 1, groupIdentifier: nil)
        var persistence = try! FSCPersistence(withConfiguration: config)
        let data = objectListOfString()
        try persistence.save(object: data.list, withKey: data.key, intoStorage: .settings)
        let updatedConfig = FSCPersistence.Configuration(version: 2, groupIdentifier: nil)
        persistence = try! FSCPersistence(withConfiguration: updatedConfig)
        let savedList = try? persistence.load(objectType: [String].self, withKey: data.key, fromStorage: .settings)
        XCTAssertNil(savedList)
    }
}

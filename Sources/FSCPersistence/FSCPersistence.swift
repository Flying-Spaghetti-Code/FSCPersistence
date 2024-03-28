import Foundation

public class FSCPersistence {

    // MARK: - Objects
    /// An object that contains the necessary configurations for the Persistence
    public struct Configuration {
        
        public init(version: Int, groupIdentifier: String? = nil) {
            self.version = version
            self.groupIdentifier = groupIdentifier
        }
        
        /// Increase this value if you need to force a migration, wiping all previously stored data. Must be bigger than 0
        public var version: Int
        
        /// Used if you want to share the UserDefaults between applications in the same App Suite
        /// Read More: https://developer.apple.com/documentation/corefoundation/preferences_utilities
        public var groupIdentifier: String?
    }
    
    public enum StorageType {
        case settings
        case file
    }
    
    public enum PersistenceError: Error {
        case failedToInitiate(withSuitName: String)
        case failedToLoadData(inStorage: StorageType)
        case invalidVersion
        case versionIsTooLow
    }
    
    // MARK: - Properties
    private let settings: UserDefaults
    private let folder: URL
    private var fileManager: FileManager
    private var keys = Set<String>()
    private var version: Int
    
    private let persistenceKeys = "kFSCPersistenceKeys"
    private let persistenceVersion = "kFSCPersistenceVersion"
    
    /// The initializer can fail if the Group Identifier is not nil or valid.
    /// - Parameter config: Configuration Object
    public init(withConfiguration config: Configuration) throws {
        
        if config.version == 0 {
            
            throw PersistenceError.invalidVersion
        }
        fileManager = FileManager.default
        version = config.version
        if config.groupIdentifier != nil {
            
            if let userDefaults = UserDefaults(suiteName: config.groupIdentifier!),
                let folderUrl = fileManager.containerURL(forSecurityApplicationGroupIdentifier: config.groupIdentifier!) {
                
                settings = userDefaults
                folder = folderUrl
            }
            else {
                
                throw PersistenceError.failedToInitiate(withSuitName: config.groupIdentifier!)
            }
        }
        else {
            
            settings = UserDefaults.standard
            folder = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        }
        loadKeys()
        try versionCheck()
    }
    
    /// Default initializer. It creates a configuration object on version 1 and without Group Identifier.
    public convenience init() throws {
        
        let config = Configuration(version: 1, groupIdentifier: nil)
        try self.init(withConfiguration: config)
    }
    
    // MARK: - Public Methods
    
    /// Generic method to save data into one of the available storage type
    /// - Parameters:
    ///   - data: encoded data to be saved
    ///   - key: unique key
    ///   - type: storage location
    public func save(data: Data, withKey key: String, intoStorage type: StorageType) throws {
        
        switch type {
                
            case .settings: settings.set(data, forKey: key)
            case .file:
                let fileURL = folder.appendingPathComponent(key)
                fileManager.createFile(atPath: fileURL.path, contents: data, attributes: nil)
        }
        store(key: key)
    }
    
    /// Returns encoded data from a given storage type
    /// - Parameters:
    ///   - key: unique key used to save the data
    ///   - type: storage location
    /// - Returns: stored encoded data
    public func load(withKey key: String, fromStorage type: StorageType) throws -> Data {
        
        var data: Data
        switch type {
            case .settings:
                if let storedData = settings.data(forKey: key) {
                    
                    data = storedData
                }
                else {
                    
                    throw PersistenceError.failedToLoadData(inStorage: type)
                }
            case .file:
                let fileURL = folder.appendingPathComponent(key)
                if let storedData = try? Data(contentsOf: fileURL) {
                    
                    data = storedData
                }
                else {
                    
                    throw PersistenceError.failedToLoadData(inStorage: type)
                }
        }
        
        return data
    }
    
    /// Saves a given object into the specified storage
    public func save<T: Codable>(object: T, withKey key: String, intoStorage type: StorageType) throws {
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(object)
        try save(data: data, withKey: key, intoStorage: type)
    }
    
    /// Loads a given object from the specified storage
    /// - Returns: Codable object as specified in the ObjectType parametre
    public func load<T: Codable>(objectType: T.Type, withKey key: String, fromStorage type: StorageType) throws -> T {
        
        let data = try load(withKey: key, fromStorage: type)
        let decoder = JSONDecoder()
        let result = try decoder.decode(objectType.self, from: data)
        
        return result
    }
    
    public func delete(withKey key: String, fromStorage type: StorageType) {
        
        switch type {
            case .settings: settings.removeObject(forKey: key)
            case .file:
                let fileURL = folder.appendingPathComponent(key)
                try? fileManager.removeItem(atPath: fileURL.path)
        }
    }
    
    // MARK: - Private Methods
    private func store(key: String) {
        
        if !keys.contains(key) {
            
            keys.insert(key)
            let encodedKeys = try! JSONEncoder().encode(keys)
            let fileURL = folder.appendingPathComponent(persistenceKeys)
            fileManager.createFile(atPath: fileURL.path, contents: encodedKeys, attributes: nil)
        }
    }
    
    private func loadKeys() {
        
        let fileURL = folder.appendingPathComponent(persistenceKeys)
        let decoder = JSONDecoder()
        if let data = try? Data(contentsOf: fileURL), let result = try? decoder.decode([String].self, from: data) {
            
            self.keys = Set(result)
        }
    }
    
    private func deleteKeys() {
        
        keys = []
        let fileURL = folder.appendingPathComponent(persistenceKeys)
        try? fileManager.removeItem(atPath: fileURL.path)
    }
    
    private func versionCheck() throws {
        
        let storedVersion = UserDefaults.standard.integer(forKey: persistenceVersion)
        guard storedVersion > 0 else {
            
            UserDefaults.standard.set(version, forKey: persistenceVersion)
            return
        }
        guard storedVersion <= version else {
            
            throw PersistenceError.versionIsTooLow
        }
        if version > storedVersion {
            
            for key in keys {
                
                delete(withKey: key, fromStorage: .settings)
                delete(withKey: key, fromStorage: .file)
            }
            deleteKeys()
        }
        UserDefaults.standard.set(version, forKey: persistenceVersion)
    }
}

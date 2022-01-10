# FSCPersistence

FSCPersistence is a library that simplifies the storage process for storing data in UserDefaults and on file.

# Overview
The FSCPersistence allows to save any Codable object, it has version control (more info) and has a consistent API.

# Installation

### Swift Package Manager
FSCPersistence is available through [Swift Package Manager](https://github.com/apple/swift-package-manager). 
To install it, simply add the dependency to your Package.Swift file:

```Swift
...
dependencies: [
    .package(url: "https://github.com/Flying-Spaghetti-Code/FSCPersistence", from: "1.0.0"),
],
targets: [
    .target( name: "YourTarget", dependencies: ["FSCPersistence"]),
]
...
```

# How to use

### Creating a Configuration Object
```Swift
import FSCPersistence

let config = FSCPersistence.Configuration(version: 1, groupIdentifier: nil)
```

The config file is used to preserve data version and to use group identifier if you’re creating an app that is in an App Group.
If you need to delete a version of data, you only need to increase the version number and all data stored through FSCPersistence will be deleted - including the metadata (key used to store the data)

### Creating a Persistence Object
```Swift
import FSCPersistence

let config = FSCPersistence.Configuration(version: 1, groupIdentifier: nil)
try! persistence = FSCPersistence(withConfiguration: config)
```

You can also instantiate a new version of FSCPersistence Object without a configuration file, which will have version 1 by default and no Group Identifier.

### Saving an object
```Swift
try? persistence.save(object: myObject, withKey: myObjectKey, intoStorage: .settings)
```

All objects to save need to conforme to ```Codable```. The key is a unique identifier for this object. If you can choose to store an object in UserDefauts aka ```.settings``` or in a file in disk aka ```.file```.

You also have the option store ```Data``` directly, and not just a Codable object.

### Loading an object
```Swift
 try? persistence.load(objectType: myObject.self, withKey: myObjectKey, fromStorage: .settings)
```

If loading a Coddle object, when calling the load method, you need to specify the ```Object.Type```. The object key used should be the same used to store it, as should the storage type.

### Deleting an Object
```Swift
persistence.delete(withKey: myObjectKey, fromStorage: .settings)
```

When deleting an object from a storage, you only need to send the object key, and storage location. 
*Note*: This object metadata (object key) will not be removed until a version is increased.

# Planned Development

- [ ] Add Realm Support;
- [ ] Add CoreData Support;

## License
FSCPersistence is available under the MIT license. See the LICENSE file for more info.

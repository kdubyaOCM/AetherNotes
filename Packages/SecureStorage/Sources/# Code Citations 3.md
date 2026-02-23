# Code Citations

## License: MIT
https://github.com/rakutentech/ios-remote-config/blob/a186fe73e3b2dd840e27618265b3c094e72f39ca/RRemoteConfig/KeyStore.swift

```


# Secure Key Storage System for AetherNotes

I'll implement a complete Secure Enclave + Keychain key storage system. This involves several components: the enclave key manager, keychain helpers, encrypted secret storage, and a fallback for devices without Secure Enclave.

Let me first check the existing project structure:

Let me build this out as a Swift package in `Packages/` per the repo layout conventions.

## 1. Package Definition

````swift
// filepath: /Users/kieranwalsh/Documents/GitHub/AetherNotes/Packages/SecureStorage/Package.swift
// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "SecureStorage",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .watchOS(.v10)
    ],
    products: [
        .library(
            name: "SecureStorage",
            targets: ["SecureStorage"]
        )
    ],
    targets: [
        .target(
            name: "SecureStorage",
            path: "Sources"
        ),
        .testTarget(
            name: "SecureStorageTests",
            dependencies: ["SecureStorage"],
            path: "Tests"
        )
    ]
)
````

## 2. Keychain Helper

````swift
// filepath: /Users/kieranwalsh/Documents/GitHub/AetherNotes/Packages/SecureStorage/Sources/KeychainHelper.swift
import Foundation
import Security

/// Low-level Keychain CRUD operations.
/// All methods are synchronous and should be called off the main thread.
public enum KeychainHelper: Sendable {

    public enum KeychainError: Error, Sendable {
        case duplicateItem
        case itemNotFound
        case unexpectedStatus(OSStatus)
        case invalidData
    }

    // MARK: - Save

    /// Stores binary data in the Keychain under the given service+account.
    /// Uses `.whenUnlockedThisDeviceOnly` so items never migrate via backup.
    public static func save(
        data: Data,
        service: String,
        account: String
    ) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        let status = SecItemAdd(query as CFDictionary, nil)

        switch status {
        case errSecSuccess:
            return
        case errSecDuplicateItem:
            // Update existing item
            let updateQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: account
            ]
            let attributes: [String: Any] = [
                kSecValueData as String: data
            ]
            let updateStatus = SecItemUpdate(
                updateQuery as CFDictionary,
                attributes as CFDictionary
            )
            guard updateStatus == errSecSuccess else {
                throw KeychainError.unexpectedStatus(updateStatus)
            }
        default:
            throw KeychainError.unexpectedStatus(status)
        }
    }

    // MARK: - Load

    /// Retrieves binary data from the Keychain for the given service+account.
    public static func load(
        service: String,
        account: String
    ) throws -> Data {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        switch status {
```


## License: MIT
https://github.com/rakutentech/ios-remote-config/blob/a186fe73e3b2dd840e27618265b3c094e72f39ca/RRemoteConfig/KeyStore.swift

```


# Secure Key Storage System for AetherNotes

I'll implement a complete Secure Enclave + Keychain key storage system. This involves several components: the enclave key manager, keychain helpers, encrypted secret storage, and a fallback for devices without Secure Enclave.

Let me first check the existing project structure:

Let me build this out as a Swift package in `Packages/` per the repo layout conventions.

## 1. Package Definition

````swift
// filepath: /Users/kieranwalsh/Documents/GitHub/AetherNotes/Packages/SecureStorage/Package.swift
// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "SecureStorage",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .watchOS(.v10)
    ],
    products: [
        .library(
            name: "SecureStorage",
            targets: ["SecureStorage"]
        )
    ],
    targets: [
        .target(
            name: "SecureStorage",
            path: "Sources"
        ),
        .testTarget(
            name: "SecureStorageTests",
            dependencies: ["SecureStorage"],
            path: "Tests"
        )
    ]
)
````

## 2. Keychain Helper

````swift
// filepath: /Users/kieranwalsh/Documents/GitHub/AetherNotes/Packages/SecureStorage/Sources/KeychainHelper.swift
import Foundation
import Security

/// Low-level Keychain CRUD operations.
/// All methods are synchronous and should be called off the main thread.
public enum KeychainHelper: Sendable {

    public enum KeychainError: Error, Sendable {
        case duplicateItem
        case itemNotFound
        case unexpectedStatus(OSStatus)
        case invalidData
    }

    // MARK: - Save

    /// Stores binary data in the Keychain under the given service+account.
    /// Uses `.whenUnlockedThisDeviceOnly` so items never migrate via backup.
    public static func save(
        data: Data,
        service: String,
        account: String
    ) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        let status = SecItemAdd(query as CFDictionary, nil)

        switch status {
        case errSecSuccess:
            return
        case errSecDuplicateItem:
            // Update existing item
            let updateQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: account
            ]
            let attributes: [String: Any] = [
                kSecValueData as String: data
            ]
            let updateStatus = SecItemUpdate(
                updateQuery as CFDictionary,
                attributes as CFDictionary
            )
            guard updateStatus == errSecSuccess else {
                throw KeychainError.unexpectedStatus(updateStatus)
            }
        default:
            throw KeychainError.unexpectedStatus(status)
        }
    }

    // MARK: - Load

    /// Retrieves binary data from the Keychain for the given service+account.
    public static func load(
        service: String,
        account: String
    ) throws -> Data {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        switch status {
```


## License: MIT
https://github.com/rakutentech/ios-remote-config/blob/a186fe73e3b2dd840e27618265b3c094e72f39ca/RRemoteConfig/KeyStore.swift

```


# Secure Key Storage System for AetherNotes

I'll implement a complete Secure Enclave + Keychain key storage system. This involves several components: the enclave key manager, keychain helpers, encrypted secret storage, and a fallback for devices without Secure Enclave.

Let me first check the existing project structure:

Let me build this out as a Swift package in `Packages/` per the repo layout conventions.

## 1. Package Definition

````swift
// filepath: /Users/kieranwalsh/Documents/GitHub/AetherNotes/Packages/SecureStorage/Package.swift
// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "SecureStorage",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .watchOS(.v10)
    ],
    products: [
        .library(
            name: "SecureStorage",
            targets: ["SecureStorage"]
        )
    ],
    targets: [
        .target(
            name: "SecureStorage",
            path: "Sources"
        ),
        .testTarget(
            name: "SecureStorageTests",
            dependencies: ["SecureStorage"],
            path: "Tests"
        )
    ]
)
````

## 2. Keychain Helper

````swift
// filepath: /Users/kieranwalsh/Documents/GitHub/AetherNotes/Packages/SecureStorage/Sources/KeychainHelper.swift
import Foundation
import Security

/// Low-level Keychain CRUD operations.
/// All methods are synchronous and should be called off the main thread.
public enum KeychainHelper: Sendable {

    public enum KeychainError: Error, Sendable {
        case duplicateItem
        case itemNotFound
        case unexpectedStatus(OSStatus)
        case invalidData
    }

    // MARK: - Save

    /// Stores binary data in the Keychain under the given service+account.
    /// Uses `.whenUnlockedThisDeviceOnly` so items never migrate via backup.
    public static func save(
        data: Data,
        service: String,
        account: String
    ) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        let status = SecItemAdd(query as CFDictionary, nil)

        switch status {
        case errSecSuccess:
            return
        case errSecDuplicateItem:
            // Update existing item
            let updateQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: account
            ]
            let attributes: [String: Any] = [
                kSecValueData as String: data
            ]
            let updateStatus = SecItemUpdate(
                updateQuery as CFDictionary,
                attributes as CFDictionary
            )
            guard updateStatus == errSecSuccess else {
                throw KeychainError.unexpectedStatus(updateStatus)
            }
        default:
            throw KeychainError.unexpectedStatus(status)
        }
    }

    // MARK: - Load

    /// Retrieves binary data from the Keychain for the given service+account.
    public static func load(
        service: String,
        account: String
    ) throws -> Data {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        switch status {
```


## License: MIT
https://github.com/rakutentech/ios-remote-config/blob/a186fe73e3b2dd840e27618265b3c094e72f39ca/RRemoteConfig/KeyStore.swift

```


# Secure Key Storage System for AetherNotes

I'll implement a complete Secure Enclave + Keychain key storage system. This involves several components: the enclave key manager, keychain helpers, encrypted secret storage, and a fallback for devices without Secure Enclave.

Let me first check the existing project structure:

Let me build this out as a Swift package in `Packages/` per the repo layout conventions.

## 1. Package Definition

````swift
// filepath: /Users/kieranwalsh/Documents/GitHub/AetherNotes/Packages/SecureStorage/Package.swift
// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "SecureStorage",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .watchOS(.v10)
    ],
    products: [
        .library(
            name: "SecureStorage",
            targets: ["SecureStorage"]
        )
    ],
    targets: [
        .target(
            name: "SecureStorage",
            path: "Sources"
        ),
        .testTarget(
            name: "SecureStorageTests",
            dependencies: ["SecureStorage"],
            path: "Tests"
        )
    ]
)
````

## 2. Keychain Helper

````swift
// filepath: /Users/kieranwalsh/Documents/GitHub/AetherNotes/Packages/SecureStorage/Sources/KeychainHelper.swift
import Foundation
import Security

/// Low-level Keychain CRUD operations.
/// All methods are synchronous and should be called off the main thread.
public enum KeychainHelper: Sendable {

    public enum KeychainError: Error, Sendable {
        case duplicateItem
        case itemNotFound
        case unexpectedStatus(OSStatus)
        case invalidData
    }

    // MARK: - Save

    /// Stores binary data in the Keychain under the given service+account.
    /// Uses `.whenUnlockedThisDeviceOnly` so items never migrate via backup.
    public static func save(
        data: Data,
        service: String,
        account: String
    ) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        let status = SecItemAdd(query as CFDictionary, nil)

        switch status {
        case errSecSuccess:
            return
        case errSecDuplicateItem:
            // Update existing item
            let updateQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: account
            ]
            let attributes: [String: Any] = [
                kSecValueData as String: data
            ]
            let updateStatus = SecItemUpdate(
                updateQuery as CFDictionary,
                attributes as CFDictionary
            )
            guard updateStatus == errSecSuccess else {
                throw KeychainError.unexpectedStatus(updateStatus)
            }
        default:
            throw KeychainError.unexpectedStatus(status)
        }
    }

    // MARK: - Load

    /// Retrieves binary data from the Keychain for the given service+account.
    public static func load(
        service: String,
        account: String
    ) throws -> Data {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        switch status {
```


## License: MIT
https://github.com/rakutentech/ios-remote-config/blob/a186fe73e3b2dd840e27618265b3c094e72f39ca/RRemoteConfig/KeyStore.swift

```


# Secure Key Storage System for AetherNotes

I'll implement a complete Secure Enclave + Keychain key storage system. This involves several components: the enclave key manager, keychain helpers, encrypted secret storage, and a fallback for devices without Secure Enclave.

Let me first check the existing project structure:

Let me build this out as a Swift package in `Packages/` per the repo layout conventions.

## 1. Package Definition

````swift
// filepath: /Users/kieranwalsh/Documents/GitHub/AetherNotes/Packages/SecureStorage/Package.swift
// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "SecureStorage",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .watchOS(.v10)
    ],
    products: [
        .library(
            name: "SecureStorage",
            targets: ["SecureStorage"]
        )
    ],
    targets: [
        .target(
            name: "SecureStorage",
            path: "Sources"
        ),
        .testTarget(
            name: "SecureStorageTests",
            dependencies: ["SecureStorage"],
            path: "Tests"
        )
    ]
)
````

## 2. Keychain Helper

````swift
// filepath: /Users/kieranwalsh/Documents/GitHub/AetherNotes/Packages/SecureStorage/Sources/KeychainHelper.swift
import Foundation
import Security

/// Low-level Keychain CRUD operations.
/// All methods are synchronous and should be called off the main thread.
public enum KeychainHelper: Sendable {

    public enum KeychainError: Error, Sendable {
        case duplicateItem
        case itemNotFound
        case unexpectedStatus(OSStatus)
        case invalidData
    }

    // MARK: - Save

    /// Stores binary data in the Keychain under the given service+account.
    /// Uses `.whenUnlockedThisDeviceOnly` so items never migrate via backup.
    public static func save(
        data: Data,
        service: String,
        account: String
    ) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        let status = SecItemAdd(query as CFDictionary, nil)

        switch status {
        case errSecSuccess:
            return
        case errSecDuplicateItem:
            // Update existing item
            let updateQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: account
            ]
            let attributes: [String: Any] = [
                kSecValueData as String: data
            ]
            let updateStatus = SecItemUpdate(
                updateQuery as CFDictionary,
                attributes as CFDictionary
            )
            guard updateStatus == errSecSuccess else {
                throw KeychainError.unexpectedStatus(updateStatus)
            }
        default:
            throw KeychainError.unexpectedStatus(status)
        }
    }

    // MARK: - Load

    /// Retrieves binary data from the Keychain for the given service+account.
    public static func load(
        service: String,
        account: String
    ) throws -> Data {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        switch status {
```


## License: MIT
https://github.com/rakutentech/ios-remote-config/blob/a186fe73e3b2dd840e27618265b3c094e72f39ca/RRemoteConfig/KeyStore.swift

```


# Secure Key Storage System for AetherNotes

I'll implement a complete Secure Enclave + Keychain key storage system. This involves several components: the enclave key manager, keychain helpers, encrypted secret storage, and a fallback for devices without Secure Enclave.

Let me first check the existing project structure:

Let me build this out as a Swift package in `Packages/` per the repo layout conventions.

## 1. Package Definition

````swift
// filepath: /Users/kieranwalsh/Documents/GitHub/AetherNotes/Packages/SecureStorage/Package.swift
// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "SecureStorage",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .watchOS(.v10)
    ],
    products: [
        .library(
            name: "SecureStorage",
            targets: ["SecureStorage"]
        )
    ],
    targets: [
        .target(
            name: "SecureStorage",
            path: "Sources"
        ),
        .testTarget(
            name: "SecureStorageTests",
            dependencies: ["SecureStorage"],
            path: "Tests"
        )
    ]
)
````

## 2. Keychain Helper

````swift
// filepath: /Users/kieranwalsh/Documents/GitHub/AetherNotes/Packages/SecureStorage/Sources/KeychainHelper.swift
import Foundation
import Security

/// Low-level Keychain CRUD operations.
/// All methods are synchronous and should be called off the main thread.
public enum KeychainHelper: Sendable {

    public enum KeychainError: Error, Sendable {
        case duplicateItem
        case itemNotFound
        case unexpectedStatus(OSStatus)
        case invalidData
    }

    // MARK: - Save

    /// Stores binary data in the Keychain under the given service+account.
    /// Uses `.whenUnlockedThisDeviceOnly` so items never migrate via backup.
    public static func save(
        data: Data,
        service: String,
        account: String
    ) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        let status = SecItemAdd(query as CFDictionary, nil)

        switch status {
        case errSecSuccess:
            return
        case errSecDuplicateItem:
            // Update existing item
            let updateQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: account
            ]
            let attributes: [String: Any] = [
                kSecValueData as String: data
            ]
            let updateStatus = SecItemUpdate(
                updateQuery as CFDictionary,
                attributes as CFDictionary
            )
            guard updateStatus == errSecSuccess else {
                throw KeychainError.unexpectedStatus(updateStatus)
            }
        default:
            throw KeychainError.unexpectedStatus(status)
        }
    }

    // MARK: - Load

    /// Retrieves binary data from the Keychain for the given service+account.
    public static func load(
        service: String,
        account: String
    ) throws -> Data {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        switch status {
```


## License: MIT
https://github.com/rakutentech/ios-remote-config/blob/a186fe73e3b2dd840e27618265b3c094e72f39ca/RRemoteConfig/KeyStore.swift

```


# Secure Key Storage System for AetherNotes

I'll implement a complete Secure Enclave + Keychain key storage system. This involves several components: the enclave key manager, keychain helpers, encrypted secret storage, and a fallback for devices without Secure Enclave.

Let me first check the existing project structure:

Let me build this out as a Swift package in `Packages/` per the repo layout conventions.

## 1. Package Definition

````swift
// filepath: /Users/kieranwalsh/Documents/GitHub/AetherNotes/Packages/SecureStorage/Package.swift
// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "SecureStorage",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .watchOS(.v10)
    ],
    products: [
        .library(
            name: "SecureStorage",
            targets: ["SecureStorage"]
        )
    ],
    targets: [
        .target(
            name: "SecureStorage",
            path: "Sources"
        ),
        .testTarget(
            name: "SecureStorageTests",
            dependencies: ["SecureStorage"],
            path: "Tests"
        )
    ]
)
````

## 2. Keychain Helper

````swift
// filepath: /Users/kieranwalsh/Documents/GitHub/AetherNotes/Packages/SecureStorage/Sources/KeychainHelper.swift
import Foundation
import Security

/// Low-level Keychain CRUD operations.
/// All methods are synchronous and should be called off the main thread.
public enum KeychainHelper: Sendable {

    public enum KeychainError: Error, Sendable {
        case duplicateItem
        case itemNotFound
        case unexpectedStatus(OSStatus)
        case invalidData
    }

    // MARK: - Save

    /// Stores binary data in the Keychain under the given service+account.
    /// Uses `.whenUnlockedThisDeviceOnly` so items never migrate via backup.
    public static func save(
        data: Data,
        service: String,
        account: String
    ) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        let status = SecItemAdd(query as CFDictionary, nil)

        switch status {
        case errSecSuccess:
            return
        case errSecDuplicateItem:
            // Update existing item
            let updateQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: account
            ]
            let attributes: [String: Any] = [
                kSecValueData as String: data
            ]
            let updateStatus = SecItemUpdate(
                updateQuery as CFDictionary,
                attributes as CFDictionary
            )
            guard updateStatus == errSecSuccess else {
                throw KeychainError.unexpectedStatus(updateStatus)
            }
        default:
            throw KeychainError.unexpectedStatus(status)
        }
    }

    // MARK: - Load

    /// Retrieves binary data from the Keychain for the given service+account.
    public static func load(
        service: String,
        account: String
    ) throws -> Data {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        switch status {
```


## License: MIT
https://github.com/rakutentech/ios-remote-config/blob/a186fe73e3b2dd840e27618265b3c094e72f39ca/RRemoteConfig/KeyStore.swift

```


# Secure Key Storage System for AetherNotes

I'll implement a complete Secure Enclave + Keychain key storage system. This involves several components: the enclave key manager, keychain helpers, encrypted secret storage, and a fallback for devices without Secure Enclave.

Let me first check the existing project structure:

Let me build this out as a Swift package in `Packages/` per the repo layout conventions.

## 1. Package Definition

````swift
// filepath: /Users/kieranwalsh/Documents/GitHub/AetherNotes/Packages/SecureStorage/Package.swift
// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "SecureStorage",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .watchOS(.v10)
    ],
    products: [
        .library(
            name: "SecureStorage",
            targets: ["SecureStorage"]
        )
    ],
    targets: [
        .target(
            name: "SecureStorage",
            path: "Sources"
        ),
        .testTarget(
            name: "SecureStorageTests",
            dependencies: ["SecureStorage"],
            path: "Tests"
        )
    ]
)
````

## 2. Keychain Helper

````swift
// filepath: /Users/kieranwalsh/Documents/GitHub/AetherNotes/Packages/SecureStorage/Sources/KeychainHelper.swift
import Foundation
import Security

/// Low-level Keychain CRUD operations.
/// All methods are synchronous and should be called off the main thread.
public enum KeychainHelper: Sendable {

    public enum KeychainError: Error, Sendable {
        case duplicateItem
        case itemNotFound
        case unexpectedStatus(OSStatus)
        case invalidData
    }

    // MARK: - Save

    /// Stores binary data in the Keychain under the given service+account.
    /// Uses `.whenUnlockedThisDeviceOnly` so items never migrate via backup.
    public static func save(
        data: Data,
        service: String,
        account: String
    ) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        let status = SecItemAdd(query as CFDictionary, nil)

        switch status {
        case errSecSuccess:
            return
        case errSecDuplicateItem:
            // Update existing item
            let updateQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: account
            ]
            let attributes: [String: Any] = [
                kSecValueData as String: data
            ]
            let updateStatus = SecItemUpdate(
                updateQuery as CFDictionary,
                attributes as CFDictionary
            )
            guard updateStatus == errSecSuccess else {
                throw KeychainError.unexpectedStatus(updateStatus)
            }
        default:
            throw KeychainError.unexpectedStatus(status)
        }
    }

    // MARK: - Load

    /// Retrieves binary data from the Keychain for the given service+account.
    public static func load(
        service: String,
        account: String
    ) throws -> Data {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        switch status {
```


## License: MIT
https://github.com/rakutentech/ios-remote-config/blob/a186fe73e3b2dd840e27618265b3c094e72f39ca/RRemoteConfig/KeyStore.swift

```


# Secure Key Storage System for AetherNotes

I'll implement a complete Secure Enclave + Keychain key storage system. This involves several components: the enclave key manager, keychain helpers, encrypted secret storage, and a fallback for devices without Secure Enclave.

Let me first check the existing project structure:

Let me build this out as a Swift package in `Packages/` per the repo layout conventions.

## 1. Package Definition

````swift
// filepath: /Users/kieranwalsh/Documents/GitHub/AetherNotes/Packages/SecureStorage/Package.swift
// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "SecureStorage",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .watchOS(.v10)
    ],
    products: [
        .library(
            name: "SecureStorage",
            targets: ["SecureStorage"]
        )
    ],
    targets: [
        .target(
            name: "SecureStorage",
            path: "Sources"
        ),
        .testTarget(
            name: "SecureStorageTests",
            dependencies: ["SecureStorage"],
            path: "Tests"
        )
    ]
)
````

## 2. Keychain Helper

````swift
// filepath: /Users/kieranwalsh/Documents/GitHub/AetherNotes/Packages/SecureStorage/Sources/KeychainHelper.swift
import Foundation
import Security

/// Low-level Keychain CRUD operations.
/// All methods are synchronous and should be called off the main thread.
public enum KeychainHelper: Sendable {

    public enum KeychainError: Error, Sendable {
        case duplicateItem
        case itemNotFound
        case unexpectedStatus(OSStatus)
        case invalidData
    }

    // MARK: - Save

    /// Stores binary data in the Keychain under the given service+account.
    /// Uses `.whenUnlockedThisDeviceOnly` so items never migrate via backup.
    public static func save(
        data: Data,
        service: String,
        account: String
    ) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        let status = SecItemAdd(query as CFDictionary, nil)

        switch status {
        case errSecSuccess:
            return
        case errSecDuplicateItem:
            // Update existing item
            let updateQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: account
            ]
            let attributes: [String: Any] = [
                kSecValueData as String: data
            ]
            let updateStatus = SecItemUpdate(
                updateQuery as CFDictionary,
                attributes as CFDictionary
            )
            guard updateStatus == errSecSuccess else {
                throw KeychainError.unexpectedStatus(updateStatus)
            }
        default:
            throw KeychainError.unexpectedStatus(status)
        }
    }

    // MARK: - Load

    /// Retrieves binary data from the Keychain for the given service+account.
    public static func load(
        service: String,
        account: String
    ) throws -> Data {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        switch status {
```


## License: MIT
https://github.com/rakutentech/ios-remote-config/blob/a186fe73e3b2dd840e27618265b3c094e72f39ca/RRemoteConfig/KeyStore.swift

```


# Secure Key Storage System for AetherNotes

I'll implement a complete Secure Enclave + Keychain key storage system. This involves several components: the enclave key manager, keychain helpers, encrypted secret storage, and a fallback for devices without Secure Enclave.

Let me first check the existing project structure:

Let me build this out as a Swift package in `Packages/` per the repo layout conventions.

## 1. Package Definition

````swift
// filepath: /Users/kieranwalsh/Documents/GitHub/AetherNotes/Packages/SecureStorage/Package.swift
// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "SecureStorage",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .watchOS(.v10)
    ],
    products: [
        .library(
            name: "SecureStorage",
            targets: ["SecureStorage"]
        )
    ],
    targets: [
        .target(
            name: "SecureStorage",
            path: "Sources"
        ),
        .testTarget(
            name: "SecureStorageTests",
            dependencies: ["SecureStorage"],
            path: "Tests"
        )
    ]
)
````

## 2. Keychain Helper

````swift
// filepath: /Users/kieranwalsh/Documents/GitHub/AetherNotes/Packages/SecureStorage/Sources/KeychainHelper.swift
import Foundation
import Security

/// Low-level Keychain CRUD operations.
/// All methods are synchronous and should be called off the main thread.
public enum KeychainHelper: Sendable {

    public enum KeychainError: Error, Sendable {
        case duplicateItem
        case itemNotFound
        case unexpectedStatus(OSStatus)
        case invalidData
    }

    // MARK: - Save

    /// Stores binary data in the Keychain under the given service+account.
    /// Uses `.whenUnlockedThisDeviceOnly` so items never migrate via backup.
    public static func save(
        data: Data,
        service: String,
        account: String
    ) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        let status = SecItemAdd(query as CFDictionary, nil)

        switch status {
        case errSecSuccess:
            return
        case errSecDuplicateItem:
            // Update existing item
            let updateQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: account
            ]
            let attributes: [String: Any] = [
                kSecValueData as String: data
            ]
            let updateStatus = SecItemUpdate(
                updateQuery as CFDictionary,
                attributes as CFDictionary
            )
            guard updateStatus == errSecSuccess else {
                throw KeychainError.unexpectedStatus(updateStatus)
            }
        default:
            throw KeychainError.unexpectedStatus(status)
        }
    }

    // MARK: - Load

    /// Retrieves binary data from the Keychain for the given service+account.
    public static func load(
        service: String,
        account: String
    ) throws -> Data {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        switch status {
```


## License: MIT
https://github.com/rakutentech/ios-remote-config/blob/a186fe73e3b2dd840e27618265b3c094e72f39ca/RRemoteConfig/KeyStore.swift

```


# Secure Key Storage System for AetherNotes

I'll implement a complete Secure Enclave + Keychain key storage system. This involves several components: the enclave key manager, keychain helpers, encrypted secret storage, and a fallback for devices without Secure Enclave.

Let me first check the existing project structure:

Let me build this out as a Swift package in `Packages/` per the repo layout conventions.

## 1. Package Definition

````swift
// filepath: /Users/kieranwalsh/Documents/GitHub/AetherNotes/Packages/SecureStorage/Package.swift
// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "SecureStorage",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .watchOS(.v10)
    ],
    products: [
        .library(
            name: "SecureStorage",
            targets: ["SecureStorage"]
        )
    ],
    targets: [
        .target(
            name: "SecureStorage",
            path: "Sources"
        ),
        .testTarget(
            name: "SecureStorageTests",
            dependencies: ["SecureStorage"],
            path: "Tests"
        )
    ]
)
````

## 2. Keychain Helper

````swift
// filepath: /Users/kieranwalsh/Documents/GitHub/AetherNotes/Packages/SecureStorage/Sources/KeychainHelper.swift
import Foundation
import Security

/// Low-level Keychain CRUD operations.
/// All methods are synchronous and should be called off the main thread.
public enum KeychainHelper: Sendable {

    public enum KeychainError: Error, Sendable {
        case duplicateItem
        case itemNotFound
        case unexpectedStatus(OSStatus)
        case invalidData
    }

    // MARK: - Save

    /// Stores binary data in the Keychain under the given service+account.
    /// Uses `.whenUnlockedThisDeviceOnly` so items never migrate via backup.
    public static func save(
        data: Data,
        service: String,
        account: String
    ) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        let status = SecItemAdd(query as CFDictionary, nil)

        switch status {
        case errSecSuccess:
            return
        case errSecDuplicateItem:
            // Update existing item
            let updateQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: account
            ]
            let attributes: [String: Any] = [
                kSecValueData as String: data
            ]
            let updateStatus = SecItemUpdate(
                updateQuery as CFDictionary,
                attributes as CFDictionary
            )
            guard updateStatus == errSecSuccess else {
                throw KeychainError.unexpectedStatus(updateStatus)
            }
        default:
            throw KeychainError.unexpectedStatus(status)
        }
    }

    // MARK: - Load

    /// Retrieves binary data from the Keychain for the given service+account.
    public static func load(
        service: String,
        account: String
    ) throws -> Data {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        switch status {
```


## License: MIT
https://github.com/rakutentech/ios-remote-config/blob/a186fe73e3b2dd840e27618265b3c094e72f39ca/RRemoteConfig/KeyStore.swift

```


# Secure Key Storage System for AetherNotes

I'll implement a complete Secure Enclave + Keychain key storage system. This involves several components: the enclave key manager, keychain helpers, encrypted secret storage, and a fallback for devices without Secure Enclave.

Let me first check the existing project structure:

Let me build this out as a Swift package in `Packages/` per the repo layout conventions.

## 1. Package Definition

````swift
// filepath: /Users/kieranwalsh/Documents/GitHub/AetherNotes/Packages/SecureStorage/Package.swift
// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "SecureStorage",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .watchOS(.v10)
    ],
    products: [
        .library(
            name: "SecureStorage",
            targets: ["SecureStorage"]
        )
    ],
    targets: [
        .target(
            name: "SecureStorage",
            path: "Sources"
        ),
        .testTarget(
            name: "SecureStorageTests",
            dependencies: ["SecureStorage"],
            path: "Tests"
        )
    ]
)
````

## 2. Keychain Helper

````swift
// filepath: /Users/kieranwalsh/Documents/GitHub/AetherNotes/Packages/SecureStorage/Sources/KeychainHelper.swift
import Foundation
import Security

/// Low-level Keychain CRUD operations.
/// All methods are synchronous and should be called off the main thread.
public enum KeychainHelper: Sendable {

    public enum KeychainError: Error, Sendable {
        case duplicateItem
        case itemNotFound
        case unexpectedStatus(OSStatus)
        case invalidData
    }

    // MARK: - Save

    /// Stores binary data in the Keychain under the given service+account.
    /// Uses `.whenUnlockedThisDeviceOnly` so items never migrate via backup.
    public static func save(
        data: Data,
        service: String,
        account: String
    ) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        let status = SecItemAdd(query as CFDictionary, nil)

        switch status {
        case errSecSuccess:
            return
        case errSecDuplicateItem:
            // Update existing item
            let updateQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: account
            ]
            let attributes: [String: Any] = [
                kSecValueData as String: data
            ]
            let updateStatus = SecItemUpdate(
                updateQuery as CFDictionary,
                attributes as CFDictionary
            )
            guard updateStatus == errSecSuccess else {
                throw KeychainError.unexpectedStatus(updateStatus)
            }
        default:
            throw KeychainError.unexpectedStatus(status)
        }
    }

    // MARK: - Load

    /// Retrieves binary data from the Keychain for the given service+account.
    public static func load(
        service: String,
        account: String
    ) throws -> Data {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        switch status {
```


## License: unknown
https://github.com/fantastito/Acebook-Mobile/blob/95c9b526576413749f4848cafe855872a008f314/MobileAcebook/Models/KeyChainHelper.swift

```


# Secure Key Storage System for AetherNotes

I'll implement a complete Secure Enclave + Keychain key storage system. This involves several components: the enclave key manager, keychain helpers, encrypted secret storage, and a fallback for devices without Secure Enclave.

Let me first check the existing project structure:

Let me build this out as a Swift package in `Packages/` per the repo layout conventions.

## 1. Package Definition

````swift
// filepath: /Users/kieranwalsh/Documents/GitHub/AetherNotes/Packages/SecureStorage/Package.swift
// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "SecureStorage",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .watchOS(.v10)
    ],
    products: [
        .library(
            name: "SecureStorage",
            targets: ["SecureStorage"]
        )
    ],
    targets: [
        .target(
            name: "SecureStorage",
            path: "Sources"
        ),
        .testTarget(
            name: "SecureStorageTests",
            dependencies: ["SecureStorage"],
            path: "Tests"
        )
    ]
)
````

## 2. Keychain Helper

````swift
// filepath: /Users/kieranwalsh/Documents/GitHub/AetherNotes/Packages/SecureStorage/Sources/KeychainHelper.swift
import Foundation
import Security

/// Low-level Keychain CRUD operations.
/// All methods are synchronous and should be called off the main thread.
public enum KeychainHelper: Sendable {

    public enum KeychainError: Error, Sendable {
        case duplicateItem
        case itemNotFound
        case unexpectedStatus(OSStatus)
        case invalidData
    }

    // MARK: - Save

    /// Stores binary data in the Keychain under the given service+account.
    /// Uses `.whenUnlockedThisDeviceOnly` so items never migrate via backup.
    public static func save(
        data: Data,
        service: String,
        account: String
    ) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        let status = SecItemAdd(query as CFDictionary, nil)

        switch status {
        case errSecSuccess:
            return
        case errSecDuplicateItem:
            // Update existing item
            let updateQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: account
            ]
            let attributes: [String: Any] = [
                kSecValueData as String: data
            ]
            let updateStatus = SecItemUpdate(
                updateQuery as CFDictionary,
                attributes as CFDictionary
            )
            guard updateStatus == errSecSuccess else {
                throw KeychainError.unexpectedStatus(updateStatus)
            }
        default:
            throw KeychainError.unexpectedStatus(status)
        }
    }

    // MARK: - Load

    /// Retrieves binary data from the Keychain for the given service+account.
    public static func load(
        service: String,
        account: String
    ) throws -> Data {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        switch status {
        case errSecSuccess:
            guard let data = result as? Data else {
                throw KeychainError.invalidData
            }
            return data
        case errSecItemNotFound:
            throw KeychainError.itemNotFound
        default:
            throw KeychainError.unexpectedStatus(status)
        }
    }

    // MARK: - Delete

    /// Removes a Keychain item for the given service+account.
    public static func delete(
        service: String,
        account: String
    ) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]

        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unexpectedStatus(status)
        }
    }

    // MARK
```


## License: unknown
https://github.com/fantastito/Acebook-Mobile/blob/95c9b526576413749f4848cafe855872a008f314/MobileAcebook/Models/KeyChainHelper.swift

```


# Secure Key Storage System for AetherNotes

I'll implement a complete Secure Enclave + Keychain key storage system. This involves several components: the enclave key manager, keychain helpers, encrypted secret storage, and a fallback for devices without Secure Enclave.

Let me first check the existing project structure:

Let me build this out as a Swift package in `Packages/` per the repo layout conventions.

## 1. Package Definition

````swift
// filepath: /Users/kieranwalsh/Documents/GitHub/AetherNotes/Packages/SecureStorage/Package.swift
// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "SecureStorage",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .watchOS(.v10)
    ],
    products: [
        .library(
            name: "SecureStorage",
            targets: ["SecureStorage"]
        )
    ],
    targets: [
        .target(
            name: "SecureStorage",
            path: "Sources"
        ),
        .testTarget(
            name: "SecureStorageTests",
            dependencies: ["SecureStorage"],
            path: "Tests"
        )
    ]
)
````

## 2. Keychain Helper

````swift
// filepath: /Users/kieranwalsh/Documents/GitHub/AetherNotes/Packages/SecureStorage/Sources/KeychainHelper.swift
import Foundation
import Security

/// Low-level Keychain CRUD operations.
/// All methods are synchronous and should be called off the main thread.
public enum KeychainHelper: Sendable {

    public enum KeychainError: Error, Sendable {
        case duplicateItem
        case itemNotFound
        case unexpectedStatus(OSStatus)
        case invalidData
    }

    // MARK: - Save

    /// Stores binary data in the Keychain under the given service+account.
    /// Uses `.whenUnlockedThisDeviceOnly` so items never migrate via backup.
    public static func save(
        data: Data,
        service: String,
        account: String
    ) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        let status = SecItemAdd(query as CFDictionary, nil)

        switch status {
        case errSecSuccess:
            return
        case errSecDuplicateItem:
            // Update existing item
            let updateQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: account
            ]
            let attributes: [String: Any] = [
                kSecValueData as String: data
            ]
            let updateStatus = SecItemUpdate(
                updateQuery as CFDictionary,
                attributes as CFDictionary
            )
            guard updateStatus == errSecSuccess else {
                throw KeychainError.unexpectedStatus(updateStatus)
            }
        default:
            throw KeychainError.unexpectedStatus(status)
        }
    }

    // MARK: - Load

    /// Retrieves binary data from the Keychain for the given service+account.
    public static func load(
        service: String,
        account: String
    ) throws -> Data {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        switch status {
        case errSecSuccess:
            guard let data = result as? Data else {
                throw KeychainError.invalidData
            }
            return data
        case errSecItemNotFound:
            throw KeychainError.itemNotFound
        default:
            throw KeychainError.unexpectedStatus(status)
        }
    }

    // MARK: - Delete

    /// Removes a Keychain item for the given service+account.
    public static func delete(
        service: String,
        account: String
    ) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]

        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unexpectedStatus(status)
        }
    }

    // MARK
```


## License: unknown
https://github.com/fantastito/Acebook-Mobile/blob/95c9b526576413749f4848cafe855872a008f314/MobileAcebook/Models/KeyChainHelper.swift

```


# Secure Key Storage System for AetherNotes

I'll implement a complete Secure Enclave + Keychain key storage system. This involves several components: the enclave key manager, keychain helpers, encrypted secret storage, and a fallback for devices without Secure Enclave.

Let me first check the existing project structure:

Let me build this out as a Swift package in `Packages/` per the repo layout conventions.

## 1. Package Definition

````swift
// filepath: /Users/kieranwalsh/Documents/GitHub/AetherNotes/Packages/SecureStorage/Package.swift
// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "SecureStorage",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .watchOS(.v10)
    ],
    products: [
        .library(
            name: "SecureStorage",
            targets: ["SecureStorage"]
        )
    ],
    targets: [
        .target(
            name: "SecureStorage",
            path: "Sources"
        ),
        .testTarget(
            name: "SecureStorageTests",
            dependencies: ["SecureStorage"],
            path: "Tests"
        )
    ]
)
````

## 2. Keychain Helper

````swift
// filepath: /Users/kieranwalsh/Documents/GitHub/AetherNotes/Packages/SecureStorage/Sources/KeychainHelper.swift
import Foundation
import Security

/// Low-level Keychain CRUD operations.
/// All methods are synchronous and should be called off the main thread.
public enum KeychainHelper: Sendable {

    public enum KeychainError: Error, Sendable {
        case duplicateItem
        case itemNotFound
        case unexpectedStatus(OSStatus)
        case invalidData
    }

    // MARK: - Save

    /// Stores binary data in the Keychain under the given service+account.
    /// Uses `.whenUnlockedThisDeviceOnly` so items never migrate via backup.
    public static func save(
        data: Data,
        service: String,
        account: String
    ) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        let status = SecItemAdd(query as CFDictionary, nil)

        switch status {
        case errSecSuccess:
            return
        case errSecDuplicateItem:
            // Update existing item
            let updateQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: account
            ]
            let attributes: [String: Any] = [
                kSecValueData as String: data
            ]
            let updateStatus = SecItemUpdate(
                updateQuery as CFDictionary,
                attributes as CFDictionary
            )
            guard updateStatus == errSecSuccess else {
                throw KeychainError.unexpectedStatus(updateStatus)
            }
        default:
            throw KeychainError.unexpectedStatus(status)
        }
    }

    // MARK: - Load

    /// Retrieves binary data from the Keychain for the given service+account.
    public static func load(
        service: String,
        account: String
    ) throws -> Data {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        switch status {
        case errSecSuccess:
            guard let data = result as? Data else {
                throw KeychainError.invalidData
            }
            return data
        case errSecItemNotFound:
            throw KeychainError.itemNotFound
        default:
            throw KeychainError.unexpectedStatus(status)
        }
    }

    // MARK: - Delete

    /// Removes a Keychain item for the given service+account.
    public static func delete(
        service: String,
        account: String
    ) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]

        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unexpectedStatus(status)
        }
    }

    // MARK
```


## License: unknown
https://github.com/fantastito/Acebook-Mobile/blob/95c9b526576413749f4848cafe855872a008f314/MobileAcebook/Models/KeyChainHelper.swift

```


# Secure Key Storage System for AetherNotes

I'll implement a complete Secure Enclave + Keychain key storage system. This involves several components: the enclave key manager, keychain helpers, encrypted secret storage, and a fallback for devices without Secure Enclave.

Let me first check the existing project structure:

Let me build this out as a Swift package in `Packages/` per the repo layout conventions.

## 1. Package Definition

````swift
// filepath: /Users/kieranwalsh/Documents/GitHub/AetherNotes/Packages/SecureStorage/Package.swift
// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "SecureStorage",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .watchOS(.v10)
    ],
    products: [
        .library(
            name: "SecureStorage",
            targets: ["SecureStorage"]
        )
    ],
    targets: [
        .target(
            name: "SecureStorage",
            path: "Sources"
        ),
        .testTarget(
            name: "SecureStorageTests",
            dependencies: ["SecureStorage"],
            path: "Tests"
        )
    ]
)
````

## 2. Keychain Helper

````swift
// filepath: /Users/kieranwalsh/Documents/GitHub/AetherNotes/Packages/SecureStorage/Sources/KeychainHelper.swift
import Foundation
import Security

/// Low-level Keychain CRUD operations.
/// All methods are synchronous and should be called off the main thread.
public enum KeychainHelper: Sendable {

    public enum KeychainError: Error, Sendable {
        case duplicateItem
        case itemNotFound
        case unexpectedStatus(OSStatus)
        case invalidData
    }

    // MARK: - Save

    /// Stores binary data in the Keychain under the given service+account.
    /// Uses `.whenUnlockedThisDeviceOnly` so items never migrate via backup.
    public static func save(
        data: Data,
        service: String,
        account: String
    ) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        let status = SecItemAdd(query as CFDictionary, nil)

        switch status {
        case errSecSuccess:
            return
        case errSecDuplicateItem:
            // Update existing item
            let updateQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: account
            ]
            let attributes: [String: Any] = [
                kSecValueData as String: data
            ]
            let updateStatus = SecItemUpdate(
                updateQuery as CFDictionary,
                attributes as CFDictionary
            )
            guard updateStatus == errSecSuccess else {
                throw KeychainError.unexpectedStatus(updateStatus)
            }
        default:
            throw KeychainError.unexpectedStatus(status)
        }
    }

    // MARK: - Load

    /// Retrieves binary data from the Keychain for the given service+account.
    public static func load(
        service: String,
        account: String
    ) throws -> Data {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        switch status {
        case errSecSuccess:
            guard let data = result as? Data else {
                throw KeychainError.invalidData
            }
            return data
        case errSecItemNotFound:
            throw KeychainError.itemNotFound
        default:
            throw KeychainError.unexpectedStatus(status)
        }
    }

    // MARK: - Delete

    /// Removes a Keychain item for the given service+account.
    public static func delete(
        service: String,
        account: String
    ) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]

        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unexpectedStatus(status)
        }
    }

    // MARK
```


## License: unknown
https://github.com/fantastito/Acebook-Mobile/blob/95c9b526576413749f4848cafe855872a008f314/MobileAcebook/Models/KeyChainHelper.swift

```


# Secure Key Storage System for AetherNotes

I'll implement a complete Secure Enclave + Keychain key storage system. This involves several components: the enclave key manager, keychain helpers, encrypted secret storage, and a fallback for devices without Secure Enclave.

Let me first check the existing project structure:

Let me build this out as a Swift package in `Packages/` per the repo layout conventions.

## 1. Package Definition

````swift
// filepath: /Users/kieranwalsh/Documents/GitHub/AetherNotes/Packages/SecureStorage/Package.swift
// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "SecureStorage",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .watchOS(.v10)
    ],
    products: [
        .library(
            name: "SecureStorage",
            targets: ["SecureStorage"]
        )
    ],
    targets: [
        .target(
            name: "SecureStorage",
            path: "Sources"
        ),
        .testTarget(
            name: "SecureStorageTests",
            dependencies: ["SecureStorage"],
            path: "Tests"
        )
    ]
)
````

## 2. Keychain Helper

````swift
// filepath: /Users/kieranwalsh/Documents/GitHub/AetherNotes/Packages/SecureStorage/Sources/KeychainHelper.swift
import Foundation
import Security

/// Low-level Keychain CRUD operations.
/// All methods are synchronous and should be called off the main thread.
public enum KeychainHelper: Sendable {

    public enum KeychainError: Error, Sendable {
        case duplicateItem
        case itemNotFound
        case unexpectedStatus(OSStatus)
        case invalidData
    }

    // MARK: - Save

    /// Stores binary data in the Keychain under the given service+account.
    /// Uses `.whenUnlockedThisDeviceOnly` so items never migrate via backup.
    public static func save(
        data: Data,
        service: String,
        account: String
    ) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        let status = SecItemAdd(query as CFDictionary, nil)

        switch status {
        case errSecSuccess:
            return
        case errSecDuplicateItem:
            // Update existing item
            let updateQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: account
            ]
            let attributes: [String: Any] = [
                kSecValueData as String: data
            ]
            let updateStatus = SecItemUpdate(
                updateQuery as CFDictionary,
                attributes as CFDictionary
            )
            guard updateStatus == errSecSuccess else {
                throw KeychainError.unexpectedStatus(updateStatus)
            }
        default:
            throw KeychainError.unexpectedStatus(status)
        }
    }

    // MARK: - Load

    /// Retrieves binary data from the Keychain for the given service+account.
    public static func load(
        service: String,
        account: String
    ) throws -> Data {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        switch status {
        case errSecSuccess:
            guard let data = result as? Data else {
                throw KeychainError.invalidData
            }
            return data
        case errSecItemNotFound:
            throw KeychainError.itemNotFound
        default:
            throw KeychainError.unexpectedStatus(status)
        }
    }

    // MARK: - Delete

    /// Removes a Keychain item for the given service+account.
    public static func delete(
        service: String,
        account: String
    ) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]

        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unexpectedStatus(status)
        }
    }

    // MARK
```


## License: unknown
https://github.com/fantastito/Acebook-Mobile/blob/95c9b526576413749f4848cafe855872a008f314/MobileAcebook/Models/KeyChainHelper.swift

```


# Secure Key Storage System for AetherNotes

I'll implement a complete Secure Enclave + Keychain key storage system. This involves several components: the enclave key manager, keychain helpers, encrypted secret storage, and a fallback for devices without Secure Enclave.

Let me first check the existing project structure:

Let me build this out as a Swift package in `Packages/` per the repo layout conventions.

## 1. Package Definition

````swift
// filepath: /Users/kieranwalsh/Documents/GitHub/AetherNotes/Packages/SecureStorage/Package.swift
// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "SecureStorage",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .watchOS(.v10)
    ],
    products: [
        .library(
            name: "SecureStorage",
            targets: ["SecureStorage"]
        )
    ],
    targets: [
        .target(
            name: "SecureStorage",
            path: "Sources"
        ),
        .testTarget(
            name: "SecureStorageTests",
            dependencies: ["SecureStorage"],
            path: "Tests"
        )
    ]
)
````

## 2. Keychain Helper

````swift
// filepath: /Users/kieranwalsh/Documents/GitHub/AetherNotes/Packages/SecureStorage/Sources/KeychainHelper.swift
import Foundation
import Security

/// Low-level Keychain CRUD operations.
/// All methods are synchronous and should be called off the main thread.
public enum KeychainHelper: Sendable {

    public enum KeychainError: Error, Sendable {
        case duplicateItem
        case itemNotFound
        case unexpectedStatus(OSStatus)
        case invalidData
    }

    // MARK: - Save

    /// Stores binary data in the Keychain under the given service+account.
    /// Uses `.whenUnlockedThisDeviceOnly` so items never migrate via backup.
    public static func save(
        data: Data,
        service: String,
        account: String
    ) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        let status = SecItemAdd(query as CFDictionary, nil)

        switch status {
        case errSecSuccess:
            return
        case errSecDuplicateItem:
            // Update existing item
            let updateQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: account
            ]
            let attributes: [String: Any] = [
                kSecValueData as String: data
            ]
            let updateStatus = SecItemUpdate(
                updateQuery as CFDictionary,
                attributes as CFDictionary
            )
            guard updateStatus == errSecSuccess else {
                throw KeychainError.unexpectedStatus(updateStatus)
            }
        default:
            throw KeychainError.unexpectedStatus(status)
        }
    }

    // MARK: - Load

    /// Retrieves binary data from the Keychain for the given service+account.
    public static func load(
        service: String,
        account: String
    ) throws -> Data {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        switch status {
        case errSecSuccess:
            guard let data = result as? Data else {
                throw KeychainError.invalidData
            }
            return data
        case errSecItemNotFound:
            throw KeychainError.itemNotFound
        default:
            throw KeychainError.unexpectedStatus(status)
        }
    }

    // MARK: - Delete

    /// Removes a Keychain item for the given service+account.
    public static func delete(
        service: String,
        account: String
    ) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]

        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unexpectedStatus(status)
        }
    }

    // MARK
```


## License: unknown
https://github.com/fantastito/Acebook-Mobile/blob/95c9b526576413749f4848cafe855872a008f314/MobileAcebook/Models/KeyChainHelper.swift

```


# Secure Key Storage System for AetherNotes

I'll implement a complete Secure Enclave + Keychain key storage system. This involves several components: the enclave key manager, keychain helpers, encrypted secret storage, and a fallback for devices without Secure Enclave.

Let me first check the existing project structure:

Let me build this out as a Swift package in `Packages/` per the repo layout conventions.

## 1. Package Definition

````swift
// filepath: /Users/kieranwalsh/Documents/GitHub/AetherNotes/Packages/SecureStorage/Package.swift
// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "SecureStorage",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .watchOS(.v10)
    ],
    products: [
        .library(
            name: "SecureStorage",
            targets: ["SecureStorage"]
        )
    ],
    targets: [
        .target(
            name: "SecureStorage",
            path: "Sources"
        ),
        .testTarget(
            name: "SecureStorageTests",
            dependencies: ["SecureStorage"],
            path: "Tests"
        )
    ]
)
````

## 2. Keychain Helper

````swift
// filepath: /Users/kieranwalsh/Documents/GitHub/AetherNotes/Packages/SecureStorage/Sources/KeychainHelper.swift
import Foundation
import Security

/// Low-level Keychain CRUD operations.
/// All methods are synchronous and should be called off the main thread.
public enum KeychainHelper: Sendable {

    public enum KeychainError: Error, Sendable {
        case duplicateItem
        case itemNotFound
        case unexpectedStatus(OSStatus)
        case invalidData
    }

    // MARK: - Save

    /// Stores binary data in the Keychain under the given service+account.
    /// Uses `.whenUnlockedThisDeviceOnly` so items never migrate via backup.
    public static func save(
        data: Data,
        service: String,
        account: String
    ) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        let status = SecItemAdd(query as CFDictionary, nil)

        switch status {
        case errSecSuccess:
            return
        case errSecDuplicateItem:
            // Update existing item
            let updateQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: account
            ]
            let attributes: [String: Any] = [
                kSecValueData as String: data
            ]
            let updateStatus = SecItemUpdate(
                updateQuery as CFDictionary,
                attributes as CFDictionary
            )
            guard updateStatus == errSecSuccess else {
                throw KeychainError.unexpectedStatus(updateStatus)
            }
        default:
            throw KeychainError.unexpectedStatus(status)
        }
    }

    // MARK: - Load

    /// Retrieves binary data from the Keychain for the given service+account.
    public static func load(
        service: String,
        account: String
    ) throws -> Data {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        switch status {
        case errSecSuccess:
            guard let data = result as? Data else {
                throw KeychainError.invalidData
            }
            return data
        case errSecItemNotFound:
            throw KeychainError.itemNotFound
        default:
            throw KeychainError.unexpectedStatus(status)
        }
    }

    // MARK: - Delete

    /// Removes a Keychain item for the given service+account.
    public static func delete(
        service: String,
        account: String
    ) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]

        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unexpectedStatus(status)
        }
    }

    // MARK
```


## License: unknown
https://github.com/fantastito/Acebook-Mobile/blob/95c9b526576413749f4848cafe855872a008f314/MobileAcebook/Models/KeyChainHelper.swift

```


# Secure Key Storage System for AetherNotes

I'll implement a complete Secure Enclave + Keychain key storage system. This involves several components: the enclave key manager, keychain helpers, encrypted secret storage, and a fallback for devices without Secure Enclave.

Let me first check the existing project structure:

Let me build this out as a Swift package in `Packages/` per the repo layout conventions.

## 1. Package Definition

````swift
// filepath: /Users/kieranwalsh/Documents/GitHub/AetherNotes/Packages/SecureStorage/Package.swift
// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "SecureStorage",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .watchOS(.v10)
    ],
    products: [
        .library(
            name: "SecureStorage",
            targets: ["SecureStorage"]
        )
    ],
    targets: [
        .target(
            name: "SecureStorage",
            path: "Sources"
        ),
        .testTarget(
            name: "SecureStorageTests",
            dependencies: ["SecureStorage"],
            path: "Tests"
        )
    ]
)
````

## 2. Keychain Helper

````swift
// filepath: /Users/kieranwalsh/Documents/GitHub/AetherNotes/Packages/SecureStorage/Sources/KeychainHelper.swift
import Foundation
import Security

/// Low-level Keychain CRUD operations.
/// All methods are synchronous and should be called off the main thread.
public enum KeychainHelper: Sendable {

    public enum KeychainError: Error, Sendable {
        case duplicateItem
        case itemNotFound
        case unexpectedStatus(OSStatus)
        case invalidData
    }

    // MARK: - Save

    /// Stores binary data in the Keychain under the given service+account.
    /// Uses `.whenUnlockedThisDeviceOnly` so items never migrate via backup.
    public static func save(
        data: Data,
        service: String,
        account: String
    ) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        let status = SecItemAdd(query as CFDictionary, nil)

        switch status {
        case errSecSuccess:
            return
        case errSecDuplicateItem:
            // Update existing item
            let updateQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: account
            ]
            let attributes: [String: Any] = [
                kSecValueData as String: data
            ]
            let updateStatus = SecItemUpdate(
                updateQuery as CFDictionary,
                attributes as CFDictionary
            )
            guard updateStatus == errSecSuccess else {
                throw KeychainError.unexpectedStatus(updateStatus)
            }
        default:
            throw KeychainError.unexpectedStatus(status)
        }
    }

    // MARK: - Load

    /// Retrieves binary data from the Keychain for the given service+account.
    public static func load(
        service: String,
        account: String
    ) throws -> Data {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        switch status {
        case errSecSuccess:
            guard let data = result as? Data else {
                throw KeychainError.invalidData
            }
            return data
        case errSecItemNotFound:
            throw KeychainError.itemNotFound
        default:
            throw KeychainError.unexpectedStatus(status)
        }
    }

    // MARK: - Delete

    /// Removes a Keychain item for the given service+account.
    public static func delete(
        service: String,
        account: String
    ) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]

        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unexpectedStatus(status)
        }
    }

    // MARK
```


## License: unknown
https://github.com/fantastito/Acebook-Mobile/blob/95c9b526576413749f4848cafe855872a008f314/MobileAcebook/Models/KeyChainHelper.swift

```


# Secure Key Storage System for AetherNotes

I'll implement a complete Secure Enclave + Keychain key storage system. This involves several components: the enclave key manager, keychain helpers, encrypted secret storage, and a fallback for devices without Secure Enclave.

Let me first check the existing project structure:

Let me build this out as a Swift package in `Packages/` per the repo layout conventions.

## 1. Package Definition

````swift
// filepath: /Users/kieranwalsh/Documents/GitHub/AetherNotes/Packages/SecureStorage/Package.swift
// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "SecureStorage",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .watchOS(.v10)
    ],
    products: [
        .library(
            name: "SecureStorage",
            targets: ["SecureStorage"]
        )
    ],
    targets: [
        .target(
            name: "SecureStorage",
            path: "Sources"
        ),
        .testTarget(
            name: "SecureStorageTests",
            dependencies: ["SecureStorage"],
            path: "Tests"
        )
    ]
)
````

## 2. Keychain Helper

````swift
// filepath: /Users/kieranwalsh/Documents/GitHub/AetherNotes/Packages/SecureStorage/Sources/KeychainHelper.swift
import Foundation
import Security

/// Low-level Keychain CRUD operations.
/// All methods are synchronous and should be called off the main thread.
public enum KeychainHelper: Sendable {

    public enum KeychainError: Error, Sendable {
        case duplicateItem
        case itemNotFound
        case unexpectedStatus(OSStatus)
        case invalidData
    }

    // MARK: - Save

    /// Stores binary data in the Keychain under the given service+account.
    /// Uses `.whenUnlockedThisDeviceOnly` so items never migrate via backup.
    public static func save(
        data: Data,
        service: String,
        account: String
    ) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        let status = SecItemAdd(query as CFDictionary, nil)

        switch status {
        case errSecSuccess:
            return
        case errSecDuplicateItem:
            // Update existing item
            let updateQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: account
            ]
            let attributes: [String: Any] = [
                kSecValueData as String: data
            ]
            let updateStatus = SecItemUpdate(
                updateQuery as CFDictionary,
                attributes as CFDictionary
            )
            guard updateStatus == errSecSuccess else {
                throw KeychainError.unexpectedStatus(updateStatus)
            }
        default:
            throw KeychainError.unexpectedStatus(status)
        }
    }

    // MARK: - Load

    /// Retrieves binary data from the Keychain for the given service+account.
    public static func load(
        service: String,
        account: String
    ) throws -> Data {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        switch status {
        case errSecSuccess:
            guard let data = result as? Data else {
                throw KeychainError.invalidData
            }
            return data
        case errSecItemNotFound:
            throw KeychainError.itemNotFound
        default:
            throw KeychainError.unexpectedStatus(status)
        }
    }

    // MARK: - Delete

    /// Removes a Keychain item for the given service+account.
    public static func delete(
        service: String,
        account: String
    ) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]

        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unexpectedStatus(status)
        }
    }

    // MARK
```


## License: unknown
https://github.com/fantastito/Acebook-Mobile/blob/95c9b526576413749f4848cafe855872a008f314/MobileAcebook/Models/KeyChainHelper.swift

```


# Secure Key Storage System for AetherNotes

I'll implement a complete Secure Enclave + Keychain key storage system. This involves several components: the enclave key manager, keychain helpers, encrypted secret storage, and a fallback for devices without Secure Enclave.

Let me first check the existing project structure:

Let me build this out as a Swift package in `Packages/` per the repo layout conventions.

## 1. Package Definition

````swift
// filepath: /Users/kieranwalsh/Documents/GitHub/AetherNotes/Packages/SecureStorage/Package.swift
// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "SecureStorage",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .watchOS(.v10)
    ],
    products: [
        .library(
            name: "SecureStorage",
            targets: ["SecureStorage"]
        )
    ],
    targets: [
        .target(
            name: "SecureStorage",
            path: "Sources"
        ),
        .testTarget(
            name: "SecureStorageTests",
            dependencies: ["SecureStorage"],
            path: "Tests"
        )
    ]
)
````

## 2. Keychain Helper

````swift
// filepath: /Users/kieranwalsh/Documents/GitHub/AetherNotes/Packages/SecureStorage/Sources/KeychainHelper.swift
import Foundation
import Security

/// Low-level Keychain CRUD operations.
/// All methods are synchronous and should be called off the main thread.
public enum KeychainHelper: Sendable {

    public enum KeychainError: Error, Sendable {
        case duplicateItem
        case itemNotFound
        case unexpectedStatus(OSStatus)
        case invalidData
    }

    // MARK: - Save

    /// Stores binary data in the Keychain under the given service+account.
    /// Uses `.whenUnlockedThisDeviceOnly` so items never migrate via backup.
    public static func save(
        data: Data,
        service: String,
        account: String
    ) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        let status = SecItemAdd(query as CFDictionary, nil)

        switch status {
        case errSecSuccess:
            return
        case errSecDuplicateItem:
            // Update existing item
            let updateQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: account
            ]
            let attributes: [String: Any] = [
                kSecValueData as String: data
            ]
            let updateStatus = SecItemUpdate(
                updateQuery as CFDictionary,
                attributes as CFDictionary
            )
            guard updateStatus == errSecSuccess else {
                throw KeychainError.unexpectedStatus(updateStatus)
            }
        default:
            throw KeychainError.unexpectedStatus(status)
        }
    }

    // MARK: - Load

    /// Retrieves binary data from the Keychain for the given service+account.
    public static func load(
        service: String,
        account: String
    ) throws -> Data {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        switch status {
        case errSecSuccess:
            guard let data = result as? Data else {
                throw KeychainError.invalidData
            }
            return data
        case errSecItemNotFound:
            throw KeychainError.itemNotFound
        default:
            throw KeychainError.unexpectedStatus(status)
        }
    }

    // MARK: - Delete

    /// Removes a Keychain item for the given service+account.
    public static func delete(
        service: String,
        account: String
    ) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]

        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unexpectedStatus(status)
        }
    }

    // MARK
```


## License: unknown
https://github.com/fantastito/Acebook-Mobile/blob/95c9b526576413749f4848cafe855872a008f314/MobileAcebook/Models/KeyChainHelper.swift

```


# Secure Key Storage System for AetherNotes

I'll implement a complete Secure Enclave + Keychain key storage system. This involves several components: the enclave key manager, keychain helpers, encrypted secret storage, and a fallback for devices without Secure Enclave.

Let me first check the existing project structure:

Let me build this out as a Swift package in `Packages/` per the repo layout conventions.

## 1. Package Definition

````swift
// filepath: /Users/kieranwalsh/Documents/GitHub/AetherNotes/Packages/SecureStorage/Package.swift
// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "SecureStorage",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .watchOS(.v10)
    ],
    products: [
        .library(
            name: "SecureStorage",
            targets: ["SecureStorage"]
        )
    ],
    targets: [
        .target(
            name: "SecureStorage",
            path: "Sources"
        ),
        .testTarget(
            name: "SecureStorageTests",
            dependencies: ["SecureStorage"],
            path: "Tests"
        )
    ]
)
````

## 2. Keychain Helper

````swift
// filepath: /Users/kieranwalsh/Documents/GitHub/AetherNotes/Packages/SecureStorage/Sources/KeychainHelper.swift
import Foundation
import Security

/// Low-level Keychain CRUD operations.
/// All methods are synchronous and should be called off the main thread.
public enum KeychainHelper: Sendable {

    public enum KeychainError: Error, Sendable {
        case duplicateItem
        case itemNotFound
        case unexpectedStatus(OSStatus)
        case invalidData
    }

    // MARK: - Save

    /// Stores binary data in the Keychain under the given service+account.
    /// Uses `.whenUnlockedThisDeviceOnly` so items never migrate via backup.
    public static func save(
        data: Data,
        service: String,
        account: String
    ) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        let status = SecItemAdd(query as CFDictionary, nil)

        switch status {
        case errSecSuccess:
            return
        case errSecDuplicateItem:
            // Update existing item
            let updateQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: account
            ]
            let attributes: [String: Any] = [
                kSecValueData as String: data
            ]
            let updateStatus = SecItemUpdate(
                updateQuery as CFDictionary,
                attributes as CFDictionary
            )
            guard updateStatus == errSecSuccess else {
                throw KeychainError.unexpectedStatus(updateStatus)
            }
        default:
            throw KeychainError.unexpectedStatus(status)
        }
    }

    // MARK: - Load

    /// Retrieves binary data from the Keychain for the given service+account.
    public static func load(
        service: String,
        account: String
    ) throws -> Data {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        switch status {
        case errSecSuccess:
            guard let data = result as? Data else {
                throw KeychainError.invalidData
            }
            return data
        case errSecItemNotFound:
            throw KeychainError.itemNotFound
        default:
            throw KeychainError.unexpectedStatus(status)
        }
    }

    // MARK: - Delete

    /// Removes a Keychain item for the given service+account.
    public static func delete(
        service: String,
        account: String
    ) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]

        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unexpectedStatus(status)
        }
    }

    // MARK: - Exists

    /// Returns true if an item exists for
```


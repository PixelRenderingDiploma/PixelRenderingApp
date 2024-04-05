//
//  Services.swift
//  PixelModeling
//
//  Created by Hlib Sobolevskyi on 2024-01-19.
//

import Foundation

enum ServiceType {
    case singleton
    case newInstance
    case automatic
}

@propertyWrapper
struct Service<Service> {
    var service: Service
    
    init(_ dependencyType: ServiceType = .singleton) {
        guard let service = ServiceContainer.resolve(dependencyType: dependencyType, Service.self) else {
            fatalError("No dependency of type \(String(describing: Service.self)) registered!")
        }
        
        self.service = service
    }
    
    var wrappedValue: Service {
        get { self.service }
        mutating set { service = newValue }
    }
}

final class ServiceContainer {
    private static var cache: [String: Any] = [:]
    private static var generators: [String: () -> Any] = [:]
    
    static func register<Service>(type: Service.Type, as serviceType: ServiceType = .automatic, _ factory: @autoclosure @escaping () -> Service) {
        generators[String(describing: type.self)] = factory
        
        if serviceType == .singleton {
            cache[String(describing: type.self)] = factory()
        }
    }
    
    static func resolve<Service>(dependencyType: ServiceType = .automatic, _ type: Service.Type) -> Service? {
        let key = String(describing: type.self)
        switch dependencyType {
        case .singleton:
            if let cachedService = cache[key] as? Service {
                return cachedService
            } else {
                fatalError("\(String(describing: type.self)) is not registeres as singleton")
            }
        case .automatic:
            if let cachedService = cache[key] as? Service {
                return cachedService
            }
            
            fallthrough
        case .newInstance:
            if let service = generators[key]?() as? Service {
                cache[String(describing: type.self)] = service
                return service
            } else {
                return nil
            }
        }
    }
}

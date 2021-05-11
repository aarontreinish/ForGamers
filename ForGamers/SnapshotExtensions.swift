//
//  SnapshotExtensions.swift
//  ForGamers
//
//  Created by Aaron Treinish on 4/7/21.
//

import Foundation
import FirebaseFirestore

extension QueryDocumentSnapshot {
    
    func decoded<T: Decodable>() throws -> T {
        let jsonData = try JSONSerialization.data(withJSONObject: data(), options: [])
        let object = try JSONDecoder().decode(T.self, from: jsonData)
        
        return object
    }
}

//
//  StorageManager.swift
//  ForGamers
//
//  Created by Aaron Treinish on 5/8/21.
//

import Foundation
import FirebaseStorage

final class StorageManager {
    
    static let shared = StorageManager()
    
    private let storage = Storage.storage().reference()
    
    public typealias UploadPictureCompletion = (Result<String, Error>) -> Void
    
    /// Uploads picture to firebase storage and returns url string
    public func uploadProfilePicture(with data: Data, fileName: String, completion: @escaping UploadPictureCompletion) {
        storage.child("images/\(fileName)").putData(data, metadata: nil) { (metadata, error) in
            guard error == nil else {
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            self.storage.child("images/\(fileName)").downloadURL { (url, error) in
                guard let url = url else {
                    completion(.failure(StorageErrors.failedToGetDownloadURL))
                    return
                }
                
                let urlString = url.absoluteString
                print(urlString)
                completion(.success(urlString))
            }
        }
    }
    
    public func uploadCommunityPicture(with data: Data, fileName: String, completion: @escaping UploadPictureCompletion) {
        storage.child("communityImages/\(fileName)").putData(data, metadata: nil) { (metadata, error) in
            guard error == nil else {
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            self.storage.child("communityImages/\(fileName)").downloadURL { (url, error) in
                guard let url = url else {
                    completion(.failure(StorageErrors.failedToGetDownloadURL))
                    return
                }
                
                let urlString = url.absoluteString
                print(urlString)
                completion(.success(urlString))
            }
        }
    }
    
    public func downloadURL(for path: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let reference = storage.child(path)
        
        reference.downloadURL { (url, error) in
            guard let url = url, error == nil else {
                completion(.failure(StorageErrors.failedToGetDownloadURL))
                return
            }
            
            completion(.success(url))
        }
    }
    
    public enum StorageErrors: Error {
        case failedToUpload
        case failedToGetDownloadURL
    }
}

//  CoreDataManager.swift
//  NewsApp
//  Created by Serhii Bets on 13.04.2022.
//  Copyright by Serhii Bets. All rights reserved.

import UIKit
import CoreData

class CoreDataManager {
    
    static let shared = CoreDataManager()
    
    enum DatabasError: Error {
        case failedToSaveData
        case failedToFetchData
        case failedToDeleteData
    }
    
    var persistentContainer: NSPersistentContainer {
            return  (UIApplication.shared.delegate as! AppDelegate).persistentContainer
        }
    
    func downloadNews(model: News, completion: @escaping (Result<Void, DatabasError>) -> Void) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let context = appDelegate.persistentContainer.viewContext
        let entity = NewsEntity(context: context)

        entity.id            = model.id
        entity.url           = model.url
        entity.publishedDate = model.publishedDate
        entity.section       = model.section
        entity.subsection    = model.subsection
        entity.title         = model.title
        entity.byline        = model.byline
        entity.abstract      = model.abstract

        do {
            try context.save()
            completion(.success(()))
        } catch {
            completion(.failure(DatabasError.failedToSaveData))
        }
    }
    
    func fetchingNewsFromCoreData(completion: @escaping (Result<[NewsEntity], DatabasError>) -> Void) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let context = appDelegate.persistentContainer.viewContext
        let request: NSFetchRequest<NewsEntity>
        request = NewsEntity.fetchRequest()
        do {
            let news = try context.fetch(request)
            completion(.success(news))
        } catch {
            completion(.failure(.failedToFetchData))
        }
    }
    
    func deleteNewsWith(model: NewsEntity, completion: @escaping (Result<Void, DatabasError>)-> Void) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let context = appDelegate.persistentContainer.viewContext
        context.delete(model)
        
        do {
            try context.save()
            completion(.success(()))
        } catch {
            completion(.failure(.failedToDeleteData))
        }
    }
}

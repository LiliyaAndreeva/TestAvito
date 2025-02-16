//
//  StorageManager.swift
//  TestAvito
//
//  Created by Лилия Андреева on 11.02.2025.
//

import Foundation
import CoreData

final class StorageManager {
	static let shared = StorageManager()
	private let context: NSManagedObjectContext
	
	// MARK: - Core Data stack
	private var persistentContainer: NSPersistentContainer = {
		
		let container = NSPersistentContainer(name: "TestAvito")
		container.loadPersistentStores(completionHandler: { (storeDescription, error) in
			if let error = error as NSError? {
				
				fatalError("Unresolved error \(error), \(error.userInfo)")
			}
		})
		return container
	}()
	
	
	private init(){
		self.context = persistentContainer.viewContext
	}
	
	// MARK: - Core Data Saving support
	
	func saveContext () {
		let context = persistentContainer.viewContext
		if context.hasChanges {
			do {
				try context.save()
			} catch {
				let nserror = error as NSError
				fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
			}
		}
	}
}

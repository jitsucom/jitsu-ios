//
//  ManualCoreData.swift
//  Jitsu
//
//  Created by Leonid Serebryanyy on 27.06.2021.
//

import Foundation
import CoreData


class CoreDataStack: NSObject {
	
	var model: NSManagedObjectModel {
		let _model = NSManagedObjectModel()
		
		let companyEntity = NSEntityDescription(from: EnrichedEventMO.self)
		companyEntity.addProperty(NSAttributeDescription(name: "name", ofType: .stringAttributeType))
		
		_model.entities = [companyEntity]
		return _model
	}
	
	lazy var persistentContainer: NSPersistentContainer = {
		// we pass future database name and NSManagedObjectModel model for which we should create this database.
		let _container = NSPersistentContainer(name: "Jitsu", managedObjectModel: model)
		_container.loadPersistentStores {
			(description, error) in
			
		}
		return _container
	}()
}



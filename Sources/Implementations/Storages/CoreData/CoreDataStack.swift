//
//  ManualCoreData.swift
//  Jitsu
//
//  Created by Leonid Serebryanyy on 27.06.2021.
//

import Foundation
import CoreData


protocol CoreDataStack: NSObjectProtocol {
	var persistentContainer: NSPersistentContainer { get }
}


let coreDataModel: NSManagedObjectModel = {
	let _model = NSManagedObjectModel()
	
	ValueTransformer.setValueTransformer(DictTransformer(), forName: DictTransformer.name)
	ValueTransformer.setValueTransformer(ArrayTransformer(), forName: ArrayTransformer.name)
	
	_model.entities = [
		EnrichedEventMO.eventEntity,
		BatchMO.batchEntity,
		ContextMO.contextEntity
	]
	return _model
}()


class CoreDataStackImpl: NSObject, CoreDataStack {
	
	var persistentContainer: NSPersistentContainer
	
	override init() {
		self.persistentContainer = NSPersistentContainer(name: "Jitsu", managedObjectModel: coreDataModel)
		super.init()
		self.persistentContainer.loadPersistentStores {
			(description, error) in
			
		}
	}
}

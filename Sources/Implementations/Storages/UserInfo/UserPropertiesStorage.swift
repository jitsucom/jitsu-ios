//
//  UserPropertiesStorage.swift
//  Jitsu
//
//  Created by Leonid Serebryanyy on 01.07.2021.
//

import Foundation
import CoreData

struct UserPropertiesModel {
	var anonymousUserId: String
	var userIdentifier: String?
	var email: String?
	var otherIdentifiers = [String : String]()
}

protocol UserPropertiesStorage {
	func loadUserProperties() -> UserPropertiesModel?
	func saveUserPropertiesModel(_ value: UserPropertiesModel)
	func removeUserPropertiesModel(_ value: UserPropertiesModel)
	func clear()
}

class UserPropertiesStorageImpl: UserPropertiesStorage {
	private var coreDataStack: CoreDataStack
	
	init(coreDataStack: CoreDataStack) {
		self.coreDataStack = coreDataStack
	}
	
	func loadUserProperties() -> UserPropertiesModel? {
		let context = coreDataStack.persistentContainer.viewContext
		let fetchRequest: NSFetchRequest<UserPropertiesMO> = UserPropertiesMO.fetchRequest()
		let result: [UserPropertiesMO]? = try? context.fetch(fetchRequest)
		guard let fetched = result?.first else {
			print("\(#function) no user properties were saved")
			return nil
		}
		let userProperties = UserPropertiesModel(mo: fetched)
		print("\(#function) fetched \(userProperties)")
		return userProperties
	}
	
	func saveUserPropertiesModel(_ value: UserPropertiesModel) {
		print("\(#function) saving user properties: \(value)")
		let context = coreDataStack.persistentContainer.newBackgroundContext()
		removeUserProperties(value, context: context)
		context.perform {
			let mo = UserPropertiesMO(context: context)
			mo.anonymousUserId = value.anonymousUserId
			mo.email = value.email
			mo.userIdentifier = value.userIdentifier
			mo.otherIdentifiers = NSDictionary(dictionary: value.otherIdentifiers)
			do {
				try context.save()
			} catch {
				print("\(#function) save failed: \(error)")
				fatalError()
			}
		}
	}
	
	func removeUserPropertiesModel(_ value: UserPropertiesModel) {
		let context = coreDataStack.persistentContainer.newBackgroundContext()
		removeUserProperties(value, context: context)
	}
	
	private func removeUserProperties(_ value: UserPropertiesModel, context: NSManagedObjectContext) {
		let fetchRequest: NSFetchRequest<UserPropertiesMO> = UserPropertiesMO.fetchRequest()
		do {
			let props = try context.fetch(fetchRequest)
			for p in props {
				print("\(#function) deleting \(p.anonymousUserId)")
				context.delete(p)
			}
			try context.save()
		} catch {
			print("\(#function) oops")
			fatalError()
		}
	}

	func clear() {
		print("\(#function)")
		let context = coreDataStack.persistentContainer.newBackgroundContext()
		let fetchRequest: NSFetchRequest<UserPropertiesMO> = UserPropertiesMO.fetchRequest()
		do {
			let valuesToRemove = try context.fetch(fetchRequest)
			print("\(#function) fetched \(valuesToRemove.count)")
			for value in valuesToRemove {
				context.delete(value)
			}
			try context.save()
		} catch {
			print("oops")
			fatalError()
		}
	}
}

extension UserPropertiesModel {
	init(mo: UserPropertiesMO) {
		self.init(
			anonymousUserId: mo.anonymousUserId,
			userIdentifier: mo.userIdentifier,
			email: mo.email,
			otherIdentifiers: Dictionary(_immutableCocoaDictionary: mo.otherIdentifiers)
		)
	}
}

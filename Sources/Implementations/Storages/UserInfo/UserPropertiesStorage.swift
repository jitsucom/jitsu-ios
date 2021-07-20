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
		do {
			let result: [UserPropertiesMO]? = try context.fetch(fetchRequest)
			guard let fetched = result?.first else {
				logDebug("\(#function) there were no user properties")
				return nil
			}
			let userProperties = UserPropertiesModel(mo: fetched)
			logInfo("\(#function) fetched \(userProperties)")
			return userProperties
		} catch {
			logCritical("\(#function) load failed, \(error)")
			return nil
		}
	}
	
	func saveUserPropertiesModel(_ value: UserPropertiesModel) {
		logInfo("\(#function) saving user properties: \(value)")
		let context = coreDataStack.persistentContainer.newBackgroundContext()
		removeUserProperties(value, context: context)
		context.perform {
			UserPropertiesMO.createModel(with: value, in: context)
			do {
				try context.save()
			} catch {
				logCritical("\(#function) save failed: \(error)")
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
				logDebug("\(#function) deleting \(p.anonymousUserId)")
				context.delete(p)
			}
			try context.save()
		} catch {
			logCriticalFrom(self, "\(#function) remove failed")
		}
	}

	func clear() {
		let context = coreDataStack.persistentContainer.newBackgroundContext()
		let fetchRequest: NSFetchRequest<UserPropertiesMO> = UserPropertiesMO.fetchRequest()
		do {
			let valuesToRemove = try context.fetch(fetchRequest)
			logDebug("\(#function) fetched \(valuesToRemove.count)")
			
			for value in valuesToRemove {
				context.delete(value)
			}
			try context.save()
		} catch {
			logCriticalFrom(self, "\(#function) clear failed")
		}
	}
}

extension UserPropertiesModel {
	init(mo: UserPropertiesMO) {
		self.init(
			anonymousUserId: mo.anonymousUserId,
			userIdentifier: mo.userIdentifier,
			email: mo.email,
			otherIdentifiers: mo.otherIdentifiers as! [String: String]
		)
	}
}

extension UserPropertiesMO {
	@discardableResult
	static func createModel(with model: UserPropertiesModel, in context: NSManagedObjectContext) -> UserPropertiesMO {
		let mo = UserPropertiesMO(context: context)
		mo.anonymousUserId = model.anonymousUserId
		mo.email = model.email
		mo.userIdentifier = model.userIdentifier
		mo.otherIdentifiers = NSDictionary(dictionary: model.otherIdentifiers)
		return mo
	}
}

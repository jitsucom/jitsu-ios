//
//  ContextViewController.swift
//  ExampleApp
//
//  Created by Leonid Serebryanyy on 09.07.2021.
//

import UIKit
import Jitsu

struct ContextValue {
	var value: [String: Any]
	var eventTypes: [String]?
	var time: String
	
	init(value: [String: Any], eventTypes: [String]?) {
		self.value = value
		self.eventTypes = eventTypes
		
		let formatter = DateFormatter()
		formatter.dateStyle = .none
		formatter.timeStyle = .medium
		self.time = formatter.string(from: Date())
	}
}

class ContextViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	
	private let ctxCellReuseId = "ctxCellReuseId"
	private let addCtxCellReuseId = "addCtxCellReuseId"
	
	var values = [ContextValue]()
	
	private lazy var eventsTable: UITableView = {
		let v = UITableView()
		v.translatesAutoresizingMaskIntoConstraints = false
		v.dataSource = self
		v.delegate = self
		v.register(CtxCell.self, forCellReuseIdentifier: ctxCellReuseId)
		v.register(AddContextCell.self, forCellReuseIdentifier: addCtxCellReuseId)
		v.tableFooterView = UIView()
		v.keyboardDismissMode = .interactive
		return v
	}()
	
	private var bottomConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
		view.addSubview(eventsTable)
		
		self.bottomConstraint = eventsTable.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0)

		NSLayoutConstraint.activate([
			eventsTable.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
			eventsTable.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
			eventsTable.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
			eventsTable.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
		])
		
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 2
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section == 0 {
			return values.count
		} else if section == 1 {
			return 1
		} else {
			fatalError()
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if indexPath.section == 0 {
			let value = values[indexPath.row]
			let cell = tableView.dequeueReusableCell(withIdentifier: ctxCellReuseId, for: indexPath) as! CtxCell
			cell.setContextValue(value)
			return cell
		} else if indexPath.section == 1 {
			let cell = tableView.dequeueReusableCell(withIdentifier: addCtxCellReuseId, for: indexPath) as! AddContextCell
			cell.valueCreated = { [weak self] value in
				guard let self = self else {return}
				self.values.append(value)
				let newIndexPath = IndexPath(row: self.values.count - 1, section: 0)
				tableView.insertRows(at: [newIndexPath], with: .fade)
				_ = cell.becomeFirstResponder()
				tableView.scrollToRow(at: newIndexPath, at: .middle, animated: true)
				try! Jitsu.shared.context.addValues(value.value, for: value.eventTypes, persist: false)
			}
			cell.hack = {
				tableView.beginUpdates()
				tableView.endUpdates()
			}
			return cell
		} else {
			fatalError()
		}
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return UITableView.automaticDimension
	}
	
	func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
		return 1000
	}
	
	func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		if indexPath.section == 0 {
			return true
		}
		return false
	}
	
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			tableView.beginUpdates()
			let toRemove = values[indexPath.row]
			values.remove(at: indexPath.row)
			for key in toRemove.value.keys {
				Jitsu.shared.context.removeValue(for: key, for: toRemove.eventTypes)
			}
			tableView.deleteRows(at: [indexPath], with: .automatic)
			tableView.endUpdates()
		}
	}
	
	
	// MARK: - Keyboard
	
	@objc private func keyboardWillShow(notification: Notification) {
		let info = notification.userInfo!
		let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
		let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
		
		UIView.animate(withDuration: duration, animations: { () -> Void in
			self.bottomConstraint.constant = -keyboardFrame.height
		})
	}
	
	@objc private func keyboardWillHide(notification: Notification) {
		let info = notification.userInfo!
		let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
		
		UIView.animate(withDuration: duration, animations: { () -> Void in
			self.bottomConstraint.constant = 0
		})
	}
	

}

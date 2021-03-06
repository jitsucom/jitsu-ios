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
	var shouldPersist: Bool
	
	init(value: [String: Any], eventTypes: [String]?, shouldPersist: Bool) {
		self.value = value
		self.eventTypes = eventTypes
		self.time = Date().timeString
		self.shouldPersist = shouldPersist
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
		let text = "1) Note that persisted context values are not shown in the table after app relaunches. Though they are here. \n \n2) Swipe the cell to remove context value."
		let label = UILabel(frame: CGRect(x: 0, y: 0, width: v.frame.width, height: 60))
		label.text = text
		label.numberOfLines = 0
		label.font = UIFont.systemFont(ofSize: 10)
		v.tableFooterView = label
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
				Jitsu.shared.context.addValues(value.value, for: value.eventTypes, persist: value.shouldPersist)
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
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: false)
	}
	
	// MARK: - Keyboard
	
	@objc private func keyboardWillShow(notification: Notification) {
		let info = notification.userInfo!
		let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
		let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
		let tabbarHeight = tabBarController?.tabBar.frame.size.height ?? 0

		UIView.animate(withDuration: duration, animations: { () -> Void in
			self.bottomConstraint.constant = -keyboardFrame.height + tabbarHeight
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

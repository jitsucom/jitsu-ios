//
//  EventsViewController.swift
//  ExampleApp
//
//  Created by Leonid Serebryanyy on 22.06.2021.
//

import UIKit
import Jitsu

class EventModel {
	var event: Event
	var sent: Bool = false
	var time: String
	
	init(event: Event, sent: Bool = false) {
		self.event = event
		self.sent = sent
		self.time = Date().timeString
	}
}

class EventsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	
	private let eventCellReuseId = "eventCellReuseId"
	private let addEventCellReuseId = "addEventCellReuseId"
	
	private lazy var eventsTable: UITableView = {
		let v = UITableView()
		v.translatesAutoresizingMaskIntoConstraints = false
		v.dataSource = self
		v.delegate = self
		v.register(EventCell.self, forCellReuseIdentifier: eventCellReuseId)
		v.register(AddEventCell.self, forCellReuseIdentifier: addEventCellReuseId)
		v.tableFooterView = UIView()
		v.keyboardDismissMode = .interactive
		return v
	}()
	
	private lazy var sendToolbar: UIView = {
		let v = SendToolbar()
		v.sendBatch = { [weak self] in
			self?.sendBatch()
		}
		v.translatesAutoresizingMaskIntoConstraints = false
		return v
	}()
	
	private var bottomConstraint: NSLayoutConstraint!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.addSubview(eventsTable)
		view.addSubview(sendToolbar)
		
		self.bottomConstraint = sendToolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0)
		
		NSLayoutConstraint.activate([
			sendToolbar.heightAnchor.constraint(equalToConstant: 60),
			self.bottomConstraint,
			sendToolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
			sendToolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
		])
		
		NSLayoutConstraint.activate([
			eventsTable.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
			eventsTable.bottomAnchor.constraint(equalTo: sendToolbar.topAnchor, constant: 0),
			eventsTable.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
			eventsTable.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
		])
		
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
	}
	
	private var events = [EventModel]()
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 2
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section == 0 {
			return events.count
		} else if section == 1 {
			return 1
		} else {
			fatalError()
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if indexPath.section == 0 {
			let event = events[indexPath.row]
			let cell = tableView.dequeueReusableCell(withIdentifier: eventCellReuseId, for: indexPath) as! EventCell
			cell.setEvent(event)
			return cell
		} else if indexPath.section == 1 {
			let cell = tableView.dequeueReusableCell(withIdentifier: addEventCellReuseId, for: indexPath) as! AddEventCell
			cell.eventCreated = { [weak self] eventName, payload in
				guard let self = self else {return}
				self.addEvent(eventName, eventPayload: payload)
				let newIndexPath = IndexPath(row: self.events.count - 1, section: 0)
				tableView.insertRows(at: [newIndexPath], with: .fade)
				_ = cell.becomeFirstResponder()
				tableView.scrollToRow(at: newIndexPath, at: .middle, animated: true)
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
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: false)
	}

	// MARK: - Actions
	
	func addEvent(_ eventType: String, eventPayload: [String: Any]? = nil) {
		let newEvent = EventModel(event: SimpleEvent(eventType, payload: eventPayload))
		self.events.append(newEvent)
		Jitsu.shared.trackScreenEvent(screen:self, event: newEvent.event)
	}
	
	@objc private func sendBatch() {
		print("\n==send==\n")
		Jitsu.shared.sendBatch()
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


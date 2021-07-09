//
//  ViewController.swift
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
	
	internal init(event: Event, sent: Bool = false) {
		self.event = event
		self.sent = sent
		
		let formatter = DateFormatter()
		formatter.dateStyle = .none
		formatter.timeStyle = .medium
		self.time = formatter.string(from: Date())
	}
}

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	
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
	
	private lazy var contextToolbar: UIView = {
		let v = MenuToolbar()
		v.translatesAutoresizingMaskIntoConstraints = false
		
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
		view.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(eventsTable)
		view.addSubview(sendToolbar)
		view.addSubview(contextToolbar)
		
		self.bottomConstraint = contextToolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0)
		
		NSLayoutConstraint.activate([
			contextToolbar.heightAnchor.constraint(equalToConstant: 60),
			bottomConstraint,
			contextToolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
			contextToolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
		])
		
		NSLayoutConstraint.activate([
			sendToolbar.heightAnchor.constraint(equalToConstant: 60),
			sendToolbar.bottomAnchor.constraint(equalTo: contextToolbar.topAnchor, constant: 0),
			sendToolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
			sendToolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
		])
		
		NSLayoutConstraint.activate([
			eventsTable.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
			eventsTable.bottomAnchor.constraint(equalTo: sendToolbar.topAnchor, constant: 0),
			eventsTable.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
			eventsTable.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
		])
		
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil);
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil);

		let options = JitsuOptions(
			apiKey: "js.kxp33.aefbvu0v5guetjki2ymz6",
			trackingHost: "https://t.jitsu.com/api/v1/event"
		)
		
		Jitsu.setupClient(with: options)
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
	
//	func scrollViewDidScroll(_ scrollView: UIScrollView) {
//		keyboard
//	}
	
	// MARK: - Actions
	
	func addEvent(_ eventType: String, eventPayload: [String: Any]? = nil) {
		let newEvent = EventModel(event: SimpleEvent(eventType, payload: eventPayload))
		self.events.append(newEvent)
		Jitsu.shared.trackEvent(newEvent.event)
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


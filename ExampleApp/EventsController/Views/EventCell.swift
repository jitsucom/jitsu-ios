//
//  EventCell.swift
//  ExampleApp
//
//  Created by Leonid Serebryanyy on 08.07.2021.
//

import Foundation
import UIKit

class EventCell: UITableViewCell {
	
	// MARK: - Public
	
	func setEvent(_ event: EventModel?) {
		self.event = event
		if let event = event {
			eventNameLabel.text = event.event.name
			timeLabel.text = event.time
			
			if let data1 = try? JSONSerialization.data(withJSONObject: event.event.payload, options: .prettyPrinted),
			   let convertedString = String(data: data1, encoding: String.Encoding.utf8) {
				payloadLabel.text = convertedString
				print(convertedString)
			}
		}
	}
	
	// MARK: - Private
	
	private lazy var eventNameLabel: UILabel = {
		let v = UILabel()
		v.translatesAutoresizingMaskIntoConstraints = false
		v.numberOfLines = 1
		v.font = UIFont.systemFont(ofSize: 12, weight: .regular)

		return v
	}()
	
	private lazy var timeLabel: UILabel = {
		let v = UILabel()
		v.translatesAutoresizingMaskIntoConstraints = false
		v.numberOfLines = 1
		v.font = UIFont.systemFont(ofSize: 12, weight: .light)
		return v
	}()
	
	private lazy var payloadLabel: UILabel = {
		let v = UILabel()
		v.translatesAutoresizingMaskIntoConstraints = false
		v.numberOfLines = 0
		v.font = UIFont.systemFont(ofSize: 10, weight: .light)
		v.textColor = .secondaryLabel
		
		return v
	}()
	
	private var event: EventModel? = nil
	
	// MARK: - Setup
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		makeUI()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		makeUI()
	}
	
	private func makeUI() {
		contentView.addSubview(eventNameLabel)
		contentView.addSubview(timeLabel)
		contentView.addSubview(payloadLabel)
	}
	
	// MARK: - Constraints
	
	override class var requiresConstraintBasedLayout: Bool {
		return true
	}
	
	override func updateConstraints() {
		NSLayoutConstraint.activate([
			eventNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
			eventNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
		])
		
		NSLayoutConstraint.activate([
			timeLabel.topAnchor.constraint(equalTo: eventNameLabel.topAnchor, constant: 0),
			timeLabel.leadingAnchor.constraint(equalTo: eventNameLabel.trailingAnchor, constant: 16),
			timeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
		])
		
		NSLayoutConstraint.activate([
			payloadLabel.topAnchor.constraint(equalTo: eventNameLabel.bottomAnchor, constant: 4),
			payloadLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
			payloadLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
			payloadLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
		])
		
		super.updateConstraints()
	}
}

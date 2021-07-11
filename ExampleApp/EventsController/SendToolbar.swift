//
//  SendToolbar.swift
//  ExampleApp
//
//  Created by Leonid Serebryanyy on 08.07.2021.
//

import UIKit
import Jitsu

typealias ToolbarAction = () -> Void

class SendToolbar: UIView {
	
	private lazy var send: UIButton = {
		let v = UIButton(type: .system)
		v.addTarget(self, action: #selector(_sendBatch), for: .touchUpInside)
		v.translatesAutoresizingMaskIntoConstraints = false
		v.setTitle("send", for: .normal)
		return v
	}()
	
	private lazy var timerView: EditableValueView = {
		let v = EditableValueView()
		v.setTitle("timer, s:")
		v.setTextValue("\(Jitsu.shared.sendingBatchesPeriod)")
		v.setButtonTitle("change")
		v.setAction { newValue in
			if let newTime = TimeInterval(newValue) {
				Jitsu.shared.sendingBatchesPeriod = newTime
			}
		}
		v.translatesAutoresizingMaskIntoConstraints = false
		return v
	}()
	
	private lazy var batchSizeView: EditableValueView = {
		let v = EditableValueView()
		v.setTitle("batch size")
		v.setTextValue("\(Jitsu.shared.eventsQueueSize)")
		v.setButtonTitle("change")
		v.setAction { newValue in
			if let newTime = Int(newValue) {
				Jitsu.shared.eventsQueueSize = newTime
			}
		}
		v.translatesAutoresizingMaskIntoConstraints = false
		return v
	}()
	
	private lazy var stack: UIStackView = {
		let stack = UIStackView(arrangedSubviews: [timerView, batchSizeView, send])
		stack.translatesAutoresizingMaskIntoConstraints = false
		stack.alignment = UIStackView.Alignment.fill
		stack.axis = .horizontal
		stack.distribution = UIStackView.Distribution.equalSpacing
		return stack
	}()
	
	var sendBatch: ToolbarAction?
	
	@objc private func _sendBatch() {
		sendBatch?()
	}
	
	convenience init() {
		self.init(frame: .zero)
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		makeUI()
	}
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		makeUI()
	}
	
	private func makeUI() {
		backgroundColor = .randomColor
		addSubview(stack)
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		NSLayoutConstraint.activate([
			stack.topAnchor.constraint(equalTo: topAnchor, constant: 8),
			stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
			stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
			stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
		])
	}

}

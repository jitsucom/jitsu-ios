//
//  SendToolbar.swift
//  ExampleApp
//
//  Created by Leonid Serebryanyy on 08.07.2021.
//

import UIKit

typealias ToolbarAction = () -> Void

class SendToolbar: UIView {
	
	private lazy var send: UIButton = {
		let v = UIButton(type: .system)
		v.addTarget(self, action: #selector(_sendBatch), for: .touchUpInside)
		v.translatesAutoresizingMaskIntoConstraints = false
		v.setTitle("send", for: .normal)
		return v
	}()

	private lazy var stack: UIStackView = {
		let stack = UIStackView(arrangedSubviews: [send])
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
			stack.topAnchor.constraint(equalTo: topAnchor, constant: 0),
			stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
			stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
			stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
		])
	}

}

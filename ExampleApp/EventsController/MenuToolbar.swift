//
//  MenuToolbar.swift
//  ExampleApp
//
//  Created by Leonid Serebryanyy on 08.07.2021.
//

import UIKit

class MenuToolbar: UIView {
	
	private lazy var timerView: EditableValueView = {
		let v = EditableValueView()
		v.setTitle("timer")
		v.setButtonTitle("change")
//		v.setAction {
//
//		}
		return v
	}()
	
//	func showPicker()

	private lazy var timer: UIButton = {
		let v = UIButton(type: .system)
//		v.addTarget(self, action: #selector(_changeTimerPressed), for: .touchUpInside)
		v.translatesAutoresizingMaskIntoConstraints = false
		v.setTitle("add event", for: .normal)
		return v
	}()
	
	private lazy var stack: UIStackView = {
		let stack = UIStackView(arrangedSubviews: [timerView])
		stack.translatesAutoresizingMaskIntoConstraints = false
		stack.alignment = UIStackView.Alignment.fill
		stack.axis = .horizontal
		stack.distribution = UIStackView.Distribution.equalSpacing
		return stack
	}()
	
//	var changeTimer: ((TimeInterval)->Void)?
//
//	@objc private func _changeTimerPressed() {
//		changeTimer?()
//	}
//
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
		addSubview(stack)
		backgroundColor = .randomColor
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

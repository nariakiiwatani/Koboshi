//
//  CustomViewsForOutlineCell.swift
//  Koboshi
//
//  Created by Iwatani Nariaki on 2018/02/19.
//  Copyright © 2018年 annolab. All rights reserved.
//

import Cocoa

protocol HasMultipulControls
{
	func addControl(control: NSControl)
}

class CustomCell : NSView
{
	var action: Selector?
	weak var target: AnyObject?
}

extension CustomCell : HasMultipulControls
{
	func childActionOccured(_ sender:Any?) {
		if let target = target {
			_ = target.perform(action, with: self)
		}
	}
	func addControl(control: NSControl) {
		control.target = self
		control.action = #selector(CustomCell.childActionOccured(_:))
		addSubview(control)
	}
}

extension CustomCell
{
	override var description : String {
		return ""
	}
}

//
//  CustomViewsForOutlineCell.swift
//  Koboshi
//
//  Created by Iwatani Nariaki on 2018/02/19.
//  Copyright © 2018年 annolab. All rights reserved.
//

import Cocoa

enum CustomControlType
{
	case combo([String], String)
	case browseFile(String)
}

class CustomCell : NSView
{
	var action: Selector?
	weak var target: AnyObject?
	var resultFuncs = [()->String]()
	var result: String {
		return resultFuncs.reduce("", { str, elem  in
			str+elem()
		})
	}
	
	func addControl(_ controlType: CustomControlType) {
		switch controlType {
		case let .combo(list, label):
			let combo = NSComboBox(string: label)
			combo.addItems(withObjectValues: list)
			addControl(combo)
			resultFuncs.append({ () -> String in
				return combo.objectValueOfSelectedItem as! String
			})
		case let .browseFile(str):
			let text = NSTextField(string: str)
			let button = NSButton(title: "Browse...", target: self, action: #selector(CustomCell.browseFile(sender:)))
			button.setValue(text, forKey: "target")
			addControl(text)
			addControl(button)
			resultFuncs.append({ () -> String in
				return text.stringValue
			})
		}
	}

	func browseFile(sender:NSButton) {
		let dialog = NSOpenPanel()
		dialog.canChooseDirectories=false
		dialog.canChooseFiles = true
		dialog.canCreateDirectories = false
		dialog.allowsMultipleSelection = false
		dialog.begin { (result) -> Void in
			if result == NSFileHandlingPanelOKButton {
				guard let url = dialog.url else { return }
				guard let target = sender.value(forKey: "target") as? NSControl else { return }
				target.stringValue = url.path
			}
		}
	}

	func childActionOccured(_ sender:Any?) {
		if let target = target {
			_ = target.perform(action, with: self)
		}
	}
	func addControl(_ control: NSControl) {
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

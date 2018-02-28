/*
CustomViewsForOutlineCell.swift
Koboshi

MIT LICENSE  

Copyright 2018 nariakiiwatani

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

import Cocoa

enum CustomControlType
{
	case text(String)
	case label(String)
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
		case let .text(str):
			let text = NSTextField(string: str)
			addControl(text)
			resultFuncs.append({ () -> String in
				return text.stringValue
			})
		case let .label(str):
			let text = NSTextField(labelWithString: str)
			addControl(text)
			resultFuncs.append({ () -> String in
				return text.stringValue
			})
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

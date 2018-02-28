/*
StatementEditor.swift
Koboshi

MIT LICENSE  

Copyright 2018 nariakiiwatani

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

import Cocoa

import SwiftyJSON
class StatementEditor : NSObject, NSOutlineViewDataSource, NSOutlineViewDelegate
{
	@IBOutlet weak var outlineView: NSOutlineView!
	var edited : Bool = false
	var jsonSrc = JSON({})
	public var json : JSON {
		set {
			jsonSrc = [
				"trigger" : TriggerType(withJSON: newValue["trigger"]).json,
				"operator": Operator(withJSON: newValue["operator"]).json,
			]
			edited = false
			outlineView.reloadItem(nil, reloadChildren:true)
		}
		get {
			return jsonSrc
		}
	}
	
	public func outlineView(_ outlineView: NSOutlineView, shouldEdit tableColumn: NSTableColumn?, item: Any) -> Bool {
		return true
	}
	
	@IBAction func didEditValue(_ sender: Any) {
		guard let sender = sender as? CustomCell else { 
			print("unknown sender type")
			return
		}
		let row = outlineView.row(for: sender)
		guard row >= 0 else { return }
		let item = outlineView.item(atRow: row) as! [JSONSubscriptType]
		var _json : JSON = jsonSrc
		_json[item] = JSON(sender.result)
		self.json = _json
		edited = true
	}
	
	public func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
		if(item == nil) {
			return 2
		}
		let item = item as! [JSONSubscriptType]
		let json = jsonSrc[item]
		switch json.type {
		case .dictionary, .array: return json.count
		default: return 0
		}
	}
	
	public func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
		if(item == nil) {
			return [["trigger", "operator"][index] as JSONSubscriptType]
		}
		var item = item as! [JSONSubscriptType]
		let json = jsonSrc[item]
		switch json.type {
		case .dictionary: item.append(json[json.index(json.startIndex, offsetBy: index)].0)
		case .array: item.append(index as JSONSubscriptType)
		default: assert(false, "something is wrong")
		}
		return item
	}
	
	public func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
		let item = item as! [JSONSubscriptType]
		let json = jsonSrc[item]
		switch json.type {
		case .dictionary, .array: return json.count > 0
		default: return false
		}
	}
	func typeArray(byItem keys: [JSONSubscriptType]) -> [String]? {
		guard let lastKey = keys.last as? String else {
			return nil
		}
		switch lastKey {
		case Operator().typename: return Operator.allTypes
		case AppState().typename: return AppState.allTypes
		case AppProc().typename: return AppProc.allTypes
		case FileState().typename: return FileState.allTypes
		case FileProc().typename: return FileProc.allTypes
		case ShellScriptExec().typename: return ShellScriptExec.allTypes
		case StringCompare().typename: return StringCompare.allTypes
		case ArrayCompare().typename: return ArrayCompare.allTypes
		case OSCMessageCompare().typename: return OSCMessageCompare.allTypes
		case TriggerType().typename: return TriggerType.allTypes
		default:
			return nil
		}
	}
	public func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
		let item = item as! [JSONSubscriptType]
		let json = jsonSrc[item]
		switch tableColumn!.identifier {
		case "TableKey":
			return NSTextField(labelWithString: item.last as! String)
		case "TableValue":
			let ret = CustomCell()
			ret.target = self
			ret.action = #selector(StatementEditor.didEditValue(_:))
			if let typeList = typeArray(byItem: item) {
				ret.addControl(.combo(typeList, jsonSrc[item].stringValue))
			}
			else {
				switch json.type {
				case .array: ret.addControl(.label("(array)"))
				case .dictionary: ret.addControl(.label("(object)"))
				case .bool: ret.addControl(.text(json.boolValue ? "true" : "false"))
				case .null: ret.addControl(.text("null"))
				case .number: ret.addControl(.text(String(describing: json.numberValue)))
				case .string: ret.addControl(.text(json.stringValue))
				default: break
				}
			}
			return ret
		default: return nil
		}
	}
	
	
	/*
	// MARK: Methods for Cell-Based OutlineView
	
	public func outlineView(_ outlineView: NSOutlineView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, byItem item: Any?) {
		guard let object = object else {
			return
		}
		let item = item as! [JSONSubscriptType]
		var json : JSON = jsonSrc
		json[item] = JSON(object)
		jsonSrc = [
			"trigger" : TriggerType(withJSON: json["trigger"]).json,
			"operator": Operator(withJSON: json["operator"]).json
		]
		outlineView.reloadItem(nil, reloadChildren:true)
	}
	

	public func outlineView(_ outlineView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
		if(item == nil) {
			return nil
		}
		let item = item as! [JSONSubscriptType]
		let json = jsonSrc[item]
		switch tableColumn!.identifier {
		case "TableKey":
			return String(describing: item.last!)
		case "TableValue":
			switch json.type {
			case .array: return "(array)"
			case .dictionary: return "(object)"
			case .bool: return json.boolValue ? "true" : "false"
			case .null: return "null"
			case .number: return String(describing: json.numberValue)
			case .string: return json.stringValue
			default: return nil
			}
		default: return nil
		}
	}
	*/
}

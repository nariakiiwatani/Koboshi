//
//  StatementEditor.swift
//  Koboshi
//
//  Created by Iwatani Nariaki on 2018/02/09.
//  Copyright © 2018年 annolab. All rights reserved.
//

import Cocoa

import SwiftyJSON
class StatementEditor : NSObject, NSOutlineViewDataSource, NSOutlineViewDelegate
{
	@IBOutlet weak var outlineView: NSOutlineView!
	var jsonSrc = JSON({})
	public var json : JSON {
		set {
			jsonSrc = newValue
			outlineView.reloadItem(nil, reloadChildren:true)
		}
		get {
			return jsonSrc
		}
	}
	
	public func outlineView(_ outlineView: NSOutlineView, shouldEdit tableColumn: NSTableColumn?, item: Any) -> Bool {
		return true
	}
	
	public func outlineView(_ outlineView: NSOutlineView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, byItem item: Any?) {
		let item = item as! [JSONSubscriptType]
		var json : JSON = jsonSrc
		json[item] = JSON(object)
		jsonSrc = [
			"trigger" : TriggerType(withJSON: json["trigger"]).json,
			"operator": Operator(withJSON: json["operator"]).json
		]
		outlineView.reloadItem(nil, reloadChildren:true)
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
}

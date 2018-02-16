//
//  RuleEditorViewController.swift
//  Koboshi
//
//  Created by Iwatani Nariaki on 2018/02/09.
//  Copyright © 2018年 annolab. All rights reserved.
//

import Cocoa

extension Operator {
	func numberOfChildren() -> Int {
		switch self {
		case .always,
		     .never:
			return 0
		case .ifthen,
		     .ifnot,
		     .and,
		     .applicationState:
			return 2
		case .ifelse:
			return 3
		default: return 0
		}
	}
	func getArg(at index:Int) -> Any {
		switch self {
		case let .and(s1,s2):
			switch index {
			case 0: return s1
			case 1: return s2
			default: break
			}
		case let .ifthen(a,b),
		     let .ifnot(a,b):
			switch index {
			case 0: return a
			case 1: return b
			default: break
			}
		case let .applicationState(a,b):
			switch index {
			case 0: return a
			case 1: return b
			default: break
			}
		case let .ifelse(c,s1,s2):
			switch index {
			case 0: return c
			case 1: return s1
			case 2: return s2
			default: break
			}
		default: break
		}
		return Operator.none
	}
}

import SwiftyJSON
class OutlineViewController : NSViewController, NSOutlineViewDataSource, NSOutlineViewDelegate
{
	@IBOutlet weak var outlineView: NSOutlineView!
	var jsonSrc: JSON!
	@IBAction func applyChanges(_ sender: Any) {
	}
	
	@IBAction func revertChanges(_ sender: Any) {
		outlineView.reloadItem(nil, reloadChildren:true)
	}
	
	override public func viewDidLoad() {
		super.viewDidLoad()
		jsonSrc = ["root":
			Operator.ifelse(
				Operator.and(
					Operator.applicationState(url:URL(fileURLWithPath: "/hogehoge.app"), Operator.AppState.running),
					Operator.never),
				Operator.ifthen(Operator.always, Operator.never),
				Operator.ifthen(Operator.always, Operator.never)
		).json]
	}
	public func outlineView(_ outlineView: NSOutlineView, shouldEdit tableColumn: NSTableColumn?, item: Any) -> Bool {
		return true
	}

	public func outlineView(_ outlineView: NSOutlineView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, byItem item: Any?) {
		let item = item as! [JSONSubscriptType]
		var json : JSON = jsonSrc
		json[item] = JSON(object)
		jsonSrc = ["root": Operator(withJSON:json["root"]).json]
		outlineView.reloadItem(nil, reloadChildren:true)
	}

	public func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
		if(item == nil) {
			return 1
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
			return ["root" as JSONSubscriptType]
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

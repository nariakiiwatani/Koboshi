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
		case .applicationState:
			return 1
		case .ifthen,
		     .ifnot,
		     .and:
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
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	public func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
		switch item {
		case is (Any, JSON):
			let json = (item as! (Any, JSON)).1
			switch json.type {
			case .dictionary, .array: return json.count
			default: return 0
			}
		case is Operator: return (item as! Operator).numberOfChildren()
		case nil: return 1
		default: return 0
		}
	}
	
	public func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
		switch item {
		case is (Any, JSON):
			let json = (item as! (Any, JSON)).1
			switch json.type {
			case .dictionary: return json[json.index(json.startIndex, offsetBy: index)]
			case .array: return (index, json[index])
			default: return []
			}
		case is JSON:
			let json = item as! JSON
			switch json.type {
			case .dictionary: return json[json.index(json.startIndex, offsetBy: index)]
			case .array: return (index, json[index])
			default: return []
			}
		case is Operator: return (item as! Operator).getArg(at: index)
		case nil: return Operator.ifelse(Operator.and(Operator.applicationState(url:URL(fileURLWithPath: "/hogehoge.app"), Operator.AppState.running), Operator.never),
		                                 Operator.ifthen(Operator.always, Operator.never),
		                                 Operator.ifnot(Operator.always, Operator.never)
			)
//		case nil: return ("root", Operator.and(Operator.always, Operator.never).json)
		default: return Operator.none
		}
	}
	
	public func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
		switch item {
		case is (Any, JSON):
			let json = (item as! (Any, JSON)).1
			switch json.type {
			case .dictionary, .array: return json.count > 0
			default: return false
			}
		case is Operator: return (item as! Operator).numberOfChildren() > 0
		case nil: return true
		default: return false
		}
	}
	public func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
		switch item {
		case is (Any, JSON):
			let (i,j) = item as! (Any, JSON)
			switch tableColumn!.identifier {
				case "TableKey":
					return NSTextField(labelWithString: String(describing: i))
				case "TableValue":
					switch j.type {
					case .array: return NSTextField(labelWithString: "array")
					case .dictionary: return NSTextField(labelWithString: "object")
					case .bool: return NSTextField(labelWithString: j.boolValue ? "true" : "false")
					case .null: return NSTextField(labelWithString: "null")
					case .number: return NSTextField(labelWithString: String(describing: j.numberValue))
					case .string: return NSTextField(labelWithString: j.stringValue)
					default: return nil
				}
			default: return nil
			}
		case is Operator:
			switch tableColumn!.identifier {
			case "TableKey":
				return NSTextField(labelWithString: (item as! Operator).type)
			case "TableValue": return nil
			default: return nil
			}
		case is URL:
			switch tableColumn!.identifier {
			case "TableKey":
				return NSTextField(labelWithString: "URL")
			case "TableValue":
				return NSTextField(string: (item as! URL).path)
			default: return nil
			}
		case is Operator.AppState:
			switch tableColumn!.identifier {
			case "TableKey":
				return NSTextField(labelWithString: "appState")
			case "TableValue":
				return NSTextField(labelWithString: (item as! Operator.AppState).type)
			default: return nil
			}
		default: return nil
		}
	}
}

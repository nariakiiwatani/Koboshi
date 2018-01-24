//
//  Trigger.swift
//  Koboshi
//
//  Created by Iwatani Nariaki on 2018/01/23.
//  Copyright © 2018年 annolab. All rights reserved.
//

import Foundation


protocol TriggerDelegate
{
	func execute() -> Bool
	func executeAsync()
}
extension TriggerDelegate
{
	func executeAsync() {
		DispatchQueue.global(qos:.background).async {
			_ = self.execute()
		}
	}
}
enum TriggerType {
	case none
	case interval(_:TimeInterval)
	
	func toTrigger() -> Trigger? {
		switch self {
		case let .interval(i):
			return IntervalTrigger(withTimeInterval:i)
		default:
			return nil
		}
	}
}
protocol Trigger : class
{
	var type : TriggerType { get }
	var enable : Bool { get set }
	var delegate : TriggerDelegate? { get set }
}


import SwiftyJSON

protocol JsonConvertibleTrigger
{
	init(withJSON json:JSON)
	var type : String{get}
	var args : Any{get}
	var json : JSON{get}
}

extension JsonConvertibleTrigger
{
	var json : JSON {
		return [
			"type" : JSON(type),
			"args" : JSON(args)
		]
	}
}

extension TriggerType : JsonConvertibleTrigger
{
	init(withJSON json: JSON) {
		let type = json["type"].stringValue
		let args = json["args"]
		switch type {
		case "interval":
			self = .interval(args["interval"].doubleValue)
		default:
			self = .none
		}
	}

	var args: Any {
		switch self {
		case let .interval(i): return ["interval":i]
		default: return []
		}
	}

	var type: String {
		switch self {
		case .interval: return "interval"
		default: return "none"
		}
	}
}

//
//  Trigger.swift
//  Koboshi
//
//  Created by Iwatani Nariaki on 2018/01/23.
//  Copyright © 2018年 annolab. All rights reserved.
//

import Foundation


protocol TriggerDelegate : class
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
	init() { self = .none }
	case none
	case interval(_:TimeInterval)
	case osc(_:OSCMessageCompare)
	
	func toTrigger() -> Trigger? {
		switch self {
		case let .interval(i): return IntervalTrigger(withTimeInterval:i)
		case let .osc(c): return OSCTrigger(withComparator:c)
		default:
			return nil
		}
	}
}
protocol Trigger : class
{
	var type : TriggerType { get }
	var enable : Bool { get set }
	weak var delegate : TriggerDelegate? { get set }
}

import SwiftyJSON

extension TriggerType : JsonConvertibleType
{
	var typename: String { return "triggerType" }
	static var allTypes : [String] {
		return ["interval","osc"]
	}

	init(withJSON json: JSON) {
		self.init()
		let type = json[typename].stringValue
		let args = json["args"]
		switch type {
		case "interval": self = .interval(args["interval"].doubleValue)
		case "osc": self = .osc(OSCMessageCompare(withJSON:args))
		default:
			self = .none
		}
	}

	var args: Any {
		switch self {
		case let .interval(i): return ["interval":i]
		case let .osc(c): return c.json
		default: return []
		}
	}

	var type: String {
		switch self {
		case .interval: return "interval"
		case .osc: return "osc"
		default: return "none"
		}
	}
}

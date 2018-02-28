/*
Trigger.swift
Koboshi

MIT LICENSE  

Copyright 2018 nariakiiwatani

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

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
	case interval(TimeInterval)
	case osc(Int, OSCMessageCompare)
	
	func toTrigger() -> Trigger? {
		switch self {
		case let .interval(i): return IntervalTrigger(withTimeInterval:i)
		case let .osc(p,c): return OSCTrigger(port: p, withComparator:c)
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
	var flatten : Bool { return true }
	static var allTypes : [String] {
		return ["interval","osc"]
	}

	init(withJSON json: JSON) {
		self.init()
		let args = flatten ? json : json["args"]
		switch json[typename] {
		case "interval": self = .interval(args["interval"].doubleValue)
		case "osc": self = .osc(args["port"].intValue, OSCMessageCompare(withJSON:args["message"]))
		default:
			self = .none
		}
	}

	var args: Any {
		switch self {
		case let .interval(i): return ["interval":i]
		case let .osc(p,c): return ["port":p, "message":c.json]
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

/*
Statement.swift
Koboshi

MIT LICENSE  

Copyright 2018 nariakiiwatani

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

import Foundation


class Statement : NSObject, TriggerDelegate
{
	var name = "New Item"
	var trigger : Trigger? {
		willSet {
			newValue?.enable = isRunning
			if trigger !== newValue {
				trigger?.enable = false
			}
		}
		didSet { trigger?.delegate = self }
	}
	var isRunning : Bool {
		set { trigger?.enable = newValue }
		get { return trigger?.enable ?? false }
	}

	var op = Operator()
	func execute() -> Bool {
		return op.execute()
	}
}

// MARK: - Json
import SwiftyJSON

extension Statement {
	convenience init(withJSON json:JSON) {
		self.init()
		self.json = json
	}
	var json : JSON {
		get {
			return [
				"name" : name,
				"trigger" : trigger?.type.json ?? {},
				"operator" : op.json,
				"isRunning" : isRunning
			]
		}
		set(_json) {
			name = _json["name"].string ?? name
			trigger = TriggerType(withJSON:_json["trigger"]).toTrigger()
			op = Operator(withJSON:_json["operator"])
			isRunning = _json["isRunning"].boolValue
		}
	}
}

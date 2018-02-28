/*
OSCTrigger.swift
Koboshi

MIT LICENSE  

Copyright 2018 nariakiiwatani

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

import Foundation
import SwiftOSC

class OSCTrigger : Trigger, OSCServerDelegateExt
{
	var type: TriggerType { return .osc(port, messageComparator) }

	weak var delegate: TriggerDelegate?
	private var messageComparator : OSCMessageCompare
	var port : Int
	
	init(port: Int, withComparator comparator:OSCMessageCompare) {
		messageComparator = comparator
		self.port = port
		OSCServerMulti.global.register(port: port, receiver: self)
	}
	deinit {
		OSCServerMulti.global.unregister(port: port, receiver: self)
	}
	var enable : Bool = false

	public func didReceive(_ message: SwiftOSC.OSCMessage) {
		guard enable else {
			return
		}
		guard messageComparator.execute(message) else {
			return
		}
		delegate?.executeAsync()
	}
}


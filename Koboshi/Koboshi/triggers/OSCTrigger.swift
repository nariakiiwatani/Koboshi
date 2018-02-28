//
//  OSCTrigger.swift
//  Koboshi
//
//  Created by Iwatani Nariaki on 2018/01/24.
//  Copyright © 2018年 annolab. All rights reserved.
//

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


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
	var type: TriggerType { return .osc(messageComparator) }

	var delegate: TriggerDelegate?
	private var messageComparator : Operator.OSCMessageCompare
	
	init(withComparator comparator:Operator.OSCMessageCompare) {
		messageComparator = comparator
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


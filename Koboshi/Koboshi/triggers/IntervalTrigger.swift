//
//  IntervalTrigger.swift
//  Koboshi
//
//  Created by Iwatani Nariaki on 2018/01/24.
//  Copyright © 2018年 annolab. All rights reserved.
//

import Foundation

class IntervalTrigger : Trigger
{
	var delegate: TriggerDelegate?
	
	private var timer : Timer? {
		willSet {
			if timer !== newValue {
				timer?.invalidate()
			}
		}
	}
	var type: TriggerType { get { return .interval(interval) } }
	var interval : Double
	
	init(withTimeInterval interval:TimeInterval) {
		self.interval = interval
	}
	var enable : Bool {
		set {
			timer?.invalidate()
			if newValue {
				timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true, block: {_ in
					self.delegate?.executeAsync()
				})
			}
		}
		get {
			return timer?.isValid ?? false
		}
	}
}


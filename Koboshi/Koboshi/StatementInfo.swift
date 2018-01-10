//
//  StatementInfo.swift
//  Koboshi
//
//  Created by Iwatani Nariaki on 2018/01/10.
//  Copyright © 2018年 annolab. All rights reserved.
//

import Foundation

class StatementInfo : NSObject
{
	var name : String = "new item"
	var enabled : Bool {
		set {
			newValue ? statement.run(withTimeInterval:1) : statement.stop()
		}
		get {
			return statement.isRunning
		}
	}
	
	var statement : Statement = Statement()
	
	init(launchApplicationIfNotRunning url:URL, withTimeInterval interval:TimeInterval = 1) {
		name = "watchdog for " + url.lastPathComponent
		statement.sentence = Operator.ifelse(
			Operator.applicationState(url: url, .notRunning)
			,Operator.applicationProc(url: url, .launch)
			,Operator.applicationProc(url: url, .activate)
		)
	}
}

//
//  ViewController.swift
//  Koboshi
//
//  Created by Iwatani Nariaki on 2017/12/27.
//  Copyright © 2017年 annolab. All rights reserved.
//

import Cocoa
import SwiftyJSON
import SwiftOSC

class ViewController: NSViewController, NSTableViewDataSource {

	let client = OSCClient(address:"localhost", port:9000)
	var oscServer = OSCServer(address:"", port:9000)
	var oscDispatcher = OSCDispatcher()
	var statements : [StatementInfo] = []
	override func viewDidLoad() {
		super.viewDidLoad()
		oscServer.delegate = oscDispatcher

//		statements.append(StatementInfo(launchApplicationIfNotRunning: URL(fileURLWithPath: "/Applications/System Preferences.app")))
//		var statement = StatementInfo(withTrigger:IntervalTrigger(withTimeInterval: 5))
		var statement = StatementInfo(withTrigger:OSCTrigger(withComparator: Operator.OSCMessageCompare.any))
		let outurl = URL(fileURLWithPath:"/Users/nariakiiwatani/Desktop/tmp.txt")
		statement.statement.op = Operator.ifelse(
			Operator.fileState(url: outurl, .exist)
			,Operator.fileProc(url: outurl, .delete)
			,Operator.fileProc(url: outurl, .create)
			)
//		statement.isRunning = true
		let json = statement.json
		print(json)
		statement = StatementInfo(withJSON:json)
		print(statement.json)
		oscDispatcher.add(statement.trigger as! OSCServerDelegateExt)
		statement.isRunning = true
		statements.append(statement)
		oscServer.start()
	}

	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}

	func numberOfRows(in tableView: NSTableView) -> Int {
		return statements.count
	}
	
	func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
		return statements[row]
	}
}


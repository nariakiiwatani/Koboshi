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

class ViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {

	let client = OSCClient(address:"localhost", port:9000)
	var oscServer = OSCServer(address:"", port:9000)
	var oscDispatcher = OSCDispatcher()
	@IBOutlet weak var tableView : NSTableView!
	var statements : [AppWatcher] = []
	@IBOutlet weak var appEditor : AppWatcherEditor!
	override func viewDidLoad() {
		super.viewDidLoad()
		oscServer.delegate = oscDispatcher

//		statements.append(StatementInfo(launchApplicationIfNotRunning: URL(fileURLWithPath: "/Applications/System Preferences.app")))
//		var statement = StatementInfo(withTrigger:IntervalTrigger(withTimeInterval: 5))
		let info = AppWatcher(Statement(withTrigger:OSCTrigger(withComparator: Operator.OSCMessageCompare.any)))
		let outurl = URL(fileURLWithPath:"/Users/nariakiiwatani/Desktop/tmp.txt")
		info.statement.op = Operator.ifelse(
			Operator.fileState(url: outurl, .exist)
			,Operator.fileProc(url: outurl, .delete)
			,Operator.fileProc(url: outurl, .create)
			)
//		statement.isRunning = true
		statements.append(info)
		let json = info.json
//		print(json)
		let info2 = AppWatcher(withJSON:json)
//		print(info.json)
//		oscDispatcher.add(info2.statement.trigger as! OSCServerDelegateExt)
		info2.isRunning = true
		info2.name = "jge"
		statements.append(info2)
		oscServer.start()
	}

	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}
	
	func newWatcher() {
		statements.append(AppWatcher(Statement(withTrigger:IntervalTrigger(withTimeInterval: 1))))
		tableView.reloadData()
		tableView.selectRowIndexes([tableView.numberOfRows-1], byExtendingSelection: false)
	}
	func delWatcher() {
		if tableView.selectedRow >= 0 {
			let index = tableView.selectedRow
			statements.remove(at: index)
			tableView.reloadData()
			tableView.selectRowIndexes([min(tableView.numberOfRows-1, index)], byExtendingSelection: false)
		}
	}

	@IBAction func addremButton(_ sender: Any) {
		guard let button = sender as? NSSegmentedControl else {
			return
		}
		if button.isSelected(forSegment: 0) {
			newWatcher()
		}
		if button.isSelected(forSegment: 1) {
			delWatcher()
		}
	}
	func numberOfRows(in tableView: NSTableView) -> Int {
		return statements.count
	}
	
	func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
		return statements[row]
	}
	public func tableViewSelectionDidChange(_ notification: Notification) {
		if tableView.selectedRow >= 0 {
			appEditor.setReference(&statements[tableView.selectedRow])
		}
		else {
			appEditor.clearReference()
		}
	}
}


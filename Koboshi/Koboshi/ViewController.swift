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

	@IBOutlet weak var tableView : NSTableView!
	@IBOutlet weak var editor : StatementEditor!
	var statements : [Statement] = []
	override func viewDidLoad() {
		super.viewDidLoad()

		if let data = UserDefaults.standard.value(forKey: "data") as? [Data] {
			data.forEach{
				if let json = try? JSON(data: $0) {
					statements.append(Statement(withJSON: json))
				}
			}
		}
		else {
			newStatement()
		}
	}
	
	override func viewDidAppear() {
		super.viewDidAppear()
		if !statements.isEmpty {
			tableView.selectRowIndexes([0], byExtendingSelection: false)
		}
	}
	
	override func viewWillDisappear() {
		super.viewWillDisappear()
		UserDefaults.standard.setValue(statements.map{try? $0.json.rawData()}, forKey: "data")
	}


	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}
	
	func newStatement() {
		let s = Statement()
		s.trigger = IntervalTrigger(withTimeInterval: 1)
		statements.append(s)
		tableView.reloadData()
		tableView.selectRowIndexes([tableView.numberOfRows-1], byExtendingSelection: false)
	}
	func delStatement() {
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
			newStatement()
		}
		if button.isSelected(forSegment: 1) {
			delStatement()
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
			editor.json = statements[tableView.selectedRow].json
		}
		else {
			editor.json = JSON({})
		}
	}
	public func selectionShouldChange(in tableView: NSTableView) -> Bool {
		if tableView.selectedRow >= 0 {
			statements[tableView.selectedRow].json = statements[tableView.selectedRow].json.merged(editor.json)
		}
		return true
	}

}


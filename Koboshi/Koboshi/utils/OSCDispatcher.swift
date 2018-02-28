//
//  OSCDispatcher.swift
//  Koboshi
//
//  Created by Iwatani Nariaki on 2018/01/24.
//  Copyright © 2018年 annolab. All rights reserved.
//

import Foundation
import SwiftOSC

protocol OSCServerDelegateExt : class, OSCServerDelegate
{
}

class OSCDispatcher : OSCServerDelegateExt
{
	var delegates:[OSCServerDelegateExt] = []
	func add(_ newDelegate:OSCServerDelegateExt) {
		delegates.append(newDelegate)
	}
	func remove(_ delegate:OSCServerDelegateExt) {
		delegates = delegates.filter { $0 !== delegate }
	}
	func didReceive(_ data: Data) {
		delegates.forEach { (d:OSCServerDelegateExt) in
			d.didReceive(data)
		}
	}
	func didReceive(_ bundle: SwiftOSC.OSCBundle) {
		delegates.forEach { (d:OSCServerDelegateExt) in
			d.didReceive(bundle)
		}
	}
	func didReceive(_ message: SwiftOSC.OSCMessage) {
		delegates.forEach { (d:OSCServerDelegateExt) in
			d.didReceive(message)
		}
	}

}

class OSCServerMulti
{
	private var servers = [Int:(OSCServer,OSCDispatcher)]()
	private func createServer(port:Int) -> (OSCServer,OSCDispatcher) {
		let server = OSCServer(address: "", port: port)
		let dispatcher = OSCDispatcher()
		server.delegate = dispatcher
		server.running = true
		servers.updateValue((server, dispatcher), forKey: port)
		return servers[port]!
	}
	private func getServer(port:Int) -> (OSCServer,OSCDispatcher) {
		return servers[port] ?? createServer(port: port)
	}
	func register(port:Int, receiver:OSCServerDelegateExt) {
		getServer(port: port).1.add(receiver)
	}
	func unregister(port:Int, receiver:OSCServerDelegateExt) {
		getServer(port: port).1.remove(receiver)
	}
	static var global = OSCServerMulti()
}

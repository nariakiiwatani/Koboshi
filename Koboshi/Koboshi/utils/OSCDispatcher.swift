/*
OSCDispatcher.swift
Koboshi

MIT LICENSE  

Copyright 2018 nariakiiwatani

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

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

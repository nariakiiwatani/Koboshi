//
//  Operator.swift
//  Koboshi
//
//  Created by Iwatani Nariaki on 2017/12/27.
//  Copyright © 2017年 annolab. All rights reserved.
//

import Foundation

indirect enum Operator {
	
	case always
	case never
	case and(Operator, Operator)
	case nand(Operator, Operator)
	case or(Operator, Operator)
	case xor(Operator, Operator)
	case ifthen(Operator, Operator)
	case ifnot(Operator, Operator)
	case ifelse(Operator, Operator, Operator)
	case anyway(Operator)
	case ignore(Operator)

	case applicationState(url:URL, AppState)
	case applicationProc(url:URL, AppProc)

	func execute() -> Bool {
		switch self {
		case .always: return true
		case .never: return false
		case let .and(l,r): return l.execute() && r.execute()
		case let .nand(l,r): return !(l.execute() && r.execute())
		case let .or(l,r): return l.execute() || r.execute()
		case let .xor(l,r): return l.execute() != r.execute()
		case let .ifthen(c,s): return c.execute() ? s.execute() : true
		case let .ifnot(c,s): return c.execute() ? true : s.execute()
		case let .ifelse(c,t,f): return c.execute() ? t.execute() : f.execute()
		case let .anyway(o): return o.execute() || true
		case .ignore(_): return true
			
		case let .applicationState(url, state): return state.execute(url)
		case let .applicationProc(url, proc): return proc.execute(url)
			
		}
	}
}


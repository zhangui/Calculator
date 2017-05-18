//
//  CalculatorModel.swift
//  Calculator
//
//  Created by Yang Zhang on 5/14/17.
//  Copyright © 2017 Yang Zhang. All rights reserved.
//

import Foundation

func factor(operand: Int) -> Int{
    if operand < 0 {
        return operand
    }
    if operand == 0 {
        return 1
    } else {
        return operand * factor(operand: operand - 1)
    }
}

struct CalculatorModel {
    
    private var accumulator: Double?
    private var floatPending = false
    private var resultIsPending = false
    private var description = ""
    private var reset = false
    
    private enum Operation {
        case constant(Double)
        case unary((Double) -> Double)
        case binary((Double,Double) -> Double)
        case factorial
        case float
        case equals
        case clear
    }
    
    private var operations: Dictionary<String, Operation> = [
        "π" : Operation.constant(Double.pi),
        "e" : Operation.constant(M_E),
        "√" : Operation.unary(sqrt),
        "cos" : Operation.unary(cos),
        "sin" : Operation.unary(sin),
        "tan" : Operation.unary(tan),
        "ln" : Operation.unary({log($0)/log(M_E)}),
        "log" : Operation.unary(log),
        "±" : Operation.unary({-$0}),
        "+" : Operation.binary({$0 + $1}),
        "−" : Operation.binary({$0 - $1}),
        "×" : Operation.binary({$0 * $1}),
        "÷" : Operation.binary({$0 / $1}),
        "!" : Operation.factorial,
        "." : Operation.float,
        "=" : Operation.equals,
        "C" : Operation.clear
    ]
    
    mutating func performOperation(_ symbol: String) {
        if let operation = operations[symbol] {
            switch operation {
            case .constant(let value):
                accumulator = value
                reset = true
                if !previousIs(symbol: description) {
                    description = ""
                    reset = false
                }
                if previousIs(symbol: description) && !resultIsPending {
                    description += symbol
                }
            case .unary(let function):
                if accumulator != nil {
                    if resultIsPending {
                        description += symbol + "(" + removeTrailing(float: String(accumulator!)) + ")"
                    } else if !resultIsPending && previousIs(symbol: description) {
                        description += symbol + "(" + removeTrailing(float: String(accumulator!)) + ")"
                    } else {
                        description = symbol + "(" + description + ")"
                    }
                    accumulator = function(accumulator!)
                    reset = true
                }
            case .binary(let function):
                resultIsPending = true
                
                if accumulator != nil {
                    if previousIs(symbol: description) {
                        description += removeTrailing(float: String(accumulator!)) + symbol
                    } else {
                        description += symbol
                    }
                    pendingBinaryOperation = PendingBinaryOperation(function: function, firstOperand: accumulator!)
                    accumulator = nil
                }
            case .factorial:
                if accumulator != nil {
                    let string = String(accumulator!)
                    if string.hasSuffix(".0") {
                        let integer = Int(accumulator!)
                        accumulator = Double(factor(operand: integer))
                    }
                }
                reset = true
            case .float:
                if accumulator != nil {
                    
                    let checker = removeTrailing(float: String(accumulator!))
                    
                    if checker.range(of: ".") == nil {
                        floatPending = true
                    }
                }
                
            case .equals:
                resultIsPending = false
                performPendingBinaryOperation()
                reset = true
            case .clear:
                accumulator = 0
                floatPending = false
                resultIsPending = false
                description = ""
                reset = false
            }
        }
    }
    
    
    private mutating func performPendingBinaryOperation() {
        if pendingBinaryOperation != nil && accumulator != nil {
            if previousIs(symbol: description) {
                description += removeTrailing(float: String(accumulator!))
            }
            accumulator = pendingBinaryOperation!.perform(with: accumulator!)
            pendingBinaryOperation = nil
        }
    }
    
    private var pendingBinaryOperation: PendingBinaryOperation?
    
    
    func checkFloat() -> Bool{
        if floatPending {
            return true
        }
        return false
    }
    
    mutating func resetFloat() {
        floatPending = false
    }
    
    private struct PendingBinaryOperation {
        let function: (Double,Double) -> Double
        let firstOperand: Double
        
        func perform(with secondOperand: Double) -> Double {
            return function(firstOperand, secondOperand)
        }
    }
    
    mutating func setOperand(_ operand: Double) {
        accumulator = operand
    }
    
    func updatePreviousActions() -> String {
        if resultIsPending {
            return description + "..."
        } else {
            return description + "="
        }
    }
    
    func removeTrailing(float: String) -> String {
        var truncate = float
        if truncate.hasSuffix(".0") {
            truncate = truncate.substring(to: truncate.index(before: truncate.endIndex))
            truncate = truncate.substring(to: truncate.index(before: truncate.endIndex))
        }
        return truncate
    }
    
    func previousIs(symbol: String) -> Bool {
        if symbol.characters.last != nil {
            let end = String(symbol.characters.last!)
            if let operation = operations[end] {
                switch operation {
                case .constant(_):
                    return false
                default:
                    return true
                }
            }
        } else {
            return true
        }
        return false
    }
    
    mutating func canReset() -> Bool {
        if reset && !resultIsPending {
            description = ""
            reset = false
            return true
        }
        return false
    }
    
    
    var result: Double? {
        get {
            return accumulator
        }
    }
}

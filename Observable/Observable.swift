//
//  Observable.swift
//  Observable
//
//  Created by magi on 2019/10/25.
//  Copyright © 2019 magi. All rights reserved.
//

import UIKit

struct ValueChange<T> {
    public let oldValue: T
    public let newValue: T
    public init(_ o: T, _ n: T) {
        oldValue = o
        newValue = n
    }
}


protocol AnyObservable {
    
    associatedtype ValueType
    
    var value: ValueType { get set }
    
    var beforeChange: Event<ValueChange<ValueType>> { get }
    
    var afterChange: Event<ValueChange<ValueType>> { get }
}


struct Observable<T>: AnyObservable {
    
    typealias ValueType = T

    private(set) var beforeChange = Event<ValueChange<T>>()
    private(set) var afterChange = Event<ValueChange<T>>()
    
    var value : T {
        willSet { beforeChange.notify(ValueChange(value, newValue)) }
        didSet { afterChange.notify(ValueChange(oldValue, value)) }
    }
    
    mutating func unshare(removeSubscriptions: Bool) {
        // TODO: unshare
    }

    public init(_ v : T) {
        value = v
    }
}


// event += { (old, new) in ... }
@discardableResult
func += <T> (event: Event<ValueChange<T>>, handler: @escaping (T, T) -> ()) -> EventSubscription<ValueChange<T>> {
    return event.add({ handler($0.oldValue, $0.newValue) })
}

// observable <- value
infix operator <-

// for observable values on variables
func <- <T : AnyObservable> (x: inout T, y: T.ValueType) {
    x.value = y
}



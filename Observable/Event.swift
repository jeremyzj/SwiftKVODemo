//
//  Event.swift
//  Observable
//
//  Created by magi on 2019/10/27.
//  Copyright © 2019 magi. All rights reserved.
//

import UIKit

class EventSubscription<T> {
    typealias HandlerType = (T) -> ()
    
    private var _valid: () -> Bool
    
    private(set) var handler: HandlerType
    
    private var _owned = [AnyObject]()
    
    init(owner o: AnyObject?, handler h: @escaping HandlerType) {
        if o == nil {
            _valid = { true }
        } else {
            _valid = { [weak o] in o != nil }
        }
        handler = h
    }
    
    
    public func valid() -> Bool {
        if !_valid() {
            invalidate()
            return false
        } else {
            return true
        }
    }
    
    /// Marks the event for removal, frees the handler and owned objects
    public func invalidate() {
        _valid = { false }
        handler = { _ in () }
        _owned = []
    }
    
    public func addOwnedObject(_ o: AnyObject) {
        _owned.append(o)
    }
   
    public func removeOwnedObject(_ o: AnyObject) {
        _owned = _owned.filter{ $0 !== o }
    }
}

protocol AnyEvent {
    
    associatedtype ValueType
    
    mutating func notify(_ value: ValueType)
    
    @discardableResult
    mutating func add(_ subscription: EventSubscription<ValueType>) -> EventSubscription<ValueType>
    
    @discardableResult
    mutating func add(_ handler : @escaping (ValueType) -> ()) -> EventSubscription<ValueType>
    
    mutating func remove(_ subscription : EventSubscription<ValueType>)
    
    mutating func removeAll()
    
    @discardableResult
    mutating func add(owner : AnyObject, _ handler : @escaping (ValueType) -> ()) -> EventSubscription<ValueType>

}

class Event<T>: AnyEvent {
    typealias ValueType = T
    typealias SubscriptionType = EventSubscription<T>
    typealias HandlerType = SubscriptionType.HandlerType
    
    private(set) var subscriptions = [SubscriptionType]()
    
    init() { }
    
    func notify(_ value: T) {
        subscriptions = subscriptions.filter { $0.valid() }
        for subscription in subscriptions {
            subscription.handler(value)
        }
    }
    
    @discardableResult
    func add(_ subscription: SubscriptionType) -> SubscriptionType {
        subscriptions.append(subscription)
        return subscription
    }
    
    @discardableResult
    func add(_ handler: @escaping HandlerType) -> SubscriptionType {
        return add(SubscriptionType(owner: nil, handler: handler))
    }
    
    func remove(_ subscription: SubscriptionType) {
        var newsubscriptions = [SubscriptionType]()
        var first = true
        for existing in subscriptions {
            if first && existing === subscription {
                first = false
            } else {
                newsubscriptions.append(existing)
            }
        }
        subscriptions = newsubscriptions
    }
    
    func removeAll() {
        subscriptions.removeAll()
    }
    
    @discardableResult
    func add(owner: AnyObject, _ handler: @escaping HandlerType) -> SubscriptionType {
        return add(SubscriptionType(owner: owner, handler: handler))
    }
    
    func unshare() {
//        _subscriptions.unshare()
    }
    
}

@discardableResult
func += <T: AnyEvent> (event: T, handler: @escaping (T.ValueType) -> ()) -> EventSubscription<T.ValueType> {
    var e = event
    return e.add(handler)
}

func -= <T: AnyEvent> (event: inout T, subscription: EventSubscription<T.ValueType>) {
    return event.remove(subscription)
}

func -= <T: AnyEvent> (event: T, subscription: EventSubscription<T.ValueType>) {
    var e = event
    return e.remove(subscription)
}

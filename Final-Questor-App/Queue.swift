//
//  Queue.swift
//  Final-Questor-App
//
//  Created by Asad Khan on 16/07/2016.
//  Copyright © 2016 Adrian Humphrey. All rights reserved.
//

import Foundation



class _QueueItem<T> {
    
    let value: T!
    var next: _QueueItem?
    
    init(_ newvalue: T?) {
        self.value = newvalue
    }
}


open class Queue<T> {
    
    typealias Element = T
    
    var _front: _QueueItem<Element>
    var _back: _QueueItem<Element>
    
    public init () {
        // Insert dummy item. Will disappear when the first item is added.
        _back = _QueueItem(nil)
        _front = _back
    }
    
    /// Add a new item to the back of the queue.
    func enqueue (_ value: Element) {
        _back.next = _QueueItem(value)
        _back = _back.next!
    }
    
    /// Return and remove the item at the front of the queue.
    func dequeue () -> Element? {
        if let newhead = _front.next {
            _front = newhead
            return newhead.value
        } else {
            return nil
        }
    }
    
    open func isEmpty() -> Bool {
        return _front === _back
    }
}

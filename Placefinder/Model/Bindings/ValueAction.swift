//
//  ValueAction.swift
//  Placefinder
//
//  Created by André Vants Soares de Almeida on 30/08/18.
//

class ValueAction<T> {
    typealias Handler = (T)->()
    private var action : Handler?
    
    func bind(_ action: Handler?) {
        self.action = action
    }
    
    func fire(_ value: T) {
        action?(value)
    }
}

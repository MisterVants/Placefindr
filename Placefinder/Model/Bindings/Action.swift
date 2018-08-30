//
//  Action.swift
//  Placefinder
//
//  Created by André Vants Soares de Almeida on 29/08/18.
//

class Action {
    typealias Handler = ()->()
    private var action : Handler?
    
    func bind(_ action: Handler?) {
        self.action = action
    }
    
    func bindAndFire(_ action: Handler?) {
        self.action = action
        action?()
    }
    
    func fire() {
        action?()
    }
}


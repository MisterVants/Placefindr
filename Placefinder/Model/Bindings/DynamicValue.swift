//
//  DynamicValue.swift
//  Placefinder
//
//  Created by André Vants Soares de Almeida on 30/08/18.
//

class Dynamic<T> {
    typealias Listener = (T)->()
    private var listener : Listener?
    
    func bind(_ listener: Listener?) {
        self.listener = listener
    }
    
    func bindAndFire(_ listener: Listener?) {
        self.listener = listener
        listener?(value)
    }
    
    var value: T {
        didSet {
            listener?(value)
        }
    }
    
    init(_ v: T) {
        value = v
    }
}

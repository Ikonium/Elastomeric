//
//  ViewController.swift
//  Elastomeric
//
//  Created by Christopher Cohen on 5/25/18.
//

import UIKit

//Elastomer declarations
extension Elastomer {
    static var someBool:Elastomer   { return Elastomer(associatedType: Bool.self, name: "someBool") }
    static var someString:Elastomer { return Elastomer(associatedType: String.self, name: "someString") }
    static var someInt:Elastomer { return Elastomer(associatedType: Int.self, name: "someInt") }
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //MARK: Elastomeric Push
        
        //Add or change a value
        Elastomer.someBool.push(value: true)
        Elastomer.someString.push(value: "hello!")
        Elastomer.someInt.push(value: Int(27))

        //Attempts to add a value of an unassociated type will be ignored
        Elastomer.someInt.push(value: Float(27))
        
        //A value may be staged after an arbitrary delay
        Elastomer.someBool.push(value: false, afterDelay: TimeInterval(12))
        
        //Redundant entries are ignored by default, but that may be overridden
        Elastomer.someBool.push(value: false, discardingRedundancy: false)
        
        
        //MARK: Elastomeric Pull
        
        //Recall value from model. Response will be deivered in a trailing closure
        Elastomer.someBool.pull { (value) in
            
            //Cast optional Any? as Bool
            guard let bool = value as? Bool else { return }
            
            //Print result
            print("Boolean derived from value in closure \(bool)")
        }
        
        //Recall multiple values from the model at once
        [Elastomer.someBool, Elastomer.someString, Elastomer.someInt].pull { (dict) in
            
            //The dictionary contains Elastomer-value associations
            guard let bool = dict[Elastomer.someBool] as? Bool else { return }
            
            //Print result
            print("Boolean derived from value subscripted from dictionary  \(bool)")
        }
        
        
        //MARK: Elastomeric Observation
        
        //Reactivly observe any mutations to the Elastomer-associated data
        Elastomer.someBool.observe { (mutation) in
            
            //The new value can be derived from the mutation
            guard let newBool = mutation.newValue as? Bool else { return }
            
            //The previous value can be derived from the mutation
            guard let oldBool = mutation.oldValue as? Bool else { return }
            
            //A timestamp of the change is also delivered by way of the mutation
            let timeOfMutation:TimeInterval = mutation.timestamp

            //Print contents of mutation
            print("old value \(oldBool) was replaced by new value \(newBool), \(abs(CACurrentMediaTime()-timeOfMutation)) seconds ago")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


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
    static var someInt:Elastomer    { return Elastomer(associatedType: Int.self, name: "someInt") }
}

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stageNewValuesToModel()
        expressExistingValuesFromModel()
        registerObservers()
    }
    
    //MARK: Staging of values to model
    fileprivate func stageNewValuesToModel() {
        
        // 1. Add or change a value on a per-value basis
        Elastomer.someBool.stageValue(true)
        Elastomer.someString.stageValue("hello!")
        Elastomer.someInt.stageValue(Int(27))
        
        // 2. All Attempts to stage a value of an unassociated type will be ignored.
        Elastomer.someInt.stageValue(Float(27))
        
        // 3. A value may be staged after an arbitrary delay
        Elastomer.someBool.stageValue(false, afterDelay: TimeInterval(12))
        
        // 4. Redundant entries are ignored by default, but that may be overridden
        Elastomer.someBool.stageValue(false, discardingRedundancy: false)
        
        // 5. Values may be staged in a batch operation
        [Elastomer.someBool:true, Elastomer.someInt:Int(72), Elastomer.someString:"goodbye!"].stage()
    }
    
    //MARK: Expression of values from model
    fileprivate func expressExistingValuesFromModel() {
        
        // 1. Recall value from model. Response will be deivered in a trailing closure
        Elastomer.someBool.expressValue { (value) in
            
            //Cast optional Any? as Bool
            guard let bool = value as? Bool else { return }
            
            //Print result
            print("Boolean derived from value in closure \(bool)")
        }
        
        // 2. Recall multiple values from the model at once
        [Elastomer.someBool, Elastomer.someString, Elastomer.someInt].expressValues { (dict) in
            
            //The dictionary contains Elastomer-value associations
            guard let bool = dict[Elastomer.someBool] as? Bool else { return }
            
            //Print result
            print("Boolean derived from value subscripted from dictionary  \(bool)")
        }
    }
    
    //MARK: Observation of value changes in model
    func registerObservers() {
        
        // 1. Observe any mutations to the Elastomer-associated data
        let _ = Elastomer.someBool.registerObserver { (mutation) in
            
            //The new value can be derived from the mutation
            guard let newBool = mutation.newValue as? Bool else { return }
            
            //The previous value can be derived from the mutation
            guard let oldBool = mutation.oldValue as? Bool else { return }
            
            //A timestamp of the change is also delivered by way of the mutation
            let timeOfMutation:TimeInterval = mutation.timestamp
            
            //Print contents of mutation
            print("old value \(oldBool) was replaced by new value \(newBool), \(abs(CACurrentMediaTime()-timeOfMutation)) seconds ago")
        }
        
        // 2. New observers will return UUD receipts that can be captured for later retirement
        let stringObserverReceipt = Elastomer.someString.registerObserver { (mutation) in
            print("The string did change")
        }
        
        // 3. An observer may be retired with the associated receipt
        Elastomer.someString.retireObserver(stringObserverReceipt)
        
        // 4. New observers may be registered in batches
        let receipts = [Elastomer.someString, Elastomer.someInt].registerObservers { (mutation) in
            
            switch mutation.elastomer {
            case .someString:   print("The string did change")
            case .someInt:      print("The int did change")
            default:            break
            }
        }
        
        // 5. A dictionary of observer receipts may be retired together
        receipts.retireAll()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        Elastomer.someBool.expressValue { (value) in
            guard let boolean = value as? Bool else { return }
            Elastomer.someBool.stageValue(!boolean)
        }
    }
}

//
//  Elastomeric.swift
//
//  Created by Christopher Cohen on 5/25/18.
//

import Foundation
import Photos

typealias ElastomericEqualityEvaluation = ((_ lhs:Any?, _ rhs:Any?)->Bool)
typealias ElastomericTypeViabilityEvaluation = ((_ value:Any?)->Bool)

typealias ObserverBlock = ((_ mutation:ElastomericMutation)->Void)?

struct ElastomericObserver {
    var inceptQueue:DispatchQueue, block:ObserverBlock
}

public struct ElastomericMutation {
    var oldValue:Any?, newValue:Any?
    let timestamp:TimeInterval = CACurrentMediaTime()
}

public struct Elastomer:Hashable {
    
    public let name:String
    public var hashValue:Int
    fileprivate let evaluateForEquality:ElastomericEqualityEvaluation
    fileprivate let evaluateForAssociatedType:ElastomericTypeViabilityEvaluation

    init<T: Equatable>(associatedType:T.Type, name:String) {
        self.hashValue = name.hashValue
        self.name = name
        self.evaluateForEquality = { lhs, rhs in return (lhs as? T) == (rhs as? T) }
        self.evaluateForAssociatedType = { value in return value is T }
    }
    
    public static func ==(lhs: Elastomer, rhs: Elastomer) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    func push(value:Any?, discardingRedundancy discardRedundant:Bool = true) {
        ElastomericArchive.pushValue(value, associatedWithElastomer: self, discardingRedundancy:discardRedundant)
    }
    
    func push(value:Any?, afterDelay delay:TimeInterval, discardingRedundancy discardRedundant:Bool = true) {
        DispatchQueue.underlying.asyncAfter(deadline: .now() + delay) {
            ElastomericArchive.pushValue(value, associatedWithElastomer: self, discardingRedundancy:discardRedundant)
        }
    }
    
    func pull(result:((Any?)->Void)?) {
        ElastomericArchive.pullValue(associatedWithElastomer: self, result: result)
    }
    
    func observe(block:ObserverBlock) {
        ElastomericArchive.observeValue(associatedWithElastomer: self, observerBlock: block)
    }
}

fileprivate struct ElastomericArchive {
    
    fileprivate static let interleaveQueue:OperationQueue = {
        let queue = OperationQueue()
        queue.name = "interleaveQueue"
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = QualityOfService.userInitiated
        return queue
    }()
    
    fileprivate static var model = [Elastomer:Any]()
    fileprivate static var observers = [Elastomer:[ElastomericObserver]]()

    @inline(__always) fileprivate static func postValue(associatedWithElastomer elastomer:Elastomer) {
        
        //Aquire elastomer-associated value from model
        let value = self.model[elastomer]
        
        //Interate through all elastomer-associated observers and post value
        self.observers[elastomer]?.forEach({ observer in
            observer.inceptQueue.async {
                
                //Create mutation package
                let mutation = ElastomericMutation(oldValue: value, newValue: value)
                
                //Report to observers
                observer.block?(mutation)
            }
        })
    }
    
    @inline(__always) fileprivate static func pushValue(_ value:Any?, associatedWithElastomer elastomer:Elastomer, discardingRedundancy discardRedundant:Bool) {
        
        //If the value is not the expected type, abort
        guard elastomer.evaluateForAssociatedType(value) else { return }
        
        //Add value to model
        self.interleaveQueue.addOperation {
            
            //Capture old value
            let oldValue = self.model[elastomer]
            
            //Determine redundancy
            let redundantAssignment:Bool = elastomer.evaluateForEquality(oldValue, value)
            
            //Abort if assignment is redundant and redundancy filter is active
            if discardRedundant && redundantAssignment { return }
            
            //Assign new value to model
            self.model[elastomer] = value
            
            //Notify observers of change
            guard let tuples = self.observers[elastomer] else { return }
            for tuple in tuples {
                
                //Create mutation package
                let mutation = ElastomericMutation(oldValue: oldValue, newValue: value)
                
                //Execute observer block
                tuple.inceptQueue.async { tuple.block?(mutation) }
            }
        }
    }
    
    @inline(__always) fileprivate static func observeValue(associatedWithElastomer elastomer:Elastomer, observerBlock:ObserverBlock) {
        
        //Attempt to capture incept queue
        let inceptQueue = DispatchQueue.underlying
        
        //Register observer
        observers[elastomer] = observers[elastomer] ?? [ElastomericObserver]()
        let observer = ElastomericObserver(inceptQueue:inceptQueue, block:observerBlock)
        observers[elastomer]?.append(observer)
    }
    
    @inline(__always) fileprivate static func pullValue(associatedWithElastomer elastomer:Elastomer, result:((Any?)->Void)?) {
        
        //Attempt to capture incept queue
        let inceptQueue = DispatchQueue.underlying
        
        //On interleave queue, query value
        self.interleaveQueue.addOperation {
            
            //Attempt to aquire value from model
            let value:Any? = self.model[elastomer]
            
            //Report result on incept queue in param block
            inceptQueue.async {
                result?(value) //Result
            }
        }
    }
}

extension DispatchQueue {
    static var underlying:DispatchQueue { return OperationQueue.current?.underlyingQueue ?? DispatchQueue.main }
}

extension Sequence where Element == Elastomer {

    ///Pull a group of Elastomer-associated values
    func pull(result:(([Elastomer:Any])->Void)?) {
        
        //Capture incept queue
        let inceptQueue = DispatchQueue.underlying

        //Populate dictionary with results
        ElastomericArchive.interleaveQueue.addOperation {
            
            //Create empty dictionary that will contain response
            var dict = [Elastomer:Any]()

            //Populate dictionary from Archive model
            for elastomer in self { dict[elastomer] = ElastomericArchive.model[elastomer] }
            
            //Publish result on incept queue
            inceptQueue.async { result?(dict) }
        }
    }
}

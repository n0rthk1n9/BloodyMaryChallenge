import Foundation
import HealthKit

class HeartRateService: ObservableObject {
    private var healthStore = HKHealthStore()
    private let heartRateQuantity = HKUnit(from: "count/min")
    
    @Published var currentHeartRate: Int = 0
    
    init() {
        autorizeHealthKit()
    }
    
    private func autorizeHealthKit() {
        let healthKitTypes: Set = [
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!]
        
        healthStore.requestAuthorization(toShare: healthKitTypes, read: healthKitTypes) { _, _ in }
    }
    
    func startMonitoring() {
        startHeartRateQuery(quantityTypeIdentifier: .heartRate)
    }
    
    private func startHeartRateQuery(quantityTypeIdentifier: HKQuantityTypeIdentifier) {
        let devicePredicate = HKQuery.predicateForObjects(from: [HKDevice.local()])
        
        let updateHandler: (HKAnchoredObjectQuery, [HKSample]?, [HKDeletedObject]?, HKQueryAnchor?, Error?) -> Void = {
            query, samples, deletedObjects, queryAnchor, error in
            
            guard let samples = samples as? [HKQuantitySample] else { return }
            self.process(samples, type: quantityTypeIdentifier)
        }
        
        let query = HKAnchoredObjectQuery(
            type: HKObjectType.quantityType(forIdentifier: quantityTypeIdentifier)!,
            predicate: devicePredicate,
            anchor: nil,
            limit: HKObjectQueryNoLimit,
            resultsHandler: updateHandler)
        
        query.updateHandler = updateHandler
        healthStore.execute(query)
    }
    
    private func process(_ samples: [HKQuantitySample], type: HKQuantityTypeIdentifier) {
        for sample in samples {
            if type == .heartRate {
                let heartRate = Int(sample.quantity.doubleValue(for: heartRateQuantity))
                DispatchQueue.main.async {
                    self.currentHeartRate = heartRate
                }
            }
        }
    }
}

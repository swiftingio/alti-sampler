import CoreData

public extension NSManagedObjectContext {
    func deleteEntities<Entity: NSManagedObject>(ofType type: Entity.Type) throws {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Entity.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        try execute(deleteRequest)
        try save()
    }
}

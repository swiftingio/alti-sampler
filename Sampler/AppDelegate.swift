import UIKit
import CoreData
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    lazy var locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 5.0
        locationManager.allowsBackgroundLocationUpdates = true
        return locationManager
    }()
    lazy var viewController: ViewController = {
        return ViewController(
            sampler: Sampler(locationManager: self.locationManager),
            exporter: Exporter(context: self.persistentContainer.viewContext)
        )
    }()
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores(completionHandler: { (_, _) in })
        return container
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = UINavigationController(rootViewController: viewController)
        window?.makeKeyAndVisible()
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        saveContext()
    }

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch { print("\(error)") }
        }
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {}
    func applicationDidEnterBackground(_ application: UIApplication) { logBackgroundTime() }
    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {}
}

extension UIApplicationDelegate {
    func logBackgroundTime(ofApplication application: UIApplication = UIApplication.shared) {
        let message = String(format: "Application entered background.  Time remaining = %.1f seconds",
                     application.backgroundTimeRemaining)
        print(message)
    }
}

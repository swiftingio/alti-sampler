import UIKit

protocol LocationViewControllerDelegate: class {
    func locationViewController(_ viewController: LocationViewController, didSelectLocation location: String)
}

enum LiftLocation: String {
    case top, bottom
}

extension LiftLocation {
    init(int: Int) {
        if int == 0 {
            self = .top
        } else {
            self = .bottom
        }
    }
}
class LocationViewController: UIViewController {

    weak var delegate: LocationViewControllerDelegate?
    fileprivate var cancelButton: UIBarButtonItem!
    fileprivate var doneButton: UIBarButtonItem!
    fileprivate lazy var tableView = UITableView(frame: .zero, style: .plain)
    let reuseIdentifier: String = String(describing: UITableViewCell.self)
    var contentArray: NSArray = NSArray()
    let segmentedControl = UISegmentedControl(items: [LiftLocation.top.rawValue, LiftLocation.bottom.rawValue])
    var liftLocation: LiftLocation = .bottom
    var selectedIndexPath: IndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()
        cancelButton = UIBarButtonItem(barButtonSystemItem:
            .cancel, target: self, action: #selector(cancelTapped))
        doneButton = UIBarButtonItem(barButtonSystemItem:
            .done, target: self, action: #selector(doneTapped))
        doneButton.isEnabled = false
        navigationItem.rightBarButtonItem = doneButton
        navigationItem.leftBarButtonItem = cancelButton
        view.addSubview(tableView)
        view.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        let path = Bundle.main.path(forResource: "Lifts", ofType: "plist")!
        contentArray = NSArray(contentsOfFile: path) ?? NSArray() //as! [ [String:[String]] ]
        tableView.reloadData()
        segmentedControl.sizeToFit()
        navigationItem.titleView = segmentedControl
        segmentedControl.addTarget(self, action: #selector(liftLocationChanged), for: .valueChanged)
    }

    func liftLocationChanged() {
        doneButton.isEnabled = true
        liftLocation = LiftLocation(int: segmentedControl.selectedSegmentIndex)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }

    @objc fileprivate func cancelTapped() {
        dismiss()
    }

    @objc fileprivate func doneTapped() {
        if let delegate = delegate,
            let indexPath = selectedIndexPath {
            let location = data(for: indexPath) + " " + liftLocation.rawValue
            delegate.locationViewController(self, didSelectLocation: location)
        }
        dismiss()
    }

}

extension String {
    static let name: String = "name"
    static let lifts: String = "lifts"
}
extension LocationViewController: UITableViewDataSource {

    func data(forSection section: Int) -> NSArray {
        return (contentArray.object(at: section) as? NSDictionary)?.value(forKey: .lifts) as? NSArray ?? NSArray()
    }

    func data(for indexPath: IndexPath) -> String {
        return data(forSection: indexPath.section).object(at: indexPath.row) as! String
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return contentArray.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return data(forSection: section).count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        cell.textLabel?.text = data(for: indexPath)
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return (contentArray[section] as? NSDictionary)?.value(forKey: .name) as? String ?? ""
    }

}

extension LocationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
    }
}

extension UIViewController {
    func dismiss() {
        view.endEditing(true)
        dismiss(animated: true, completion: nil)
    }
}

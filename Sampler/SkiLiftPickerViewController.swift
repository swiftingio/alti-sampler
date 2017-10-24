import UIKit

protocol SkiLiftPickerViewControllerDelegate: class {
    func locationViewController(_ viewController: SkiLiftPickerViewController, didSelectLocation location: String)
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

extension UITableViewCell {
    public static var reuseIdentifier: String {
        return String(describing: self)
    }
}

class SkiLiftPickerViewController: UIViewController {

    weak var delegate: SkiLiftPickerViewControllerDelegate?
    fileprivate lazy var cancelButton: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem:
            .cancel, target: self, action: #selector(cancelTapped))
    }()
    fileprivate lazy var doneButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem:
            .done, target: self, action: #selector(doneTapped))
        button.isEnabled = false
        return button
    }()
    fileprivate lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.reuseIdentifier)
        return tableView
    }()
    lazy var contentArray: NSArray = {
        let path = Bundle.main.path(forResource: "Lifts", ofType: "plist")!
        let contentArray: NSArray = NSArray(contentsOfFile: path)!
        return contentArray
    }()
    let segmentedControl = UISegmentedControl(items: [LiftLocation.top.rawValue, LiftLocation.bottom.rawValue])
    var liftLocation: LiftLocation = .bottom
    var selectedIndexPath: IndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        view.backgroundColor = .white

        segmentedControl.sizeToFit()
        segmentedControl.addTarget(self, action: #selector(liftLocationChanged), for: .valueChanged)

        navigationItem.rightBarButtonItem = doneButton
        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.titleView = segmentedControl

        tableView.reloadData()
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
            let location = "\(data(for: indexPath)) \(liftLocation.rawValue)"
            delegate.locationViewController(self, didSelectLocation: location)
        }
        dismiss()
    }

}

extension String {
    static let name: String = "name"
    static let lifts: String = "lifts"
}

extension SkiLiftPickerViewController: UITableViewDataSource {

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
        let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.reuseIdentifier, for: indexPath)
        cell.textLabel?.text = data(for: indexPath)
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return (contentArray[section] as? NSDictionary)?.value(forKey: .name) as? String ?? ""
    }

}

extension SkiLiftPickerViewController: UITableViewDelegate {
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

import UIKit

class ViewController: UIViewController {

    var button: UIBarButtonItem!
    var export: UIBarButtonItem!
    var textView: UITextView!
    let toolbar = UIToolbar(frame: .zero)
    var locationButton: UIBarButtonItem!

    let exporter: Exporter
    let sampler: Sampler

    init(sampler: Sampler, exporter: Exporter) {
        self.sampler = sampler
        self.exporter = exporter
        super.init(nibName: nil, bundle: nil)
        sampler.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Pressure + Location"
        setupButton()
        setupTextView()
        setupToolbar()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        textView.frame = view.bounds
        toolbar.sizeToFit()
        toolbar.frame.origin.x = view.bounds.origin.x
        toolbar.frame.origin.y = view.bounds.origin.y + view.bounds.size.height - toolbar.frame.size.height
    }

    private func setupButton() {
        button = UIBarButtonItem(title: "stop", style: .plain, target: self, action: #selector(toggleRecording))
        setButtonTitle(self.sampler.isRecording)
        navigationItem.rightBarButtonItem = button
        export = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareAll))
        navigationItem.leftBarButtonItem = export
    }

    private func setupToolbar() {
        locationButton = UIBarButtonItem(title: "location", style: .plain, target: self, action: #selector(showLocationPicker))
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.items = [flexible, locationButton, flexible]
        view.addSubview(toolbar)
    }

    private func setButtonTitle(_ isRecording: Bool) {
        button.title = isRecording ? "stop" : "record"
    }

    private func setupTextView() {
        textView = UITextView()
        textView.isEditable = false
        textView.isUserInteractionEnabled = false
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        view.addSubview(textView)
    }

    @objc private func toggleRecording() {
        if sampler.isRecording {
            sampler.stopSampling()
            exporter.save(sampler.samples)
        } else {
            sampler.clearSamples()
            sampler.startSampling()
        }
        setButtonTitle(sampler.isRecording)
    }

    func showLocationPicker() {
        let viewController = LocationViewController()
        viewController.delegate = self
        let navigationController = UINavigationController(rootViewController: viewController)
        present(navigationController, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        exporter.save(sampler.samples)
    }

    func exportAll() {
        do {
            if let filePath: String = try exporter.saveAsPlistToDocuments() {
                showMsg("Saved at filePath: \(filePath).")
            }
        } catch {
            showMsg("Error when saving :(!")
        }
    }

    func shareAll() {
        do {
            let json = try exporter.allJSONRecordings()
            let activityVC = UIActivityViewController(activityItems: [json], applicationActivities: nil)

            var excluded: [UIActivityType] = [
                .addToReadingList,
                .assignToContact,
                .message,
                .openInIBooks,
                .postToFacebook,
                .postToFlickr,
                .postToTencentWeibo,
                .postToTwitter,
                .postToVimeo,
                .postToWeibo,
                .print,
                .saveToCameraRoll,
                ]
            if #available(iOS 11.0, *) {
                excluded.append(.markupAsPDF)
            }
            activityVC.excludedActivityTypes = excluded
            present(activityVC, animated: true, completion: nil)
        } catch {
            printE(error)
        }
    }
}

extension ViewController: LocationViewControllerDelegate {
    func locationViewController(_ viewController: LocationViewController, didSelectLocation location: String) {
        sampler.locationName = location
    }
}

extension UIViewController {
    func printE(_ error: Error) {
        showMsg(error.localizedDescription)
    }
    func showMsg(_ message: String) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension ViewController: SamplerDelegate {
    func sampler(_ sampler: Sampler, didAdd sample: Sample) {
        show(sample)
    }
    func show(_ sample: Sample) {
        textView.text = exporter.json(from: sample)
    }
}

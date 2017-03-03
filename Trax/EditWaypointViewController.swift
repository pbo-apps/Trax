//
//  EditWaypointViewController.swift
//  Trax
//
//  Created by Pete Bounford on 03/03/2017.
//  Copyright © 2017 PBO Apps. All rights reserved.
//

import UIKit

class EditWaypointViewController: UIViewController, UITextFieldDelegate {

    var waypointToEdit: EditableWaypoint? { didSet { updateUI() } }
    
    private func updateUI() {
        nameTextField?.text = waypointToEdit?.name
        infoTextField?.text = waypointToEdit?.info
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        nameTextField.becomeFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        listenToTextFields()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopListeningToTextFields()
    }
    
    private func stopListeningToTextFields() {
        removeObserver(ntfObserver)
        removeObserver(itfObserver)
    }
    
    private func removeObserver(_ observer: NSObjectProtocol?) {
        if let obs = observer {
            NotificationCenter.default.removeObserver(obs)
        }
    }
    
    private var ntfObserver: NSObjectProtocol?
    private var itfObserver: NSObjectProtocol?
    
    private func listenToTextFields() {
        let center = NotificationCenter.default
        let queue = OperationQueue.main

        ntfObserver = center.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: nameTextField, queue: queue) { notification in
            if let waypoint = self.waypointToEdit {
                waypoint.name = self.nameTextField.text
            }
        }
        itfObserver = center.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: infoTextField, queue: queue) { notification in
            if let waypoint = self.waypointToEdit {
                waypoint.info = self.infoTextField.text
            }
        }
    }
    @IBAction func done(_ sender: UIBarButtonItem) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var nameTextField: UITextField! { didSet { nameTextField.delegate = self } }
    @IBOutlet weak var infoTextField: UITextField! { didSet { infoTextField.delegate = self } }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

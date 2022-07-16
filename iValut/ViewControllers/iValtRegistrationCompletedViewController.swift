import UIKit

class iValtRegistrationCompletedViewController: UIViewController {
    
    let congratulations = "Congratulations!\nYou have successfully created your Universal Biometic ID with iVALT®"
        let biometric = "To use this further, please enroll this ID in one of our supported 3rd party apps as described in our FAQ accessible through \"info\" button"
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
}

// MARK: - UIBUTTON ACTIONS
extension iValtRegistrationCompletedViewController {
    @IBAction func doneClicked(_ sender: UIButton) {
        NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATION_SUCCESS), object: nil)
        self.dismiss(animated: true, completion: nil)
    }
}

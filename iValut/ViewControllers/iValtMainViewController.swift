import UIKit
import Foundation
import LocalAuthentication

class iValtMainViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        faceAuthentication()
    }
    
    func faceAuthentication() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Identify yourself!"

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
                [weak self] success, authenticationError in

                DispatchQueue.main.async {
                    if success {
                        Helper.setBoolPREF(true, key: UserDefaultsConstants.PREF_IS_FACE_SCANNED)
                        if let vc = ViewControllerHelper.getViewController(ofType: .iValtRegistrationCompletedViewController) as? iValtRegistrationCompletedViewController {
                            self?.navigationController?.pushViewController(vc, animated: true)
                        }
                    } else {
                        var data: [AnyHashable: Any] = [:]
                        data[WSResponseParams.WS_RESP_PARAM_MESSAGE] = error?.localizedDescription ?? AlertMessages.PASSCODE_NOT_ALLOWED
                        NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATION_FAILURE), object: nil, userInfo: data)
                    }
                }
            }
        } else {
            Helper.showOKCancelAlertWithCompletion(onVC: self, title: Alert.ERROR, message: AlertMessages.FACE_ID_NOT_CONFIGURED, btnOkTitle: "Settings", btnCancelTitle: "Cancel", onOk: {
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }

                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        print("Settings opened: \(success)") // Prints true
                    })
                }
            })
        }
    }
}

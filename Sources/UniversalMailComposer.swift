//
//  UniversalMailComposer.swift
//  UniversalMailComposer
//
//  Created by Giada Ciotola on 13 Jun 2022.
//  Copyright © 2022 Beatcode. All rights reserved.
//

import UIKit
import MessageUI

open class UniversalMailComposer: NSObject, MFMailComposeViewControllerDelegate {
    public static let shared = UniversalMailComposer()
    public override init() {}
    
    open func sendMail(
        recipient: String,
        subject: String,
        body: String,
        hostVC: UIViewController
    ) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([recipient])
            mail.setSubject(subject)
            mail.setMessageBody(body, isHTML: false)
            
            hostVC.present(mail, animated: true)
            
            /// Show third party email composer if default Mail app is not present
        } else if let fallbackURLs = fallbackClients(to: recipient, subject: subject, body: body) {
            UIApplication.shared.open(fallbackURLs)
        }
    }
    
    func fallbackClients(to: String, subject: String, body: String) -> URL? {
        guard let subjectEncoded = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let bodyEncoded = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return URL(string: "") }
        
        let gmailURL = URL(string: "googlegmail://co?to=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
        let outlookURL = URL(string: "ms-outlook://compose?to=\(to)&subject=\(subjectEncoded)")
        let yahooURL = URL(string: "ymail://mail/compose?to=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
        let sparkURL = URL(string: "readdle-spark://compose?recipient=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
        let defaultURL = URL(string: "mailto:\(to)?subject=\(subjectEncoded)&body=\(bodyEncoded)")
        
        if let gmailURL = gmailURL, UIApplication.shared.canOpenURL(gmailURL) {
            return gmailURL
        } else if let outlookURL = outlookURL, UIApplication.shared.canOpenURL(outlookURL) {
            return outlookURL
        } else if let yahooURL = yahooURL, UIApplication.shared.canOpenURL(yahooURL) {
            return yahooURL
        } else if let sparkURL = sparkURL, UIApplication.shared.canOpenURL(sparkURL) {
            return sparkURL
        }
        
        return defaultURL
    }
    
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}


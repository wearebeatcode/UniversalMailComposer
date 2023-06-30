//
//  UniversalMailComposer.swift
//  UniversalMailComposer
//
//  Created by Giada Ciotola on 13 Jun 2022.
//  Copyright © 2022 Beatcode. All rights reserved.
//
//swiftlint:disable large_tuple identifier_name line_length

import MessageUI
import UIKit

open class UniversalMailComposer: NSObject, MFMailComposeViewControllerDelegate {
    public static let shared = UniversalMailComposer()
    public override init() {}
    
    open func sendMail(
        recipient: String,
        subject: String?,
        body: String?,
        attachment: (data: Data, mimeType: String, name: String)?,
        hostVC: UIViewController
    ) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([recipient])
            if let subject {
                mail.setSubject(subject)
            }
            if let body {
                mail.setMessageBody(body, isHTML: false)
            }
            if let attachment {
                mail.addAttachmentData(attachment.data, mimeType: attachment.mimeType, fileName: attachment.name)
            }
            hostVC.present(mail, animated: true)
            
            /// Show third party email composer if default Mail app is not present
        } else if let fallbackURLs = fallbackClients(to: recipient, subject: subject, body: body) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(fallbackURLs)
            }
        }
    }
    
    func fallbackClients(to: String, subject: String?, body: String?, attachmentData: Data? = nil, mimeType: String? = nil, attachmentName: String? = nil) -> URL? {
        
        var gmailURLString = "googlegmail://co?to=\(to)"
        var outlookURLString = "ms-outlook://compose?to=\(to)"
        var yahooURLString = "ymail://mail/compose?to=\(to)"
        var sparkURLString = "readdle-spark://compose?recipient=\(to)"
        var defaultURLString = "mailto:\(to)"
        
        if let subjectEncoded = subject?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            gmailURLString.append("&subject=\(subjectEncoded)")
            outlookURLString.append("&subject=\(subjectEncoded)")
            yahooURLString.append("&subject=\(subjectEncoded)")
            sparkURLString.append("&subject=\(subjectEncoded)")
            defaultURLString.append("&subject=\(subjectEncoded)")
        }
        if let bodyEncoded = body?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            gmailURLString.append("&body=\(bodyEncoded)")
            yahooURLString.append("&body=\(bodyEncoded)")
            sparkURLString.append("&body=\(bodyEncoded)")
            defaultURLString.append("&body=\(bodyEncoded)")
        }
        
        if let gmailURL = URL(string: gmailURLString), UIApplication.shared.canOpenURL(gmailURL) {
            return gmailURL
        } else if let outlookURL = URL(string: outlookURLString), UIApplication.shared.canOpenURL(outlookURL) {
            return outlookURL
        } else if let yahooURL = URL(string: yahooURLString), UIApplication.shared.canOpenURL(yahooURL) {
            return yahooURL
        } else if let sparkURL = URL(string: sparkURLString), UIApplication.shared.canOpenURL(sparkURL) {
            return sparkURL
        }
        
        return URL(string: defaultURLString)
    }
    
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}

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
        recipient: String?,
        subject: String?,
        body: String?,
        attachment: (data: Data, mimeType: String, name: String)?,
        hostVC: UIViewController
    ) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            if let recipient {
                mail.setToRecipients([recipient])
            }
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
    
    func fallbackClients(to: String?, subject: String?, body: String?, attachmentData: Data? = nil, mimeType: String? = nil, attachmentName: String? = nil) -> URL? {
        
        var gmailComponents = URLComponents(string: "googlegmail://co")
        gmailComponents?.queryItems = []
        
        var outlookURLComponents = URLComponents(string: "ms-outlook://compose")
        outlookURLComponents?.queryItems = []
        
        var yahooURLComponents = URLComponents(string: "ymail://mail/compose")
        yahooURLComponents?.queryItems = []
        
        var sparkURLComponents = URLComponents(string: "readdle-spark://compose")
        sparkURLComponents?.queryItems = []
        
        var defaultURLComponents = URLComponents(string: "mailto:")
        defaultURLComponents?.queryItems = []
        
        if let to {
            gmailComponents?.queryItems?.append(URLQueryItem(name: "to", value: to))
            outlookURLComponents?.queryItems?.append(URLQueryItem(name: "to", value: to))
            yahooURLComponents?.queryItems?.append(URLQueryItem(name: "to", value: to))
            sparkURLComponents?.queryItems?.append(URLQueryItem(name: "recipient", value: to))
            defaultURLComponents?.path = to
        }
        
        if let subjectEncoded = subject?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            let subjectItem = URLQueryItem(name: "subject", value: subjectEncoded)
            gmailComponents?.queryItems?.append(subjectItem)
            outlookURLComponents?.queryItems?.append(subjectItem)
            yahooURLComponents?.queryItems?.append(subjectItem)
            sparkURLComponents?.queryItems?.append(subjectItem)
            defaultURLComponents?.queryItems?.append(subjectItem)
        }
        if let bodyEncoded = body?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            let bodyItem = URLQueryItem(name: "body", value: bodyEncoded)
            gmailComponents?.queryItems?.append(bodyItem)
            yahooURLComponents?.queryItems?.append(bodyItem)
            sparkURLComponents?.queryItems?.append(bodyItem)
            defaultURLComponents?.queryItems?.append(bodyItem)
        }
        
        if let gmailURL = gmailComponents?.url, UIApplication.shared.canOpenURL(gmailURL) {
            return gmailURL
        } else if let outlookURL = outlookURLComponents?.url, UIApplication.shared.canOpenURL(outlookURL) {
            return outlookURL
        } else if let yahooURL = yahooURLComponents?.url, UIApplication.shared.canOpenURL(yahooURL) {
            return yahooURL
        } else if let sparkURL = sparkURLComponents?.url, UIApplication.shared.canOpenURL(sparkURL) {
            return sparkURL
        }
        
        return defaultURLComponents?.url
    }
    
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}

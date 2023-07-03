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
    
    func fallbackClients(to recipient: String?, subject: String?, body: String?, attachmentData: Data? = nil, mimeType: String? = nil, attachmentName: String? = nil) -> URL? {
        
        let gmailComponents = urlComponents(from: "googlegmail://co", parameters: [
            (recipient, "to", false),
            (subject?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), "subject", false),
            (body?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), "body", false)
        ])
        
        let outlookURLComponents = urlComponents(from: "ms-outlook://compose", parameters: [
            (recipient, "to", false),
            (subject?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), "subject", false)
        ])
        
        let yahooURLComponents = urlComponents(from: "ymail://mail/compose", parameters: [
            (recipient, "to", false),
            (subject?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), "subject", false),
            (body?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), "body", false)
        ])
        
        let sparkURLComponents = urlComponents(from: "readdle-spark://compose", parameters: [
            (recipient, "recipient", false),
            (subject?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), "subject", false),
            (body?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), "body", false)
        ])
        
        let defaultURLComponents = urlComponents(from: "mailto:", parameters: [
            (recipient, "to", true),
            (subject?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), "subject", false),
            (body?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), "body", false)
        ])
        
        if let gmailURL = openableUrl(from: gmailComponents) {
            return gmailURL
        } else if let outlookURL = openableUrl(from: outlookURLComponents) {
            return outlookURL
        } else if let yahooURL = openableUrl(from: yahooURLComponents) {
            return yahooURL
        } else if let sparkURL = openableUrl(from: sparkURLComponents) {
            return sparkURL
        }
        
        return defaultURLComponents?.url
    }
    
    private func urlComponents(from string: String, parameters: [(value: String?, key: String, isQueryItem: Bool)]) -> URLComponents? {
        var components = URLComponents(string: string)
        components?.queryItems = []
        parameters.forEach { parameter in
            guard let value = parameter.value else {
                return
            }
            if parameter.isQueryItem {
                let item = URLQueryItem(name: parameter.key, value: value)
                components?.queryItems?.append(item)
            } else {
                components?.path.append(value)
            }
        }
        return components
    }
    
    private func openableUrl(from components: URLComponents?) -> URL? {
        guard let url = components?.url, UIApplication.shared.canOpenURL(url) else {
            return nil
        }
        return url
    }
    
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}

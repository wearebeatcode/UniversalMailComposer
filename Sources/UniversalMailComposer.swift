//
//  UniversalMailComposer.swift
//  UniversalMailComposer
//
//  Created by Giada Ciotola on 13 Jun 2022.
//  Copyright © 2022 Beatcode. All rights reserved.
//

import MessageUI
import UIKit

public struct UniversalMailAttachment {
    let data: Data
    let mimeType: String
    let name: String
    
    public init(data: Data, mimeType: String, name: String) {
        self.data = data
        self.mimeType = mimeType
        self.name = name
    }
}

open class UniversalMailComposer: NSObject, MFMailComposeViewControllerDelegate {
    public static let shared = UniversalMailComposer()
    public override init() {}
    
    open func sendMail(
        recipient: String?,
        subject: String?,
        body: String?,
        attachment: UniversalMailAttachment?,
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
    
    func fallbackClients(to recipient: String?, subject: String?, body: String?,
                         attachmentData: Data? = nil, mimeType: String? = nil, attachmentName: String? = nil) -> URL? {
        
        let gmailComponents = urlComponents(from: "googlegmail://co", parameters: [
            ComponentsParameter(value: recipient, key: "to", isQueryItem: false),
            ComponentsParameter(value: subject?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                                key: "subject", isQueryItem: false),
            ComponentsParameter(value: body?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                                key: "body", isQueryItem: false)
        ])
        
        let outlookURLComponents = urlComponents(from: "ms-outlook://compose", parameters: [
            ComponentsParameter(value: recipient, key: "to", isQueryItem: false),
            ComponentsParameter(value: subject?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                                key: "subject", isQueryItem: false)
        ])
        
        let yahooURLComponents = urlComponents(from: "ymail://mail/compose", parameters: [
            ComponentsParameter(value: recipient, key: "to", isQueryItem: false),
            ComponentsParameter(value: subject?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                                key: "subject", isQueryItem: false),
            ComponentsParameter(value: body?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                                key: "body", isQueryItem: false)
        ])
        
        let sparkURLComponents = urlComponents(from: "readdle-spark://compose", parameters: [
            ComponentsParameter(value: recipient, key: "recipient", isQueryItem: false),
            ComponentsParameter(value: subject?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                                key: "subject", isQueryItem: false),
            ComponentsParameter(value: body?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                                key: "body", isQueryItem: false)
        ])
        
        let defaultURLComponents = urlComponents(from: "mailto:", parameters: [
            ComponentsParameter(value: recipient, key: "to", isQueryItem: true),
            ComponentsParameter(value: subject?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                                key: "subject", isQueryItem: false),
            ComponentsParameter(value: body?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                                key: "body", isQueryItem: false)
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
    
    private struct ComponentsParameter {
        let value: String?
        let key: String
        let isQueryItem: Bool
    }
    
    private func urlComponents(from string: String, parameters: [ComponentsParameter]) -> URLComponents? {
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
    
    public func mailComposeController(_ controller: MFMailComposeViewController,
                                      didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}

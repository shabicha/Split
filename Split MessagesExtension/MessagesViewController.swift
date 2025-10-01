//
//  MessagesViewController.swift
//  Split MessagesExtension
//
//  Created by Shabicha Sureshkumar on 2025-08-06.
//

import UIKit
import Messages

// MARK: - Message Data Model
struct SplitBillMessage: Codable {
    let billTitle: String
    let totalAmount: Double
    var people: [PersonSplit]
    let splitMode: String
    
    struct PersonSplit: Codable {
        let name: String
        let amount: Double
        var isPaid: Bool
    }
}

class MessagesViewController: MSMessagesAppViewController {
    @objc func amountChanged() {
        guard let text = numField.text,
              let amount = Double(text),
              amount > 0 else {
            peopleListVC?.updateTotalAmount(0.0)
            return
        }
        
        peopleListVC?.updateTotalAmount(amount)
    }
    // MARK: - UI Properties
    private var backgroundView: UIView!
    private var logoView = UIImageView()
    private var appName = UILabel()
    private var billTitle = UITextField()
    private var amount = UILabel()
    private var splitBy = UILabel()
    private var people = UILabel()

    private var percent = UIButton()
    private var equal = UIButton()
    private var dollarSelect = UIButton()
    private var send = UIButton()

    private var numField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "0.00"
        tf.keyboardType = .decimalPad
        
        tf.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        tf.layer.cornerRadius = 5.5
          tf.borderStyle = .none
          tf.font = UIFont.systemFont(ofSize: 16)
          tf.textColor = UIColor.black
          tf.textAlignment = .left
        
          
        // container view for the $ sign
          let leftContainer = UIView(frame: CGRect(x: 0, y: 0, width: 35, height: 20))
          let dollarLabel = UILabel(frame: CGRect(x: 12, y: 0, width: 20, height: 20))
          dollarLabel.text = "$"
          dollarLabel.font = UIFont.systemFont(ofSize: 16)
          dollarLabel.textColor = UIColor(red: 0.518, green: 0.557, blue: 0.6, alpha: 1)
          dollarLabel.textAlignment = .center
          
          leftContainer.addSubview(dollarLabel)
          tf.leftView = leftContainer
          tf.leftViewMode = .always
           
           tf.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 20))
           tf.rightViewMode = .always
        return tf
    } ()
    
    private var peopleListVC: PeopleListViewController?

    
    var isPercentSelected = true
    var isDollarSelected = false
    var isEqualSelected = false
    @objc func toggleButton() {
      
        if !isPercentSelected {
                    isPercentSelected = true
                    isDollarSelected = false
            isEqualSelected = false
            
                    percent.layer.borderWidth = 3.0
                    percent.layer.borderColor = UIColor.black.cgColor
                    dollarSelect.layer.borderWidth = 0
            equal.layer.borderWidth = 0
            
                    peopleListVC?.updateSplitMode(isDollar: false, isPercent:true, isEqual:false)
                }
    }

    @objc func toggleButton2() {
        if !isDollarSelected {
                  isDollarSelected = true
                  isPercentSelected = false
            isEqualSelected = false
                  dollarSelect.layer.borderWidth = 3.0
                  dollarSelect.layer.borderColor = UIColor.black.cgColor
                  percent.layer.borderWidth = 0
            equal.layer.borderWidth = 0
            
                  peopleListVC?.updateSplitMode(isDollar: true,  isPercent:false, isEqual:false)
              }
    }
    
    @objc func toggleButton3() {
        if !isEqualSelected {
                  isDollarSelected = false
                  isPercentSelected = false
                    isEqualSelected = true
            equal.layer.borderWidth = 3.0
            equal.layer.borderColor = UIColor.black.cgColor
                  percent.layer.borderWidth = 0
            dollarSelect.layer.borderWidth = 0
                  
                  peopleListVC?.updateSplitMode(isDollar: false,  isPercent:false, isEqual:true)
              }
    }



    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.949, green: 0.949, blue: 0.969, alpha: 1)

        // background view
        setupBackgroundView()
        
        // logo
        logoView.contentMode = .scaleAspectFit
        logoView.image = UIImage(named: "splitzLogo")
      
        view.addSubview(logoView)
        logoView.translatesAutoresizingMaskIntoConstraints = false
        logoView.widthAnchor.constraint(equalToConstant: 29.32).isActive = true
        logoView.heightAnchor.constraint(equalToConstant: 55).isActive = true
        logoView.centerXAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 35).isActive = true
        logoView.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor).isActive = true
        
        // splitz name
        appName.text = "Splitz"
        appName.frame = CGRect(x: 0, y: 0, width: 38.25, height: 20.4)
        appName.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        appName.font = UIFont.systemFont(ofSize: 14.5, weight: .medium)
        
        
        view.addSubview(appName)
        appName.translatesAutoresizingMaskIntoConstraints = false
        appName.heightAnchor.constraint(equalToConstant: 20.4).isActive = true
        appName.leadingAnchor.constraint(equalTo: logoView.trailingAnchor, constant: 8).isActive = true
        appName.centerYAnchor.constraint(equalTo: logoView.centerYAnchor).isActive = true
        
        // bill name
        billTitle.frame = CGRect(x: 0, y: 0, width: 154.4, height: 34.2)
        billTitle.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        billTitle.font = UIFont(name: ".NewYorkLarge-Bold", size: 32)
        billTitle.text = "Add Your Bill Title"
        billTitle.placeholder = "Bill Title"
        billTitle.borderStyle = .none
        
        view.addSubview(billTitle)
        billTitle.translatesAutoresizingMaskIntoConstraints = false
        
  
        billTitle.topAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: 30).isActive = true
        billTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32).isActive = true
        
        //subtext
        amount.text = "AMOUNT"
        amount.frame = CGRect(x: 0, y: 0, width: 63.52, height: 16)
        amount.textColor = UIColor(red: 0.557, green: 0.557, blue: 0.576, alpha: 1)
        amount.font = UIFont.systemFont(ofSize: 12.7, weight: .regular)
        
        view.addSubview(amount)
        amount.translatesAutoresizingMaskIntoConstraints = false
        amount.topAnchor.constraint(equalTo: billTitle.bottomAnchor, constant: 30).isActive = true
        amount.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 47).isActive = true
        
        //splitby
        splitBy.text = "SPLIT BY"
        splitBy.frame = CGRect(x: 0, y: 0, width: 63.52, height: 16)
        splitBy.textColor = UIColor(red: 0.557, green: 0.557, blue: 0.576, alpha: 1)
        splitBy.font = UIFont.systemFont(ofSize: 12.7, weight: .regular)
        
        view.addSubview(splitBy)
        splitBy.translatesAutoresizingMaskIntoConstraints = false
        splitBy.topAnchor.constraint(equalTo: billTitle.bottomAnchor, constant: 30).isActive = true
        splitBy.leadingAnchor.constraint(equalTo: amount.leadingAnchor, constant: 170).isActive = true
        //text field
        view.addSubview(numField)
        numField.translatesAutoresizingMaskIntoConstraints = false
        numField.heightAnchor.constraint(equalToConstant: 35).isActive = true
        numField.topAnchor.constraint(equalTo: amount.bottomAnchor, constant: 8).isActive = true
        numField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32).isActive = true
        numField.addTarget(self, action: #selector(amountChanged), for: .editingChanged)

        //percent
        percent.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        percent.layer.cornerRadius = 5
        percent.setTitle("%", for: .normal)
        percent.setTitleColor(UIColor(red: 0.557, green: 0.557, blue: 0.576, alpha: 1), for: .normal)
        percent.titleLabel?.font = UIFont.systemFont(ofSize: 16)

            // pressed state
        percent.addTarget(self, action: #selector(toggleButton), for: .touchUpInside)

        view.addSubview(percent)
        percent.translatesAutoresizingMaskIntoConstraints = false
        percent.widthAnchor.constraint(equalToConstant: 44.95).isActive = true

        percent.heightAnchor.constraint(equalToConstant: 35).isActive = true
        percent.topAnchor.constraint(equalTo: splitBy.bottomAnchor, constant: 8).isActive = true
        percent.leadingAnchor.constraint(equalTo: numField.leadingAnchor, constant: 170).isActive = true
        
        //dollar
        dollarSelect.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        dollarSelect.layer.cornerRadius = 5
        dollarSelect.setTitle("$", for: .normal)
        dollarSelect.setTitleColor(UIColor(red: 0.557, green: 0.557, blue: 0.576, alpha: 1), for: .normal)
        dollarSelect.titleLabel?.font = UIFont.systemFont(ofSize: 16)

            // pressed state
        dollarSelect.addTarget(self, action: #selector(toggleButton2), for: .touchUpInside)

        view.addSubview(dollarSelect)
        dollarSelect.translatesAutoresizingMaskIntoConstraints = false
        dollarSelect.widthAnchor.constraint(equalToConstant: 44.95).isActive = true

        dollarSelect.heightAnchor.constraint(equalToConstant: 35).isActive = true
        dollarSelect.topAnchor.constraint(equalTo: splitBy.bottomAnchor, constant: 8).isActive = true
        dollarSelect.leadingAnchor.constraint(equalTo: percent.leadingAnchor, constant: 60).isActive = true
        
        //equal
        equal.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        equal.layer.cornerRadius = 5
        equal.setTitle("=", for: .normal)
        equal.setTitleColor(UIColor(red: 0.557, green: 0.557, blue: 0.576, alpha: 1), for: .normal)
        equal.titleLabel?.font = UIFont.systemFont(ofSize: 16)

            // pressed state
        equal.addTarget(self, action: #selector(toggleButton3), for: .touchUpInside)

        view.addSubview(equal)
        equal.translatesAutoresizingMaskIntoConstraints = false
        equal.widthAnchor.constraint(equalToConstant: 44.95).isActive = true

        equal.heightAnchor.constraint(equalToConstant: 35).isActive = true
        equal.topAnchor.constraint(equalTo: splitBy.bottomAnchor, constant: 8).isActive = true
        equal.leadingAnchor.constraint(equalTo: dollarSelect.leadingAnchor, constant: 60).isActive = true
        setInitialToggleState()
        
        // send button
       
        send.frame = CGRect(x: 0, y: 0, width: 334.22, height: 51.79)
        send.layer.backgroundColor = UIColor(red: 0, green: 0.533, blue: 1, alpha: 1).cgColor
        send.layer.cornerRadius = 20
        send.setTitle("Send Split", for: .normal)
        send.setTitleColor(UIColor.white, for: .normal)
        send.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        view.addSubview(send)
        send.translatesAutoresizingMaskIntoConstraints = false
        
        var config = UIButton.Configuration.filled()
        config.title = "Send Split"
        config.image = UIImage(systemName: "arrow.up",   withConfiguration: UIImage.SymbolConfiguration(pointSize: 12, weight: .medium))
        config.imagePlacement = .leading  // on left
        config.imagePadding = 12  // text and arrow spacing
        config.baseBackgroundColor = UIColor(red: 0, green: 0.533, blue: 1, alpha: 1)
        config.baseForegroundColor = UIColor.white
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 16)
            return outgoing
        }

        send.configuration = config
        
        send.widthAnchor.constraint(equalToConstant: 334.22).isActive = true

        send.heightAnchor.constraint(equalToConstant: 51.79).isActive = true
        send.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        send.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        
        // ADD SEND BUTTON ACTION
        send.addTarget(self, action: #selector(sendSplitPressed), for: .touchUpInside)

        
        people.text = "PEOPLE"
        people.textColor = UIColor(red: 0.557, green: 0.557, blue: 0.576, alpha: 1)
        people.font = UIFont.systemFont(ofSize: 12.7, weight: .regular)
        
        view.addSubview(people)
        people.translatesAutoresizingMaskIntoConstraints = false
        people.topAnchor.constraint(equalTo: numField.bottomAnchor, constant: 32).isActive = true
        people.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 47).isActive = true

        //PeopleListViewController
        embedPeopleList()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
            tapGesture.cancelsTouchesInView = false
            view.addGestureRecognizer(tapGesture)

    }
    
    
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    private func setInitialToggleState() {
           // Set percent as initially selected
           percent.layer.borderWidth = 3.0
           percent.layer.borderColor = UIColor.black.cgColor
           dollarSelect.layer.borderWidth = 0
           
           // Update the people list to percent mode
           peopleListVC?.updateSplitMode(isDollar: false, isPercent:true, isEqual:true)
       }
    
    private func embedPeopleList() {
        let peopleVC = PeopleListViewController()
        peopleListVC = peopleVC
        addChild(peopleVC)
        view.addSubview(peopleVC.view)
        peopleVC.didMove(toParent: self)
        
        peopleVC.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            peopleVC.view.topAnchor.constraint(equalTo: people.bottomAnchor, constant: 8),
            peopleVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            peopleVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            peopleVC.view.bottomAnchor.constraint(equalTo: send.topAnchor)
        ])
      
        
    }
    
    private func setupBackgroundView() {
           backgroundView = UIView()
           backgroundView.layer.backgroundColor = UIColor(red: 0.463, green: 0.463, blue: 0.502, alpha: 0.12).cgColor
           
           view.addSubview(backgroundView)
           
           backgroundView.translatesAutoresizingMaskIntoConstraints = false
           NSLayoutConstraint.activate([
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                        backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                        
                        backgroundView.heightAnchor.constraint(equalToConstant: 40.07),
                        
                        // under status bar
                        backgroundView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
           ])
       }
    
    
    
    
    
    
    // MARK: - Conversation Handling
    
    
    override func willBecomeActive(with conversation: MSConversation) {
        print("willBecomeActive called")
            print("Selected message exists: \(conversation.selectedMessage != nil)")
            
            if let selectedMessage = conversation.selectedMessage {
                print("Message was tapped - showing tracking view")
                if let url = selectedMessage.url,
                           let messageData = decodeMessageData(from: url) {
                            showPaymentTrackingView(with: messageData, originalMessage: selectedMessage, conversation: conversation)
                        }
            } else {
                print("No selected message - normal creation view")
            }
        // Called when the extension is about to move from the inactive to active state.
        // This will happen when the extension is about to present UI.
        
        // Use this method to configure the extension and restore previously stored state.
    }
    
    override func didResignActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the active to inactive state.
        // This will happen when the user dismisses the extension, changes to a different
        // conversation or quits Messages.
        
        // Use this method to release shared resources, save user data, invalidate timers,
        // and store enough state information to restore your extension to its current state
        // in case it is terminated later.
    }
   
    override func didReceive(_ message: MSMessage, conversation: MSConversation) {
        // Handle received message
        handleReceivedMessage(message, conversation: conversation)
    }
    
    override func didStartSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user taps the send button.
    }
    
    override func didCancelSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user deletes the message without sending it.
    
        // Use this to clean up state related to the deleted message.
    }
    
    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called before the extension transitions to a new presentation style.
    
        // Use this method to prepare for the change in presentation style.
    }
    
    override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called after the extension transitions to a new presentation style.
    
        // Use this method to finalize any behaviors associated with the change in presentation style.
    }
    
    // MARK: - Send Split Functionality
    
    @objc func sendSplitPressed() {
        guard let conversation = activeConversation else { return }
        
        // Validate inputs
        guard let billTitleText = billTitle.text, !billTitleText.isEmpty else {
            showAlert(message: "Please enter a bill title")
            return
        }
        
        guard let amountText = numField.text,
              let totalAmount = Double(amountText),
              totalAmount > 0 else {
            showAlert(message: "Please enter a valid amount")
            return
        }
        
        guard let people = peopleListVC?.people, !people.isEmpty else {
            showAlert(message: "Please add at least one person")
            return
        }
        
        // Determine split mode
        let splitMode: String
        if isPercentSelected {
            splitMode = "percent"
        } else if isDollarSelected {
            splitMode = "dollar"
        } else {
            splitMode = "equal"
        }
        
        // Convert people to PersonSplit with calculated amounts
        var personSplits: [SplitBillMessage.PersonSplit] = []
                        
                for (index, person) in people.enumerated() {
                    let indexPath = IndexPath(row: index, section: 0)
                    var dollarAmount: Double = 0.0
                    
                    // Read the current value from the cell
                    if let cell = peopleListVC?.tableView.cellForRow(at: indexPath) as? PersonTableViewCell,
                       let valueText = cell.percentageTextField.text,
                       let value = Double(valueText) {
                        
                        if isEqualSelected {
                            // Equal split - divide total evenly
                            dollarAmount = totalAmount / Double(people.count)
                        } else if isPercentSelected {
                            // Convert percentage to dollars
                            dollarAmount = (value / 100.0) * totalAmount
                        } else {
                            // Already in dollars
                            dollarAmount = value
                        }
                    } else if isEqualSelected {
                        // Fallback for equal mode if cell isn't visible
                        dollarAmount = totalAmount / Double(people.count)
                    }
                    
                    let split = SplitBillMessage.PersonSplit(
                        name: person.name.isEmpty ? "Person" : person.name,
                        amount: dollarAmount,
                        isPaid: false
                    )
                    personSplits.append(split)
                }
        
        // Create message data
        let messageData = SplitBillMessage(
            billTitle: billTitleText,
            totalAmount: totalAmount,
            people: personSplits,
            splitMode: splitMode
        )
        
        // Create the message
        let layout = MSMessageTemplateLayout()
       // layout.caption = billTitleText
      //  layout.subcaption = String(format: "Total: $%.2f", totalAmount)
      //  layout.trailingCaption = "\(personSplits.count) people"
        
        // Create image for the message
        let image = createMessageImage(for: messageData)
        layout.image = image
        
        // Encode data to URL
        let message = MSMessage()
        message.layout = layout
        
        if let url = encodeMessageData(messageData) {
            message.url = url
        }
        
        // Insert message into conversation
        conversation.insert(message) { error in
            if let error = error {
                print("Error inserting message: \(error)")
            }
        }
    }
    
    private func createMessageImage(for data: SplitBillMessage) -> UIImage {
        let width: CGFloat = 300
        let rowHeight: CGFloat = 50
        let headerHeight: CGFloat = 80
        let height = headerHeight + (CGFloat(data.people.count) * rowHeight) + 20
        
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height))
        
        return renderer.image { context in
            // Background
            UIColor.white.setFill()
            context.fill(CGRect(x: 0, y: 0, width: width, height: height))
            
            // Header
            let headerRect = CGRect(x: 0, y: 0, width: width, height: headerHeight)
            UIColor(red: 0.463, green: 0.463, blue: 0.502, alpha: 0.12).setFill()
            context.fill(headerRect)
            
            // Bill title
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 20, weight: .bold),
                .foregroundColor: UIColor.black
            ]
            let titleString = NSAttributedString(string: data.billTitle, attributes: titleAttributes)
            titleString.draw(at: CGPoint(x: 20, y: 15))
            
            // Total amount
            let amountAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 16, weight: .medium),
                .foregroundColor: UIColor.darkGray
            ]
            let amountString = NSAttributedString(
                string: String(format: "Total: $%.2f", data.totalAmount),
                attributes: amountAttributes
            )
            amountString.draw(at: CGPoint(x: 20, y: 45))
            
            // People list
            var yOffset = headerHeight + 10
            
            for (index, person) in data.people.enumerated() {
                let rowRect = CGRect(x: 10, y: yOffset, width: width - 20, height: rowHeight)
                
                // Alternating row background
                if index % 2 == 0 {
                    UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1).setFill()
                    context.fill(rowRect)
                }
                
                // Checkbox circle
                let circleSize: CGFloat = 24
                let circleRect = CGRect(
                    x: 20,
                    y: yOffset + (rowHeight - circleSize) / 2,
                    width: circleSize,
                    height: circleSize
                )
                
                UIColor.systemBlue.setStroke()
                let circlePath = UIBezierPath(ovalIn: circleRect)
                circlePath.lineWidth = 2
                circlePath.stroke()
                
                if person.isPaid {
                    // Draw checkmark
                    UIColor.systemBlue.setFill()
                    context.fill(circleRect)
                    
                    UIColor.white.setStroke()
                    let checkPath = UIBezierPath()
                    checkPath.move(to: CGPoint(x: circleRect.minX + 6, y: circleRect.midY))
                    checkPath.addLine(to: CGPoint(x: circleRect.midX - 2, y: circleRect.maxY - 8))
                    checkPath.addLine(to: CGPoint(x: circleRect.maxX - 6, y: circleRect.minY + 6))
                    checkPath.lineWidth = 2
                    checkPath.lineCapStyle = .round
                    checkPath.stroke()
                }
                
                // Name
                let nameAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 16, weight: .regular),
                    .foregroundColor: UIColor.black
                ]
                let nameString = NSAttributedString(string: person.name, attributes: nameAttributes)
                nameString.draw(at: CGPoint(x: 55, y: yOffset + 15))
                
                // Amount
                let amountStr = String(format: "$%.2f", person.amount)
                let personAmountAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 16, weight: .semibold),
                    .foregroundColor: UIColor.systemBlue
                ]
                let personAmountString = NSAttributedString(string: amountStr, attributes: personAmountAttributes)
                let amountSize = personAmountString.size()
                personAmountString.draw(at: CGPoint(x: width - amountSize.width - 20, y: yOffset + 15))
                
                yOffset += rowHeight
            }
        }
    }
    
    private func encodeMessageData(_ data: SplitBillMessage) -> URL? {
        guard let jsonData = try? JSONEncoder().encode(data),
              let jsonString = String(data: jsonData, encoding: .utf8),
              let encodedString = jsonString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "splitz.app"
        components.path = "/split"
        components.queryItems = [URLQueryItem(name: "data", value: encodedString)]
        
        return components.url
    }
    
    private func decodeMessageData(from url: URL) -> SplitBillMessage? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems,
              let dataString = queryItems.first(where: { $0.name == "data" })?.value,
              let decodedString = dataString.removingPercentEncoding,
              let jsonData = decodedString.data(using: .utf8),
              let messageData = try? JSONDecoder().decode(SplitBillMessage.self, from: jsonData) else {
            return nil
        }
        
        return messageData
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "cmon dawg", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ur good", style: .default))
        present(alert, animated: true)
    }
    
    // Handle received messages
    func handleReceivedMessage(_ message: MSMessage, conversation: MSConversation) {
        guard let url = message.url,
              let messageData = decodeMessageData(from: url) else {
            return
        }
        
        // Show view for payment view controller people as paid
        showPaymentTrackingView(with: messageData, originalMessage: message,  conversation: conversation)
    }
    
    private func showPaymentTrackingView(with data: SplitBillMessage, originalMessage: MSMessage, conversation: MSConversation) {
        
        // Create and show a view controller for tracking payments
        let trackingVC = PaymentTrackingViewController()
        trackingVC.messageData = data
        trackingVC.originalMessage = originalMessage
        trackingVC.conversation = conversation
        
        addChild(trackingVC)
        view.addSubview(trackingVC.view)
        trackingVC.didMove(toParent: self)
        
        trackingVC.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            trackingVC.view.topAnchor.constraint(equalTo: view.topAnchor),
            trackingVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trackingVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            trackingVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

}

//
//  PaymentTrackingViewController.swift
//  Split
//
//  Created by Shabicha Sureshkumar on 2025-09-30.
//

import UIKit
import Messages

// MARK: - Payment Tracking View Controller
class PaymentTrackingViewController: UIViewController {
    var messageData: SplitBillMessage?
    var originalMessage: MSMessage?
    var conversation: MSConversation?
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let headerView = UIView()
    private let billTitleLabel = UILabel()
    private let totalAmountLabel = UILabel()
    private let updateButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.949, green: 0.949, blue: 0.969, alpha: 1)
        setupUI()
        print("PaymentTrackingViewController loaded")
        print("Message data: \(messageData?.billTitle ?? "nil")")
        print("People count: \(messageData?.people.count ?? 0)")
    }
    
    private func setupUI() {
        // Header with bill info
        headerView.backgroundColor = UIColor(red: 0.463, green: 0.463, blue: 0.502, alpha: 0.12)
        view.addSubview(headerView)
        
        billTitleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        billTitleLabel.text = messageData?.billTitle ?? "Split Bill"
        headerView.addSubview(billTitleLabel)
        
        totalAmountLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        totalAmountLabel.textColor = .darkGray
        if let total = messageData?.totalAmount {
            totalAmountLabel.text = String(format: "Total: $%.2f", total)
        }
        headerView.addSubview(totalAmountLabel)
        
        // Table view for people list
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PaymentTrackingCell.self, forCellReuseIdentifier: "PaymentTrackingCell")
        tableView.backgroundColor = .clear
        view.addSubview(tableView)
        
        // Update button
        updateButton.setTitle("Update Split", for: .normal)
        updateButton.backgroundColor = UIColor(red: 0, green: 0.533, blue: 1, alpha: 1)
        updateButton.layer.cornerRadius = 20
        updateButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        updateButton.addTarget(self, action: #selector(updateSplit), for: .touchUpInside)
        view.addSubview(updateButton)
        
        // Layout
        headerView.translatesAutoresizingMaskIntoConstraints = false
        billTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        totalAmountLabel.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        updateButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 80),
            
            billTitleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 15),
            billTitleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            
            totalAmountLabel.topAnchor.constraint(equalTo: billTitleLabel.bottomAnchor, constant: 5),
            totalAmountLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            
            tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: updateButton.topAnchor, constant: -20),
            
            updateButton.heightAnchor.constraint(equalToConstant: 51.79),
            updateButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            updateButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            updateButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    @objc private func updateSplit() {
        print("updateSplit button tapped")
        
        guard let data = messageData else {
            print("ERROR: No message data")
            showError("No message data available")
            return
        }
        
        guard let message = originalMessage else {
            print("ERROR: No original message")
            showError("No original message found")
            return
        }
        
        guard let conversation = conversation else {
            print("ERROR: No conversation")
            showError("No conversation available")
            return
        }
        
        print("Creating updated message...")
        print("Paid count: \(data.people.filter { $0.isPaid }.count)/\(data.people.count)")
        
        // Create the message layout
        let layout = MSMessageTemplateLayout()
        layout.caption = data.billTitle
        layout.subcaption = String(format: "Total: $%.2f", data.totalAmount)
        
        let paidCount = data.people.filter { $0.isPaid }.count
        layout.trailingCaption = "\(paidCount)/\(data.people.count) paid"
        
        // Create updated image
        let image = createUpdatedMessageImage(for: data)
        layout.image = image
        
        // Create message with same session
        let updatedMessage = MSMessage(session: message.session ?? MSSession())
        updatedMessage.layout = layout
        
        // Encode data into URL
        if let url = encodeMessageData(data) {
            print("Encoded URL: \(url.absoluteString.prefix(100))...")
            updatedMessage.url = url
        } else {
            print("ERROR: Failed to encode message data")
            showError("Failed to encode message")
            return
        }
        
        // Send the message
        print("Inserting message into conversation...")
        conversation.insert(updatedMessage) { error in
            if let error = error {
                print("ERROR inserting message: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.showError("Failed to send: \(error.localizedDescription)")
                }
            } else {
                print("SUCCESS: Message sent!")
                DispatchQueue.main.async {
                    // Optional: Show success feedback
                    self.updateButton.setTitle("Sent!", for: .normal)
                    self.updateButton.backgroundColor = .systemGreen
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.updateButton.setTitle("Update Split", for: .normal)
                        self.updateButton.backgroundColor = UIColor(red: 0, green: 0.533, blue: 1, alpha: 1)
                    }
                }
            }
        }
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func createUpdatedMessageImage(for data: SplitBillMessage) -> UIImage {
        let width: CGFloat = 250
        let rowHeight: CGFloat = 40
        let headerHeight: CGFloat = 60
        let maxPeople = min(data.people.count, 5)
        let height = headerHeight + (CGFloat(maxPeople) * rowHeight) + 20
        
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height))
        
        return renderer.image { context in
            // Background
            UIColor.white.setFill()
            context.fill(CGRect(x: 0, y: 0, width: width, height: height))
            
            // Header
            let headerRect = CGRect(x: 0, y: 0, width: width, height: headerHeight)
            UIColor(red: 0.463, green: 0.463, blue: 0.502, alpha: 0.12).setFill()
            context.fill(headerRect)
            
            // Title
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 18, weight: .bold),
                .foregroundColor: UIColor.black
            ]
            NSAttributedString(string: data.billTitle, attributes: titleAttributes).draw(at: CGPoint(x: 15, y: 10))
            
            // Total
            let amountAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14, weight: .medium),
                .foregroundColor: UIColor.darkGray
            ]
            NSAttributedString(string: String(format: "Total: $%.2f", data.totalAmount), attributes: amountAttributes).draw(at: CGPoint(x: 15, y: 35))
            
            // People list
            var yOffset = headerHeight + 10
            
            for (index, person) in data.people.prefix(maxPeople).enumerated() {
                let rowRect = CGRect(x: 10, y: yOffset, width: width - 20, height: rowHeight)
                
                // Alternating background
                if index % 2 == 0 {
                    UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1).setFill()
                    context.fill(rowRect)
                }
                
                // Circle checkbox
                let circleSize: CGFloat = 20
                let circleRect = CGRect(x: 15, y: yOffset + (rowHeight - circleSize) / 2, width: circleSize, height: circleSize)
                
                if person.isPaid {
                    // Filled green circle with checkmark
                    UIColor.systemGreen.setFill()
                    context.fill(circleRect)
                    
                    UIColor.white.setStroke()
                    let checkPath = UIBezierPath()
                    checkPath.move(to: CGPoint(x: circleRect.minX + 5, y: circleRect.midY))
                    checkPath.addLine(to: CGPoint(x: circleRect.midX - 1, y: circleRect.maxY - 6))
                    checkPath.addLine(to: CGPoint(x: circleRect.maxX - 5, y: circleRect.minY + 5))
                    checkPath.lineWidth = 2
                    checkPath.lineCapStyle = .round
                    checkPath.stroke()
                } else {
                    // Empty blue circle
                    UIColor.systemBlue.setStroke()
                    let circlePath = UIBezierPath(ovalIn: circleRect)
                    circlePath.lineWidth = 2
                    circlePath.stroke()
                }
                
                // Name
                let nameAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 14, weight: .regular),
                    .foregroundColor: person.isPaid ? UIColor.lightGray : UIColor.black
                ]
                NSAttributedString(string: person.name, attributes: nameAttributes).draw(at: CGPoint(x: 45, y: yOffset + 12))
                
                // Amount
                let amountStr = String(format: "$%.2f", person.amount)
                let personAmountAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 14, weight: .semibold),
                    .foregroundColor: person.isPaid ? UIColor.systemGreen : UIColor.systemBlue
                ]
                let personAmountString = NSAttributedString(string: amountStr, attributes: personAmountAttributes)
                let amountSize = personAmountString.size()
                personAmountString.draw(at: CGPoint(x: width - amountSize.width - 15, y: yOffset + 12))
                
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
}

// MARK: - Table View Data Source & Delegate
extension PaymentTrackingViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = messageData?.people.count ?? 0
        print("Table view showing \(count) rows")
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentTrackingCell", for: indexPath) as! PaymentTrackingCell
        
        if let person = messageData?.people[indexPath.row] {
            print("Configuring cell for \(person.name) - isPaid: \(person.isPaid)")
            cell.configure(with: person)
            
            // Handle toggle
            cell.onTogglePaid = { [weak self] in
                self?.messageData?.people[indexPath.row].isPaid.toggle()
                if let updatedPerson = self?.messageData?.people[indexPath.row] {
                    print("Toggled \(updatedPerson.name) to isPaid: \(updatedPerson.isPaid)")
                    cell.configure(with: updatedPerson)
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

// MARK: - Payment Tracking Cell
class PaymentTrackingCell: UITableViewCell {
    private let nameLabel = UILabel()
    private let amountLabel = UILabel()
    private let checkButton = UIButton()
    
    var onTogglePaid: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        
        // Checkbox button
        checkButton.setImage(UIImage(systemName: "circle"), for: .normal)
        checkButton.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .selected)
        checkButton.tintColor = .systemBlue
        checkButton.addTarget(self, action: #selector(togglePressed), for: .touchUpInside)
        
        // Name label
        nameLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        nameLabel.textColor = .black
        
        // Amount label
        amountLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        amountLabel.textColor = .systemBlue
        
        contentView.addSubview(checkButton)
        contentView.addSubview(nameLabel)
        contentView.addSubview(amountLabel)
        
        checkButton.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            checkButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            checkButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkButton.widthAnchor.constraint(equalToConstant: 30),
            checkButton.heightAnchor.constraint(equalToConstant: 30),
            
            nameLabel.leadingAnchor.constraint(equalTo: checkButton.trailingAnchor, constant: 16),
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: amountLabel.leadingAnchor, constant: -16),
            
            amountLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            amountLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            amountLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 60)
        ])
    }
    
    func configure(with person: SplitBillMessage.PersonSplit) {
        nameLabel.text = person.name
        amountLabel.text = String(format: "$%.2f", person.amount)
        checkButton.isSelected = person.isPaid
        
        // Visual states
        if person.isPaid {
            nameLabel.textColor = .lightGray
            amountLabel.textColor = .systemGreen
            checkButton.tintColor = .systemGreen
        } else {
            nameLabel.textColor = .black
            amountLabel.textColor = .systemBlue
            checkButton.tintColor = .systemBlue
        }
    }
    
    @objc private func togglePressed() {
        print("Cell checkbox tapped")
        onTogglePaid?()
    }
}

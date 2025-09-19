//
//  PeopleListViewController.swift
//  Split
//
//  Created by Shabicha Sureshkumar on 2025-09-18.
//

import UIKit
// cell model
struct Person {
    var name: String
    var percentage: Int
}

// MARK: - Person Cell
class PersonTableViewCell: UITableViewCell {
    static let identifier = "PersonTableViewCell"
    
    private let nameTextField = UITextField()
    private let percentageTextField = UITextField()
    private let removeButton = UIButton()
    private let containerView = UIView()
    private let percentLabel = UILabel()
    private var totalAmount: Double = 0.0
    private var dollarMode:Bool = false
    private let dollarLabel = UILabel()

    var onPercentageChanged: ((Int) -> Void)?
    var onRemovePressed: (() -> Void)?
    var onNameChanged: ((String) -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        selectionStyle = .none
        
       

        // Name label
        nameTextField.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        nameTextField.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        nameTextField.keyboardType = .default
        nameTextField.addTarget(self, action: #selector(nameChanged), for: .editingChanged)
        nameTextField.placeholder = "Enter Name"
        
        // Percentage text field
        percentageTextField.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        percentageTextField.textColor = .systemBlue
        percentageTextField.textAlignment = .center
        percentageTextField.keyboardType = .decimalPad
        percentageTextField.borderStyle = .roundedRect
        percentageTextField.backgroundColor = UIColor(red: 0.948, green: 0.948, blue: 0.948, alpha: 1)
        percentageTextField.placeholder = "0" //change for dollar
        percentageTextField.layer.borderColor = UIColor.systemBlue.cgColor
        percentageTextField.layer.borderWidth = 1
        percentageTextField.layer.cornerRadius = 5.86
        percentageTextField.addTarget(self, action: #selector(percentageChanged), for: .editingChanged)
        
        percentLabel.text = "%   " // change for dollar
        percentLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            percentLabel.textColor = .systemBlue
            percentLabel.sizeToFit()
        
        percentageTextField.rightView = percentLabel
        
        percentageTextField.rightViewMode = .always
        // Remove button
        removeButton.setImage(UIImage(systemName: "minus.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 22, weight: .regular)), for: .normal)
        removeButton.tintColor = .systemRed
        removeButton.addTarget(self, action: #selector(removePressed), for: .touchUpInside)
        
        //constraints
        contentView.addSubview(nameTextField)
                contentView.addSubview(percentageTextField)
                contentView.addSubview(removeButton)
                
                
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
                percentageTextField.translatesAutoresizingMaskIntoConstraints = false
                removeButton.translatesAutoresizingMaskIntoConstraints = false
                
                NSLayoutConstraint.activate([
                    nameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
                    nameTextField.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                    nameTextField.trailingAnchor.constraint(lessThanOrEqualTo: percentageTextField.leadingAnchor, constant: -16),
                    
                    percentageTextField.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                    percentageTextField.widthAnchor.constraint(equalToConstant: 80),
                    percentageTextField.heightAnchor.constraint(equalToConstant: 36),
                    
                    removeButton.leadingAnchor.constraint(equalTo: percentageTextField.trailingAnchor, constant: 16),
                    removeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                    removeButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                    removeButton.widthAnchor.constraint(equalToConstant: 30),
                    removeButton.heightAnchor.constraint(equalToConstant: 30)
                ])
            }
    
    
    func configure(with person: Person,  totalAmount: Double) {
        self.totalAmount = totalAmount

        nameTextField.text = person.name
            percentageTextField.text = (person.percentage) == 0 ? "" : "\(person.percentage)"
        }
    func switchToDollarMode() {
           percentageTextField.placeholder = "0.00"
           percentLabel.text = "  $"
           percentageTextField.keyboardType = .decimalPad
        
        percentageTextField.leftView = percentLabel
            percentageTextField.leftViewMode = .always
            percentageTextField.rightView = nil
            percentageTextField.rightViewMode = .never
        
        if let currentText = percentageTextField.text,
              let percentage = Double(currentText),
              percentage > 0,
              totalAmount > 0,
           dollarMode == false {
            
               let dollarAmount = (Double(percentage) / 100.0) * totalAmount
               percentageTextField.text = String(format: "%.2f", dollarAmount)
            
        } else if let currentText = percentageTextField.text,
                  let percentage = Double(currentText),
                  percentage > 0,
                  totalAmount > 0,
               dollarMode == true {
            percentageTextField.text = String(format: "%.2f", percentage)
            
        }
       }
       
       func switchToPercentMode() {
           percentageTextField.placeholder = "0"
           percentLabel.text = "%   "
           percentageTextField.keyboardType = .decimalPad
           
           percentageTextField.rightView = percentLabel
               percentageTextField.rightViewMode = .always
               percentageTextField.leftView = nil
               percentageTextField.leftViewMode = .never
           
           if let currentText = percentageTextField.text,
                  let dollarAmount = Double(currentText),
                  dollarAmount > 0,
                  totalAmount > 0 {
                  dollarMode = false
                   let percentage = Double((dollarAmount / totalAmount) * 100)
                   percentageTextField.text = String(format: "%.2f", percentage)
               }
           
       }
    
    func switchToEqualMode(numberOfPeople: Int) {
        percentageTextField.placeholder = "0.00"
        percentLabel.text = "  $"
        percentageTextField.keyboardType = .decimalPad
     
     percentageTextField.leftView = percentLabel
         percentageTextField.leftViewMode = .always
         percentageTextField.rightView = nil
         percentageTextField.rightViewMode = .never
     
    if totalAmount > 0 {
         let count = max(numberOfPeople, 1) // prevent divide by zero
         let dollarAmount = totalAmount / Double(count)
         dollarMode = true
         percentageTextField.text = String(format: "%.2f", dollarAmount)
     }
        
    }
    
        @objc private func percentageChanged() {
            guard let text = percentageTextField.text,
                  let percentage = Int(text),
                  percentage >= 0, percentage <= 100 else {
                return
            }
            onPercentageChanged?(percentage)
        }
        
        @objc private func removePressed() {
            onRemovePressed?()
        }
    @objc private func nameChanged() {
        onNameChanged?(nameTextField.text ?? "Enter Name")
    }
    
    }
// MARK: - Add People Cell
class AddPeopleTableViewCell: UITableViewCell {
    static let identifier = "AddPeopleTableViewCell"
    
    private let addButton = UIButton()
    var onAddPressed: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        selectionStyle = .none
        overrideUserInterfaceStyle = .light
        
        addButton.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        addButton.tintColor = .systemBlue
            addButton.contentHorizontalAlignment = .left
        
        addButton.setTitle("     Add People", for: .normal)
        addButton.setTitleColor(.systemBlue, for: .normal)
        addButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        addButton.contentHorizontalAlignment = .left
        addButton.addTarget(self, action: #selector(addPressed), for: .touchUpInside)
        
        contentView.addSubview(addButton)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            addButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            addButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            addButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            addButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    @objc private func addPressed() {
        onAddPressed?()
    }
}

// Main View Controller
class PeopleListViewController: UIViewController {
    
    // insetGrouped == rounded style + padding
    let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: 10, height: 100), style: .insetGrouped)
    let containerView = UIView()
    private var totalAmount: Double = 0.0
    private var isDollarMode = false
    private var isPercentMode = true
    private var isEqualMode = false
    
    private var people: [Person] = [
        Person(name: "Shabicha", percentage: 100),
        Person(name: "Shabicha", percentage: 20),
        Person(name: "Shabicha", percentage: 53)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.949, green: 0.949, blue: 0.969, alpha: 1)
        setupUI()
        setupTableView()
    }
    private func setupUI() {
            overrideUserInterfaceStyle = .light
            view.backgroundColor = .systemGroupedBackground
        
            navigationController?.navigationBar.prefersLargeTitles = false
            navigationItem.largeTitleDisplayMode = .never
            
        
            view.addSubview(tableView)
        
            tableView.translatesAutoresizingMaskIntoConstraints = false
        
        
            NSLayoutConstraint.activate([
                tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
                       tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                       tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                       tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -32)
            ])
        }
    private func setupTableView() {
        
            tableView.delegate = self
            tableView.dataSource = self
        tableView.bounces = false
           tableView.alwaysBounceVertical = false
        
            tableView.overrideUserInterfaceStyle = .light
            tableView.backgroundColor = .systemGroupedBackground
            tableView.separatorStyle = .singleLine
            tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
            tableView.rowHeight = 200
            
            tableView.register(PersonTableViewCell.self, forCellReuseIdentifier: PersonTableViewCell.identifier)
            tableView.register(AddPeopleTableViewCell.self, forCellReuseIdentifier: AddPeopleTableViewCell.identifier)
        }
    
    func updateSplitMode(isDollar: Bool, isPercent:Bool, isEqual:Bool) {
            isDollarMode = isDollar
            isPercentMode = isPercent
            isEqualMode = isEqual
        
            // Update all visible cells
            for indexPath in tableView.indexPathsForVisibleRows ?? [] {
                if indexPath.row < people.count,
                   let cell = tableView.cellForRow(at: indexPath) as? PersonTableViewCell {
                    
                    if isDollarMode {
                        cell.switchToDollarMode()
                    } else if isPercentMode {
                        cell.switchToPercentMode()
                    } else if isEqualMode {
                        cell.switchToEqualMode(numberOfPeople: people.count)
                    }
                    
                }
            }
        }
    
    private func addNewPerson() {
            let newPerson = Person(name: "", percentage: 0)
            people.append(newPerson)
            
            let indexPath = IndexPath(row: people.count - 1, section: 0)
            tableView.insertRows(at: [indexPath], with: .automatic)
        }
        
        private func removePerson(at index: Int) {
            people.remove(at: index)
            let indexPath = IndexPath(row: index, section: 0)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        private func updatePersonPercentage(at index: Int, percentage: Int) {
            people[index].percentage = percentage
        }
    private func updatePersonName(at index: Int, name: String) {
        people[index].name = name
    }
    }

// MARK: - Table View Data Source & Delegate
extension PeopleListViewController: UITableViewDataSource, UITableViewDelegate {
    func updateTotalAmount(_ amount: Double) {
        totalAmount = amount
        
        // Refresh visible cells with new total
        for indexPath in tableView.indexPathsForVisibleRows ?? [] {
            if indexPath.row < people.count,
               let cell = tableView.cellForRow(at: indexPath) as? PersonTableViewCell {
                let person = people[indexPath.row]
                cell.configure(with: person, totalAmount: totalAmount)
            }
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return people.count + 1 // +1 for the "Add People" cell
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            if indexPath.row < people.count {
                let cell = tableView.dequeueReusableCell(withIdentifier: PersonTableViewCell.identifier, for: indexPath) as! PersonTableViewCell
                let person = people[indexPath.row]
                cell.configure(with: person, totalAmount: totalAmount)
                
                if isDollarMode {
                    cell.switchToDollarMode()
                } else if isPercentMode {
                    cell.switchToPercentMode()
                } else if isEqualMode {
                    cell.switchToEqualMode(numberOfPeople: people.count)
                }
                // Capture cell dynamically instead of using stale indexPath
                cell.onPercentageChanged = { [weak self, weak tableView, weak cell] percentage in
                    guard let self = self, let cell = cell, let currentIndexPath = tableView?.indexPath(for: cell) else { return }
                    self.updatePersonPercentage(at: currentIndexPath.row, percentage: percentage)
                }
                
                cell.onRemovePressed = { [weak self, weak tableView, weak cell] in
                    guard let self = self, let cell = cell, let currentIndexPath = tableView?.indexPath(for: cell) else { return }
                    
                    // Prevent removing last person
                    guard self.people.count > 1 else { return }
                    
                    self.removePerson(at: currentIndexPath.row)
                }
                
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: AddPeopleTableViewCell.identifier, for: indexPath) as! AddPeopleTableViewCell
                
                cell.onAddPressed = { [weak self] in
                    self?.addNewPerson()
                }
                
                return cell
            }
        }

        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 60
        }
    }


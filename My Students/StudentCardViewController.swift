//
//  StudentCardViewController.swift
//  My Students
//
//  Created by Марк Кулик on 24.06.2024.
//

import UIKit
import SwiftUI
import Combine
import Photos
import RealmSwift

protocol StudentCardDelegate: AnyObject {
    func didSaveStudent()
}

enum EditMode {
    case add
    case edit
}

class StudentCardViewController: UIViewController {
    
    @ObservedObject var viewModel: StudentViewModel
    var student: Student?
    var editMode: EditMode
    weak var delegate: StudentCardDelegate?
    
    // Настройка UI и переменных
    
    init(viewModel: StudentViewModel, editMode: EditMode, delegate: StudentCardDelegate?) {
        self.viewModel = viewModel
        self.editMode = editMode
        super.init(nibName: nil, bundle: nil)
        self.delegate = delegate
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Properties
    // Add a segmented control for student type
    let studentTypeSegmentedControl: UISegmentedControl = {
        let items = ["Schoolchild", "Adult"]
        let control = UISegmentedControl(items: items)
        control.selectedSegmentIndex = 0
        return control
    }()
    
    var selectedSchedules = [(weekday: String, time: String)]()
    var selectedImage: UIImage?
    
    let scrollView = UIScrollView()
    let studentNameTextField = UITextField()
    let studentNameLabel = UILabel()
    let parentNameTextField = UITextField()
    let parentNameLabel = UILabel()
    let phoneTextField = UITextField()
    let phoneLabel = UILabel()
    let lessonPriceLabel = UILabel()
    let lessonPriceTextField = UITextField()
    let currencyLabel = UILabel()
    let currencyTextField = UITextField()
    let scheduleTextField = UITextField()
    let scheduleLabel = UILabel()
    
    var imageButton = UIButton(type: .system)
    
    let imagePicker = UIImagePickerController()
    
    var lessonPriceValue: Double?
    var enteredPrice: Double?
    var enteredCurrency: String?
    
    // MARK: - View Lifecycle
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        updateScheduleTextField()
        
        // Повторно проверяем выбранный индекс и скрываем поля, если необходимо
        if studentTypeSegmentedControl.selectedSegmentIndex != 0 {
            parentNameLabel.isHidden = true
            parentNameTextField.isHidden = true
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateScheduleTextField()
        self.title = editMode == .add ? "Add Student" : "Edit Student"
        //        // Заменяем кнопку "Back" на кастомную кнопку
        //        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backButtonTapped))
        //        navigationItem.leftBarButtonItem = backButton
        
        let saveButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveButtonTapped))
        navigationItem.rightBarButtonItem = saveButton
        
        //        // Добавляем жест для скрытия клавиатуры при тапе вне текстовых полей
        //        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboardOnTap))
        //        view.addGestureRecognizer(tapGesture)
        
        // Добавляем обработчик изменений в UISegmentedControl
        studentTypeSegmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
        
        // Повторно проверяем выбранный индекс и скрываем поля, если необходимо
        if studentTypeSegmentedControl.selectedSegmentIndex != 0 {
            parentNameLabel.isHidden = true
            parentNameTextField.isHidden = true
        }
        
    }
    
    // Метод для обработки изменений в UISegmentedControl
    @objc private func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        // Проверяем выбранный индекс и скрываем или отображаем соответствующие поля
        switch sender.selectedSegmentIndex {
        case 0:
            parentNameLabel.isHidden = false
            parentNameTextField.isHidden = false
        case 1:
            parentNameLabel.isHidden = true
            parentNameTextField.isHidden = true
        default:
            break
        }
    }
    
    @objc internal func saveButtonTapped() {
        view.endEditing(true)
        
        if let existingStudent = student {
            saveStudent(existingStudent, mode: .edit)
        } else {
            saveStudent(nil, mode: .add)
        }
        
        navigationController?.popViewController(animated: true)
        delegate?.didSaveStudent()
        
        viewModel.fetchStudents()
        
    }
    
    private func saveStudent(_ existingStudent: Student?, mode: EditMode) {
        do {
            let realm = try Realm()
            try realm.write {
                let student: Student
                if let existingStudent = existingStudent {
                    student = existingStudent
                } else {
                    student = Student()
                    student.id = UUID().uuidString // Set the primary key only for new objects
                }
                
                let studentTypeIndex = studentTypeSegmentedControl.selectedSegmentIndex
                let studentType: StudentType = studentTypeIndex == 0 ? .schoolchild : .adult
                
                guard let studentName = studentNameTextField.text, !studentName.isEmpty else {
                    displayErrorAlert(message: "Student's name cannot be empty")
                    return
                }
                
                guard studentType == .adult || !parentNameTextField.text!.isEmpty else {
                    displayErrorAlert(message: "Parent's name cannot be empty for schoolchildren")
                    return
                }
                
                let parentName = studentType == .adult ? "" : parentNameTextField.text!
                
                guard let phoneNumber = phoneTextField.text, !phoneNumber.isEmpty else {
                    displayErrorAlert(message: "Phone number cannot be empty")
                    return
                }
                
                guard let lessonPriceText = lessonPriceTextField.text, !lessonPriceText.isEmpty else {
                    displayErrorAlert(message: "Please enter a valid lesson price")
                    return
                }
                
                let formattedLessonPriceText = lessonPriceText.replacingOccurrences(of: ",", with: ".")
                guard let lessonPriceValue = Double(formattedLessonPriceText) else {
                    displayErrorAlert(message: "Invalid lesson price")
                    return
                }
                
                guard let currency = currencyTextField.text, !currency.isEmpty else {
                    displayErrorAlert(message: "Currency cannot be empty")
                    return
                }
                
                let newLessonPrice = LessonPrice()
                newLessonPrice.price = lessonPriceValue
                newLessonPrice.currency = currency
                
                
                // Handle schedules based on edit mode and student type
                if mode == .edit {
                    // Remove existing schedules only if switching from schoolchild to adult
                    if existingStudent?.type == StudentType.schoolchild.rawValue && studentType == .adult {
                        // Do nothing with schedules here, as we won't remove them
                    }
                } else {
                    // Clear schedules for new student or when switching from adult to schoolchild
                    student.schedule.removeAll()
                }
                
                // Add new schedules if switching to schoolchild and there are selected schedules
                if studentType == .schoolchild && !selectedSchedules.isEmpty {
                    for (weekday, time) in selectedSchedules {
                        let newSchedule = Schedule()
                        newSchedule.weekday = weekday
                        newSchedule.time = time
                        student.schedule.append(newSchedule)
                    }
                }
                
                student.name = studentName
                student.parentName = parentName
                student.phoneNumber = phoneNumber
                student.lessonPrice = newLessonPrice
                student.type = studentType.rawValue
                if let selectedImage = selectedImage {
                    student.imageForCellData = selectedImage.pngData()
                } else {
                    student.imageForCellData = existingStudent?.imageForCellData
                }
                
                // Add or update the student in the realm
                realm.add(student, update: .modified)
            }
        } catch {
            displayErrorAlert(message: "Failed to save student: \(error.localizedDescription)")
        }
    }
    
    private func displayErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

extension StudentCardViewController {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        switch textField {
        case lessonPriceTextField:
            let currentText = textField.text ?? ""
            if currentText.contains(",") && string.contains(",") {
                return false
            }
            let allowedCharacters = CharacterSet(charactersIn: "0123456789,")
            if string.rangeOfCharacter(from: allowedCharacters.inverted) != nil {
                return false
            }
        case studentNameTextField, parentNameTextField, currencyTextField:
            let allowedCharacters = CharacterSet.letters
            if string.rangeOfCharacter(from: allowedCharacters.inverted) != nil {
                return false
            }
        case phoneTextField:
            let allowedCharacters = CharacterSet(charactersIn: "+0123456789")
            if string.rangeOfCharacter(from: allowedCharacters.inverted) != nil {
                return false
            }
        default:
            break
        }
        
        return true
    }
}

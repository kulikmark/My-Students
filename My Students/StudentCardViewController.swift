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


enum EditMode {
    case add
    case edit
}

class StudentCardViewController: UIViewController {
    
    @ObservedObject var viewModel: StudentViewModel
    private var cancellables = Set<AnyCancellable>()
    
    var student: Student?
    var editMode: EditMode
    
    init(viewModel: StudentViewModel, editMode: EditMode) {
        self.viewModel = viewModel
        self.editMode = editMode
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let studentTypeSegmentedControl: UISegmentedControl = {
        let items = ["Schoolchild", "Adult"]
        let control = UISegmentedControl(items: items)
        control.selectedSegmentIndex = 0
        return control
    }()
    
    var selectedSchedules = [(weekday: String, time: String)]()
    var selectedImage: UIImage?
    var imageIsChanged = false
    
    var scheduleItems: [Schedule] = []
    
    var scheduleCollectionView: UICollectionView!
    let addScheduleButton = UIButton()
    var weekdayTextField: UITextField!
    var timeTextField: UITextField!
    
    
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
    
    var profileImageView = UIImageView()
    
    var lessonPriceValue: Double?
    var enteredPrice: Double?
    var enteredCurrency: String?
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        updateScheduleTextField()
        if studentTypeSegmentedControl.selectedSegmentIndex != 0 {
            parentNameLabel.isHidden = true
            parentNameTextField.isHidden = true
        }
        scheduleCollectionView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.$students
            .receive(on: RunLoop.main)
            .sink { [weak self] students in
                self?.scheduleCollectionView.reloadData()
            }
            .store(in: &cancellables)
        
        setupUI()
        scheduleCollectionView.reloadData()
//        updateScheduleTextField()
        self.title = editMode == .add ? "Add Student" : "Edit Student"
        let saveButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveButtonTapped))
        navigationItem.rightBarButtonItem = saveButton
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboardOnTap))
        view.addGestureRecognizer(tapGesture)
        studentTypeSegmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
        if studentTypeSegmentedControl.selectedSegmentIndex != 0 {
            parentNameLabel.isHidden = true
            parentNameTextField.isHidden = true
        }
        
        // Инициализация scheduleItems данными из студента
           if let student = student {
               scheduleItems = Array(student.schedule)
               scheduleCollectionView.reloadData()
           }
    }
    
    @objc private func hideKeyboardOnTap() {
        view.endEditing(true)
    }
    
    @objc private func segmentedControlValueChanged(_ sender: UISegmentedControl) {
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
    
    @objc private func saveButtonTapped() {
        view.endEditing(true)
        if let existingStudent = student {
            saveStudent(existingStudent, mode: .edit)
        } else {
            saveStudent(nil, mode: .add)
        }
        
        navigationController?.popViewController(animated: true)
        viewModel.fetchStudents()
    }
    
    private func saveStudent(_ existingStudent: Student?, mode: EditMode) {
        let studentID = existingStudent?.id ?? UUID().uuidString
        
        let studentTypeIndex = studentTypeSegmentedControl.selectedSegmentIndex
        let studentType: StudentType = studentTypeIndex == 0 ? .schoolchild : .adult
        
        // Убираем проверку на пустое имя студента
        let studentName = studentNameTextField.text ?? ""
        
        // Убираем проверку на пустое имя родителя для школьников
        let parentName = studentType == .adult ? parentNameTextField.text ?? "" : (parentNameTextField.text ?? "")
        
        // Убираем проверку на пустой номер телефона
        let phoneNumber = phoneTextField.text ?? ""
        
        // Убираем проверку на пустую цену урока
        let lessonPriceText = lessonPriceTextField.text ?? "0"
        let lessonPriceValue = Int(lessonPriceText) ?? 0
        
        // Убираем проверку на пустую валюту
        let currency = currencyTextField.text ?? ""
        
        let newLessonPrice = LessonPrice()
        newLessonPrice.price = lessonPriceValue
        newLessonPrice.currency = currency
        
        let updatedLessons = existingStudent?.lessons ?? List<Lesson>()
        let updatedMonths = existingStudent?.months ?? List<Month>()
        
        let updatedSchedule = existingStudent?.schedule ?? List<Schedule>()
            
            if !scheduleItems.isEmpty {
                viewModel.realm.beginWrite()
                for item in scheduleItems {
                    let newSchedule = Schedule()
                    newSchedule.weekday = item.weekday
                    newSchedule.time = item.time
                    updatedSchedule.removeAll()
                    updatedSchedule.append(objectsIn: scheduleItems)
                }
                do {
                    try viewModel.realm.commitWrite()
                } catch {
                    print("Failed to commit write transaction: \(error)")
                }
            }
        
        // Сохранение изображения
        var imagePath: String?
        if let selectedImage = selectedImage {
            imagePath = saveImageToDocumentsDirectory(image: selectedImage)
        } else if let existingImage = existingStudent?.studentImage {
            imagePath = existingImage
        }
        
        let newStudent = Student(
            id: UUID(uuidString: studentID) ?? UUID(),
            name: studentName,
            parentName: parentName,
            phoneNumber: phoneNumber,
            months: Array(updatedMonths),
            lessons: Array(updatedLessons),
            lessonPrice: newLessonPrice,
            schedule: Array(updatedSchedule),
            type: studentType,
            studentImage: imagePath ?? ""
        )
        
        switch mode {
        case .add:
            viewModel.addStudent(newStudent)
        case .edit:
            viewModel.updateStudent(newStudent)
        }
    }
    
    private func saveImageToDocumentsDirectory(image: UIImage) -> String {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return "" }
        
        let filename = UUID().uuidString + ".jpg"
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsDirectory.appendingPathComponent(filename)
        
        do {
            try data.write(to: fileURL)
            return fileURL.path
        } catch {
            print("Unable to save image to documents directory: \(error)")
            return ""
        }
    }
    
    func displayErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

extension StudentCardViewController {
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        switch textField {
//        case lessonPriceTextField:
//            let currentText = textField.text ?? ""
//            if currentText.contains(",") && string.contains(",") {
//                return false
//            }
//            let allowedCharacters = CharacterSet(charactersIn: "0123456789,")
//            if string.rangeOfCharacter(from: allowedCharacters.inverted) != nil {
//                return false
//            }
//        case studentNameTextField, parentNameTextField, currencyTextField:
//            let allowedCharacters = CharacterSet.letters
//            if string.rangeOfCharacter(from: allowedCharacters.inverted) != nil {
//                return false
//            }
//        case phoneTextField:
//            let allowedCharacters = CharacterSet(charactersIn: "+0123456789")
//            if string.rangeOfCharacter(from: allowedCharacters.inverted) != nil {
//                return false
//            }
//        default:
//            break
//        }
//        
//        return true
//    }
}

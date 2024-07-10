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
import FirebaseFirestore


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
        
        let studentType: StudentType = studentTypeSegmentedControl.selectedSegmentIndex == 0 ? .schoolchild : .adult
        
        // Validate inputs
        guard let studentName = studentNameTextField.text, !studentName.isEmpty else {
            displayErrorAlert(message: "Please enter the student's name.")
            return
        }
        
        guard let phone = phoneTextField.text, !phone.isEmpty else {
            displayErrorAlert(message: "Please enter the phone number.")
            return
        }
        
        var parentName: String? = nil
        if studentTypeSegmentedControl.selectedSegmentIndex == 0 {
            guard let parent = parentNameTextField.text, !parent.isEmpty else {
                displayErrorAlert(message: "Please enter the parent's name.")
                return
            }
            parentName = parent
        }
        
        guard let lessonPriceString = lessonPriceTextField.text, let lessonPrice = Double(lessonPriceString) else {
            displayErrorAlert(message: "Please enter a valid lesson price.")
            return
        }
        
        guard let currency = currencyTextField.text, !currency.isEmpty else {
            displayErrorAlert(message: "Please enter the currency.")
            return
        }
        
//        var studentImagePath: String? = nil
//        if let selectedImage = selectedImage, imageIsChanged {
//            studentImagePath = saveImageToDocumentsDirectory(image: selectedImage)
//        } else if let studentImage = student?.studentImage {
//            studentImagePath = studentImage
//        }
        
        let lessonPriceDetails = LessonPrice(price: Int(lessonPrice), currency: currency)
        
        var studentDetails = Student(
//            studentImage: studentImagePath ?? "",
//            studentImageURL: studentImageURL,
            type: studentType,
            name: studentName,
            parentName: parentName ?? "",
            phoneNumber: phone,
            lessonPrice: lessonPriceDetails,
            schedule: Array(scheduleItems),
            months: [], // Значения-заполнители для months, lessons и photoUrls
            lessons: [],
            photoUrls: []
        )
        
        // Сохранение изображения в Firebase Storage, если оно было изменено
            if let selectedImage = selectedImage, imageIsChanged {
                FirebaseManager.shared.uploadImage(selectedImage) { result in
                    switch result {
                    case .success(let imageUrl):
                        studentDetails.studentImageURL = imageUrl

//                        // Сохранение данных студента в Firestore
//                        self.saveStudentToFirestore(studentDetails)
                        // Save to Firestore
                        switch self.editMode {
                           case .add:
                               FirebaseManager.shared.addOrUpdateStudent(studentDetails) { error in
                                   if let error = error {
                                       print("Error adding student: \(error.localizedDescription)")
                                   } else {
                                       print("Student added successfully.")
                                       // Дополнительные действия после добавления студента
                                   }
                               }
                           case .edit:
                               guard let studentId = self.student?.id else {
                                   print("Error: Trying to edit student without an ID.")
                                   return
                               }
                               studentDetails.id = studentId // Установка существующего ID студента
                               
                               FirebaseManager.shared.addOrUpdateStudent(studentDetails) { error in
                                   if let error = error {
                                       print("Error updating student: \(error.localizedDescription)")
                                   } else {
                                       print("Student updated successfully.")
                                       // Дополнительные действия после обновления студента
                                   }
                               }
                           }
                    case .failure(let error):
                        print("Error uploading image to Firebase Storage: \(error.localizedDescription)")
                    }
                }
            } else {
                // Если изображение не было изменено, сохраняем данные студента в Firestore без загрузки изображения
                // Save to Firestore
                   switch editMode {
                   case .add:
                       FirebaseManager.shared.addOrUpdateStudent(studentDetails) { error in
                           if let error = error {
                               print("Error adding student: \(error.localizedDescription)")
                           } else {
                               print("Student added successfully.")
                               // Дополнительные действия после добавления студента
                           }
                       }
                   case .edit:
                       guard let studentId = student?.id else {
                           print("Error: Trying to edit student without an ID.")
                           return
                       }
                       studentDetails.id = studentId // Установка существующего ID студента
                       
                       FirebaseManager.shared.addOrUpdateStudent(studentDetails) { error in
                           if let error = error {
                               print("Error updating student: \(error.localizedDescription)")
                           } else {
                               print("Student updated successfully.")
                               // Дополнительные действия после обновления студента
                           }
                       }
                   }
            }
        
//        // Save to Firestore
//           switch editMode {
//           case .add:
//               FirebaseManager.shared.addOrUpdateStudent(studentDetails) { error in
//                   if let error = error {
//                       print("Error adding student: \(error.localizedDescription)")
//                   } else {
//                       print("Student added successfully.")
//                       // Дополнительные действия после добавления студента
//                   }
//               }
//           case .edit:
//               guard let studentId = student?.id else {
//                   print("Error: Trying to edit student without an ID.")
//                   return
//               }
//               studentDetails.id = studentId // Установка существующего ID студента
//               
//               FirebaseManager.shared.addOrUpdateStudent(studentDetails) { error in
//                   if let error = error {
//                       print("Error updating student: \(error.localizedDescription)")
//                   } else {
//                       print("Student updated successfully.")
//                       // Дополнительные действия после обновления студента
//                   }
//               }
//           }
        
        navigationController?.popViewController(animated: true)
    }
    
//    private func saveImageToDocumentsDirectory(image: UIImage) -> String {
//        guard let data = image.jpegData(compressionQuality: 0.8) else { return "" }
//        
//        let filename = UUID().uuidString + ".jpg"
//        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//        let fileURL = documentsDirectory.appendingPathComponent(filename)
//        
//        do {
//            try data.write(to: fileURL)
//            return fileURL.path
//        } catch {
//            print("Unable to save image to documents directory: \(error)")
//            return ""
//        }
//    }
    
    private func compressImage(_ image: UIImage) -> Data? {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return nil }
        guard let compressedImage = UIImage(data: imageData) else { return nil }

        let maxSize: CGFloat = 512
        var size = compressedImage.size
        var scale: CGFloat = 1.0

        if size.width > maxSize || size.height > maxSize {
            if size.width > size.height {
                scale = maxSize / size.width
            } else {
                scale = maxSize / size.height
            }
        }

        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        UIGraphicsBeginImageContext(newSize)
        compressedImage.draw(in: CGRect(origin: .zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage?.jpegData(compressionQuality: 0.8)
    }
    
    func displayErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

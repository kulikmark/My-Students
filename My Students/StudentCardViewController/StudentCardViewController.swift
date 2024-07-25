//
//  StudentCardViewController.swift
//  My Students
//
//  Created by Марк Кулик on 24.06.2024.
//

//import UIKit
//import SwiftUI
//import Combine
//import Photos
//import FirebaseFirestore
//
//
//enum EditMode {
//    case add
//    case edit
//}
//
//class StudentCardViewController: UIViewController {
//
//    @ObservedObject var viewModel: StudentViewModel
//    private var cancellables = Set<AnyCancellable>()
//
//    var student: Student?
//    var editMode: EditMode
//
//    init(viewModel: StudentViewModel, editMode: EditMode) {
//        self.viewModel = viewModel
//        self.editMode = editMode
//        super.init(nibName: nil, bundle: nil)
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    let studentTypeSegmentedControl: UISegmentedControl = {
//        let items = ["Schoolchild", "Adult"]
//        let control = UISegmentedControl(items: items)
//        control.selectedSegmentIndex = 0
//        return control
//    }()
//
//    var selectedSchedules = [(weekday: String, time: String)]()
//    var selectedImage: UIImage?
//    var imageIsChanged = false
//
//    var scheduleItems: [Schedule] = []
//
//    var scheduleCollectionView: UICollectionView!
//    let addScheduleButton = UIButton()
//    var weekdayTextField: UITextField!
//    var timeTextField: UITextField!
//
//
//    let scrollView = UIScrollView()
//    let studentNameTextField = UITextField()
//    let studentNameLabel = UILabel()
//    let parentNameTextField = UITextField()
//    let parentNameLabel = UILabel()
//    let phoneTextField = UITextField()
//    let phoneLabel = UILabel()
//    let lessonPriceLabel = UILabel()
//    let lessonPriceTextField = UITextField()
//    let currencyLabel = UILabel()
//    let currencyTextField = UITextField()
//    let scheduleTextField = UITextField()
//    let scheduleLabel = UILabel()
//
//    var profileImageView = UIImageView()
//
//    var lessonPriceValue: Double?
//    var enteredPrice: Double?
//    var enteredCurrency: String?
//
//
//
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        if studentTypeSegmentedControl.selectedSegmentIndex != 0 {
//            parentNameLabel.isHidden = true
//            parentNameTextField.isHidden = true
//        }
//        scheduleCollectionView.reloadData()
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        viewModel.$students
//            .receive(on: RunLoop.main)
//            .sink { [weak self] students in
//                self?.scheduleCollectionView.reloadData()
//            }
//            .store(in: &cancellables)
//
//        setupUI()
//        scheduleCollectionView.reloadData()
//        self.title = editMode == .add ? "Add Student" : "Edit Student"
//        let saveButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveButtonTapped))
//        navigationItem.rightBarButtonItem = saveButton
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboardOnTap))
//        view.addGestureRecognizer(tapGesture)
//
//        studentTypeSegmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
//        if studentTypeSegmentedControl.selectedSegmentIndex != 0 {
//            parentNameLabel.isHidden = true
//            parentNameTextField.isHidden = true
//        }
//
//        // Инициализация scheduleItems данными из студента
//           if let student = student {
//               scheduleItems = Array(student.schedule)
//               scheduleCollectionView.reloadData()
//           }
//    }
//
//    @objc private func hideKeyboardOnTap() {
//        view.endEditing(true)
//    }
//
//    @objc private func segmentedControlValueChanged(_ sender: UISegmentedControl) {
//        switch sender.selectedSegmentIndex {
//        case 0:
//            parentNameLabel.isHidden = false
//            parentNameTextField.isHidden = false
//        case 1:
//            parentNameLabel.isHidden = true
//            parentNameTextField.isHidden = true
//        default:
//            break
//        }
//    }
//
//    @objc private func saveButtonTapped() {
//        view.endEditing(true)
//
//       let studentOrder = student?.order
//
//        let studentType: StudentType = studentTypeSegmentedControl.selectedSegmentIndex == 0 ? .schoolchild : .adult
//
//        // Validate inputs
//        guard let studentName = studentNameTextField.text, !studentName.isEmpty else {
//            displayErrorAlert(message: "Please enter the student's name.")
//            return
//        }
//
//        guard let phone = phoneTextField.text, !phone.isEmpty else {
//            displayErrorAlert(message: "Please enter the phone number.")
//            return
//        }
//
//        var parentName: String? = nil
//        if studentTypeSegmentedControl.selectedSegmentIndex == 0 {
//            guard let parent = parentNameTextField.text, !parent.isEmpty else {
//                displayErrorAlert(message: "Please enter the parent's name.")
//                return
//            }
//            parentName = parent
//        }
//
//        guard let lessonPriceString = lessonPriceTextField.text, let lessonPrice = Double(lessonPriceString) else {
//            displayErrorAlert(message: "Please enter a valid lesson price.")
//            return
//        }
//
//        guard let currency = currencyTextField.text, !currency.isEmpty else {
//            displayErrorAlert(message: "Please enter the currency.")
//            return
//        }
//
//        let lessonPriceDetails = LessonPrice(price: Int(lessonPrice), currency: currency)
//
//        var studentDetails = Student(
//            order: studentOrder,
//            type: studentType,
//            name: studentName,
//            parentName: parentName ?? "",
//            phoneNumber: phone,
//            lessonPrice: lessonPriceDetails,
//            schedule: Array(scheduleItems),
//            months: [],
//            lessons: [],
//            photoUrls: []
//        )
//
//        // Сохранение изображения в Firebase Storage, если оно было изменено
//            if let selectedImage = selectedImage, imageIsChanged {
//                FirebaseManager.shared.uploadImage(selectedImage) { result in
//                    switch result {
//                    case .success(let imageUrl):
//                        studentDetails.studentImageURL = imageUrl
//
//                        // Save to Firestore
//                        switch self.editMode {
//                           case .add:
//                               FirebaseManager.shared.addOrUpdateStudent(studentDetails) { error in
//                                   if let error = error {
//                                       print("Error adding student: \(error.localizedDescription)")
//                                   } else {
//                                       print("Student added successfully.")
//                                       // Дополнительные действия после добавления студента
//                                   }
//                               }
//                           case .edit:
//                               guard let studentId = self.student?.id else {
//                                   print("Error: Trying to edit student without an ID.")
//                                   return
//                               }
//                               studentDetails.id = studentId // Установка существующего ID студента
//
//                               FirebaseManager.shared.addOrUpdateStudent(studentDetails) { error in
//                                   if let error = error {
//                                       print("Error updating student: \(error.localizedDescription)")
//                                   } else {
//                                       print("Student updated successfully.")
//                                       // Дополнительные действия после обновления студента
//                                   }
//                               }
//                           }
//                    case .failure(let error):
//                        print("Error uploading image to Firebase Storage: \(error.localizedDescription)")
//                    }
//                }
//            } else {
//                // Если изображение не было изменено, сохраняем данные студента в Firestore без загрузки изображения
//                // Save to Firestore
//                   switch editMode {
//                   case .add:
//                       FirebaseManager.shared.addOrUpdateStudent(studentDetails) { error in
//                           if let error = error {
//                               print("Error adding student: \(error.localizedDescription)")
//                           } else {
//                               print("Student added successfully.")
//                               // Дополнительные действия после добавления студента
//                           }
//                       }
//                   case .edit:
//                       guard let studentId = student?.id else {
//                           print("Error: Trying to edit student without an ID.")
//                           return
//                       }
//                       studentDetails.id = studentId // Установка существующего ID студента
//
//                       FirebaseManager.shared.addOrUpdateStudent(studentDetails) { error in
//                           if let error = error {
//                               print("Error updating student: \(error.localizedDescription)")
//                           } else {
//                               print("Student updated successfully.")
//                               // Дополнительные действия после обновления студента
//                           }
//                       }
//                   }
//            }
//
//        navigationController?.popViewController(animated: true)
//    }
//
//    private func compressImage(_ image: UIImage) -> Data? {
//        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return nil }
//        guard let compressedImage = UIImage(data: imageData) else { return nil }
//
//        let maxSize: CGFloat = 512
//        let size = compressedImage.size
//        var scale: CGFloat = 1.0
//
//        if size.width > maxSize || size.height > maxSize {
//            if size.width > size.height {
//                scale = maxSize / size.width
//            } else {
//                scale = maxSize / size.height
//            }
//        }
//
//        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
//        UIGraphicsBeginImageContext(newSize)
//        compressedImage.draw(in: CGRect(origin: .zero, size: newSize))
//        let newImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//
//        return newImage?.jpegData(compressionQuality: 0.8)
//    }
//
//    func displayErrorAlert(message: String) {
//        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//        self.present(alert, animated: true, completion: nil)
//    }
//}


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
    
    // MARK: - Properties
    
    private var viewModel: StudentViewModel
    private var cancellables = Set<AnyCancellable>()
    
    var student: Student?
    private var editMode: EditMode
    
    // UI Elements
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
    var weekdayTextField: UITextField!
    var timeTextField: UITextField!
    let profileImageView = UIImageView()
    let studentTypeSegmentedControl: UISegmentedControl = {
        let items = ["Schoolchild", "Adult"]
        let control = UISegmentedControl(items: items)
        control.selectedSegmentIndex = 0
        return control
    }()
    var scheduleCollectionView: UICollectionView!
    
    var scheduleItems: [Schedule] = []
    var selectedImage: UIImage?
    var imageIsChanged = false
    
    var lessonPriceValue: Double?
    var enteredPrice: Double?
    var enteredCurrency: String?
    
    // Activity Indicator
    let activityIndicator = UIActivityIndicatorView(style: .large)
    
    // MARK: - Initialization
    
    init(viewModel: StudentViewModel, editMode: EditMode) {
        self.viewModel = viewModel
        self.editMode = editMode
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        setupGestures()
        setupSegmentedControl()
        initializeScheduleItems()
        bindViewModel()
        setupActivityIndicator()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateParentNameVisibility()
        scheduleCollectionView.reloadData()
    }
    
    // MARK: - UI Setup
    
    private func setupNavigationBar() {
        // Setup navigation bar title and save button
        title = (editMode == .add) ? "Add Student" : "Edit Student"
        let saveButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveButtonTapped))
        navigationItem.rightBarButtonItem = saveButton
    }
    
    private func setupGestures() {
        // Setup tap gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboardOnTap))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupSegmentedControl() {
        // Setup segmented control actions and initial state
        studentTypeSegmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
        updateParentNameVisibility()
    }
    
    private func setupActivityIndicator() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    // MARK: - Data Initialization
    
    private func initializeScheduleItems() {
        // Initialize schedule items if editing existing student
        if let student = student {
            scheduleItems = Array(student.schedule)
            scheduleCollectionView.reloadData()
        }
    }
    
    // MARK: - View Model Binding
    
    private func bindViewModel() {
        viewModel.$students
            .receive(on: RunLoop.main)
            .sink { [weak self] students in
                self?.scheduleCollectionView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Actions
    
    @objc private func hideKeyboardOnTap() {
        view.endEditing(true)
    }
    
    @objc private func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        updateParentNameVisibility()
    }
    
    @objc private func saveButtonTapped() {
        view.endEditing(true)
        
        guard let studentType = getStudentType() else { return }
        guard validateInputs() else { return }
        
        var studentDetails = prepareStudentDetails(studentType: studentType)
        
        // Start activity indicator
        activityIndicator.startAnimating()
        
        // Handle image upload if needed
        if let selectedImage = selectedImage, imageIsChanged {
            FirebaseManager.shared.uploadProfileImage(selectedImage) { result in
                switch result {
                case .success(let imageUrl):
                    studentDetails.studentImageURL = imageUrl // Update student image URL
                    print("Image uploaded successfully. Image URL: \(imageUrl)")
                    self.saveStudentToFirestore(studentDetails)
                case .failure(let error):
                    print("Error uploading image to Firebase Storage: \(error.localizedDescription)")
                    self.activityIndicator.stopAnimating()
                    // Optionally display an error alert
                }
            }
        } else {
            // If no image is selected or it is not changed
            saveStudentToFirestore(studentDetails)
        }
    }
    
    // MARK: - Helper Methods
    
    private func updateParentNameVisibility() {
        parentNameLabel.isHidden = (studentTypeSegmentedControl.selectedSegmentIndex == 1)
        parentNameTextField.isHidden = (studentTypeSegmentedControl.selectedSegmentIndex == 1)
    }
    
    private func getStudentType() -> StudentType? {
        return studentTypeSegmentedControl.selectedSegmentIndex == 0 ? .schoolchild : .adult
    }
    
    private func validateInputs() -> Bool {
        // Validate inputs
        guard let studentName = studentNameTextField.text, !studentName.isEmpty else {
            displayErrorAlert(message: "Please enter the student's name.")
            return false
        }
        
        guard let phone = phoneTextField.text, !phone.isEmpty else {
            displayErrorAlert(message: "Please enter the phone number.")
            return false
        }
        
        if studentTypeSegmentedControl.selectedSegmentIndex == 0 {
            guard let parent = parentNameTextField.text, !parent.isEmpty else {
                displayErrorAlert(message: "Please enter the parent's name.")
                return false
            }
        }
        
        guard let lessonPriceString = lessonPriceTextField.text, let _ = Int(lessonPriceString) else {
            displayErrorAlert(message: "Please enter a valid lesson price.")
            return false
        }
        
        guard let currency = currencyTextField.text, !currency.isEmpty else {
            displayErrorAlert(message: "Please enter the currency.")
            return false
        }
        
        return true
    }
    
    
    private func prepareStudentDetails(studentType: StudentType) -> Student {
        // Prepare student details object from UI inputs
        return Student( order: student?.order,
                        type: studentType,
                        name: studentNameTextField.text ?? "",
                        parentName: parentNameTextField.text ?? "",
                        phoneNumber: phoneTextField.text ?? "",
                        lessonPrice: LessonPrice(price: Int(lessonPriceTextField.text ?? "") ?? 0,
                                                 currency: currencyTextField.text ?? ""),
                        schedule: Array(scheduleItems),
                        months: [],
                        lessons: [],
                        HWPhotos: [])
    }
    
    private func saveStudentToFirestore(_ studentDetails: Student) {
        guard let studentType = getStudentType() else { return }
        
        // Save student details to Firestore
        switch editMode {
        case .add:
            FirebaseManager.shared.addOrUpdateStudent(studentDetails) { result in
                switch result {
                case .success:
                    print("Student added successfully.")
                case .failure(let error):
                    print("Error adding student: \(error.localizedDescription)")
                }
                    self.activityIndicator.stopAnimating()
                    // Navigate back after successful save
                    self.navigationController?.popViewController(animated: true)
                }
            
        case .edit:
            guard var existingStudent = student else {
                print("Error: Trying to edit student details without an existing student.")
                return
            }
            guard let studentId = student?.id else {
                print("Error: Trying to edit student without an ID.")
                return
            }
            existingStudent.id = studentId // Set existing student ID
            existingStudent.studentImageURL = studentDetails.studentImageURL // Ensure image URL is updated
            
            // Обновление остальных данных студента
                existingStudent.type = studentDetails.type
                 existingStudent.name = studentDetails.name
                 existingStudent.parentName = studentDetails.parentName
                 existingStudent.phoneNumber = studentDetails.phoneNumber
                 existingStudent.lessonPrice = studentDetails.lessonPrice
                 existingStudent.schedule = studentDetails.schedule
                 existingStudent.months = studentDetails.months
                 existingStudent.lessons = studentDetails.lessons
                 existingStudent.HWPhotos = studentDetails.HWPhotos
            
            FirebaseManager.shared.addOrUpdateStudent(existingStudent) { result in
                switch result {
                case .success:
                    print("Student added successfully.")
                case .failure(let error):
                    print("Error adding student: \(error.localizedDescription)")
                }
                    self.activityIndicator.stopAnimating()
                    // Navigate back after successful update
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    
    private func compressImage(_ image: UIImage) -> Data? {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return nil }
        guard let compressedImage = UIImage(data: imageData) else { return nil }
        
        let maxSize: CGFloat = 512
        let size = compressedImage.size
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
        // Display error alert with given message
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

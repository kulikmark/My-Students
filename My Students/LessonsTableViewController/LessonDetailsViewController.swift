//
//  LessonDetailsViewController.swift
//  Accounting
//
//  Created by Марк Кулик on 16.04.2024.
//

import UIKit
import SwiftUI
import Combine
import SnapKit
import PhotosUI
import FirebaseStorage
import Kingfisher

class LessonDetailsViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    @ObservedObject var viewModel: StudentViewModel
    private var cancellables = Set<AnyCancellable>()
    
    var studentId: String
    var selectedLesson: Lesson
    var photoCollectionView: UICollectionView
    
    var enterHWLabel: UILabel
    var clippedPhotosLabel: UILabel
    var attendanceSwitch: UISwitch
    var statusLabel: UILabel
    var paperclipButton = UIButton(type: .system)
    
    let homeworkTextView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = UIColor.systemGroupedBackground
        textView.layer.cornerRadius = 10
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.textColor = .darkGray
        return textView
    }()
    
    init(viewModel: StudentViewModel, studentId: String, selectedLesson: Lesson) {
        self.viewModel = viewModel
            self.studentId = studentId
            self.selectedLesson = selectedLesson
            
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .horizontal
            self.photoCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
            
            self.enterHWLabel = UILabel()
            self.clippedPhotosLabel = UILabel()
            self.attendanceSwitch = UISwitch()
            self.statusLabel = UILabel()
            
            super.init(nibName: nil, bundle: nil)
        }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            attendanceSwitch.isOn = selectedLesson.attended
            loadLessonDetails()
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Lesson \(selectedLesson.date)"
        view.backgroundColor = .white
        
        viewModel.studentsSubject
            .receive(on: RunLoop.main)
            .sink { _ in
            }
            .store(in: &cancellables)
        
        updateUIWithLessonDetails()
        
        loadLessonDetails()
        setupNavigationItems()
        setupUI()
        setupObservers()
        setupTapGesture()
        
        photoCollectionView.delegate = self
        photoCollectionView.dataSource = self

    }
    
    func setupNavigationItems() {
            // Создание кастомной кнопки "Назад"
            let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backButtonTapped))
            navigationItem.leftBarButtonItem = backButton
            
            // Кнопки "Поделиться" и "Скрепка" остаются без изменений
            let shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareHomework))
            let paperclipButton = UIBarButtonItem(image: UIImage(systemName: "paperclip"), style: .plain, target: self, action: #selector(paperclipButtonTapped))
            navigationItem.rightBarButtonItems = [shareButton, paperclipButton]
        }
    
    @objc func backButtonTapped() {
        // Обновление объекта lesson текущим состоянием
        selectedLesson.homework = homeworkTextView.text
        selectedLesson.attended = attendanceSwitch.isOn
        
        FirebaseManager.shared.saveLessonDetails(studentId: studentId, monthId: selectedLesson.monthId, lesson: selectedLesson) { result in
            switch result {
            case .success:
                print("Lesson successfully saved.")
                self.navigationController?.popViewController(animated: true)
            case .failure(let error):
                print("Error saving lesson: \(error)")
                self.navigationController?.popViewController(animated: true)
            }
        }
       }
    
    func saveLessonsDetails() {
        selectedLesson.homework = homeworkTextView.text
        selectedLesson.attended = attendanceSwitch.isOn
        
        FirebaseManager.shared.saveLessonDetails(studentId: studentId, monthId: selectedLesson.monthId, lesson: selectedLesson) { result in
            switch result {
            case .success:
                print("Lesson successfully saved.")
            case .failure(let error):
                print("Error saving lesson: \(error)")
            }
        }
    }
    
    @objc func attendanceSwitchValueChanged(_ sender: UISwitch) {
        selectedLesson.attended = sender.isOn
        statusLabel.text = sender.isOn ? "Student was present" : "Student was absent"
    }
    
    func loadLessonDetails() {
        FirebaseManager.shared.loadLessonDetails(studentId: studentId, monthId: selectedLesson.monthId, lessonId: selectedLesson.id) { result in
               switch result {
               case .success(let lesson):
                   self.selectedLesson = lesson
                   self.updateUIWithLessonDetails()
               case .failure(let error):
                   print("Error loading lesson: \(error)")
               }
           }
       }
    
    func updateUIWithLessonDetails() {
           homeworkTextView.text = selectedLesson.homework
           attendanceSwitch.isOn = selectedLesson.attended
           statusLabel.text = selectedLesson.attended ? "Student was present" : "Student was absent"
       }
}

// MARK: - Paper clip button: Photo Gallery methods

extension LessonDetailsViewController {
    
    @objc func paperclipButtonTapped() {
        let actionSheet = UIAlertController(title: "Add Photo", message: "Choose a source", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.presentCamera()
        }))
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { _ in
            self.presentImagePicker(sourceType: .photoLibrary)
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(actionSheet, animated: true, completion: nil)
    }
    
    func presentCamera() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        if #available(iOS 14, *) {
            var configuration = PHPickerConfiguration()
            configuration.filter = .images // Фильтр только для изображений
            configuration.selectionLimit = 0 // 0 означает неограниченное количество выбранных элементов
            
            let picker = PHPickerViewController(configuration: configuration)
            picker.delegate = self
            present(picker, animated: true, completion: nil)
        } else {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = sourceType
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            addImageForHW(image: selectedImage)
        }
        dismiss(animated: true, completion: nil)
    }
    
    func addImageForHW(image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
        let uniqueID = UUID().uuidString
        let temporaryPlaceholder = "temporary_\(uniqueID)"
        selectedLesson.HWPhotos.append(temporaryPlaceholder)
        let tempIndexPath = IndexPath(item: selectedLesson.HWPhotos.count - 1, section: 0)
        photoCollectionView.insertItems(at: [tempIndexPath])

        let storageRef = FirebaseManager.shared.storage.reference().child("homework_images/\(uniqueID).jpg")

        storageRef.putData(imageData, metadata: nil) { (metadata, error) in
            guard error == nil else {
                print("Error uploading image: \(String(describing: error))")
                return
            }
            
            storageRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    print("Error getting download URL: \(String(describing: error))")
                    return
                }
                
                let photoUrl = downloadURL.absoluteString
                
                if let tempIndex = self.selectedLesson.HWPhotos.firstIndex(of: temporaryPlaceholder) {
                    self.selectedLesson.HWPhotos[tempIndex] = photoUrl
                    DispatchQueue.main.async {
                        self.photoCollectionView.reloadItems(at: [IndexPath(item: tempIndex, section: 0)])
                    }
                }

                // Save the updated lesson details to Firebase
                FirebaseManager.shared.saveLessonDetails(studentId: self.studentId, monthId: self.selectedLesson.monthId, lesson: self.selectedLesson) { result in
                    switch result {
                    case .success:
                        print("Lesson successfully updated with new photo URL.")
                    case .failure(let error):
                        print("Error saving lesson with new photo URL: \(error)")
                    }
                }
            }
        }
    }
    
    @objc func deleteImage(_ sender: UIButton) {
        // Identify the index path of the photo to be deleted
        let point = sender.convert(CGPoint.zero, to: photoCollectionView)
        guard let indexPath = photoCollectionView.indexPathForItem(at: point) else { return }
        
        // Get the URL of the photo to be deleted
        let photoUrl = selectedLesson.HWPhotos[indexPath.item]
        
        // Remove the photo from the data source
        selectedLesson.HWPhotos.remove(at: indexPath.item)
        
        // Update the collection view to reflect the deletion
        photoCollectionView.deleteItems(at: [indexPath])
        
        // Delete the photo from Firebase storage
        let storageRef = FirebaseManager.shared.storage.reference(forURL: photoUrl)
        storageRef.delete { error in
            if let error = error {
                print("Error deleting photo from storage: \(error.localizedDescription)")
            } else {
                // Photo successfully deleted from storage
                
                // Save the updated lesson details to Firebase
                FirebaseManager.shared.saveLessonDetails(studentId: self.studentId, monthId: self.selectedLesson.monthId, lesson: self.selectedLesson) { result in
                    switch result {
                    case .success:
                        print("Lesson successfully updated after deleting photo.")
                    case .failure(let error):
                        print("Error saving lesson after deleting photo: \(error)")
                    }
                }
            }
        }
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout

extension LessonDetailsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedLesson.HWPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HWPhotoCell", for: indexPath) as! HWPhotoCollectionViewCell
        let photoURL = selectedLesson.HWPhotos[indexPath.item]
        
        if photoURL.starts(with: "temporary") {
            cell.imageView.image = nil
            cell.showLoadingIndicator()
        } else {
            if let url = URL(string: photoURL) {
                cell.imageView.kf.setImage(with: url)
            }
            cell.hideLoadingIndicator()
        }

        cell.deleteButton.addTarget(self, action: #selector(deleteImage(_:)), for: .touchUpInside)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Cell at index \(indexPath.item) was tapped")
        
        saveLessonsDetails()
        
        let images = selectedLesson.HWPhotos.compactMap { URL(string: $0) }
        if !images.isEmpty {
            let fullscreenVC = FullscreenImageViewController(imageURLs: images, initialIndex: indexPath.item)
            present(fullscreenVC, animated: true, completion: nil)
        } else {
            print("No images to display")
        }
    }
}

// MARK: - Расширение для работы с PHPickerViewController (только для iOS 14 и новее)
@available(iOS 14, *)
extension LessonDetailsViewController: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true, completion: nil)
        
        // Temporary dictionary to store images with their corresponding order
        var imageDict = [Int: UIImage]()
        
        let dispatchGroup = DispatchGroup()
        
        for (index, result) in results.enumerated() {
            if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                dispatchGroup.enter()
                result.itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                    if let image = image as? UIImage {
                        imageDict[index] = image
                    }
                    dispatchGroup.leave()
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            let sortedKeys = imageDict.keys.sorted()
            for key in sortedKeys {
                if let image = imageDict[key] {
                    self.addImageForHW(image: image)
                }
            }
        }
    }
}

extension LessonDetailsViewController {
    
    func setupUI() {
        
        let statusStackView = UIStackView()
               statusStackView.axis = .horizontal
               statusStackView.spacing = 10
               statusStackView.alignment = .fill
               statusStackView.distribution = .fill
        
        enterHWLabel = UILabel()
        enterHWLabel.font = UIFont.systemFont(ofSize: 14)
        enterHWLabel.textColor = .darkGray
        enterHWLabel.text = "Enter Homework here:"
        
        clippedPhotosLabel = UILabel()
        clippedPhotosLabel.font = UIFont.systemFont(ofSize: 14)
        clippedPhotosLabel.textColor = .darkGray
        clippedPhotosLabel.text = "Clipped photos"
        
        statusLabel = UILabel()
        enterHWLabel.font = UIFont.systemFont(ofSize: 14)
        enterHWLabel.textColor = .darkGray
        statusLabel.textAlignment = .left
        
        attendanceSwitch = UISwitch()
        attendanceSwitch.addTarget(self, action: #selector(attendanceSwitchValueChanged(_:)), for: .valueChanged)
        attendanceSwitch.isOn = selectedLesson.attended
        statusLabel.text = attendanceSwitch.isOn ? "Student was present" : "Student was absent"
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 10
        layout.itemSize = CGSize(width: 250, height: 250)
        
        photoCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        photoCollectionView.delegate = self
        photoCollectionView.dataSource = self
        photoCollectionView.register(HWPhotoCollectionViewCell.self, forCellWithReuseIdentifier: "HWPhotoCell")
        photoCollectionView.backgroundColor = .systemGroupedBackground
        photoCollectionView.layer.cornerRadius = 10
                
        view.addSubview(enterHWLabel)
        view.addSubview(homeworkTextView)
        view.addSubview(clippedPhotosLabel)
        view.addSubview(photoCollectionView)
        view.addSubview(statusStackView)
        statusStackView.addArrangedSubview(statusLabel)
        statusStackView.addArrangedSubview(attendanceSwitch)
    
        // Constraints:
        enterHWLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        homeworkTextView.snp.makeConstraints { make in
            make.top.equalTo(enterHWLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(300)
        }
        
        clippedPhotosLabel.snp.makeConstraints { make in
            make.top.equalTo(homeworkTextView.snp.bottom).offset(16)
            make.leading.equalToSuperview().inset(16)
        }
        
        photoCollectionView.snp.makeConstraints { make in
            make.top.equalTo(clippedPhotosLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
//            make.height.equalTo(80)
            make.bottom.equalTo(statusStackView.snp.top).offset(-20)
        }
        photoCollectionView.layer.cornerRadius = 10
        
        statusStackView.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-50)
            make.trailing.leading.equalToSuperview().inset(16)
        }
    }
    
    func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false // Позволяет касаниям проходить через жест
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleKeyboardWillShow(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        // Рассчитываем сдвиг для текстового поля
        let keyboardHeight = keyboardFrame.height
        let textViewBottomY = homeworkTextView.frame.origin.y + homeworkTextView.frame.height
        let overlap = textViewBottomY - (view.frame.height - keyboardHeight)
        
        if overlap > 0 {
            view.frame.origin.y = -overlap
        }
    }

    @objc func handleKeyboardWillHide(notification: Notification) {
        view.frame.origin.y = 0
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func shareHomework() {
        print("shareHomework вызван")
        
        print("Загружено студентов: \(viewModel.students.count)")
        
        guard let student = viewModel.students.first else {
            print("Ошибка: студент не найден")
            return
        }
        
        let studentType = student.type
        let name = studentType == .schoolchild ? student.parentName : student.name
        let lessonDate = student.months.first?.lessons.first?.date ?? "Unknown date"
        
        guard let homeworkText = homeworkTextView.text, !homeworkText.isEmpty else {
            print("Ошибка: текст домашнего задания пустой")
            return
        }
        
        print("Студент: \(name), Дата урока: \(lessonDate), Домашнее задание: \(homeworkText)")
        
        let message = "Hello, \(name)! Homework for \(lessonDate) is \(homeworkText)"
        
        // Собираем фотографии из коллекции
        var activityItems: [Any] = [message]
        for photoUrlString in selectedLesson.HWPhotos {
            if let photoUrl = URL(string: photoUrlString) {
                activityItems.append(photoUrl)
            } else {
                print("Ошибка: некорректный URL фотографии \(photoUrlString)")
            }
        }
        
        if activityItems.isEmpty {
            print("Ошибка: нет элементов для шаринга")
            return
        }
        
        let activityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        
        // Для iPad
        if let popoverController = activityVC.popoverPresentationController {
            popoverController.barButtonItem = self.navigationItem.rightBarButtonItems?.first
            popoverController.sourceView = self.view
        }
        
        present(activityVC, animated: true) {
            print("UIActivityViewController представлен")
        }
    }
}

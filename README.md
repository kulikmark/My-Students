# My Students: Student Accounting and Payments

## Description

**My Students** is a user-friendly student accounting and payment application designed for teachers, coaches, and tutors. This app allows you to efficiently organize your educational process and track financial transactions seamlessly.

## Key Features

- **Student Registration:** Easily add new students to your database by entering their name, contact details, and other necessary information.
- **Payment and Schedule Management:** Record payments and manage the class schedule for each student.
- **Data Visualization:** View student data in a convenient spreadsheet format for quick access to essential information.
- **User-friendly Interface:** The simple and intuitive interface ensures a comfortable and efficient user experience.
- **Additional Features:** Add photos of students and detailed payment information for individual months, making this app a comprehensive tool for managing your educational process.

## Ideal For

- Teachers and tutors of all subjects and directions.
- Coaches in sports, dance, music, and other activities.
- Parents who want to track their children's academic progress and paid classes.

## Development Journey

### Combine Framework Integration
To manage the state of the data more efficiently, the Combine framework was integrated into the "My Students" application. This allows for easy management of asynchronous events and state, which is particularly useful for real-time updates of the student list.

- **Data Model with Combine:** Created a `StudentViewModel` that contains an array of students and methods for adding, updating, and deleting students. The `students` property in `StudentViewModel` is marked as `@Published`, automatically notifying all subscribers of changes.
- **Subscription to Data Changes:** In `StudentsCollectionViewController` and other controllers, changes in `StudentViewModel` are subscribed to using Combine, enabling automatic UI updates when students are added, deleted, or modified.

### UI Improvements
- **UICollectionView:** Replaced `UITableView` with `UICollectionView` for better flexibility and visual presentation.
- **Bottom Sheet:** Added a sleek bottom sheet for quick and easy profile edits and deletions, simplifying the user experience by removing extra buttons.

### Login & Registration Enhancements
- **Welcoming UI:** Implemented using SnapKit.
- **Firebase Authentication:** Integrated for secure login and registration, with error handling for authentication issues like invalid emails and weak passwords.
- **Password Reset:** Added a 'Forgot Password' screen for easy password recovery, ensuring users receive clear feedback when resetting their passwords.

### Real-time Data Management with Firebase
- **Firebase Integration:** Chose Firebase over RealmSwift (Atlas MongoDB) for real-time data management, offline data handling, and smooth synchronization when reconnecting to the internet, offering maximum reliability and convenience for users.

## Screenshots

### Login Screens
- **LoginScreen**
- **LoginScreen with Keyboard**
- **LoginScreen Password Showing Button**
- **LoginScreen Password Resetting**

### Main Screens
- **MainScreen**
- **MainScreen Bottom Sheet**
- **MainScreen Side Menu**

### Student Cards
- **New Student Card**
- **Existing Student Card**

### Search Screen
- **SearchScreen**

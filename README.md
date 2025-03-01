# Task Management App

A comprehensive Flutter application for managing tasks with offline support, real-time sync, and user authentication.

## Features

- **User Authentication**
  - Registration and Login with persistent sessions
  - Secure token-based authentication
  - Automatic session management

- **Task Management**
  - Create, view, edit, and delete tasks
  - Task attributes include:
    - Title
    - Description
    - Due Date
    - Priority (High, Medium, Low)
    - Status (To-Do, In Progress, Done)
    - Assigned User
  - Real-time task synchronization
  - Offline support with local storage

- **Search & Filtering**
  - Search tasks by title, description, status, or priority
  - Filter tasks by status
  - Animated search interface
  - Pagination support for large task lists

- **UI/UX Features**
  - Modern Material Design interface
  - Smooth animations and transitions
  - Responsive layout
  - Error handling with user-friendly messages
  - Pull-to-refresh functionality

## API Integration

### Authentication Endpoints
- **Base URL**: `https://reqres.in/api`
- **Register**: `POST /register`
- **Login**: `POST /login`

### Task Management Endpoints
- **Base URL**: `https://jsonplaceholder.typicode.com`
- **Get Tasks**: `GET /todos`
- **Create Task**: `POST /todos`
- **Update Task**: `PUT /todos/{id}`
- **Delete Task**: `DELETE /todos/{id}`

### User Information Endpoints
- **Base URL**: `https://reqres.in/api`
- **Get Users**: `GET /users`
- **Get User**: `GET /users/{id}`

## Getting Started

### Prerequisites
- Flutter SDK (version 3.0 or higher)
- Dart SDK (version 2.17 or higher)
- Android Studio / VS Code with Flutter extensions

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/task_management_app.git
   ```README.md

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

### Test Credentials

Use these credentials for testing:
- **Email**: `eve.holt@reqres.in`
- **Password**: `cityslicka`


## Architecture

The app follows Clean Architecture principles with:
- **Domain Layer**: Business logic and entities
- **Data Layer**: Repositories and data sources
- **Presentation Layer**: BLoC pattern for state management

## Dependencies

- `flutter_bloc`: State management
- `dio`: HTTP client
- `hive`: Local storage
- `injectable`: Dependency injection
- `freezed`: Code generation for immutable classes
- `connectivity_plus`: Network connectivity handling

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## Acknowledgments

- [ReqRes](https://reqres.in/) for the authentication API
- [JSONPlaceholder](https://jsonplaceholder.typicode.com/) for the task management API


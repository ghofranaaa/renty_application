# Rent'y: Musical Instrument Marketplace

## Overview
Rent'y is a mobile and web application designed to connect musical instrument enthusiasts, enabling users to rent, buy, or sell musical instruments seamlessly. This project is **not yet deployed** and must be run locally for testing and development purposes.

- Blog article link : https://github.com/ghofranaaa/renty_application/tree/main/renty
---
## Author
- Ghofrane Amemi

**Linkedin**: https://www.linkedin.com/in/ghofrane-amemi-6200a3338/

---

## Features

- **User Authentication**:
  - Secure user registration and login with JWT-based authentication.
  - Manage user profiles.

- **Marketplace Functionality**:
  - Post musical instruments for **sale** or **rental**.
  - Search and filter posts by instrument type.

- **Post Creation**:
  - User can post music intruments.

- **Profile Screen**:
  - User can track his posts, updates his informations, or logs out.

- **Validation**:
  - Input validation for fields like title, price, and description.
  - Robust error handling to ensure data consistency.

---

## Screenshots

### Welcome Page
![Welcome Page](assets/screenshots/welcome.png "Welcome Page Screenshot")

### Home Page
![Home Page](assets/screenshots/home.png "Home Page Screenshot")

### Login Page
![Login Page](assets/screenshots/login.png "Login Page Screenshot")

### Post Creation
![Post Creation](assets/screenshots/post.png "Post Creation Screenshot")

### Profile Page
![Profile Page](assets/screenshots/profile.png "Profile Page Screenshot")

---

## Usage

Since the app is not deployed, you need to run it locally. Follow the steps below:



### Backend (Flask API)

1. Clone the repository:
   ```bash
   git clone <https://github.com/ghofranaaa/renty_application.git>
   cd backend

2. Create a .env file with the following:
   ```bash
   JWT_SECRET_KEY=your_secret_key
   DATABASE_URL=mysql+pymysql://username:password@localhost/database_name

3. Run the Flask server:
   ```bash
   flask run

- The server will be accessible at http://127.0.0.1:5000/.


### Frontend (Flutter)

1. Navigate to the Flutter directory:
   cd frontend

2. Install dependencies:
   flutter pub get

3. Connect a device or emulator, and run the app:
   flutter run


### Technical Aspects && Technologies

**Backend**

- Framework: Flask
- Database: MySQL
- ORM: SQLAlchemy
- Authentication: JWT (JSON Web Tokens)
- Validation: Custom input validation logic


**Frontend**

- Framework: Flutter (Dart)
- State Management: Flutter’s setState method
- HTTP Requests: http package to interact with the backend API


**Development Tools**

- Database Management: MySQL Workbench
- Testing: Thunderclient for API testing
- IDE: Visual Studio Code (Python backend), Android Studio (Flutter frontend)


### Current Limitations

* The application is not deployed and must be run locally.
* Deployment to production will require setup with hosting services like AWS, Azure, or Google Cloud.



### Future Improvements

* Deployment: Host the application for public use.
* Search Optimization: Improve search filters and algorithms for enhanced usability.
* Image upload: Improve image upload feature.
* Notifications: Implement push notifications to alert users of updates or activities.


### Contributing

**I welcome contributions to make this app better! If you'd like to contribute:**

1. Fork the repository.

2. Create a new branch for your feature or bug fix.

3. Submit a pull request with detailed changes.

**Feel free to clone, explore, and improve Rent'y!**
# Medical Test Record Management System in MIPS Assembly

## Table of Contents
1. [Project Overview](#project-overview)
2. [File Structure](#file-structure)
3. [System Requirements](#system-requirements)
4. [Compilation and Execution](#compilation-and-execution)
5. [System Functionality](#system-functionality)
6. [Error Handling](#error-handling)
7. [Data Validation](#data-validation)
8. [Contributing](#contributing)
9. [License](#license)

## Project Overview
This project is a Medical Test Record Management System implemented in MIPS assembly language. It efficiently stores, manages, and retrieves medical test data for individual patients. The system operates on a text-based menu allowing users to perform various operations such as adding, searching, updating, and deleting medical test records.

## File Structure
- **main.asm**: The main file containing the menu loop and primary logic.
- **functions.asm**: Contains the definitions of various functions used for operations like adding, searching, updating, and deleting records.
- **list.asm**: Contains linked list manipulation functions and related operations.
- **testfile.txt**: The input file storing medical test records in a specific format.

## System Requirements
- **Assembler**: MIPS assembler (MARS or SPIM)
- **Platform**: Any platform capable of running the MIPS assembler
- **Editor**: Text editor or IDE supporting assembly language (e.g., VSCode, Notepad++, etc.)

## Compilation and Execution
1. **Open MARS/SPIM**: Launch the MIPS assembler of your choice.
2. **Load Files**: Load `main.asm`, `functions.asm`, and `list.asm` into the assembler.
3. **Set Input File**: Ensure `testfile.txt` is in the correct directory and accessible.
4. **Assemble and Run**: Assemble the loaded files and run the program. Follow the on-screen menu to interact with the system.

## System Functionality
### Menu Options
1. **Add a New Medical Test**: Adds a new medical test record after validating the input data.
2. **Search for a Test by Patient ID**:
   - Retrieve all patient tests.
   - Retrieve all abnormal patient tests.
   - Retrieve all patient tests in a specific period.
3. **Searching for Abnormal Tests**: Retrieves all abnormal tests based on the selected medical test.
4. **Average Test Value**: Computes and displays the average value of each medical test.
5. **Update an Existing Test Result**: Updates the test result for a specific record.
6. **Delete a Test**: Deletes a specific test record.
7. **Exit**: Writes data back to the file and exits the program.

### Searching Submenu
When searching by patient ID, you will encounter a submenu:
- Show all tests for a patient.
- Show all abnormal tests for a patient.
- Show all tests in a specific period.
- Return to the main menu.

## Error Handling
The system includes error handling for various scenarios:
- Invalid file name.
- Searching for non-existent tests or patients.
- Invalid input data types.

## Data Validation
The system performs data validation to ensure proper input data types:
- Patient ID: Must be a 7-digit integer.
- Test Date: Must follow the format `YYYY-MM`.
- Test Result: Must be a floating-point number.

## Contributing
1. Fork the repository.
2. Create a new branch for your feature or bug fix.
3. Commit your changes with descriptive messages.
4. Push to the branch.
5. Open a pull request.

## License

Feel free to contribute to this project by adding new features, fixing bugs, or improving the documentation. If you have any questions or need further assistance, please open an issue in the repository.



## 🔗 Links

[![facebook](https://img.shields.io/badge/facebook-0077B5?style=for-the-badge&logo=facebook&logoColor=white)](https://www.facebook.com/qossay.rida?mibextid=2JQ9oc)

[![Whatsapp](https://img.shields.io/badge/Whatsapp-25D366?style=for-the-badge&logo=Whatsapp&logoColor=white)](https://wa.me/+972598592423)

[![linkedin](https://img.shields.io/badge/linkedin-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/qossay-rida-3aa3b81a1?utm_source=share&utm_campaign=share_via&utm_content=profile&utm_medium=android_app )

[![twitter](https://img.shields.io/badge/twitter-1DA1F2?style=for-the-badge&logo=twitter&logoColor=white)](https://twitter.com/qossayrida)



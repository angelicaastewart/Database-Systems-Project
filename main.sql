--Task 1: See Folder
--Task 2
--Write the commands for creating tables
--Students Table
CREATE TABLE Students (
    student_id INT PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100)
);
--Courses Table
CREATE TABLE Courses (
    course_id INT PRIMARY KEY AUTO_INCREMENT,
    department VARCHAR(100),
    course_name VARCHAR(255),
    course_number VARCHAR(50),
    semester VARCHAR(50), 
    year INT 
);
--Categories Table
CREATE TABLE Categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(100),
    percentage DECIMAL(5,2),
    course_id INT,
    FOREIGN KEY (course_id) REFERENCES Courses(course_id)
);
--Assignments Table
CREATE TABLE Assignments (
    assignment_id INT PRIMARY KEY AUTO_INCREMENT,
    assignment_name VARCHAR(255),
    max_score INT,
    category_id INT,
    FOREIGN KEY (category_id) REFERENCES Categories(category_id)
);
--Enrollment Table
CREATE TABLE Enrollment (
    student_id INT,
    course_id INT,
    PRIMARY KEY (student_id, course_id),
    FOREIGN KEY (student_id) REFERENCES Students(student_id),
    FOREIGN KEY (course_id) REFERENCES Courses(course_id)
);
--Scores Table
CREATE TABLE Scores (
    student_id INT,
    assignment_id INT,
    score INT,
    PRIMARY KEY (student_id, assignment_id),
    FOREIGN KEY (student_id) REFERENCES Students(student_id),
    FOREIGN KEY (assignment_id) REFERENCES Assignments(assignment_id)
);

-- and inserting values;
-- Insert into "Students"
INSERT INTO Students (student_id, first_name, last_name) 
VALUES 
(1, 'Madeline', 'Bumpus'),
(2, 'Angelica', 'Stewart');
(3, 'Johan', 'Lingani');

-- Insert into "Courses"
INSERT INTO Courses (department, course_name, course_number, semester, year) 
VALUES 
('CS', 'Introduction to Computer Science', 'CS101', 'Fall', 2023);

-- Insert into "Categories"
INSERT INTO Categories (category_name, percentage, course_id) 
VALUES 
('Participation', 10.00, 1),
('Homework', 20.00, 1),
('Exams', 70.00, 1);

-- Insert into "Assignments"
INSERT INTO Assignments (assignment_name, max_score, category_id) 
VALUES 
('Attend Class', 100, 1),
('Homework 1', 100, 2),
('Midterm', 100, 3);

--Insert into "Enrollment"
INSERT INTO Enrollment (student_id, course_id) 
VALUES 
(1, 1),
(2, 1);
(3, 1);

-- Task 2
--Insert into "Scores"
-- Madeline Bumpus's scores
INSERT INTO Scores (student_id, assignment_id, score) 
VALUES 
(1, 1, 100), -- Full participation
(1, 2, 95),  -- Score for Homework 1
(1, 3, 88);  -- Score for Midterm

-- Angelica's scores
INSERT INTO Scores (student_id, assignment_id, score) 
VALUES 
(2, 1, 100), -- Full participation
(2, 2, 64),  -- Score for Homework 1
(2, 3, 92);  -- Score for Midterm

-- Johan's Score
INSERT INTO Scores (student_id, assignment_id, score) 
VALUES 
(3, 1, 100), -- Full participation
(3, 2, 93),  -- Score for Homework 1
(3, 3, 87);  -- Score for Midterm

-- Task 3: See Folder
-- Task 4
-- average score for an assignment
SELECT AVG(score) AS average_score
FROM Scores
WHERE assignment_id = 2;

--highest score for an assignment
SELECT MAX(score) AS highest_score
FROM Scores
WHERE assignment_id = 2;

--lowest score for an assignment
SELECT MIN(score) AS lowest_score
FROM Scores
WHERE assignment_id = 2;

--Task 5
--List all the students in a given course
--query by course id
SELECT 
    s.student_id, 
    s.first_name, 
    s.last_name
FROM 
    Students s
JOIN 
    Enrollment e ON s.student_id = e.student_id
WHERE 
    e.course_id = 1; -- Assuming 1 is the course_id for "Introduction to Computer Science"

--query by course name
SELECT 
    s.student_id, 
    s.first_name, 
    s.last_name
FROM 
    Students s
JOIN 
    Enrollment e ON s.student_id = e.student_id
JOIN 
    Courses c ON e.course_id = c.course_id
WHERE 
    c.course_name = 'Introduction to Computer Science';

--Task 6
--List all of the students in a course and all of their scores on every assignment;
SELECT 
    s.student_id,
    s.first_name,
    s.last_name,
    c.course_name,
    a.assignment_name,
    sc.score
FROM 
    Students s
JOIN 
    Enrollment e ON s.student_id = e.student_id
JOIN 
    Courses c ON e.course_id = c.course_id
JOIN 
    Scores sc ON s.student_id = sc.student_id
JOIN 
    Assignments a ON sc.assignment_id = a.assignment_id AND a.course_id = c.course_id
WHERE 
    c.course_name = 'Introduction to Computer Science'; -- Or use c.course_id = 1 if you know the course ID

--Task 7
--Add and assigment to a course
SELECT category_id
FROM Categories
JOIN Courses ON Categories.course_id = Courses.course_id
WHERE Courses.course_name = 'Introduction to Computer Science'
AND Categories.category_name = 'Exams';
INSERT INTO Assignments (assignment_name, max_score, category_id) 
VALUES ('Final Exam', 100, 3);

--Task 8
--Change the percentages of the categories for a course;
SELECT course_id FROM Courses WHERE course_name = 'Introduction to Computer Science';
UPDATE Categories 
SET percentage = 30.00 
WHERE course_id = 1 AND category_name = 'Homework';
UPDATE Categories 
SET percentage = 60.00 
WHERE course_id = 1 AND category_name = 'Exams';

--Task 9
--Add 2 points to the score of each student on an assignment;
UPDATE Scores
SET score = score + 2
WHERE assignment_id = 2;
UPDATE Scores
SET score = CASE 
                WHEN score + 2 > 100 THEN 100
                ELSE score + 2 
            END
WHERE assignment_id = 2;

--Task 10
--Add 2 points just to those students whose last name contains a ‘Q’.
UPDATE Scores
SET score = score + 2
WHERE student_id IN (
    SELECT student_id
    FROM Students
    WHERE last_name LIKE '%Q%'
);

--Task 11
--Compute the grade for a student;
SELECT 
    s.student_id,
    SUM((sc.score / a.max_score) * c.percentage) AS weighted_score
FROM 
    Scores sc
JOIN 
    Assignments a ON sc.assignment_id = a.assignment_id
JOIN 
    Categories c ON a.category_id = c.category_id
JOIN 
    Students s ON sc.student_id = s.student_id
WHERE 
    s.student_id = 1
    AND c.course_id = 1
GROUP BY 
    s.student_id;


--Task 12
--Compute the grade for a student, where the lowest score for a given category is dropped.
WITH LowestScores AS (
    SELECT 
        MIN(sc.score) AS lowest_score, 
        a.category_id
    FROM 
        Scores sc
    JOIN 
        Assignments a ON sc.assignment_id = a.assignment_id
    WHERE 
        sc.student_id = 1
    GROUP BY 
        a.category_id
),
TotalScores AS (
    SELECT 
        sc.student_id,
        a.category_id,
        SUM(sc.score) - COALESCE(ls.lowest_score, 0) AS adjusted_score,
        SUM(a.max_score) - (SELECT MIN(a.max_score) FROM Assignments a WHERE a.category_id = c.category_id) AS adjusted_max_score,
        c.percentage
    FROM 
        Scores sc
    JOIN 
        Assignments a ON sc.assignment_id = a.assignment_id
    JOIN 
        Categories c ON a.category_id = c.category_id
    LEFT JOIN 
        LowestScores ls ON a.category_id = ls.category_id
    WHERE 
        sc.student_id = 1 AND c.course_id = 1
    GROUP BY 
        sc.student_id, a.category_id
)
SELECT 
    student_id,
    SUM((adjusted_score / adjusted_max_score) * percentage) AS final_grade
FROM 
    TotalScores
GROUP BY 
    student_id;

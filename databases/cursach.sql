-- Cтворення таблиці StudentClubFresh

CREATE OR REPLACE TABLE StudentClubFresh (
	id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    MemberID VARCHAR(50),
    MemberFirstName VARCHAR(50),
    MemberLastName VARCHAR(50),
    MemberEmail VARCHAR(100),
    MemberPosition VARCHAR(50),
    MemberTshirtSize VARCHAR(20),
    MemberPhone VARCHAR(20),
    MemberZipCode INT,
    
    MajorID VARCHAR(50),
    MajorName VARCHAR(100),
    MajorDepartment VARCHAR(100),
    MajorCollege VARCHAR(100),
    
    ZipCode int,
    ZipType VARCHAR(50),
    ZipCity VARCHAR(100),
    ZipCounty VARCHAR(100),
    ZipState VARCHAR(100),
    ZipShortState VARCHAR(10),
    
    EventID VARCHAR(50),
    EventMemberID VARCHAR(50),
    EventName VARCHAR(100),
    EventDate DATETIME,
    EventType VARCHAR(50),
    EventNotes TEXT,
    EventLocation VARCHAR(100),
    EventStatus VARCHAR(50)    
);

-- Cтворення процедури парсингу
DELIMITER $$

CREATE PROCEDURE convertStudentClub()
BEGIN
  INSERT INTO StudentClubFresh (
    MemberID, MemberFirstName, MemberLastName, MemberEmail, MemberPosition, MemberTshirtSize, MemberPhone, MemberZipCode,
    MajorID, MajorName, MajorDepartment, MajorCollege,
    ZipCode, ZipType, ZipCity, ZipCounty, ZipState, ZipShortState,
    EventID, EventMemberID, EventName, EventDate, EventType, EventNotes, EventLocation, EventStatus
  )
  SELECT
    JSON_UNQUOTE(JSON_EXTRACT(json_data, '$.MemberID')),
    JSON_UNQUOTE(JSON_EXTRACT(json_data, '$.MemberFirstName')),
    JSON_UNQUOTE(JSON_EXTRACT(json_data, '$.MemberLastName')),
    JSON_UNQUOTE(JSON_EXTRACT(json_data, '$.MemberEmail')),
    JSON_UNQUOTE(JSON_EXTRACT(json_data, '$.MemberPosition')),
    JSON_UNQUOTE(JSON_EXTRACT(json_data, '$.MemberTshirtSize')),
    JSON_UNQUOTE(JSON_EXTRACT(json_data, '$.MemberPhone')),
    IF(
      JSON_UNQUOTE(JSON_EXTRACT(json_data, '$.MemberZipCode')) IS NULL
      OR JSON_UNQUOTE(JSON_EXTRACT(json_data, '$.MemberZipCode')) = 'null',
      NULL,
      CAST(JSON_UNQUOTE(JSON_EXTRACT(json_data, '$.MemberZipCode')) AS UNSIGNED)
    ),

    JSON_UNQUOTE(JSON_EXTRACT(json_data, '$.MajorID')),
    JSON_UNQUOTE(JSON_EXTRACT(json_data, '$.MajorName')),
    JSON_UNQUOTE(JSON_EXTRACT(json_data, '$.MajorDepartment')),
    JSON_UNQUOTE(JSON_EXTRACT(json_data, '$.MajorCollege')),

    IF(
      JSON_UNQUOTE(JSON_EXTRACT(json_data, '$.ZipCode')) IS NULL
      OR JSON_UNQUOTE(JSON_EXTRACT(json_data, '$.ZipCode')) = 'null',
      NULL,
      CAST(JSON_UNQUOTE(JSON_EXTRACT(json_data, '$.ZipCode')) AS UNSIGNED)
    ),
    JSON_UNQUOTE(JSON_EXTRACT(json_data, '$.ZipType')),
    JSON_UNQUOTE(JSON_EXTRACT(json_data, '$.ZipCity')),
    JSON_UNQUOTE(JSON_EXTRACT(json_data, '$.ZipCounty')),
    JSON_UNQUOTE(JSON_EXTRACT(json_data, '$.ZipState')),
    JSON_UNQUOTE(JSON_EXTRACT(json_data, '$.ZipShortState')),

    JSON_UNQUOTE(JSON_EXTRACT(json_data, '$.EventID')),
    JSON_UNQUOTE(JSON_EXTRACT(json_data, '$.EventMemberID')),
    JSON_UNQUOTE(JSON_EXTRACT(json_data, '$.EventName')),
    IF(
      JSON_UNQUOTE(JSON_EXTRACT(json_data, '$.EventDate')) IS NULL
      OR JSON_UNQUOTE(JSON_EXTRACT(json_data, '$.EventDate')) = 'null',
      NULL,
      STR_TO_DATE(JSON_UNQUOTE(JSON_EXTRACT(json_data, '$.EventDate')), '%Y-%m-%d %h:%i %p')
    ),
    JSON_UNQUOTE(JSON_EXTRACT(json_data, '$.EventType')),
    JSON_UNQUOTE(JSON_EXTRACT(json_data, '$.EventNotes')),
    JSON_UNQUOTE(JSON_EXTRACT(json_data, '$.EventLocation')),
    JSON_UNQUOTE(JSON_EXTRACT(json_data, '$.EventStatus'))
  FROM StudentClub;
END$$

DELIMITER ;


call convertStudentClub();
DROP PROCEDURE IF EXISTS convertStudentClub;

-- Очищаємо rec

UPDATE StudentClubFresh
SET MemberID = SUBSTRING(MemberID, 4)
WHERE MemberID LIKE 'rec%';

UPDATE StudentClubFresh
SET MajorID = SUBSTRING(MajorID, 4)
WHERE MajorID LIKE 'rec%';

UPDATE StudentClubFresh
SET EventID = SUBSTRING(EventID, 4)
WHERE EventID LIKE 'rec%';

UPDATE StudentClubFresh
SET EventMemberID = SUBSTRING(EventMemberID, 4)
WHERE EventMemberID LIKE 'rec%';


-- Заміна NULL

UPDATE StudentClubFresh
SET
  MemberID = NULLIF(MemberID, 'null'),
  MemberFirstName = NULLIF(MemberFirstName, 'null'),
  MemberLastName = NULLIF(MemberLastName, 'null'),
  MemberEmail = NULLIF(MemberEmail, 'null'),
  MemberPosition = NULLIF(MemberPosition, 'null'),
  MemberPhone = NULLIF(MemberPhone, 'null'),
  MemberTshirtSize = NULLIF(MemberTshirtSize, 'null'),

  MajorID = NULLIF(MajorID, 'null'),
  MajorName = NULLIF(MajorName, 'null'),
  MajorDepartment = NULLIF(MajorDepartment, 'null'),
  MajorCollege = NULLIF(MajorCollege, 'null'),

  ZipCity = NULLIF(ZipCity, 'null'),
  ZipCounty = NULLIF(ZipCounty, 'null'),
  ZipState = NULLIF(ZipState, 'null'),
  ZipShortState = NULLIF(ZipShortState, 'null'),
  ZipType = NULLIF(ZipType, 'null'),

  EventMemberID = NULLIF(EventMemberID, 'null'),
  EventID = NULLIF(EventID, 'null'),
  EventLocation = NULLIF(EventLocation, 'null'),
  EventName = NULLIF(EventName, 'null'),
  EventNotes = NULLIF(EventNotes, 'null'),
  EventStatus = NULLIF(EventStatus, 'null'),
  EventType = NULLIF(EventType, 'null');

-- Виокремлення Студентів
CREATE TABLE Members AS SELECT MemberID, MemberFirstName, MemberLastName,
MemberEmail, MemberPosition, MemberPhone, MemberTshirtSize, MemberZipCode, MajorID
FROM StudentClubFresh scf 
WHERE MemberID IS NOT NULL
GROUP BY scf.MemberID;

ALTER TABLE Members
ADD PRIMARY KEY (MemberID),
MODIFY MemberFirstName VARCHAR(30) NOT NULL,
MODIFY MemberLastName VARCHAR(30) NOT NULL,
MODIFY MemberEmail VARCHAR(30) NOT NULL,
MODIFY MemberPhone VARCHAR(20) NOT NULL,
MODIFY MemberPosition ENUM('Inactive', 'Member', 'President', 'Secretary', 'Treasurer', 'Vice President') NOT NULL,
MODIFY MemberTshirtSize ENUM('Large', 'Medium', 'Small', 'X-Large') NOT NULL;

-- Виокремлення таблиці спеціальностей

CREATE TABLE Majors AS SELECT MajorID, MajorName, MajorDepartment, MajorCollege
FROM StudentClubFresh scf 
WHERE scf.MajorID IS NOT NULL
GROUP BY MajorID;

ALTER TABLE Majors
MODIFY MajorName VARCHAR(100) NOT NULL,
ADD PRIMARY KEY (MajorID);

-- Виокремлення таблиці Zip Кодів

CREATE TABLE Zip AS SELECT ZipCode, ZipCity, ZipCounty, ZipState, ZipShortState, ZipType
FROM StudentClubFresh scf
WHERE ZipCode IS NOT NULL
GROUP BY ZipCode;

ALTER TABLE Zip
MODIFY ZipType ENUM('Unique', 'Standard', 'PO Box') NOT NULL,
ADD PRIMARY KEY (ZipCode);

-- Виокремленя таблиці подій

CREATE TABLE Events AS SELECT EventID, EventDate, EventLocation, EventName, EventNotes, EventStatus, EventType
FROM StudentClubFresh scf
WHERE scf.EventID IS NOT NULL
GROUP BY scf.EventID;

ALTER TABLE Events
ADD PRIMARY KEY (EventID),
MODIFY EventName VARCHAR(100) NOT NULL,
MODIFY EventDate datetime NOT NULL,
MODIFY EventType ENUM("Standard"),
MODIFY EventStatus ENUM('Closed', 'Open', 'Planning') NOT NULL;


-- створення таблиці Мембер-івентс та зв'язування ключами

CREATE TABLE MemberEvents AS SELECT MemberID, EventID
FROM StudentClubFresh scf 
WHERE MemberID IS NOT NULL and EventID IS NOT NULL;

ALTER TABLE MemberEvents
ADD PRIMARY KEY (MemberID, EventID),
ADD CONSTRAINT fk_Member FOREIGN KEY (MemberID) REFERENCES Members(MemberID),
ADD CONSTRAINT fk_Event FOREIGN KEY (EventID) REFERENCES Events(EventID);


ALTER TABLE Members 
MODIFY COLUMN MemberZipCode INT NOT NULL,
ADD CONSTRAINT fk_Major FOREIGN KEY (MajorID) REFERENCES Majors(MajorID),
ADD CONSTRAINT fk_Zip FOREIGN KEY (MemberZipCode) REFERENCES Zip(ZipCode);

DROP TABLE StudentClubFresh;


-- Відокремлення відділів та коледжів від спеціальностей

CREATE TABLE Departments AS SELECT MajorDepartment as "Department", MajorCollege 
FROM Majors m
GROUP BY MajorDepartment;

ALTER TABLE Departments
ADD COLUMN id INT AUTO_INCREMENT PRIMARY KEY,
MODIFY COLUMN Department VARCHAR(100) NOT NULL;

ALTER TABLE Majors
ADD COLUMN Department INT;

ALTER TABLE Majors
ADD CONSTRAINT f FOREIGN KEY (Department) REFERENCES Departments(id);


UPDATE Majors m
JOIN Departments d 
ON d.Department  = m.MajorDepartment
SET m.Department = d.id;

ALTER TABLE Majors
DROP COLUMN MajorDepartment,
MODIFY COLUMN Department INT NOT NULL,
DROP COLUMN MajorCollege;


-- Виділення коледжів

CREATE TABLE Colleges AS SELECT MajorCollege as "College"
FROM Departments
GROUP BY MajorCollege;

ALTER TABLE Colleges
ADD COLUMN id INT AUTO_INCREMENT PRIMARY KEY,
MODIFY COLUMN College VARCHAR(100) NOT NULL;

ALTER TABLE Departments
ADD COLUMN College INT;

ALTER TABLE Departments
ADD CONSTRAINT fk_College FOREIGN KEY (College) REFERENCES Colleges(id);


CREATE INDEX idx_dep ON Departments(MajorCollege);
CREATE INDEX idx_col ON Colleges(College);

UPDATE Departments m
JOIN Colleges d 
ON d.College = m.MajorCollege
SET m.College = d.id;

DROP INDEX idx_dep ON Departments;
DROP INDEX idx_col ON Colleges;

ALTER TABLE Departments
MODIFY COLUMN College INT NOT NULL,
DROP COLUMN MajorCollege;


-- Виокремлення Cities

CREATE TABLE Cities AS SELECT z.ZipCity as "City", z.ZipState as "ZipState"
FROM Zip z
GROUP BY z.ZipCity, z.ZipState;

ALTER TABLE Cities
ADD COLUMN id INT AUTO_INCREMENT PRIMARY KEY,
MODIFY COLUMN City VARCHAR(50) NOT NULL,
MODIFY COLUMN ZipState VARCHAR(50) NOT NULL;

ALTER TABLE Zip
ADD COLUMN City INT;

ALTER TABLE Zip
ADD CONSTRAINT fk_City FOREIGN KEY (City) REFERENCES Cities(id);


CREATE INDEX idx_zipcity ON Zip(ZipCity);
CREATE INDEX idx_city_city ON Cities(City);

UPDATE Zip z
JOIN Cities c  
ON z.ZipCity = c.City AND z.ZipState = c.ZipState
SET z.City = c.id;

DROP INDEX idx_zipcity ON Zip;
DROP INDEX idx_city_city ON Cities;


ALTER TABLE Zip
MODIFY COLUMN City INT NOT NULL,
DROP COLUMN ZipCity;

-- Відокремлення State ShortState

CREATE TABLE States AS SELECT z.ZipState as "State", z.ZipShortState as "ShortState"
FROM Zip z 
GROUP BY z.ZipState;

ALTER TABLE States
ADD COLUMN id INT AUTO_INCREMENT PRIMARY KEY,
MODIFY COLUMN State VARCHAR(30) NOT NULL,
MODIFY COLUMN ShortState VARCHAR(5) NOT NULL;

ALTER TABLE Cities
ADD COLUMN State INT;

ALTER TABLE Cities
ADD CONSTRAINT fk_State FOREIGN KEY (State) REFERENCES States(id);

UPDATE Cities c
JOIN States s
ON c.ZipState = s.State
SET c.State = s.id;


ALTER TABLE Cities 
DROP COLUMN ZipState,
MODIFY COLUMN State int NOT NULL,
ADD UNIQUE (State, City);



ALTER TABLE Zip 
DROP COLUMN ZipState,
DROP COLUMN ZipShortState;


-- Виділення округів

CREATE TABLE Counties AS SELECT z.ZipCounty as "County"
FROM Zip z 
WHERE NOT ISNULL(z.ZipCounty)
GROUP BY z.ZipCounty;

ALTER TABLE Counties 
ADD COLUMN id INT AUTO_INCREMENT PRIMARY KEY,
MODIFY COLUMN County VARCHAR(50) NOT NULL;


ALTER TABLE Zip
ADD COLUMN County INT;

ALTER TABLE Zip
ADD CONSTRAINT fk_Counties FOREIGN KEY (County) REFERENCES Counties(id);

CREATE INDEX idx_counties ON Counties(County);

UPDATE Zip z
JOIN Counties c  
ON z.ZipCounty = c.County AND NOT ISNULL(z.ZipCounty)
SET z.County = c.id
WHERE NOT ISNULL(z.ZipCounty);

DROP INDEX idx_counties ON Counties;

ALTER TABLE Zip
DROP Column ZipCounty;


-- Створення Zip адрес

CREATE TABLE ZipAddres AS SELECT z.City, z.County
FROM Zip z
GROUP BY z.City, z.County;

ALTER TABLE ZipAddres
ADD CONSTRAINT fk_City_ZipAddres FOREIGN KEY (City) REFERENCES Cities(id),
ADD CONSTRAINT fk_County_ZipAddres FOREIGN KEY (County) REFERENCES Counties(id),
ADD COLUMN id INT AUTO_INCREMENT PRIMARY KEY;

ALTER TABLE Zip
ADD COLUMN ZipAddres INT;

ALTER TABLE Zip
ADD CONSTRAINT fk_ZipAddres FOREIGN KEY (ZipAddres) REFERENCES ZipAddres(id);

UPDATE Zip z
JOIN ZipAddres za
ON z.City = za.City AND NOT ISNULL(z.County) AND z.County = za.County
SET z.ZipAddres = za.id;

UPDATE Zip z
JOIN ZipAddres za
ON z.City = za.City AND ISNULL(z.County)
SET z.ZipAddres = za.id;

ALTER TABLE ZipAddres
ADD CONSTRAINT unique_ZipAddress UNIQUE (City, County);

ALTER TABLE Zip
DROP FOREIGN KEY fk_City,
DROP FOREIGN KEY fk_Counties;

ALTER TABLE Zip
DROP COLUMN City,
DROP COLUMN County;




-- Відокремлення локацій івентів

CREATE TABLE Locations AS SELECT e.EventLocation as "Location"
FROM Events e
WHERE NOT ISNULL(e.EventLocation)
GROUP BY e.EventLocation;

ALTER TABLE Locations 
ADD COLUMN id INT AUTO_INCREMENT PRIMARY KEY,
MODIFY COLUMN Location VARCHAR(50) NOT NULL;

ALTER TABLE Events
ADD COLUMN Location INT;

ALTER TABLE Events
ADD CONSTRAINT fc_location FOREIGN KEY (Location) REFERENCES Locations(id);
CREATE TABLE Locations AS SELECT e.EventLocation as "Location"
FROM Events e
WHERE NOT ISNULL(e.EventLocation)
GROUP BY e.EventLocation;

ALTER TABLE Locations 
ADD COLUMN id INT AUTO_INCREMENT PRIMARY KEY,
MODIFY COLUMN Location VARCHAR(50) NOT NULL;

ALTER TABLE Events
ADD COLUMN Location INT;

ALTER TABLE Events
ADD CONSTRAINT fc_location FOREIGN KEY (Location) REFERENCES Locations(id);


UPDATE Events e
JOIN Locations l 
ON e.EventLocation = l.Location AND NOT ISNULL(e.EventLocation)
SET e.Location = l.id
WHERE NOT ISNULL(e.EventLocation);

ALTER TABLE Events
DROP COLUMN EventLocation;

UPDATE Events e
JOIN Locations l 
ON e.EventLocation = l.Location AND NOT ISNULL(e.EventLocation)
SET e.Location = l.id
WHERE NOT ISNULL(e.EventLocation);

ALTER TABLE Events
DROP COLUMN EventLocation;

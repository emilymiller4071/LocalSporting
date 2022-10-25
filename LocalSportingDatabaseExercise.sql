--First we need to use master for our new database using SQL commands

USE master;
GO

--we need to drop the database if it is found

IF DB_ID(LocalSporting) IS NOT NULL
	DROP DATABASE LocalSporting
GO

/* Now for the fun stuff! We have dropped any previous database
with the name LocalSporting, so the following code will create (or recreate)
the LocalSporting database, then it will change our drop down to
LocalSporting*/


CREATE DATABASE LocalSporting;

USE LocalSporting
GO


/*Time for some table creation.  It's important to start with a table that does
not have FK, since you can't reference something
that does not yet exist.  Our Sports table has only a PK, so we will
begin there  */


CREATE TABLE Sports
(
	SportID					INT				NOT NULL IDENTITY PRIMARY KEY,
	SportName				VARCHAR(25)		NOT NULL,
	PracticeDay				VARCHAR(25)		NOT NULL,
	RegistrationFee			MONEY			NOT NULL
);
 --I realized later on that I wanted this table to also hold PracticeLocation

ALTER TABLE Sports
ADD PracticeLocation		 INT			NOT NULL;


--What fun is an empty table?  Let's fill it with joy.


INSERT INTO Sports (SportName, PracticeDay, RegistrationFee, PracticeLocation)
VALUES 
('Volleyball', 'Saturday', 500, 1),
('Volleyball', 'Wednesday', 500, 1),
('Volleyball', 'Friday', 500, 1),
('Jazzercise', 'Monday', 250, 4),
('Jazzercise', 'Tuesday', 250, 4),
('Basketball', 'Thursday', 400, 2),
('Basketball', 'Wednesday', 400, 2),
('Tiny Tots', 'Friday', 75, 3);


/*  I know you're thinking that Jazzercise is not actually a sport,
but Aunt Edna can't exactly run around chucking dodgeballs, so we're 
counting it, OK?  */

-- quick sanity check, as Kait likes to say

SELECT * FROM Sports;

/* Everything looks good in Sports table, time to create our
Athletes table.  This table has a PK, and also one FK.  It is fine that it has the 
FK, since it is only referencing the table that we just created (Sports).  This table
includes a null column, as not everyone goes by a nickname.  I know you're 
jealous of Emily Miller's nickname  */

CREATE TABLE Athletes 
(
	AthleteID				INT				NOT NULL IDENTITY PRIMARY KEY,
	AthleteFName			VARCHAR(25)		NOT NULL,
	AthleteLName			VARCHAR(25)		NOT NULL,
	Nickname				VARCHAR(25)		NULL,
	FavoriteSnack			VARCHAR(25)		NULL,
	AthleteAge				TINYINT			NOT NULL,
	SportParticipating		INT				NOT NULL REFERENCES Sports(SportID)
);


SELECT * FROM Athletes;

--ok, I really only put FavoriteSnack in here so that I could drop it...

ALTER TABLE Athletes
DROP COLUMN FavoriteSnack;

--make a table, fill a table...

INSERT INTO Athletes
(AthleteFName, AthleteLName, Nickname, AthleteAge, SportParticipating)
VALUES
('Emily', 'Miller', 'The Barracuda', 39, 4),
('Dustin', 'Miller', 'Dusty', 40, 6),
('Dex', 'Alexander', NULL, 11, 4),
('Addison', 'Jean', 'Addie', 14, 1),
('Juniper', 'Eve', 'Juni', 3, 8),
('Adeline', 'Curry', 'Addy', 4, 8),
('Brody', 'Crawford', NULL, 9, 7),
('Ethan', 'Fasbender', NULL, 5, 6),
('Finley', 'Chard', 'Finn', 3, 8),
('Gavin', 'Messer', NULL, 27, 4),
('Hazel', 'Smith', NULL, 44, 4),
('Isabel', 'Ginsele', 'Izzy', 12, 1),
('Joseph', 'Meiser', 'Joe', 15, 7),
('Luciana', 'Ariapad', 'Luci', 13, 2),
('Olivia', 'Bain', 'Livvy', 12, 2),
('Ronan', 'Caudill', NULL, 39, 3),
('Rose', 'Henson', 'Rosie', 61, 3),
('Ruby', 'Henson', NULL, 56, 5),
('Tarik', 'Qazzaz', NULL, 48, 5),
('Wyatt', 'Featherstone', NULL, 39, 5);




/* We need a table to store information about the locations that 
our sports will meet.  Let's create SportingLocation. This table only holds a FK
that refers back to the Sports table.  It doesn't need a PK  */

CREATE TABLE SportingLocation
(
SportID					INT				NOT NULL REFERENCES Sports (SportID),
LocationID				INT				NOT NULL,
ArenaAddress			VARCHAR(50)		NOT NULL,
ArenaCity				VARCHAR(20)		NOT NULL,
ArenaState				VARCHAR(20)		NOT NULL,		
ArenaZip				SMALLINT		NOT NULL,
LocationName			VARCHAR(50)		NOT NULL
);


--SMALLINT did not work for a zip code, change datatype to VARCHAR(20)

ALTER TABLE SportingLocation
ALTER COLUMN ArenaZip VARCHAR(20);

INSERT INTO SportingLocation (LocationID, LocationName, ArenaAddress, ArenaCity, ArenaState, ArenaZip, SportID)
VALUES 
(1, 'Sports of All Sorts', '10094 Investment Way', 'Florence', 'KY', '41042', 1),
(1, 'Sports of All Sorts', '10094 Investment Way', 'Florence', 'KY', '41042', 2),
(1, 'Sports of All Sorts', '10094 Investment Way', 'Florence', 'KY', '41042', 3),
(2, 'Sports Plus', '10765 Reading Rd.', 'Cincinnati', 'OH', '45241', 6),
(2, 'Sports Plus', '10765 Reading Rd.', 'Cincinnati', 'OH', '45241', 7),
(3, 'Recreations Outlet', '885 OH-28', 'Milford', 'OH','45150', 8),
(4, 'Expressions Dance Theatre', '2434 High St.', 'Crescent Springs', 'KY', '41017', 4),
(4, 'Expressions Dance Theatre', '2434 High St.', 'Crescent Springs', 'KY', '41017', 5);


--did it work? Let's check!
SELECT * FROM SportingLocation;

/* Our final table is the SportingInvoices table, since you can't play
sports for free :(   
This table has a PK and also an FK that refers to our Athletes table, for the purpose
of sending an invoice to the correct player. PaymentAmount needs to be null, because sometimes 
people haven't paid yet (new player) or is dodging their bill. You can't have a PaymentDate if
you haven't paid, so null there. Not everyone will have a Credit to their account, so a third null */

CREATE TABLE SportingInvoices
(
InvoiceID			INT				NOT NULL IDENTITY PRIMARY KEY,
AthleteID			INT				NOT NULL REFERENCES Athletes(AthleteID),
InvoiceAmount		MONEY			NOT NULL,
PaymentAmount		MONEY			NULL,
CreditTotal			MONEY			NULL,
InvoiceDueDate		DATE			NOT NULL,
PaymentDate			DATE			NULL		
);



/* Received this error message when trying to insert into SportingInvoices

Msg 206, Level 16, State 2, Line 123
Operand type clash: int is incompatible with date

I received it for making a very time consuming mistake.  I probably should have known
this, but the date needs to be a string.  I did enter all of these bajillion invoice records, only
to realize my mistake.  I got to spend half of forever typing ' ' around each and 
every one.  Time will tell if I have officially learned this lesson  */



INSERT INTO SportingInvoices (AthleteID, InvoiceAmount, CreditTotal, InvoiceDueDate, PaymentAmount, PaymentDate)
VALUES
(1,		250,	0,		'2022-09-01',		0,		NULL),
(1,		250,	0,		'2022-10-01',		100,	'2022-10-01'),
(1,		250,	0,		'2022-11-01',		0,		NULL),
(1,		250,	250,	'2022-12-01',		500,	'2022-11-03'),
(2,		500,	0,		'2022-09-01',		500,	'2022-09-01'),
(2,		500,	0,		'2022-10-01',		100,	'2022-10-01'),
(2,		500,	0,		'2022-11-01',		0,		NULL),
(2,		500,	0,		'2022-12-01',		500,	'2022-11-02'),
(3,		250,	0,		'2022-09-01',		500,	'2022-09-01'),
(3,		250,	200,	'2022-10-01',		300,	'2022-10-01'),
(3,		250,	0,		'2022-11-01',		500,	'2022-11-01'),
(3,		250,	0,		'2022-12-01',		500,	'2022-11-28'),
(4,		500,	0,		'2022-09-01',		500,	'2022-09-01'),
(4,		500,	0,		'2022-10-01',		100,	'2022-10-01'),
(4,		500,	0,		'2022-11-01',		0,		NULL),
(4,		500,	0,		'2022-12-01',		500,	'2022-11-02'),
(5,		75,		0,		'2022-07-01',		75,		'2022-09-01'),
(5,		75,		0,		'2022-08-01',		75,		'2022-10-01'),
(5,		75,		0,		'2022-09-01',		0,		NULL),
(5,		75,		0,		'2022-10-01',		0,		NULL),
(6,		75,		0,		'2022-02-01',		75,		'2022-02-03'),
(6,		75,		75,		'2022-03-01',		75,		'2022-03-01'),
(6,		75,		0,		'2022-04-01',		0,		NULL),
(6,		75,		0,		'2022-05-01',		25,		'2022-05-02'),
(8,		400,	0,		'2022-06-01',		0,		NULL),
(8,		400,	0,		'2022-07-01',		800,	'2022-07-02'),
(8,		400,	0,		'2022-08-01',		400,	'2022-08-01'),
(8,		400,	0,		'2022-09-01',		0,		NULL),
(9,		75,		0,		'2022-07-01',		75,		'2022-07-01'),
(9,		75,		0,		'2022-08-01',		75,		'2022-08-01'),
(9,		75,		0,		'2022-09-01',		75,		'2022-09-01'),
(9,		75,		0,		'2022-10-01',		0,		NULL),
(10,	250,	0,		'2022-10-01',		250,	'2022-10-01'),
(10,	250,	0,		'2022-11-01',		250,	'2022-11-01'),
(11,	250,	200,	'2022-10-01',		300,	'2022-10-01'),
(11,	250,	0,		'2022-11-01',		150,	'2022-11-01'),
(12,	500,	0,		'2022-09-01',		0,		NULL),
(13,	400,	0,		'2022-07-01',		400,	'2022-07-02'),
(13,	400,	0,		'2022-08-01',		400,	'2022-08-01'),
(14,	500,	0,		'2022-01-01',		500,	'2022-01-01'),
(14,	500,	0,		'2022-02-01',		100,	'2022-02-01'),
(14,	500,	0,		'2022-03-01',		0,		NULL),
(15,	500,	0,		'2022-07-01',		500,	'2022-07-06'),
(15,	500,	200,	'2022-08-01',		100,	'2022-08-01'),
(15,	500,	0,		'2022-09-01',		500,	'2022-09-03'),
(16,	500,	0,		'2021-09-01',		500,	'2021-09-01'),
(17,	500,	0,		'2022-03-01',		0,		NULL),
(17,	500,	0,		'2022-04-01',		500,	'2022-07-06'),
(17,	500,	0,		'2022-05-01',		450,	'2022-08-01'),
(17,	500,	0,		'2022-06-01',		500,	'2022-09-03'),
(17,	500,	0,		'2022-07-01',		0,		NULL),
(18,	250,	0,		'2022-10-01',		250,	'2022-10-01'),
(18,	250,	0,		'2022-11-01',		250,	'2022-11-01'),
(19,	250,	200,	'2022-10-01',		0,		NULL),
(20,	250,	0,		'2021-10-01',		150,	'2022-10-01'),
(20,	250,	0,		'2021-11-01',		250,	'2022-11-01'),
(20,	250,	0,		'2021-12-01',		250,	'2022-12-01'),
(20,	250,	200,	'2022-01-01',		300,	'2022-01-01');

	


/* Athlete is pausing his membership, so InvoiceID does not need paid.  
Removing from SportingInvoices  */

DELETE FROM SportingInvoices
WHERE InvoiceID = 3;

/* I want to see which students are the youngest athletes are to assign 
them correctly to Tiny Tots, and see which students will be moving on
in the near future.  I will sort the AthleteAge   */

SELECT AthleteAge
FROM Athletes
ORDER BY AthleteAge ASC;

/* We need to see who owes us the most $$ */

SELECT TOP 10 InvoiceAmount
FROM SportingInvoices
ORDER BY InvoiceAmount DESC;



SELECT DISTINCT AthleteID, InvoiceAmount AS 'Invoice Total', PaymentAmount
	AS 'Payment Amount'
FROM SportingInvoices
WHERE InvoiceAmount IN (75, 400)
ORDER BY InvoiceAmount ASC;

--I wanted to view Invoices from last year

SELECT InvoiceAmount - CreditTotal - PaymentAmount AS BalanceDue, InvoiceDueDate, AthleteID
FROM SportingInvoices
WHERE InvoiceDueDate BETWEEN '2021-01-01' AND '2021-12-31'
ORDER BY BalanceDue DESC;

/* !!! I posted a question about this in Teams. OK, I've been running queries 
on the database that I created for our last class.  After reading over the new notes 
on JOIN types (INNER, RIGHT, LEFT), I think I'm seeing it more clearly.  When drafting 
the plan for the tables, however, they contain information that connects between tables 
(purposely, as I'm pretty sure that's the point).  My question is, if the information used
to create the tables is information that connects...won't all of these JOINS produce the 
same result set?  I'm wondering if I need to add Athletes to the table that do not connect
to the Invoices, Locations, or SportingEvent tables and so on through the other tables in 
order to achieve a differing result set for the JOIN types.  Hopefully this is 
correct. 

JOIN information from Athletes table and SportingInvoices table to show the balance due
for each athlete */

SELECT AthleteFName + ' ' + AthleteLName AS 'Athlete Name', 
	InvoiceAmount - CreditTotal - PaymentAmount AS 'Balance Due'
FROM Athletes 
	INNER JOIN SportingInvoices
	ON Athletes.AthleteID = SportingInvoices.AthleteID
ORDER BY 'Balance Due' DESC;


SELECT AthleteFName + ' ' + AthleteLName AS 'Athlete Name', 
	InvoiceAmount - CreditTotal - PaymentAmount AS 'Balance Due'
FROM Athletes 
	RIGHT JOIN SportingInvoices
	ON Athletes.AthleteID = SportingInvoices.AthleteID
ORDER BY 'Balance Due' DESC;



SELECT AthleteFName + ' ' + AthleteLName AS 'Athlete Name', 
	InvoiceAmount - CreditTotal - PaymentAmount AS 'Balance Due'
FROM Athletes 
	LEFT JOIN SportingInvoices
	ON Athletes.AthleteID = SportingInvoices.AthleteID
ORDER BY 'Balance Due' DESC;

/* After testing my theory, I wanted to add some Athletes that were no longer participating in sports 
that were in the Sports table. Changed datatype to accept null, so I could add some athletes
that wouldn't be included in all join types.  Fingers crossed */

ALTER TABLE Athletes
ALTER COLUMN SportParticipating  INT NULL;

INSERT INTO Athletes
(AthleteFName, AthleteLName, Nickname, AthleteAge, SportParticipating)
VALUES
('Christine', 'Miller', 'Chrissy', 37, NULL),
('Daniel', 'Alan', 'Dan', 56, NULL),
('Chelsea', 'Everett', NULL, 11, NULL),
('Ean', 'Everett', NULL, 14, NULL);

--Continuing to add information that will not occur in another table

INSERT INTO Sports (SportName, PracticeDay, RegistrationFee, PracticeLocation)
VALUES 
('Cheerleading', 'Saturday', 275, 1),
('Karate', 'Wednesday', 500, 2),
('Pilates', 'Friday', 500, 4);


--Checking that the information displays as hoped

SELECT * FROM Sports
SELECT * FROM Athletes


/* Now that I have inserted information into Athletes and Sports that will not appear in 
both tables...let's hope some JOIN magic happens  */

SELECT AthleteID, AthleteFName, AthleteLName, SportID, LocationName
FROM Athletes INNER JOIN SportingLocation
ON Athletes.SportParticipating = SportingLocation.SportID;

SELECT AthleteID, AthleteFName, AthleteLName, SportID, LocationName
FROM Athletes RIGHT JOIN SportingLocation
ON Athletes.SportParticipating = SportingLocation.SportID;

SELECT AthleteID, AthleteFName, AthleteLName, SportID, LocationName
FROM Athletes LEFT JOIN SportingLocation
ON Athletes.SportParticipating = SportingLocation.SportID;

--This is where I do a dance, because it worked!


/* SUM function to get a total of balance due  */

SELECT SUM(InvoiceAmount - CreditTotal- PaymentAmount) AS 'Total Outstanding Balance'
FROM SportingInvoices;

/* COUNT function queries...this was fun!  */

SELECT COUNT(InvoiceAmount - CreditTotal- PaymentAmount) AS 'Number of Accounts Owing Money'
FROM SportingInvoices
WHERE (InvoiceAmount - CreditTotal- PaymentAmount) <> 0;


SELECT COUNT(InvoiceAmount - CreditTotal- PaymentAmount) AS 'Accounts With 0 Balance'
FROM SportingInvoices
WHERE (InvoiceAmount - CreditTotal- PaymentAmount) = 0;


/* I realized that the CreditTotal column was nullable, however, I didn't assign any 
records as null...I executed the folowing command to remedy that  */

UPDATE SportingInvoices
SET CreditTotal = NULL
WHERE AthleteID IN (8, 17);


SELECT
	COUNT(*) AS 'All CreditTotal Lines',
	COUNT(CreditTotal) AS 'All non-NULL Credits',
	COUNT(*) - COUNT(CreditTotal) AS '# of NULL CreditTotal Lines'
FROM SportingInvoices;


--Sanity check

SELECT * FROM SportingInvoices

/* Using the AVG function to find the Average amount that people owe,
only including people with an outstanding balance.  */

SELECT AVG(InvoiceAmount - CreditTotal- PaymentAmount) AS 'Average Amount Owed'
FROM SportingInvoices
WHERE (InvoiceAmount - CreditTotal- PaymentAmount) <> 0
ORDER BY AVG(InvoiceAmount - CreditTotal- PaymentAmount) DESC;


/* I want to send an invoice that has the full name of the athlete,
the sport played, and the address of practice location they will go to, along with an invoice amount.  
This will be printed and mailed to each participant */


SELECT DISTINCT AthleteFName + ' ' + AthleteLName AS AthleteName, SportName, LocationName,
	(ArenaAddress + ' ' + ArenaCity + ', ' + ArenaState + ' ' + ArenaZip) AS PracticeLocationAddress,
	SUM(InvoiceAmount - CreditTotal - PaymentAmount) AS BalanceDue
FROM Athletes RIGHT JOIN Sports
	ON Athletes.SportParticipating = Sports.SportID
	JOIN SportingLocation
	ON Sports.SportID = SportingLocation.SportID
	LEFT JOIN SportingInvoices
	ON Athletes.AthleteID = SportingInvoices.AthleteID
GROUP BY (AthleteFName + ' ' + AthleteLName), SportName, Sports.SportID, LocationName,
	(ArenaAddress + ' ' + ArenaCity + ', ' + ArenaState + ' ' + ArenaZip), InvoiceAmount
ORDER BY AthleteName;


/* Showing that Dex Miller does in fact have an invoice balance of -$1000, he likes to 
pay ahead  */

SELECT * FROM SportingInvoices
WHERE AthleteID = 3


-- Using CONCAT to create full names
SELECT CONCAT(AthleteFName, ' ', AthleteLName) AS AthleteFullName
FROM Athletes


/* Comment for commit  */
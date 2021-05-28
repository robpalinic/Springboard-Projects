/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a Python connection.

This is Tier 2 of the case study, which means that there'll be less guidance for you about how to setup
your local SQLite connection in PART 2 of the case study. This will make the case study more challenging for you:
you might need to do some digging, aand revise the Working with Relational Databases in Python chapter in the previous resource.

Otherwise, the questions in the case study are exactly the same as with Tier 1.

PART 1: PHPMyAdmin
You will complete questions 1-9 below in the PHPMyAdmin interface.
Log in by pasting the following URL into your browser, and
using the following Username and Password:

URL: https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

In this case study, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */


/* QUESTIONS
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */

SELECT * FROM Facilities WHERE membercost>0;


/* Q2: How many facilities do not charge a fee to members? */

SELECT COUNT(facid) FROM Facilities WHERE membercost=0;


/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT * FROM Facilities WHERE membercost>0 AND membercost/monthlymaintenance<.2;


/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */

SELECT * FROM Facilities WHERE FACID IN (1,5) ORDER BY FACID;


/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */

SELECT name, monthlymaintenance, CASE WHEN monthlymaintenance>100 THEN 'expensive' ELSE 'cheap' END AS category FROM Facilities;


/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */

SELECT firstname, surname FROM Members WHERE joindate=(SELECT MAX(joindate) FROM Members);


/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT 	DISTINCT CONCAT(a.firstname, a.surname) as member_name,c.name
FROM Members a INNER JOIN Bookings b ON a.memid=b.memid INNER JOIN Facilities c ON b.facid=c.facid AND c.name LIKE ('%Tennis Court%')
WHERE firstname <>'GUEST'
ORDER BY member_name;


/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT
	b.name,
	CONCAT(c.firstname, c.surname) as member,
	(b.membercost+b.guestcost) as cost
FROM
	Bookings a
	INNER JOIN Facilities b on a.facid=b.facid
	INNER JOIN Members c on a.memid=c.memid
WHERE
	DATE_FORMAT(a.starttime, '%Y-%m-%d')='2012-09-14' AND
	(b.membercost+b.guestcost)>30
ORDER BY (b.membercost+b.guestcost) DESC;


/* Q9: This time, produce the same result as in Q8, but using a subquery. */

SELECT
	a.name,
	CONCAT(b.firstname, b.surname) as member,
	a.cost
FROM
	(SELECT
     	b.name,
     	a.memid,
     	b.membercost+b.guestcost AS cost
     FROM
     	Bookings a
     	INNER JOIN Facilities b on a.facid=b.facid
     WHERE DATE_FORMAT(a.starttime, '%Y-%m-%d')='2012-09-14') a
	INNER JOIN Members b ON a.memid=b.memid
WHERE a.cost>30
ORDER BY a.cost DESC


/* PART 2: SQLite

Export the country club data from PHPMyAdmin, and connect to a local SQLite instance from Jupyter notebook
for the following questions.

QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

SELECT
	name,
	sum(revenue) AS TotalRevenue
FROM
	(SELECT
		a.bookid,
		a.facid,
		b.name,
		CASE WHEN a.memid=0 THEN b.guestcost ELSE b.membercost END AS Revenue
	FROM
		Bookings a
		LEFT JOIN Facilities b ON a.facid=b.facid) a
GROUP BY name
HAVING sum(revenue)<1000
ORDER BY TotalRevenue DESC;

/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */
SELECT
	a.firstname,
	a.surname,
	CASE WHEN b.firstname = 'Guest' THEN 'No Recommender' ELSE b.firstname END as Recommender_FirstName,
	CASE WHEN b.surname = 'Guest' THEN 'No Recommender' ELSE b.surname END as Recommender_Surname
FROM
	Members a
	INNER JOIN Members b ON a.recommendedby=b.memid
WHERE a.firstname<>'Guest'
ORDER BY a.surname, a.firstname



/* Q12: Find the facilities with their usage by member, but not guests */
SELECT
	a.facid,
	b.name,
	COUNT(memid) as Member_Usage
FROM
	Bookings a
	LEFT JOIN Facilities b ON a.facid=b.facid
WHERE
	memid<>0
GROUP BY a.facid
ORDER BY COUNT(memid) DESC;


/* Q13: Find the facilities usage by month, but not guests */

SELECT
	b.name,
	MONTHNAME(a.starttime) AS Mth,
	COUNT(a.bookid) as Monthly_Usage
FROM
	Bookings a
	LEFT JOIN Facilities b on a.facid=b.facid
WHERE memid<>0
GROUP BY a.facid, Mth
ORDER BY a.facid, EXTRACT(Month FROM a.starttime)

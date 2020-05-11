-- Solution to https://mystery.knightlab.com


-- Starting Point
-- You vaguely remember that the crime was a ​murder​ that occurred sometime on ​Jan.15, 2018​ and that it took place in ​SQL City​. Start by retrieving the corresponding crime scene report from the police department’s database.

-- Step 1: Find the murderer...

-- We only care about murders on Jan 15 in SQL City...
SELECT *
FROM crime_scene_report
WHERE type = 'murder'
AND city = 'SQL City'
AND date = '20180115';

-- This yields one record, with the following description:
-- Security footage shows that there were 2 witnesses. The first witness lives at the last house on "Northwestern Dr". The second witness, named Annabel, lives somewhere on "Franklin Ave".

-- To find witness 1:
SELECT *
FROM person
WHERE address_street_name = 'Northwestern Dr'
ORDER BY address_number DESC
LIMIT 1;

-- To find witness 2:
SELECT *
FROM person
WHERE address_street_name = 'Franklin Ave'
AND name LIKE '%Annabel%';

-- From here, I can look to see if either provided a transcript in the interview table...

-- Witness 1:
-- person_id = 14887

SELECT *
FROM interview
WHERE person_id = 14887;

-- The transcript contained the following: I heard a gunshot and then saw a man run out. He had a "Get Fit Now Gym" bag. The membership number on the bag started with "48Z". Only gold members have those bags. The man got into a car with a plate that included "H42W".

-- Witness 2:
-- person_id = 16371

SELECT *
FROM interview
WHERE person_id = 16371

-- The transcript contained the following: I saw the murder happen, and I recognized the killer from my gym when I was working out last week on January the 9th.

-- From the two transcripts, the following information was found:
  -- man
  -- "Get Fit Now Gym" bag
  -- membership number on the bag started with "48Z"
  -- gold member
  -- car with a plate that included "H42W"

  -- recognized the killer from Witness 2's gym when I was working out last week on January the 9th

-- To find the time when witness 2 went to the gym on Jan 9th...
SELECT get_fit_now_check_in.*
FROM person
INNER JOIN get_fit_now_member
  ON person.id = get_fit_now_member.person_id
  AND person.id = 16371 -- Witness 2 ID
INNER JOIN get_fit_now_check_in
  ON get_fit_now_member.id = get_fit_now_check_in.membership_id
  AND check_in_date

-- checked in at 1600 and checked out at 1700

-- Could try searching for overlap in gym time with witness 2...
SELECT *
FROM get_fit_now_check_in
WHERE check_in_date = 20180109
AND check_out_time >= 1600
AND check_in_time <= 1700
AND membership_id != 90081 --exclude w2 membership id
AND membership_id LIKE '%48Z%' --clue from w1

-- this yields two records, shown below

  -- membership_id	check_in_date	check_in_time	check_out_time
  -- 48Z7A	20180109	1600	1730
  -- 48Z55	20180109	1530	1700

-- Using other clues from witness 1 to filter results...

  -- first only using gym data...
  SELECT *
  FROM get_fit_now_member
  WHERE
  	id in ('48Z7A','48Z55')
  	AND membership_status = 'gold'
    and membership_start_date <= 20180109

  -- id	person_id	name	membership_start_date	membership_status
  -- 48Z55	67318	Jeremy Bowers	20160101	gold
  -- 48Z7A	28819	Joe Germuska	20160305	gold

-- Both records remain... need to use other car license plate info...

SELECT *
FROM person
INNER JOIN drivers_license
  ON person.license_id = drivers_license.id
  AND person.id in (67318, 28819)
  AND drivers_license.gender = 'male' --from w1
  AND plate_number LIKE '%H42W%'  -- from w1

-- Narrows result to 1 person...
  -- person_id	person_name
  -- 67318	Jeremy Bowers

-- Checking the result, Jeremy Bowers was the correct answer! But, an additional clue was revealed:
  -- Congrats, you found the murderer! But wait, there's more... If you think you're up for a challenge, try querying the interview transcript of the murderer to find the real villian behind this crime. If you feel especially confident in your SQL skills, try to complete this final step with no more than 2 queries. Use this same INSERT statement to check your answer.

-- Querying the interview transcript of the murderer...
SELECT *
FROM interview
WHERE person_id = 67318;

-- Yields the following transcript:
  -- I was hired by a woman with a lot of money. I don't know her name but I know she's around 5'5" (65") or 5'7" (67"). She has red hair and she drives a Tesla Model S. I know that she attended the SQL Symphony Concert 3 times in December 2017.

-- Info: (table)
  -- woman (drivers_license)
  -- high income (income, drivers_license->person->income)
  -- height around 5'5" (65") or 5'7" (67") (drivers_license)
  -- red hair (drivers_license)
  -- drives Tesla Model S (drivers_license)
  -- attended SQL Symphony Concert 3x in December 2017 (facebook_event_check_in -> person)

-- to do this in two total queries, need to intersect both queries, output should be person_id, person_name




SELECT
  person.id as person_id,
  person.name as person_name
FROM drivers_license
INNER JOIN person
  ON drivers_license.id = person.license_id
  AND drivers_license.hair_color = 'red'
  AND drivers_license.gender = 'female'
  AND drivers_license.car_make = 'Tesla'
  AND drivers_license.car_model = 'Model S'
  AND drivers_license.height >= 65
  AND drivers_license.height <= 67
INNER JOIN income
  ON person.ssn = income.ssn
  AND income.annual_income >= 250000


  -- person_id	person_name
  -- 78881	Red Korb
  -- 99716	Miranda Priestly

INTERSECT

SELECT
    facebook_event_checkin.person_id,
    person.name as person_name
  FROM facebook_event_checkin
  INNER JOIN person
    ON person.id = facebook_event_checkin.person_id
  WHERE facebook_event_checkin.event_name LIKE 'SQL Symphony Concert'
    AND date LIKE '201712%'
  GROUP BY facebook_event_checkin.person_id
    HAVING COUNT(facebook_event_checkin.event_id) = 3;

  -- person_id	person_name
    -- 24556	Bryan Pardo
    -- 99716	Miranda Priestly

-- Looks like Miranda Priestly...

--Solution Output:
-- Congrats, you found the brains behind the murder! Everyone in SQL City hails you as the greatest SQL detective of all time. Time to break out the champagne!

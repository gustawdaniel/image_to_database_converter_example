Feature: Selecting chosen fields from database
  In order to check if my queries are correct
  As an an database user
  I want to execute them and test some asserts

  Scenario Outline: Checking number of rows
    When I select "SELECT count(*) AS c FROM <table>" from database
    Then I should see 1 results
    And Firs result should have "c" equal <count>

    Examples:
      | table   | count |
      | product | 30    |
      | pc      | 13    |
      | laptop  | 10    |
      | printer | 7     |

  Scenario Outline: Testing query
    When I select <query> from database
    Then Result should contain fields:
      | <row>  |
      | <yes1> |
      | <yes2> |
    And Result should not contain fields:
      | <row>  |
      | <no1>  |
      | <no2>  |

    Examples:
      | row   | yes1 | yes2 | no1  | no2  | query                                                                                                                                                                                                                              |
      | model | 1013 | 1006 | 1012 | 1007 | "SELECT model FROM pc WHERE speed >= 3.0;"                                                                                                                                                                                         |
      | maker | E    | A    | C    | H    | "SELECT maker FROM product NATURAL JOIN laptop WHERE hd >= 100;"                                                                                                                                                                   |
      | model | 3003 | 3007 | 3002 | 3005 | "SELECT model FROM printer WHERE color AND type='laser'"                                                                                                                                                                           |
      | maker | F    | G    | A    | D    | "SELECT DISTINCT maker FROM laptop NATURAL JOIN product WHERE maker NOT IN (SELECT DISTINCT maker FROM pc NATURAL JOIN product);"                                                                                                  |
      | maker | F    | G    | A    | D    | "SELECT l.maker FROM (SELECT maker,type FROM product WHERE type='laptop') as l LEFT JOIN (SELECT maker,type FROM product WHERE type='pc') as p ON l.maker=p.maker WHERE p.maker IS NULL;"                                          |
      | hd    | 250  | 80   | 300  | 350  | "SELECT hd FROM (SELECT count(*) as c, hd FROM pc GROUP BY hd) as calc WHERE c>=2;"                                                                                                                                                |
      | maker | B    | E    | H    | G    | "SELECT  maker from (SELECT maker, count(model) as c FROM product as p NATURAL JOIN (SELECT model, speed FROM pc WHERE speed>=2.8 UNION  SELECT model, speed FROM laptop WHERE speed>=2.8) as u GROUP BY maker) as mc WHERE c>=2;" |
      | maker | A    | B    | C    | G    | "SELECT maker from (SELECT maker, count(speed) as c FROM product NATURAL JOIN pc GROUP BY maker) as s WHERE s.c>=3;"                                                                                                               |
      | maker | A    | D    | C    | H    | "SELECT maker from (SELECT maker, count(model) as c FROM product NATURAL JOIN pc GROUP BY maker) as s WHERE s.c=3;"                                                                                                                |

  Scenario: Testing query (maker B)
    When I select "SELECT model,price FROM product as p NATURAL JOIN (SELECT model,price FROM pc UNION SELECT model,price FROM laptop UNION SELECT model,price FROM printer) as s WHERE maker='B'" from database
    Then Result should contain fields:
      | model | price |
      | 1004  | 649   |
      | 2007  | 1429  |
    And Result should not contain fields:
      | model | price |
      | 2004  | 1150  |
      | 3007  | 200   |

  Scenario: Testing query (pairs)
    When I select "SELECT a.model as a, b.model as b FROM pc as a JOIN pc as b ON a.speed=b.speed AND a.ram=b.ram WHERE a.model>b.model;" from database
    Then Result should contain fields:
      | a     | b       |
      | 1012  | 1004    |
    And I should see 1 results

  Scenario: Testing query (max speed)
    When I select "SELECT DISTINCT maker FROM product as p NATURAL JOIN (SELECT model,speed FROM laptop UNION SELECT model,speed FROM pc) as c WHERE speed=(SELECT MAX(speed) FROM (SELECT speed FROM laptop UNION SELECT speed FROM pc) as u);" from database
    Then Result should contain fields:
      | maker |
      | B     |
    And I should see 1 results
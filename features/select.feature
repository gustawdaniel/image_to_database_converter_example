Feature: Selecting chosen fields from database
  In order to check if my queries are correct
  As an an database user
  I want to execute them and test some asserts

  Scenario Outline: Checking number of rows
    Given I'm connected to <db> database
    When I select "SELECT count(*) AS c FROM <table>" from database
    Then I should see 1 results
    And Firs result should have "c" equal <count>

    Examples:
      | db | table    | count |
      | 1  | product  | 30    |
      | 1  | pc       | 13    |
      | 1  | laptop   | 10    |
      | 1  | printer  | 7     |
      | 2  | classes  | 8     |
      | 2  | battles  | 4     |
      | 2  | outcomes | 16    |
      | 2  | ships    | 21    |

  Scenario Outline: Testing query
    Given I'm connected to <db> database
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
      | db | row   | yes1      | yes2             | no1       | no2        | query                                                                                                                                                                                                                              |
      | 1  | model | 1013      | 1006             | 1012      | 1007       | "SELECT model FROM pc WHERE speed >= 3.0;"                                                                                                                                                                                         |
      | 1  | maker | E         | A                | C         | H          | "SELECT maker FROM product NATURAL JOIN laptop WHERE hd >= 100;"                                                                                                                                                                   |
      | 1  | model | 3003      | 3007             | 3002      | 3005       | "SELECT model FROM printer WHERE color AND type='laser'"                                                                                                                                                                           |
      | 1  | maker | F         | G                | A         | D          | "SELECT DISTINCT maker FROM laptop NATURAL JOIN product WHERE maker NOT IN (SELECT DISTINCT maker FROM pc NATURAL JOIN product);"                                                                                                  |
      | 1  | maker | F         | G                | A         | D          | "SELECT l.maker FROM (SELECT maker,type FROM product WHERE type='laptop') as l LEFT JOIN (SELECT maker,type FROM product WHERE type='pc') as p ON l.maker=p.maker WHERE p.maker IS NULL;"                                          |
      | 1  | hd    | 250       | 80               | 300       | 350        | "SELECT hd FROM (SELECT count(*) as c, hd FROM pc GROUP BY hd) as calc WHERE c>=2;"                                                                                                                                                |
      | 1  | maker | B         | E                | H         | G          | "SELECT  maker from (SELECT maker, count(model) as c FROM product as p NATURAL JOIN (SELECT model, speed FROM pc WHERE speed>=2.8 UNION  SELECT model, speed FROM laptop WHERE speed>=2.8) as u GROUP BY maker) as mc WHERE c>=2;" |
      | 1  | maker | A         | B                | C         | G          | "SELECT maker from (SELECT maker, count(speed) as c FROM product NATURAL JOIN pc GROUP BY maker) as s WHERE s.c>=3;"                                                                                                               |
      | 1  | maker | A         | D                | C         | H          | "SELECT maker from (SELECT maker, count(model) as c FROM product NATURAL JOIN pc GROUP BY maker) as s WHERE s.c=3;"                                                                                                                |
      | 2  | name  | Ramillies | Royal Oak        | Wisconsin | Yamato     | "SELECT name FROM ships WHERE launched<1921;"                                                                                                                                                                                      |
      | 2  | ship  | Bismarck  | Hood             | Wisconsin | Rodney     | "SELECT ship FROM outcomes WHERE result='sunk' AND battle='Denmark Strait'"                                                                                                                                                        |
      | 2  | name  | Yamato    | North Carolina   | Kirishima | California | "SELECT name FROM classes NATURAL JOIN ships WHERE launched>1921 AND displacement>35000"                                                                                                                                           |
      | 2  |country| Japan     | Gt. Britain      |USA        | Germany    | "SELECT t1.country FROM classes as t1 JOIN classes as t2 ON t1.country=t2.country WHERE t1.type='bb' AND t2.type='bc';"                                                                                                            |

  Scenario Outline: Testing query with two attributes
    Given I'm connected to <db> database
    When I select <query> from database
    Then Result should contain fields:
      | <rowA>  | <rowB>  |
      | <yes1A> | <yes1B> |
      | <yes2A> | <yes2B> |
    And Result should not contain fields:
      | <rowA> | <rowB> |
      | <no1A> | <no1B> |
      | <no2A> | <no2B> |
    Examples:
      | db | rowA  | rowB    | yes1A  | yes1B | yes2A          | yes2B | no1A    | no1B         | no2A       | no2B | query                                                                                                                                                                            |
      | 1  | model | price   | 1004   | 649   | 2007           | 1429  | 2004    | 1150         | 3007       | 200  | "SELECT model,price FROM product as p NATURAL JOIN (SELECT model,price FROM pc UNION SELECT model,price FROM laptop UNION SELECT model,price FROM printer) as s WHERE maker='B'" |
      | 2  | name  | country | Yamato | Japan | North Carolina | USA   | Repulse | Gr. Brritain | California | USA  | "SELECT name, country FROM classes NATURAL JOIN ships WHERE bore>=16;"                                                                                                           |

  Scenario: Testing query with three attributes
    Given I'm connected to 2 database
    When I select "SELECT DISTINCT name, displacement, numGuns FROM classes NATURAL JOIN ships NATURAL JOIN outcomes WHERE battle='Guadalcanal';" from database
    Then Result should contain fields:
      | name       | numGuns | displacement |
      | Kirishima  | 8       | 32000        |
      | Washington | 9       | 37000        |
    And Result should not contain fields:
      | name     | numGuns | displacement |
      | Tenessee | 12      | 32000        |
      | Bismarck | 8       | 42000        |

  Scenario: Testing query (pairs)
    When I select "SELECT a.model as a, b.model as b FROM pc as a JOIN pc as b ON a.speed=b.speed AND a.ram=b.ram WHERE a.model>b.model;" from database
    Then Result should contain fields:
      | a     | b       |
      | 1012  | 1004    |
    And I should see 1 results

  Scenario Outline: Testing query (max speed)
    Given I'm connected to <db> database
    When I select <query> from database
    Then Result should contain fields:
      | <row>   |
      | <value> |
    And I should see 1 results
    Examples:
      | db | row   | value    | query                                                                                                                                                                                                                          |
      | 1  | maker | B        | "SELECT DISTINCT maker FROM product as p NATURAL JOIN (SELECT model,speed FROM laptop UNION SELECT model,speed FROM pc) as c WHERE speed=(SELECT MAX(speed) FROM (SELECT speed FROM laptop UNION SELECT speed FROM pc) as u);" |
      | 2  | class | Bismarck | "SELECT class FROM (SELECT class, count(class) as c FROM classes as cl NATURAL JOIN (SELECT ship, ship as class FROM outcomes as o UNION SELECT name, class FROM ships as s) as ext_ship GROUP BY class) as total WHERE c=1;"  |

    Scenario: Select all ships
      Given I'm connected to 2 database
      When I select "SELECT name FROM ships UNION SELECT ship FROM outcomes;" from database
      Then I should see not less than "21" results
      And I should see not less than "16" results
      And I should see not more than 37 results
      And Result should contain fields:
        | name |
        | Yamashiro |
        | Bismarck |
        | Fuso |

      Scenario: Select null
        Given I'm connected to 2 database
        When I select "SELECT f.name as name FROM (SELECT name, RIGHT(date,2) as year,ship,battle,result FROM battles as b1 JOIN outcomes as o1 ON b1.name=o1.battle) as f JOIN (SELECT name, RIGHT(date,2) as year,ship,battle,result FROM battles as b1 JOIN outcomes as o1 ON b1.name=o1.battle) as s ON f.name=s.name AND s.year < f.year AND s.result='sunk';" from database
        Then I should see 0 results
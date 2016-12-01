<?php

use Behat\Behat\Tester\Exception\PendingException;
use Behat\Behat\Context\Context;
use Behat\Gherkin\Node\PyStringNode;
use Behat\Gherkin\Node\TableNode;
use Symfony\Component\Yaml\Yaml;
use PHPUnit\Framework\TestCase;

/**
 * Defines application features from the specific context.
 */
class FeatureContext extends TestCase implements Context
{
    /**
     * Initializes context.
     *
     * Every scenario gets its own context instance.
     * You can also pass arbitrary arguments to the
     * context constructor through behat.yml.
     */

    private $config;
    private $pdo;
    private $data;

    public function __construct()
    {
        parent::__construct();

        $this->config = Yaml::parse(file_get_contents(__DIR__.'/../../config/parameters.yml'))["config"];
        $this->setPdoUsingBaseNumber(0);
    }

    private function setPdoUsingBaseNumber($baseNumber)
    {
        try {
            $this->pdo = new PDO(
                $this->config["type"].
                ':host='.$this->config["host"].
                ';dbname='.$this->config["bases"][$baseNumber],
                $this->config["user"],
                $this->config["pass"]);

            $this->pdo->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_OBJ);

        } catch (PDOException $e) {
            echo 'Connection failed: ' . $e->getMessage();
        }
    }

    private function assertArrayContainsObject($theArray, $theObject)
    {
        foreach($theArray as $arrayItem) {
//            print_r($arrayItem);
//            print_r($theObject);
//            print_r((array) $theObject);
//            print "----------------";
            if((array) $arrayItem == $theObject) {
                return true;
            }
        }
        throw new Exception(print_r($theArray)." do not contain ".print_r($theObject));
    }

    private function assertArrayNotContainsObject($theArray, $theObject)
    {
        foreach($theArray as $arrayItem) {
            if((array) $arrayItem == $theObject) {
                throw new Exception(print_r($theArray)." do contain ".print_r($theObject));
            }
        }
        return true;
    }

    /**
     * @Given I connected to :number database
     */
    public function connectToSecondDatabase($number)
    {
        $this->setPdoUsingBaseNumber($number-1);
    }

    /**
     * @When I select :query from database
     */
    public function iSelectFromDatabase($query)
    {
        $stmt = $this->pdo->query($query);
        $stmt->execute();
        $this->data = $stmt->fetchAll();
        $stmt->closeCursor();
    }

    /**
     * @Then I print result
     */
    public function iPrintResult()
    {
//        echo json_encode($this->data, JSON_PRETTY_PRINT);
        print_r($this->data);
    }

    /**
     * @Then I should see :count results
     */
    public function iShouldSeeResults($count)
    {
        $this->assertEquals(sizeof($this->data), $count);
    }

    /**
     * @Then Firs result should have :key equal :value
     */
    public function firsResultShouldHaveEqual($key, $value)
    {
        $this->assertArrayHasKey(0,$this->data);
        $this->assertObjectHasAttribute($key,$this->data[0]);
        $this->assertEquals($this->data[0]->$key,$value);
    }

    /**
     * @Then /^Result should( not)? contain fields:$/
     */
    public function resultShouldContainFields($not = null, TableNode $table)
    {
        foreach($table->getHash() as $hash)
        {
            if (!$not) {
                $this->assertArrayContainsObject($this->data, $hash);
            } else {
                $this->assertArrayNotContainsObject($this->data,$hash);
            }
        }
    }

}

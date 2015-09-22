import qualified ConfigTests
import qualified IntegrationTests
import qualified ParserTests
import qualified UtilTests

import           Test.Framework

main :: IO ()
main = defaultMain tests

tests :: [Test]
tests =
     UtilTests.tests
  ++ ParserTests.tests
  ++ ConfigTests.tests
  ++ IntegrationTests.tests

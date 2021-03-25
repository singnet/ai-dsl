module Main
import Types
import Lib



---Testcase calculateDeltas--PASS

main: IO()
main = do
  let thetas = (0, 0)
  let alpha = 0.3
  let trainingset = [(0.0,50.0), (1.0,60.0), (2.0,70.0)]
  let iterations = 1
  print $ show $ linearRegression thetas alpha trainingset iterations

--Results for the test -50.0

--Testcase adjustDeltas -- PASS
--main: IO()
--main = do
--  let deltas = [6.0, 5.2]
--  let examples = [(7.0,50.0), (2.0,3.0)]
--  print $ adjustDeltas deltas examples

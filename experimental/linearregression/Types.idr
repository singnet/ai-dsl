module Types 

--data Example: Type where
--  Points: Double -> Double -> Example
public export
data Examples = Points Double Double
--data Dataset = TrainingSet [Example] | TestSet [Example]
public export
data Dataset : Type where
  TrainingSet: List Examples -> Dataset
  TestSet: List Examples -> Dataset

public export
data Coefficients = Val Double Double 

example1 : Examples
example1 = Points 10.2 10.9

example2 : Examples
example2 = Points 0.0 0.0

example3 : Examples
example3 = Points 2.8 4.9

mytrainset: Dataset
mytrainset = TrainingSet [example1,example2, example3]

module LogisticRegression

import System.Random
import Data.String
import Data.Vect
import Matrix
import Descent

--------------------------------
-- Define Logistic Regression --
--------------------------------

-- NEXT

------------
-- Proofs --
------------

-- NEXT

----------
-- Test --
----------

-- Logistic regression example: try to predict the success of a query
-- to the AI-DSL registry given:
--
-- 1. the size of the query,
-- 2. the expenditure of the query,
-- 3. the familiarity of the query with respect to past queries.
--
-- The smaller the query, the larger the expenditure allocated to
-- fulfill that query and the larger the familiarity of the query,
-- then more likely the query is to be fulfilled.

||| Generative model, β₀=-1, β₁=-2, β₂=4, β₃=8, where
|||
||| β₀ is the bias term
||| β₁ is the query size factor
||| β₂ is the query expenditure factor
||| β₃ is the query familiarity factor
true_beta : Vect 4 Double
true_beta = [-1, -2, 4, 8]

||| Calculate the odd ratio of the success as the dot product between
|||
||| xs = [1, size, expenditure, familiarity]
|||
||| and true_beta, thus
|||
||| success = β₀ + β₁*size + β₂*expenditure + β₃*familiarity
success : Vect 4 Double -> Double
success xs = dot xs true_beta

-- Generate a train/test data set

-- NEXT

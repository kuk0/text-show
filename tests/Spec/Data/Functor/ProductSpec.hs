{-|
Module:      Spec.Data.Functor.ProductSpec
Copyright:   (C) 2014-2016 Ryan Scott
License:     BSD-style (see the file LICENSE)
Maintainer:  Ryan Scott
Stability:   Provisional
Portability: GHC

@hspec@ test for 'Product'.
-}
module Spec.Data.Functor.ProductSpec (main, spec) where

import Control.Monad.Trans.Instances ()

import Data.Functor.Product (Product)

import Instances.Data.Functor.Product ()

import Spec.Utils (prop_matchesTextShow1)

import Test.Hspec (Spec, describe, hspec, parallel)
import Test.Hspec.QuickCheck (prop)

main :: IO ()
main = hspec spec

spec :: Spec
spec = parallel . describe "Product Maybe Maybe Int" $
    prop "TextShow1 instance" (prop_matchesTextShow1 :: Int -> Product Maybe Maybe Int -> Bool)

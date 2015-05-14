{-|
Module:      Spec.Data.RatioSpec
Copyright:   (C) 2014-2015 Ryan Scott
License:     BSD-style (see the file LICENSE)
Maintainer:  Ryan Scott
Stability:   Experimental
Portability: GHC

@hspec@ test for 'Ratio'.
-}
module Spec.Data.RatioSpec (main, spec) where

import Data.Ratio (Ratio)

import Spec.Utils (prop_matchesShow)

import Test.Hspec (Spec, describe, hspec, parallel)
import Test.Hspec.QuickCheck (prop)

main :: IO ()
main = hspec spec

spec :: Spec
spec = parallel . describe "Text.Show.Text.Data.Ratio" $ do
    prop "Ratio Int instance" (prop_matchesShow :: Int -> Ratio Int -> Bool)
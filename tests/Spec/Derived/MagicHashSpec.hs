{-# LANGUAGE CPP       #-}
{-# LANGUAGE MagicHash #-}

{-|
Module:      Spec.Derived.MagicHashSpec
Copyright:   (C) 2014-2016 Ryan Scott
License:     BSD-style (see the file LICENSE)
Maintainer:  Ryan Scott
Stability:   Provisional
Portability: GHC

@hspec@ tests for data types with fields that have unlifted types.
-}
module Spec.Derived.MagicHashSpec (main, spec) where

import Derived.MagicHash

import Spec.Utils (prop_matchesTextShow1, prop_genericTextShow, prop_genericTextShow1)

import Test.Hspec (Spec, describe, hspec, parallel)
import Test.Hspec.QuickCheck (prop)

main :: IO ()
main = hspec spec

spec :: Spec
spec = parallel $ do
    describe "TyCon# Int Int" $ do
        prop "TextShow1 instance" (prop_matchesTextShow1 :: Int -> TyCon# Int Int -> Bool)
        prop "generic TextShow"   (prop_genericTextShow  :: Int -> TyCon# Int Int -> Bool)
        prop "generic TextShow1"  (prop_genericTextShow1 :: Int -> TyCon# Int Int -> Bool)
#if MIN_VERSION_template_haskell(2,7,0)
    describe "TyFamily# Int Int" $ do
        prop "TextShow1 instance" (prop_matchesTextShow1 :: Int -> TyFamily# Int Int -> Bool)
        prop "generic TextShow"   (prop_genericTextShow  :: Int -> TyFamily# Int Int -> Bool)
        prop "generic TextShow1"  (prop_genericTextShow1 :: Int -> TyFamily# Int Int -> Bool)
#endif

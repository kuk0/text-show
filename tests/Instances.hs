{-# LANGUAGE CPP, GeneralizedNewtypeDeriving, StandaloneDeriving #-}
#if MIN_VERSION_base(4,7,0)
{-# LANGUAGE TypeFamilies, TypeOperators #-}
#endif
{-# OPTIONS_GHC -fno-warn-orphans #-}
-----------------------------------------------------------------------------
-- |
-- Module      :  Instances
-- Copyright   :  (C) 2014 Ryan Scott
-- License     :  BSD-style (see the file LICENSE)
-- Maintainer  :  Ryan Scott
-- Stability   :  Experimental
-- Portability :  GHC
-- 
-- Miscellaneous typeclass instances.
----------------------------------------------------------------------------
module Instances where

import Control.Applicative
import Control.Exception
import Control.Monad.ST (ST, fixST)

#if MIN_VERSION_bytestring(0,10,4)
import Data.ByteString.Short (ShortByteString, pack)
#endif
import Data.Char (GeneralCategory(..))
import Data.Data (Constr, ConstrRep(..), DataRep(..), DataType, Fixity(..),
                  mkConstr, mkDataType)
import Data.Dynamic (Dynamic, toDyn)
import Data.Monoid (All(..), Any(..), Dual(..), First(..),
                    Last(..), Product(..), Sum(..))
#if MIN_VERSION_base(4,6,0)
import Data.Ord (Down(..))
#endif
#if MIN_VERSION_base(4,7,0)
import Data.Proxy (Proxy(..))
#endif
import Data.Text.Lazy.Builder (Builder, fromString)
#if MIN_VERSION_base(4,7,0)
import Data.Coerce (Coercible)
import Data.Type.Coercion (Coercion(..))
import Data.Type.Equality ((:~:)(..))
#endif
#if MIN_VERSION_base(4,4,0)
import Data.Typeable.Internal (Typeable, TyCon(..), TypeRep(..),
                               mkTyConApp, splitTyConApp, typeOf)
import GHC.Fingerprint.Type (Fingerprint(..))
import Data.Word (Word)

#if !MIN_VERSION_base(4,7,0)
import Data.Word (Word64)
import Numeric (showHex)
#endif
#endif
import Data.Version (Version(..))

import Foreign.C.Types
import Foreign.Ptr (FunPtr, IntPtr, Ptr, WordPtr,
                    castPtrToFunPtr, nullPtr, plusPtr,
                    ptrToIntPtr, ptrToWordPtr)

import GHC.Conc (BlockReason(..), ThreadStatus(..))
#if MIN_VERSION_base(4,4,0)
import GHC.IO.Encoding.Types (CodingProgress(..))
#endif

import System.Exit (ExitCode(..))
import System.IO (BufferMode(..), IOMode(..), Newline(..),
                  NewlineMode(..), SeekMode(..))
import System.Posix.Types

import Test.QuickCheck

instance Arbitrary Builder where
    arbitrary = fromString <$> arbitrary

#if MIN_VERSION_bytestring(0,10,4)
instance Arbitrary ShortByteString where
    arbitrary = pack <$> arbitrary
#endif

instance Arbitrary (Ptr a) where
    arbitrary = plusPtr nullPtr <$> arbitrary

instance Arbitrary (FunPtr a) where
    arbitrary = castPtrToFunPtr <$> arbitrary

instance Arbitrary IntPtr where
    arbitrary = ptrToIntPtr <$> arbitrary

instance Arbitrary WordPtr where
    arbitrary = ptrToWordPtr <$> arbitrary

-- TODO: instance Arbitrary (ForeignPtr a)

instance Arbitrary GeneralCategory where
    arbitrary = oneof $ map pure [ UppercaseLetter     
                                 , LowercaseLetter
                                 , TitlecaseLetter
                                 , ModifierLetter
                                 , OtherLetter
                                 , NonSpacingMark
                                 , SpacingCombiningMark
                                 , EnclosingMark
                                 , DecimalNumber
                                 , LetterNumber
                                 , OtherNumber
                                 , ConnectorPunctuation
                                 , DashPunctuation
                                 , OpenPunctuation
                                 , ClosePunctuation
                                 , InitialQuote
                                 , FinalQuote 
                                 , OtherPunctuation
                                 , MathSymbol
                                 , CurrencySymbol
                                 , ModifierSymbol
                                 , OtherSymbol
                                 , Space
                                 , LineSeparator
                                 , ParagraphSeparator
                                 , Control
                                 , Format
                                 , Surrogate
                                 , PrivateUse
                                 , NotAssigned
                                 ]

instance Arbitrary Version where
    arbitrary = Version <$> arbitrary <*> arbitrary

-- TODO: Be more creative with this instance
instance Arbitrary SomeException where
    arbitrary = SomeException <$> (arbitrary :: Gen AssertionFailed)

-- instance Arbitrary IOException

instance Arbitrary ArithException where
    arbitrary = oneof $ map pure [ Overflow
                                 , Underflow
                                 , LossOfPrecision
                                 , DivideByZero
                                 , Denormal
#if MIN_VERSION_base(4,6,0)
                                 , RatioZeroDenominator
#endif
                                 ]

instance Arbitrary ArrayException where
    arbitrary = oneof [ IndexOutOfBounds <$> arbitrary
                      , UndefinedElement <$> arbitrary
                      ]

instance Arbitrary AssertionFailed where
    arbitrary = AssertionFailed <$> arbitrary

#if MIN_VERSION_base(4,7,0)
-- TODO: Be more creative with this instance
instance Arbitrary SomeAsyncException where
    arbitrary = SomeAsyncException <$> (arbitrary :: Gen AsyncException)
#endif

instance Arbitrary AsyncException where
    arbitrary = oneof $ map pure [ StackOverflow
                                 , HeapOverflow
                                 , ThreadKilled
                                 , UserInterrupt
                                 ]

instance Arbitrary NonTermination where
    arbitrary = pure NonTermination

instance Arbitrary NestedAtomically where
    arbitrary = pure NestedAtomically

instance Arbitrary BlockedIndefinitelyOnMVar where
    arbitrary = pure BlockedIndefinitelyOnMVar

instance Arbitrary BlockedIndefinitelyOnSTM where
    arbitrary = pure BlockedIndefinitelyOnSTM

instance Arbitrary Deadlock where
    arbitrary = pure Deadlock

instance Arbitrary NoMethodError where
    arbitrary = NoMethodError <$> arbitrary

instance Arbitrary PatternMatchFail where
    arbitrary = PatternMatchFail <$> arbitrary

instance Arbitrary RecConError where
    arbitrary = RecConError <$> arbitrary

instance Arbitrary RecSelError where
    arbitrary = RecSelError <$> arbitrary

instance Arbitrary RecUpdError where
    arbitrary = RecUpdError <$> arbitrary

-- deriving instance Arbitrary ErrorCall
-- ErrorCall is a newtype starting with base-4.7.0.0, but we'll
-- manually derive Arbitrary to support older version of GHC
instance Arbitrary ErrorCall where
    arbitrary = ErrorCall <$> arbitrary

instance Arbitrary MaskingState where
    arbitrary = oneof $ map pure [ Unmasked
                                 , MaskedInterruptible
                                 , MaskedUninterruptible
                                 ]

-- instance Arbitrary Lexeme
-- #if MIN_VERSION_base(4,7,0)
-- instance Arbitrary Number
-- #endif

#if MIN_VERSION_base(4,7,0)
instance Arbitrary (Proxy s) where
    arbitrary = pure Proxy
#endif

#if MIN_VERSION_base(4,4,0)
-- Borrowed from the concrete-typerep package
instance Arbitrary TypeRep where
    arbitrary = do
        nargs <- elements [0,1,2]
        mkTyConApp <$> (genTyCon nargs) <*> (vectorOf nargs arbitrary)

genTyCon :: Int -- ^ Number of arguments; must be in [0,1,2]
         -> Gen TyCon
genTyCon 0 = elements [tyConOf (__::Int), tyConOf (__::Word), tyConOf (__::Double), tyConOf (__::Bool)]
genTyCon 1 = elements [tyConOf (__::Maybe Int), tyConOf (__::IO Int), tyConOf (__::[Int])]
genTyCon 2 = elements [tyConOf (__::Either Int Int), tyConOf (__::Int -> Int)]
genTyCon _ = genTyCon 0

tyConOf :: Typeable a => a -> TyCon
tyConOf ty = fst $ splitTyConApp (typeOf ty)

__ :: t
__ = undefined

instance Arbitrary TyCon where
    arbitrary = TyCon <$> arbitrary <*> arbitrary <*> arbitrary <*> arbitrary

instance Arbitrary Fingerprint where
    arbitrary = Fingerprint <$> arbitrary <*> arbitrary

#if !MIN_VERSION_base(4,7,0)
instance Show Fingerprint where
  show (Fingerprint w1 w2) = hex16 w1 ++ hex16 w2
    where
      -- | Formats a 64 bit number as 16 digits hex.
      hex16 :: Word64 -> String
      hex16 i = let hex = showHex i ""
                 in replicate (16 - length hex) '0' ++ hex
#endif
#endif

-- TODO: Be more creative with this instance
instance Arbitrary Dynamic where
    arbitrary = toDyn <$> (arbitrary :: Gen Int)

instance Arbitrary Constr where
    arbitrary = mkConstr <$> arbitrary <*> arbitrary <*> arbitrary <*> arbitrary

instance Arbitrary ConstrRep where
    arbitrary = oneof [ AlgConstr   <$> arbitrary
                      , IntConstr   <$> arbitrary
                      , FloatConstr <$> arbitrary
                      , CharConstr  <$> arbitrary
                      ]

instance Arbitrary DataRep where
    arbitrary = oneof [ AlgRep <$> arbitrary
                      , pure IntRep
                      , pure FloatRep
                      , pure CharRep
                      , pure NoRep
                      ]

instance Arbitrary DataType where
    arbitrary = mkDataType <$> arbitrary <*> arbitrary

instance Arbitrary Fixity where
    arbitrary = oneof $ map pure [Prefix, Infix]

#if MIN_VERSION_base(4,7,0)
instance Coercible a b => Arbitrary (Coercion a b) where
    arbitrary = pure Coercion

instance a ~ b => Arbitrary (a :~: b) where
    arbitrary = pure Refl
#endif

instance Arbitrary BlockReason where
    arbitrary = oneof $ map pure [ BlockedOnMVar
                                 , BlockedOnBlackHole
                                 , BlockedOnException
                                 , BlockedOnSTM
                                 , BlockedOnForeignCall
                                 , BlockedOnOther
                                 ]

-- instance Arbitrary ThreadId

instance Arbitrary ThreadStatus where
    arbitrary = oneof [ pure ThreadRunning
                      , pure ThreadFinished
                      , ThreadBlocked <$> arbitrary
                      , pure ThreadDied
                      ]

instance Arbitrary (ST s a) where
    arbitrary = pure $ fixST undefined

-- instance Arbitrary Handle
-- instance Arbitrary HandlePosn

instance Arbitrary IOMode where
    arbitrary = oneof $ map pure [ReadMode, WriteMode, AppendMode, ReadWriteMode]

instance Arbitrary BufferMode where
    arbitrary = oneof [ pure NoBuffering
                      , pure LineBuffering
                      , BlockBuffering <$> arbitrary
                      ]

instance Arbitrary SeekMode where
    arbitrary = oneof $ map pure [AbsoluteSeek, RelativeSeek, SeekFromEnd]

instance Arbitrary Newline where
    arbitrary = oneof $ map pure [LF, CRLF]

instance Arbitrary NewlineMode where
    arbitrary = NewlineMode <$> arbitrary <*> arbitrary

#if MIN_VERSION_base(4,3,0)
-- instance Arbitrary TextEncoding
#else
deriving instance Show Newline
deriving instance Show NewlineMode
#endif

#if MIN_VERSION_base(4,4,0)
instance Arbitrary CodingProgress where
    arbitrary = oneof $ map pure [InputUnderflow, OutputUnderflow, InvalidSequence]
#endif

deriving instance Arbitrary CChar
deriving instance Arbitrary CSChar
deriving instance Arbitrary CUChar
deriving instance Arbitrary CShort
deriving instance Arbitrary CUShort
deriving instance Arbitrary CInt
deriving instance Arbitrary CUInt
deriving instance Arbitrary CLong
deriving instance Arbitrary CULong
deriving instance Arbitrary CLLong
deriving instance Arbitrary CULLong
deriving instance Arbitrary CFloat
deriving instance Arbitrary CDouble
deriving instance Arbitrary CPtrdiff
deriving instance Arbitrary CSize
deriving instance Arbitrary CWchar
deriving instance Arbitrary CSigAtomic
deriving instance Arbitrary CClock
deriving instance Arbitrary CTime
deriving instance Arbitrary CUSeconds
deriving instance Arbitrary CSUSeconds
deriving instance Arbitrary CIntPtr
deriving instance Arbitrary CUIntPtr
deriving instance Arbitrary CIntMax
deriving instance Arbitrary CUIntMax

instance Arbitrary ExitCode where
    arbitrary = oneof [pure ExitSuccess, ExitFailure <$> arbitrary]

deriving instance Arbitrary CDev
deriving instance Arbitrary CIno
deriving instance Arbitrary CMode
deriving instance Arbitrary COff
deriving instance Arbitrary CPid
deriving instance Arbitrary CSsize
deriving instance Arbitrary CGid
deriving instance Arbitrary CNlink
deriving instance Arbitrary CUid
deriving instance Arbitrary CCc
deriving instance Arbitrary CSpeed
deriving instance Arbitrary CTcflag
deriving instance Arbitrary CRLim
deriving instance Arbitrary Fd

deriving instance Arbitrary All
deriving instance Arbitrary Any
deriving instance Arbitrary a => Arbitrary (Dual a)
deriving instance Arbitrary a => Arbitrary (First a)
deriving instance Arbitrary a => Arbitrary (Last a)
deriving instance Arbitrary a => Arbitrary (Product a)
deriving instance Arbitrary a => Arbitrary (Sum a)
 
deriving instance Arbitrary a => Arbitrary (ZipList a)
#if !MIN_VERSION_base(4,7,0)
deriving instance Show a => Show (ZipList a)
#endif

#if MIN_VERSION_base(4,6,0)
deriving instance Arbitrary a => Arbitrary (Down a)
#if !MIN_VERSION_base(4,7,0)
deriving instance Show a => Show (Down a)
#endif
#endif
{-# LANGUAGE DeriveDataTypeable #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}

module GHCJS.Prim.Internal ( JSVal(..)
                           , JSValueRef
                           , JSException(..)
                           , WouldBlockException(..)
                           , mkJSException
                           , jsNull
                           ) where

import           Data.Int (Int64)
import           Data.Typeable (Typeable)
import           Unsafe.Coerce (unsafeCoerce)

import           Data.Aeson (ToJSON(..), FromJSON(..))

import qualified GHC.Exception as Ex

-- A reference to a particular JavaScript value inside the JavaScript context
type JSValueRef = Int64

{-
  JSVal is a boxed type that can be used as FFI
  argument or result.
-}
newtype JSVal = JSVal JSValueRef deriving(Show, ToJSON, FromJSON)

{-
  When a JavaScript exception is raised inside
  a safe or interruptible foreign call, it is converted
  to a JSException
 -}
data JSException = JSException JSVal String
  deriving (Typeable)

instance Ex.Exception JSException

instance Show JSException where
  show (JSException _ xs) = "JavaScript exception: " ++ xs

mkJSException :: JSVal -> IO JSException
mkJSException ref =
  return (JSException (unsafeCoerce ref) "")

jsNull :: JSVal
jsNull = JSVal 0
{-# INLINE jsNull #-}

{- | If a synchronous thread tries to do something that can only
     be done asynchronously, and the thread is set up to not
     continue asynchronously, it receives this exception.
 -}
data WouldBlockException = WouldBlockException
  deriving (Typeable)

instance Show WouldBlockException where
  show _ = "thread would block"

instance Ex.Exception WouldBlockException

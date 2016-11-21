{-
Copyright 2016 SlamData, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
-}

module Control.Monad.Fork.Canceler where

import Prelude

import Control.Monad.Eff.Exception (Error)
import Data.Monoid (class Monoid)
import Data.Newtype (class Newtype)

-- | Semigroup (and monoid) for combining cancel functions produced by `fork`.
newtype Canceler m = Canceler (Error → m Boolean)

derive instance newtypeCanceler ∷ Newtype (Canceler m) _

instance semigroupCanceler ∷ Apply m ⇒ Semigroup (Canceler m) where
  append (Canceler f1) (Canceler f2) = Canceler (\e → (||) <$> f1 e <*> f2 e)

instance monoidCanceler ∷ Applicative m ⇒ Monoid (Canceler m) where
  mempty = Canceler (const (pure false))

cancel ∷ ∀ m. Canceler m → Error → m Boolean
cancel (Canceler f) = f

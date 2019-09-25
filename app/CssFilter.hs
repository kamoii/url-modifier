{-# LANGUAGE FlexibleContexts  #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes       #-}

module Main where

import Prelude()
import Protolude
import qualified Data.ByteString.Lazy as BS
import qualified Data.Text as T
import qualified Data.Text.IO as T
import           Text.Regex.PCRE.Heavy (re)
import qualified Text.Regex.PCRE.Heavy as RH

main :: IO ()
main = do
  [basename] <- getArgs
  cont <- BS.getContents
  BS.putStr $ rep (toS basename) cont

rep :: ByteString -> LByteString -> LByteString
rep basename =
  RH.gsub [re|url\(\s*['"]?(/[^)'"]*)['"]?\s*\)|]
    $ \[a] -> "url(" <> basename <> a <> ")" :: ByteString

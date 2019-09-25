module Main where

import Prelude()
import Protolude
import Lib
import System.IO

main :: IO ()
main = do
  (basename:excludePrefixs) <- getArgs
  convert (toS basename) (map toS excludePrefixs) stdin stdout

{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE OverloadedStrings #-}

module Lib where

import Prelude()
import Protolude
import Text.HTML.TagSoup
import qualified Data.ByteString as BS

-- | 変換を行なう
--
-- TODO: 現在は Strict なバイナリ使っているので重いかな？パフォーマン
-- スが問題ならまず計測してみて、多分 Lazy な ByteString に変更したら
-- 定数メモリになるかな。
convert
  :: ByteString
  -> [ByteString]    -- ^ 変換を除外する prefix (e.g. [/foo/hoge, /bar])
  -> Handle
  -> Handle
  -> IO ()
convert basename excludePrefixes inh outh = do
  bs <- BS.hGetContents inh
  let intags = parseTags' bs
      outtags = map (addBasePath basename excludePrefixes) intags
      bs' = renderTags' outtags
  BS.hPut outh bs'

-- &nbsp; をそのままテキストとして扱う。
parseTags' :: ByteString -> [Tag ByteString]
parseTags' =
  parseTagsOptions opt
  where
    opt =
      let opt' = parseOptions :: ParseOptions ByteString
      in opt'
         { optEntityData = \(str,b) -> [TagText $ "&" <> str <> bool "" ";" b]
         , optEntityAttrib = \(str,b) -> ("&" <> str <> bool "" ";" b, [])
         }

-- エスケープは行なわない。でないと "foo&nbsp;" が "foo&amp;nbsp;" に
-- なってしまう。
renderTags' :: [Tag ByteString] -> ByteString
renderTags' =
  renderTagsOptions opt
  where
    opt =
      let opt' = renderOptions :: RenderOptions ByteString
      in opt' { optEscape = identity }

-- path は /foo/bar のような感じ
addBasePath
  :: ByteString
  -> [ByteString]
  -> Tag ByteString
  -> Tag ByteString
addBasePath path excludePrefixes (TagOpen name attrs) =
  TagOpen name (map f attrs)
  where
    f a@(attrName, attrValue)
      | needConv a = (attrName, path <> attrValue)
      | otherwise = a
    needConv (attrName, attrValue) =
      isPathAttr name attrName
        && isAbsPath attrValue
        && not (any (flip BS.isPrefixOf attrValue) excludePrefixes)
addBasePath _ _ tag = tag

isAbsPath :: ByteString -> Bool
isAbsPath =
  BS.isPrefixOf "/"

isPathAttr :: ByteString -> ByteString -> Bool
isPathAttr "a" "href"      = True
isPathAttr "img" "src"     = True
isPathAttr "form" "action" = True
isPathAttr "link" "href"   = True
isPathAttr "script" "src"  = True
isPathAttr _ _             = False

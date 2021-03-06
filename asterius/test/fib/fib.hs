{-# LANGUAGE BangPatterns #-}
{-# OPTIONS_GHC -ddump-to-file -ddump-stg -ddump-cmm-raw -ddump-asm #-}

fib :: Int -> Int
fib n = go 0 1 0
  where
    go !acc0 acc1 i
      | i == n = acc0
      | otherwise = go acc1 (acc0 + acc1) (i + 1)

fact :: Int -> Int
fact 0 = 1
fact n = n * fact (n - 1)

facts :: [Int]
facts = scanl (*) 1 [1 ..]

data BinTree
  = Tip
  | Branch !BinTree
           !BinTree
  deriving (Eq, Ord)

genBinTree :: Int -> BinTree
genBinTree 0 = Tip
genBinTree n = Branch t t
  where
    t = genBinTree (n - 1)

foreign import ccall unsafe "print_i64" print_i64 :: Int -> IO ()

foreign import ccall unsafe "print_f64" print_f64 :: Double -> IO ()

main :: IO ()
main = do
  print_i64 $ fib 10
  print_i64 $ fact 5
  print_f64 $ cos 0.5
  print_f64 $ 2 ** 3
  print_i64 $
    if genBinTree 3 < genBinTree 5
      then 1
      else 0
  print_i64 $ facts !! 5

{-# LANGUAGE OverloadedLists #-}
{-# LANGUAGE OverloadedStrings #-}
{-# OPTIONS_GHC -Wno-overflowed-literals #-}

import Asterius.Marshal
import Asterius.Types
import Bindings.Binaryen.Raw
import qualified Data.ByteString as BS
import Foreign

main :: IO ()
main = do
  m <-
    withPool $ \pool ->
      marshalModule pool $
      emptyModule
        { functionTypeMap = [("func_type", FunctionType I32 [])]
        , functionMap' =
            [ ( "func"
              , Function "func_type" [I32, I32] $
                Block
                  ""
                  [ CFG
                      { graph =
                          RelooperRun
                            { entry = ".entry"
                            , blockMap =
                                [ ( ".entry"
                                  , RelooperBlock
                                      { addBlock =
                                          AddBlockWithSwitch
                                            Null
                                            (GetLocal 1 I32)
                                      , addBranches =
                                          [ AddBranchForSwitch
                                              ".odd"
                                              [2, 3, 5, 7]
                                              Null
                                          , AddBranch ".def" Null Null
                                          ]
                                      })
                                , ( ".odd"
                                  , RelooperBlock
                                      { addBlock =
                                          AddBlock $ SetLocal 1 $ ConstI32 19
                                      , addBranches = []
                                      })
                                , ( ".def"
                                  , RelooperBlock
                                      { addBlock =
                                          AddBlock $ SetLocal 1 $ ConstI32 233
                                      , addBranches = []
                                      })
                                ]
                            , labelHelper = 0
                            }
                      }
                  , Return $ GetLocal 1 I32
                  ]
                  I32)
            ]
        }
  fptr <- mallocForeignPtrBytes 1000000
  (s, _) <-
    withForeignPtr fptr $ \p -> do
      s <- c_BinaryenModuleWrite m p 1000000
      bs <- BS.packCStringLen (p, fromIntegral s)
      finalizeForeignPtr fptr
      pure (s, bs)
  print s
  c_BinaryenModulePrint m
  c_BinaryenModuleValidate m >>= print
  c_BinaryenModuleDispose m

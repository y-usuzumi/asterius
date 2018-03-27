{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE ConstraintKinds #-}
{-# LANGUAGE MagicHash #-}
{-# LANGUAGE UnboxedTuples #-}

module Language.WebAssembly.Internals
  ( withSBS
  , withSV
  , peekSBS
  ) where

import qualified Data.ByteString.Short.Internal as SBS
import qualified Data.Vector.Storable as SV
import GHC.Exts
import GHC.Types
import UnliftIO
import UnliftIO.Foreign

{-# INLINEABLE withSBS #-}
withSBS :: MonadUnliftIO m => SBS.ShortByteString -> (Ptr CChar -> m r) -> m r
withSBS (SBS.SBS ba) cont =
  withRunInIO
    (\u ->
       (IO
          (\s0 ->
             case newPinnedByteArray# (l0 +# 1#) s0 of
               (# s1, mba #) ->
                 case copyByteArray# ba 0# mba 0# l0 s1 of
                   s2 ->
                     case writeWord8Array# mba l0 0## s2 of
                       s3 ->
                         case unsafeFreezeByteArray# mba s3 of
                           (# s4, ba' #) ->
                             case (u . cont) (Ptr (byteArrayContents# ba')) of
                               IO cf -> cf s4)))
  where
    l0 = sizeofByteArray# ba

{-# INLINEABLE withSV #-}
withSV ::
     (MonadUnliftIO m, Storable a, Num n)
  => SV.Vector a
  -> (Ptr a -> n -> m r)
  -> m r
withSV v cont =
  withRunInIO
    (\u ->
       SV.unsafeWith
         v
         (\p -> (\buf len -> u (cont buf len)) p (fromIntegral (SV.length v))))

{-# INLINEABLE peekSBS #-}
peekSBS :: (MonadIO m, Storable a) => a -> m SBS.ShortByteString
peekSBS a =
  liftIO
    (alloca
       (\buf@(Ptr addr) -> do
          poke buf a
          IO
            (\s0 ->
               case newByteArray# l s0 of
                 (# s1, mba #) ->
                   case copyAddrToByteArray# addr mba 0# l s1 of
                     s2 ->
                       case unsafeFreezeByteArray# mba s2 of
                         (# s3, ba #) -> (# s3, SBS.SBS ba #))))
  where
    !(I# l) = sizeOf a

module Initialize (initialize) where

import Control.Applicative ((<$>))
import Control.Monad.Error
import Data.List (lookup)

import Ast
import Parse.Parser (parseProgram)
import Rename
import Types.Types ((-:))
import Types.Hints (hints)
import Types.Unify
import Types.Substitutions (dealias)
import Optimize


initialize str =
    do Module name ex im stmts <- parseProgram str
       let stmts' = dealias stmts
           modul = Module name ex im stmts'
       (escapees, subs) <- unify hints modul
       let modul' = optimize . renameModule $ Module name ex im' stmts'
               where im' | any ((=="Prelude") . fst) im = im
                         | otherwise = ("Prelude", Hiding []) : im
       subs `seq` return (escapees, modul')

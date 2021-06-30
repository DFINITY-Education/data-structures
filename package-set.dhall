let upstream = https://github.com/dfinity/vessel-package-set/releases/download/mo-0.6.1-20210511/package-set.dhall sha256:aa5083f7cfd9dd0ddbd0210847175417a7efeaf8adcca6838fe9dd2ac460d236
let Package =
    { name : Text, version : Text, repo : Text, dependencies : List Text }

let
  -- This is where you can add your own packages to the package-set
  additions =
    [] : List Package

let
  {- This is where you can override existing packages in the package-set

     For example, if you wanted to use version `v2.0.0` of the foo library:
     let overrides = [
         { name = "foo"
         , version = "v2.0.0"
         , repo = "https://github.com/bar/foo"
         , dependencies = [] : List Text
         }
     ]
  -}
  overrides =
    [] : List Package

in  upstream # additions # overrides

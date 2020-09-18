let upstream =
    https://raw.githubusercontent.com/kritzcreek/vessel-package-set/b8a50b772af45877ed1d7fae929c415820790b01/src/packages.dhall sha256:2ba38db2e5454a25e91841ba93e8f7bdb4b73fd59e0e6e2f3d8550d61fa63b1c

let Package =
    { name : Text, version : Text, repo : Text, dependencies : List Text }

let
  -- This is where you can add your own packages to the package-set
  additions = [ { name = "motoko-sha"
      , repo = "https://github.com/enzoh/motoko-sha"
      , version = "master"
      , dependencies = [] : List Text
      }
    ] : List Package

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


HASKELL_COMPILER="ghc"

if hash $HASKELL_COMPILER 2>/dev/null; then
    $HASKELL_COMPILER -o textme textme.hs
    ./textme --setup
else
    echo You do not have ghc installed. Either change the default compiler in the install.sh file, or install ghc from https://www.haskell.org/ghc/
fi

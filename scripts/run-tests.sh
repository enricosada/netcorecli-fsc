
BASEDIR=$(dirname "$0")
REPOROOT=$(dirname "$BASEDIR")

# test helper

RunCmd ()
{
  echo "[EXEC] $1 $2"
  eval "$1 $2"
  if [ $? != 0 ]; then
      echo "run-build: Error $?."
      exit $?
  fi
}




# pack src/dotnet-compile-fsc

cd "$REPOROOT/src/dotnet-compile-fsc"

Run-Cmd "dotnet" 'restore -v Information --no-cache --configfile "$REPOROOT\test\NuGet.Config"' 

Run-Cmd "dotnet" "-v pack -C Release"

# run tests

cd "$REPOROOT/test/"

Run-Cmd "dotnet" "restore -v Information --no-cache --configfile `"$REPOROOT/test/NuGet.Config`"" 

cd "$REPOROOT/test/dotnet-new.Tests"

Run-Cmd "dotnet" "-v test"

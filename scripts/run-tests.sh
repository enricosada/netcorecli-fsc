
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ "$SOURCE" != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
REPOROOT="$(dirname $DIR)/rootdir"

# test helper

function Run-Cmd {
  echo "$1 $2"
  eval "$1 $2"
  if [ $? != 0 ]; then
      echo "run-build: Error $?."
      exit $?
  fi
}

function Dotnet-Build {
  Run-Cmd "dotnet" "--verbose build"
}

function Dotnet-Run {
  Run-Cmd "dotnet" "--verbose run $1"
}

function Dotnet-Restore {
  Run-Cmd "dotnet" 'restore -v Information --no-cache --configfile "$REPOROOT\test\NuGet.Config"' 
}

function Run-Test {
  echo "Running '$1'..."
}

# dotnet new
Run-Test "dotnet new"
{
  rm -rf "$REPOROOT/test/test-dotnet-new"

  mkdir "$REPOROOT/test/test-dotnet-new" -Force | cd

  Run-Cmd "dotnet" "new --lang f#"

  Dotnet-Restore
  #Run-Cmd "dotnet" "restore"

  Dotnet-Build

  Dotnet-Run "c d"
}

# test from assets

Run-Test "test/TestAppWithArgs"
{
  cd "$REPOROOT/test/TestAppWithArgs"

  Dotnet-Restore

  Dotnet-Build

  Dotnet-Run ""
}

Run-Test "test/TestLibrary"
{
  cd "$REPOROOT/test/TestLibrary"

  Dotnet-Restore

  Dotnet-Build
}

Run-Test "test/TestApp"
{
  cd "$REPOROOT/test/TestApp"

  Dotnet-Restore

  Dotnet-Build

  Dotnet-Run ""
}

# test templates

Run-Test "examples/preview2.1/console"
{
  cd "$REPOROOT/examples/preview2.1/console"

  Dotnet-Restore

  Dotnet-Build

  Dotnet-Run ""
}

Run-Test "examples/preview2.1/lib"
{
  cd "$REPOROOT/examples/preview2.1/lib"

  Dotnet-Restore

  Dotnet-Build
}

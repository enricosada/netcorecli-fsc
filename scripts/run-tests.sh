
BASEDIR=$(dirname "$0")
REPOROOT=$(dirname "$BASEDIR")

# test helper

function RunCmd {
  echo "$1 $2"
  eval "$1 $2"
  if [ $? != 0 ]; then
      echo "run-build: Error $?."
      exit $?
  fi
}

function DotnetBuild {
  RunCmd "dotnet" "--verbose build"
}

function DotnetRun {
  RunCmd "dotnet" "--verbose run $1"
}

function DotnetRestore {
  RunCmd "dotnet" 'restore -v Information --no-cache --configfile "$REPOROOT\test\NuGet.Config"' 
}

function RunTest {
  echo "Running '$1'..."
}

# dotnet new
RunTest "dotnet new"
{
  rm -rf "$REPOROOT/test/test-dotnet-new"

  mkdir "$REPOROOT/test/test-dotnet-new" -Force | cd

  RunCmd "dotnet" "new --lang f#"

  DotnetRestore
  #RunCmd "dotnet" "restore"

  DotnetBuild

  DotnetRun "c d"
}

# test from assets

RunTest "test/TestAppWithArgs"
{
  cd "$REPOROOT/test/TestAppWithArgs"

  DotnetRestore

  DotnetBuild

  DotnetRun ""
}

RunTest "test/TestLibrary"
{
  cd "$REPOROOT/test/TestLibrary"

  DotnetRestore

  DotnetBuild
}

RunTest "test/TestApp"
{
  cd "$REPOROOT/test/TestApp"

  DotnetRestore

  DotnetBuild

  DotnetRun ""
}

# test templates

RunTest "examples/preview2.1/console"
{
  cd "$REPOROOT/examples/preview2.1/console"

  DotnetRestore

  DotnetBuild

  DotnetRun ""
}

RunTest "examples/preview2.1/lib"
{
  cd "$REPOROOT/examples/preview2.1/lib"

  DotnetRestore

  DotnetBuild
}

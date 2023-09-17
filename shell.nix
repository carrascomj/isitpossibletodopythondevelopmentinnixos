
with import <nixpkgs> {};

mkShell {
  name = "example-env";
  buildInputs = [
    python39
    python39Packages.venvShellHook
    autoPatchelfHook
    expat
    zlib
  ];
  propagatedBuildInputs = [
    stdenv.cc.cc.lib
  ];

  venvDir = "./venv";
  postVenvCreation = ''
    unset SOURCE_DATE_EPOCH
    pip install -U pip setuptools wheel
    pip install -r requirements.txt -r requirements-dev.txt
    pip install -e .
    autoPatchelf ./venv
  '';

  # LD_LIBRARY_PATH = "${pkgs.stdenv.cc.cc.lib}/lib:$LD_LIBRARY_PATH";

  postShellHook = ''
  # set SOURCE_DATE_EPOCH so that we can use python wheels
  export SOURCE_DATE_EPOCH=315532800
  unset LD_LIBRARY_PATH
  '';
  preferLocalBuild = true;
}

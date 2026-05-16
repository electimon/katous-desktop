{
  stdenv,
  lib,
  buildDotnetModule,
  fetchFromGitHub,
  bashNonInteractive,
  dotnetCorePackages,
  clang,
  dbus,
  ffmpeg,
  fontconfig,
  freetype,
  openssl,
  icu,
  at,
  sudo,
  libxrandr,
  libxcb,
  xdg-utils,
}:
buildDotnetModule (finalAttrs: {
  pname = "snapx";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "SnapXL";
    repo = "SnapX";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Z7uqvtM0Q0UZSHcfjWPZVEJ8HqmlqTNQdvetPNwwVpA=";
  };

  nativeBuildInputs = [ clang ];

  buildInputs = [
    dbus
    ffmpeg
    fontconfig
    freetype
    openssl
    icu
    at
    sudo
    libxrandr
    libxcb
    xdg-utils
  ];

  nugetDeps = ./deps.json;

  dotnet-sdk = dotnetCorePackages.sdk_10_0;

  postPatch = ''
    substituteInPlace build.sh --replace "/usr/bin/env sh" ${lib.getExe' bashNonInteractive "sh"}
  '';

  buildPhase = ''
    runHook preBuild

    ./build.sh --configuration Release

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    ./build.sh install --prefix / --dest-dir "$out" --assembly snapx --skip compile

    ./build.sh install --prefix / --dest-dir "$out" --assembly snapx-ui --skip compile

    runHook postInstall
  '';

  meta = {
    description = "Free, open-source, cross-platform tool that lets you capture or record any area of your screen";
    homepage = "https://github.com/SnapXL/SnapX";
    license = lib.licenses.gpl3;
    mainProgram = "snapx";
    maintainers = with lib.maintainers; [ ];
  };
})

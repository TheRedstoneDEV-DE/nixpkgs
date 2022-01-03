{ lib
, pkg-config
, python3Packages
, meson
, ninja
, appstream-glib
, desktop-file-utils
, glib
, gtk3
, gobject-introspection
, wrapGAppsHook
, fetchFromGitHub
}:

python3Packages.buildPythonApplication rec {
  name = "tuhi";
  version = "0.5";

  format = "other";

  src = fetchFromGitHub {
    owner = "tuhiproject";
    repo = name;
    rev = "${version}";
    sha256 = "17kggm9c423vj7irxx248fjc8sxvkp9w1mgawlx1snrii817p3db";
  };

  dontWrapGApps = true;
  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  nativeBuildInputs = [
    pkg-config meson ninja
    appstream-glib desktop-file-utils
    wrapGAppsHook
  ];
  buildInputs = [
    gtk3 gobject-introspection
    glib
  ];
  checkInputs = with python3Packages; [ flake8 pytest ];
  propagatedBuildInputs = with python3Packages; [
    svgwrite pyxdg pycairo pygobject3 setuptools-scm
  ];

  strictDeps = false;
  preConfigure = ''
    substituteInPlace meson_install.sh \
      --replace "/usr/bin/env sh" "sh"
  '';
  postFixup = ''
    wrapPythonProgramsIn $out/libexec "$out $pythonPath"
  '';

  meta = with lib; {
    description = "DBus daemon to access Wacom SmartPad devices";
    homepage = "https://github.com/tuhiproject/tuhi";
    license = licenses.gpl2;
    platforms = platforms.linux;
    maintainers = with maintainers; [ lammermann ];
  };
}

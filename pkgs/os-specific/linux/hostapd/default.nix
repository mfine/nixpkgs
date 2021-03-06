{ stdenv, fetchurl, fetchpatch, pkgconfig, libnl, openssl, sqlite ? null }:

with stdenv.lib;
stdenv.mkDerivation rec {
  name = "hostapd-${version}";
  version = "2.5";

  src = fetchurl {
    url = "http://hostap.epitest.fi/releases/${name}.tar.gz";
    sha256 = "0jn77r39ysshkzihv5rjbdajqazci59v2yab4rn05my09najs9wf";
  };

  patches = [
    (fetchpatch {
      url = "https://raw.githubusercontent.com/voidlinux/void-packages/a7bcbc258ba9884bccde831c0ae2069cade99e41/srcpkgs/wpa_supplicant/patches/patch-src_crypto_tls_openssl_c";
      sha256 = "1ifa2i54a7ijsha197dyldal3m4q5i05ih2sk15f5a5ybb6x7vmp";
      addPrefixes = true;
    })
  ];

  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [ libnl openssl sqlite ];

  extraConfig = ''
    CONFIG_DRIVER_WIRED=y
    CONFIG_LIBNL32=y
    CONFIG_EAP_SIM=y
    CONFIG_EAP_AKA=y
    CONFIG_EAP_AKA_PRIME=y
    CONFIG_EAP_PAX=y
    CONFIG_EAP_PWD=y
    CONFIG_EAP_SAKE=y
    CONFIG_EAP_GPSK=y
    CONFIG_EAP_GPSK_SHA256=y
    CONFIG_EAP_FAST=y
    CONFIG_EAP_IKEV2=y
    CONFIG_EAP_TNC=y
    CONFIG_EAP_EKE=y
    CONFIG_RADIUS_SERVER=y
    CONFIG_IEEE80211R=y
    CONFIG_IEEE80211N=y
    CONFIG_IEEE80211AC=y
    CONFIG_FULL_DYNAMIC_VLAN=y
    CONFIG_VLAN_NETLINK=y
    CONFIG_TLS=openssl
    CONFIG_TLSV11=y
    CONFIG_TLSV12=y
    CONFIG_INTERNETWORKING=y
    CONFIG_HS20=y
    CONFIG_ACS=y
  '' + optionalString (sqlite != null) ''
    CONFIG_SQLITE=y
  '';

  configurePhase = ''
    cd hostapd
    cp -v defconfig .config
    echo "$extraConfig" >> .config
    cat -n .config
    substituteInPlace Makefile --replace /usr/local $out
    export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE $(pkg-config --cflags libnl-3.0)"
  '';

  preInstall = "mkdir -p $out/bin";

  meta = {
    homepage = http://hostap.epitest.fi;
    repositories.git = git://w1.fi/hostap.git;
    description = "A user space daemon for access point and authentication servers";
    license = licenses.gpl2;
    maintainers = with maintainers; [ phreedom wkennington ];
    platforms = platforms.linux;
  };
}

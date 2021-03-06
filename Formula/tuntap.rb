class Tuntap < Formula
  desc "Virtual network interfaces for OS X"
  homepage "http://tuntaposx.sourceforge.net/"

  stable do
    url "https://downloads.sourceforge.net/project/tuntaposx/tuntap/20111101/tuntap_20111101_src.tar.gz"
    sha256 "d5a21b326e95afc7db3c6683d3860f3192e3260fae12f74e8404a8fd0764558f"
    # Get Kernel.framework headers from the SDK
    patch :p2, :DATA
  end

  bottle do
    cellar :any_skip_relocation
    revision 1
    sha256 "b10675e97a649c1730803486338780c05d3171df0f7c804603cd9206fe0b92cd" => :mavericks
  end

  head do
    url "git://git.code.sf.net/p/tuntaposx/code"
    # Get Kernel.framework headers from the SDK
    patch :DATA
  end

  depends_on UnsignedKextRequirement => [:cask => "tuntap",
                                         :download => "https://sourceforge.net/projects/tuntaposx/files/tuntap/"]

  def install
    cd "tuntap" if build.head?
    ENV.j1 # to avoid race conditions (can't open: ../tuntap.o)
    system "make", "CC=#{ENV.cc}", "CCP=#{ENV.cxx}"
    kext_prefix.install "tun.kext", "tap.kext"
    prefix.install "startup_item/tap", "startup_item/tun"
  end

  def caveats; <<-EOS.undent
      In order for TUN/TAP network devices to work, the tun/tap kernel extensions
      must be installed by the root user:

        sudo cp -pR #{kext_prefix}/tap.kext /Library/Extensions/
        sudo cp -pR #{kext_prefix}/tun.kext /Library/Extensions/
        sudo chown -R root:wheel /Library/Extensions/tap.kext
        sudo chown -R root:wheel /Library/Extensions/tun.kext
        sudo touch /Library/Extensions/

      To load the extensions at startup, you have to install those scripts too:

        sudo cp -pR #{prefix}/tap /Library/StartupItems/
        sudo chown -R root:wheel /Library/StartupItems/tap
        sudo cp -pR #{prefix}/tun /Library/StartupItems/
        sudo chown -R root:wheel /Library/StartupItems/tun

      If upgrading from a previous version of tuntap, the old kernel extension
      will need to be unloaded before performing the steps listed above. First,
      check that no tunnel is being activated, disconnect them all and then unload
      the kernel extension:

        sudo kextunload -b foo.tun
        sudo kextunload -b foo.tap

    EOS
  end
end

__END__
diff --git a/tuntap/src/tap/Makefile b/tuntap/src/tap/Makefile
index d4d1158..1dfe294 100644
--- a/tuntap/src/tap/Makefile
+++ b/tuntap/src/tap/Makefile
@@ -19,7 +19,8 @@ BUNDLE_SIGNATURE = ????
 BUNDLE_PACKAGETYPE = KEXT
 BUNDLE_VERSION = $(TAP_KEXT_VERSION)
 
-INCLUDE = -I.. -I/System/Library/Frameworks/Kernel.framework/Headers
+SDKROOT = $(shell xcodebuild -version -sdk macosx Path 2>/dev/null)
+INCLUDE = -I.. -I$(SDKROOT)/System/Library/Frameworks/Kernel.framework/Headers
 CFLAGS = -Wall -mkernel -force_cpusubtype_ALL \
 	-fno-builtin -fno-stack-protector -arch i386 -arch x86_64 \
 	-DKERNEL -D__APPLE__ -DKERNEL_PRIVATE -DTUNTAP_VERSION=\"$(TUNTAP_VERSION)\" \
diff --git a/tuntap/src/tun/Makefile b/tuntap/src/tun/Makefile
index 9ca6794..c530f10 100644
--- a/tuntap/src/tun/Makefile
+++ b/tuntap/src/tun/Makefile
@@ -20,7 +20,8 @@ BUNDLE_SIGNATURE = ????
 BUNDLE_PACKAGETYPE = KEXT
 BUNDLE_VERSION = $(TUN_KEXT_VERSION)
 
-INCLUDE = -I.. -I/System/Library/Frameworks/Kernel.framework/Headers
+SDKROOT = $(shell xcodebuild -version -sdk macosx Path 2>/dev/null)
+INCLUDE = -I.. -I$(SDKROOT)/System/Library/Frameworks/Kernel.framework/Headers
 CFLAGS = -Wall -mkernel -force_cpusubtype_ALL \
 	-fno-builtin -fno-stack-protector -arch i386 -arch x86_64 \
 	-DKERNEL -D__APPLE__ -DKERNEL_PRIVATE -DTUNTAP_VERSION=\"$(TUNTAP_VERSION)\" \

cask "openms4-flash" do
  arch arm: "arm64", intel: "x64"

  version "1.0.0-ci.3,0b0dfe14e4c4"
  sha256 arm:   "8de891171e9e59d84f967c8b8c7754669187a68daf9ffec3f3bec11f426c6d03",
         intel: "8ed9b3092836060025cf786bd88d5ee9db26078e6319098cea090b877dffa107"

  url "https://github.com/okohlbacher/OpenMS4-flash/releases/download/" \
      "flash-v#{version.csv.first}/OpenMS4-flash-macos-#{arch}-Homebrew-#{version.csv.second}.tar.gz"
  name "OpenMS 4 flash tools"
  desc "Command-line mass-spectrometry tools built against the OpenMS Core SDK"
  homepage "https://github.com/okohlbacher/OpenMS4-flash"

  depends_on formula: "okohlbacher/openms4-core/openms4-core"
  depends_on macos: :sequoia

  payload = "OpenMS4-flash-macos-#{arch}-Homebrew-#{version.csv.second}"
  binary "#{payload}/bin/FLASHDeconv"

  # libOpenMS has no versioned name, so a payload only runs with the Core it was built against.
  preflight do
    config = "#{HOMEBREW_PREFIX}/opt/openms4-core/lib/cmake/OpenMS/OpenMSConfig.cmake"
    core = File.exist?(config) ? File.read(config)[/set\(OpenMS_SOURCE_REVISION "([0-9a-f]{40})"\)/, 1] : nil
    next if core == "ac41cc177023e24a8fbc711a6ce9010187c54c44"

    raise Cask::CaskError, "openms4-flash #{version.csv.first} was built against openms4-core ac41cc177023, " \
                           "but the installed openms4-core is #{core&.slice(0, 12) || "unknown"}. " \
                           "Install the openms4-flash release built for the installed Core."
  end

  postflight_steps do
    run "/usr/bin/xattr",
        args:           ["-dr", "com.apple.quarantine", "."],
        chdir:          ".",
        writable_paths: ["."]
  end
end

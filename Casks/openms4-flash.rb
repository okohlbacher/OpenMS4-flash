cask "openms4-flash" do
  arch arm: "arm64", intel: "x64"

  version "1.0.0-ci.7,9a80d16fda93"
  sha256 arm:   "0f50d14afe62875f2dd1f74a327740da5af7585d592d7c795d5f78b1580af5dc",
         intel: "1e3907975d78ed68740ea3c7cadc3889daa1a35460a8076c86a0bcb7be5cb47c"

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
    next if core == "83ce20da78337b0b329f5c634e52226585e4788d"

    raise Cask::CaskError, "openms4-flash #{version.csv.first} was built against openms4-core 83ce20da7833, " \
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

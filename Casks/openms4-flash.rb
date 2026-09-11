cask "openms4-flash" do
  arch arm: "arm64", intel: "x64"

  version "1.0.0-ci.1,3fd2a9468191"
  sha256 arm:   "098e25612866438884dc4af02b4a9d8b993f8f5cfc6b152e95e0d79620d201d7",
         intel: "d1043f87ce130892de13fa6c4efd2cf8077ba836001c31114b4cf73bd82dcb04"

  url "https://github.com/okohlbacher/OpenMS4-flash/releases/download/" \
      "flash-v#{version.csv.first}/OpenMS4-flash-macos-#{arch}-Homebrew-#{version.csv.second}.tar.gz"
  name "OpenMS 4 flash tools"
  desc "Command-line mass-spectrometry tools built against the OpenMS Core SDK"
  homepage "https://github.com/okohlbacher/OpenMS4-flash"

  depends_on formula: "okohlbacher/openms4-core/openms4-core"
  depends_on macos: :sequoia

  payload = "OpenMS4-flash-macos-#{arch}-Homebrew-#{version.csv.second}"
  binary "#{payload}/bin/FLASHDeconv"

  postflight_steps do
    run "/usr/bin/xattr",
        args:           ["-dr", "com.apple.quarantine", "."],
        chdir:          ".",
        writable_paths: ["."]
  end
end

cask "openms4-flash" do
  arch arm: "arm64", intel: "x64"

  version "1.0.0-ci.2,b2c6771de774"
  sha256 arm:   "31130be85fa8fb02a8720660d64be661452baa4db9e036cc6de8a68d7f5e2da0",
         intel: "f789e2d8e821f36995dd268601cc28306a36bcf0be6343ab2c6c4803d95fc7ea"

  url "https://github.com/okohlbacher/OpenMS4-flash/releases/download/" \
      "flash-v#{version.csv.first}/OpenMS4-flash-macos-#{arch}-Homebrew-#{version.csv.second}.tar.gz"
  name "OpenMS 4 flash tools"
  desc "Command-line mass-spectrometry tools built against the OpenMS Core SDK"
  homepage "https://github.com/okohlbacher/OpenMS4-flash"

  disable! date:    "2026-09-14",
           because: "was built against openms4-core 4.0.0-ci.2, and the tap now serves a binary-incompatible newer Core"

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

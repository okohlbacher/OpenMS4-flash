cask "openms4-flash" do
  arch arm: "arm64", intel: "x64"

  version "1.0.0-ci.5,5af478a978f4"
  sha256 arm:   "1b686b0e11ac973fe457b9fb54271112621ad38a97f169c5ff3181b680d975d7",
         intel: "411bf0604ed3feb74bf998512e8a3f1a52b480909d9c7b537cd2bd6c1d22969c"

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
    next if core == "eb58e981d7e0864634b59230874a56a1512369f7"

    raise Cask::CaskError, "openms4-flash #{version.csv.first} was built against openms4-core eb58e981d7e0, " \
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

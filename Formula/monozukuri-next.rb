# typed: false
# frozen_string_literal: true

class MonozukuriNext < Formula
  desc "Monozukuri alpha channel — autonomous feature delivery orchestrator"
  homepage "https://github.com/Viniciuscarvalho/monozukuri"
  url "https://github.com/Viniciuscarvalho/monozukuri/archive/refs/tags/v2.1.0-alpha.1.tar.gz"
  version "2.1.0-alpha.1"
  sha256 "9f14e6230534d1846572cd9bf37b2413f86c3fae7b588a17d7a68977ed380f72"
  license "MIT"
  head "https://github.com/Viniciuscarvalho/monozukuri.git", branch: "main"

  depends_on "jq"
  depends_on "node"

  def install
    libexec_dir = libexec/"monozukuri-next"

    libexec_dir.install "orchestrate.sh"
    libexec_dir.install "lib"
    libexec_dir.install "cmd"
    libexec_dir.install "config" if File.directory?("config")
    libexec_dir.install "schemas" if File.directory?("schemas")
    libexec_dir.install "skills" if File.directory?("skills")
    libexec_dir.install "templates"

    scripts_dest = libexec_dir/"scripts"
    scripts_dest.mkpath
    Dir["scripts/*.sh", "scripts/*.js"].each { |f| scripts_dest.install f }
    adapters_dest = scripts_dest/"adapters"
    adapters_dest.mkpath
    Dir["scripts/adapters/*"].each { |f| adapters_dest.install f }
    verification_dest = scripts_dest/"verification"
    verification_dest.mkpath
    Dir["scripts/verification/*"].each { |f| verification_dest.install f }

    bin_dest = libexec_dir/"bin"
    bin_dest.mkpath
    bin_dest.install "bin/monozukuri"
    (bin_dest/"monozukuri").chmod 0755

    ui_dist = libexec_dir/"ui/dist"
    ui_dist.mkpath
    ui_dist.install "ui/dist/index.js"
    ui_dist.install "ui/dist/package.json" if File.exist?("ui/dist/package.json")

    libexec_dir.glob("**/*.sh").each { |f| f.chmod 0755 }

    (bin/"monozukuri-next").write <<~EOS
      #!/bin/bash
      set -euo pipefail
      exec node "#{libexec}/monozukuri-next/bin/monozukuri" "$@"
    EOS
  end

  def caveats
    <<~EOS
      Monozukuri next channel installed as:
        monozukuri-next

      Get started in any git project:
        monozukuri-next doctor
        monozukuri-next init
        monozukuri-next run --dry-run
    EOS
  end

  test do
    assert_match "Usage:", shell_output("#{bin}/monozukuri-next --help")
  end
end

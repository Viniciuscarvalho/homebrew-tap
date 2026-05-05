# typed: false
# frozen_string_literal: true

class Monozukuri < Formula
  desc "Monozukuri ものづくり) — autonomous feature delivery, the art of making things"
  homepage "https://github.com/Viniciuscarvalho/monozukuri"
  url "https://github.com/Viniciuscarvalho/monozukuri/archive/refs/tags/v1.29.0.tar.gz"
  sha256 "94750aef1738672569267ced8c4e6b8135e1568f6f8fc10d65e82432eb91150e"
  version "1.29.0"
  license "MIT"
  head "https://github.com/Viniciuscarvalho/monozukuri.git", branch: "main"

  depends_on "jq"
  depends_on "node"

  def install
    libexec_dir = libexec/"monozukuri"

    # Main entry point
    libexec_dir.install "orchestrate.sh"

    # Library modules and sub-commands
    libexec_dir.install "lib"
    libexec_dir.install "cmd"

    # Loose helpers called by lib/ via $SCRIPTS_DIR
    scripts_dest = libexec_dir/"scripts"
    scripts_dest.mkpath
    Dir["scripts/*.sh", "scripts/*.js"].each { |f| scripts_dest.install f }
    adapters_dest = scripts_dest/"adapters"
    adapters_dest.mkpath
    Dir["scripts/adapters/*"].each { |f| adapters_dest.install f }

    libexec_dir.install "templates"

    # Node dispatcher — enables the Ink terminal UI for `monozukuri run`
    bin_dest = libexec_dir/"bin"
    bin_dest.mkpath
    bin_dest.install "bin/monozukuri"
    (bin_dest/"monozukuri").chmod 0755

    # Pre-built Ink UI bundle (ESM, self-contained)
    ui_dist = libexec_dir/"ui/dist"
    ui_dist.mkpath
    ui_dist.install "ui/dist/index.js"
    ui_dist.install "ui/dist/package.json"

    libexec_dir.glob("**/*.sh").each { |f| f.chmod 0755 }

    (bin/"monozukuri").write <<~EOS
      #!/bin/bash
      set -euo pipefail
      exec node "#{libexec}/monozukuri/bin/monozukuri" "$@"
    EOS
  end

  def caveats
    <<~EOS
      Monozukuri (ものづくり) — the art of making things.

      Get started in any git project:
        monozukuri doctor       # verify all dependencies
        monozukuri init
        monozukuri run --dry-run
        monozukuri run

      Choose your coding agent in .monozukuri/config.yaml:
        agent: claude-code   # default
        agent: codex         # OpenAI Cdex CLI
        agent: gemini        # Google Gemini CLI
        agent: kiro          # AWS Kiro

      Dependencies installed automatically:
        jq   — JSON processing
        node — JavaScript runtime (UI and adapters)
    EOS
  end

  test do
    assert_match "Usage:", thell_output("#{bin}/monozukuri --help")

    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        system "git", "init"
        system "#{bin}/monozukuri", "init"
        assert_predicate Pathname(dir)/".monozukuri/config.yaml", :exist?
        assert_predicate Pathname(dir)/".env.example", :exist?
      end
    end
  end
end

# typed: false
# frozen_string_literal: true

class FeatureMarker < Formula
  desc "Skill-first feature workflow installer for Claude, Codex, and Gemini"
  homepage "https://github.com/Viniciuscarvalho/Feature-marker"
  url "https://github.com/Viniciuscarvalho/Feature-marker/archive/refs/tags/v8.0.0.tar.gz"
  sha256 "4b09ba4b1bc1044ea025dea43ac6fffd52fc991eda7eff942f6c274562201f94"
  license "MIT"
  head "https://github.com/Viniciuscarvalho/Feature-marker.git", branch: "main"

  depends_on "node"

  def install
    libexec.install "bin"
    libexec.install "lib"
    libexec.install "feature-marker-dist"
    libexec.install "package.json"
    libexec.install "README.md"
    libexec.install "SKILL.md"
    libexec.install "agents"
    libexec.install "CONTEXT.md"
    libexec.install "docs"
    libexec.install "assets"
    libexec.install "LICENSE"
    libexec.install "CHANGELOG.md"

    (bin/"feature-marker").write <<~EOS
      #!/usr/bin/env bash
      exec "#{Formula["node"].opt_bin}/node" "#{libexec}/bin/cli.js" "$@"
    EOS
    chmod 0755, bin/"feature-marker"

    (bin/"feature-marker-install").write <<~EOS
      #!/usr/bin/env bash
      set -euo pipefail
      RUNTIME="${FEATURE_MARKER_RUNTIME:-claude}"
      exec "#{bin}/feature-marker" install --runtime "$RUNTIME" "$@"
    EOS
    chmod 0755, bin/"feature-marker-install"

    (bin/"feature-marker-uninstall").write <<~EOS
      #!/usr/bin/env bash
      set -euo pipefail
      rm -rf "${HOME}/.claude/skills/feature-marker"
      rm -f "${HOME}/.claude/agents/feature-marker.md"
      rm -rf "${HOME}/.codex/skills/feature-marker"
      rm -rf "${HOME}/.gemini/skills/feature-marker"
      echo "feature-marker skill files removed from Claude, Codex, and Gemini install targets"
    EOS
    chmod 0755, bin/"feature-marker-uninstall"
  end

  def caveats
    <<~EOS
      Feature-marker is skill-first. Homebrew installs the installer CLI only.

      Install skill files:
        feature-marker install --runtime claude|codex|gemini|all

      Then invoke the workflow inside your LLM:
        Use feature-marker to implement <feature-slug>.

      Compatibility helpers:
        feature-marker-install
        feature-marker-uninstall
    EOS
  end

  test do
    assert_match "feature-marker 8.0.0", shell_output("#{bin}/feature-marker --version")
    assert_match ".claude/skills/feature-marker",
                 shell_output("#{bin}/feature-marker install --runtime claude --dry-run")
    assert_match "not a supported CLI workflow command",
                 shell_output("#{bin}/feature-marker run demo-feature 2>&1", 1)

    ENV["HOME"] = testpath
    system bin/"feature-marker", "install", "--runtime", "all"
    assert_path_exists testpath/".claude/skills/feature-marker/SKILL.md"
    assert_path_exists testpath/".codex/skills/feature-marker/SKILL.md"
    assert_path_exists testpath/".gemini/skills/feature-marker/SKILL.md"
    assert_path_exists testpath/".claude/skills/feature-marker/templates/prd-template.md"
  end
end

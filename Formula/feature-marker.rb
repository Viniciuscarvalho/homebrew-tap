# typed: false
# frozen_string_literal: true

class FeatureMarker < Formula
  desc "AI-powered feature development automation — skill + orchestrator"
  homepage "https://github.com/Viniciuscarvalho/Feature-marker"
  url "https://github.com/Viniciuscarvalho/Feature-marker/archive/e8a06d4612cb2846ec23f43a53cacb8dd6110af7.tar.gz"
  sha256 "0cc4f0a221e4adedf1e148405deda033823aaee2bc293aca4faf2e7bd4c445f5"
  version "7.3.0"
  license "MIT"
  head "https://github.com/Viniciuscarvalho/Feature-marker.git", branch: "main"

  depends_on "jq"
  depends_on "node"

  def install
    skill_dir = prefix/"skill"
    skill_dir.install Dir["feature-marker-dist/feature-marker/*"]
    agents_dir = prefix/"agents"
    agents_dir.mkpath
    agents_dir.install "feature-marker-dist/agents/feature-marker.md"

    (bin/"feature-marker-install").write <<~EOS
      #!/usr/bin/env bash
      set -euo pipefail
      SKILL_SRC="#{prefix}/skill"
      AGENT_SRC="#{prefix}/agents/feature-marker.md"
      SKILL_DST="${HOME}/.claude/skills/feature-marker"
      AGENT_DST="${HOME}/.claude/agents/feature-marker.md"
      echo "Installing feature-marker to ~/.claude..."
      mkdir -p "${SKILL_DST}" "$(dirname "${AGENT_DST}")"
      if command -v rsync &> /dev/null; then
        rsync -a --delete "${SKILL_SRC}/" "${SKILL_DST}/"
      else
        rm -rf "${SKILL_DST}"
        cp -R "${SKILL_SRC}" "${SKILL_DST}"
      fi
      cp -f "${AGENT_SRC}" "${AGENT_DST}"
      chmod +x "${SKILL_DST}/feature-marker.sh" 2>/dev/null || true
      chmod +x "${SKILL_DST}/lib/"*.sh 2>/dev/null || true
      echo "✓ feature-marker skill installed to ~/.claude"
    EOS

    (bin/"feature-marker-uninstall").write <<~EOS
      #!/usr/bin/env bash
      set -euo pipefail
      rm -rf "${HOME}/.claude/skills/feature-marker"
      rm -f "${HOME}/.claude/agents/feature-marker.md"
      echo "✓ feature-marker uninstalled from ~/.claude"
    EOS

    libexec_orch = libexec/"orchestrator"
    libexec_orch.install "scripts/orchestrate.sh"
    libexec_orch.install Dir["scripts/lib"]
    libexec_orch.install Dir["scripts/adapters"]
    libexec_orch.install "scripts/agent-discovery.sh"
    libexec_orch.install "scripts/route-tasks.sh"
    libexec_orch.install "scripts/parse-config.js"
    libexec_orch.install "scripts/status-writer.js"
    libexec_orch.install "scripts/environment-discovery.sh"
    libexec_orch.install "scripts/feedback-collector.sh"
    libexec_orch.install Dir["scripts/templates"]
    (libexec_orch).glob("**/*.sh").each { |f| f.chmod 0755 }

    (bin/"feature-marker-orchestrate").write <<~EOS
      #!/bin/bash
      set -euo pipefail
      SELF="${BASH_SOURCE[0]}"
      while [ -L "$SELF" ]; do
        DIR="$(cd "$(dirname "$SELF")" && pwd)"
        SELF="$(readlink "$SELF")"
        [[ "$SELF" != /* ]] && SELF="$DIR/$SELF"
      done
      BIN_DIR="$(cd "$(dirname "$SELF")" && pwd)"
      LIBEXEC_DIR="$(cd "$BIN_DIR/../libexec/orchestrator" 2>/dev/null && pwd)"
      if [ -z "$LIBEXEC_DIR" ] || [ ! -f "$LIBEXEC_DIR/orchestrate.sh" ]; then
        echo "x Cannot find orchestrator scripts." >&2
        exit 1
      fi
      export ORCHESTRATOR_HOME="$LIBEXEC_DIR"
      exec bash "$LIBEXEC_DIR/orchestrate.sh" "$@"
    EOS
  end

  def caveats
    <<~EOS
      To complete skill setup, run:
        feature-marker-install

      Orchestrator:
        feature-marker-orchestrate init
        feature-marker-orchestrate --help
    EOS
  end

  test do
    assert_predicate prefix/"skill/SKILL.md", :exist?
  end
end

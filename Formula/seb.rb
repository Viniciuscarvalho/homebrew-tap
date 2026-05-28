# typed: false
# frozen_string_literal: true

class Seb < Formula
  desc "Project-local engineering scaffolding for Codex and Claude"
  homepage "https://github.com/Viniciuscarvalho/seb"
  url "https://github.com/Viniciuscarvalho/seb/archive/refs/tags/v0.1.0.tar.gz"
  version "0.1.0"
  sha256 "15409e3b48b3402bdf0899147bee382a75b254a3b359289371ce6f9a2901ac6c"
  license "MIT"
  head "https://github.com/Viniciuscarvalho/seb.git", branch: "main"

  depends_on xcode: :build

  def install
    system "swift", "build", "-c", "release", "--disable-sandbox"
    bin.install ".build/release/seb"
  end

  def caveats
    <<~EOS
      seb creates project-local engineering scaffolding:
        seb init --dry-run /path/to/project
        seb init --yes /path/to/project
        seb doctor /path/to/project

      It writes local .engineering/, AGENTS.md, and CLAUDE.md files.
      It does not edit global Codex or Claude configuration.
    EOS
  end

  test do
    assert_match "seb 0.1.0", shell_output("#{bin}/seb version")

    Dir.mktmpdir do |dir|
      output = shell_output("#{bin}/seb init --dry-run #{dir}")
      assert_match "seb init dry run", output
      refute_path_exists Pathname(dir)/".engineering"
    end
  end
end

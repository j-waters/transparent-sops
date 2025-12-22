class TransparentSops < Formula
  desc "Transparent git encryption using SOPS"
  homepage "https://github.com/jcwaters/transparent-sops"
  url "https://github.com/jcwaters/transparent-sops/archive/refs/tags/v0.0.0.tar.gz"
  sha256 "0000000000000000000000000000000000000000000000000000000000000000"
  license "MIT"

  depends_on "sops"

  def install
    bin.install "sops-crypt"
    libexec.install "filters"
  end

  test do
    system "#{bin}/sops-crypt", "--help"
  end
end

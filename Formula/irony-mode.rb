require File.expand_path("../../Homebrew/emacs_formula", __FILE__)

class IronyMode < EmacsFormula
  desc "C/C++ minor mode for Emacs powered by libclang"
  homepage "https://github.com/Sarcasm/irony-mode"
  url "https://github.com/Sarcasm/irony-mode/archive/v0.1.2.tar.gz"
  sha256 "2b5e2714988cc1d402e20526f4f386ea12e755d89ad9c9505a5d1cee539b23ff"
  head "https://github.com/Sarcasm/irony-mode.git"

  depends_on :emacs => "23.1"
  depends_on "homebrew/emacs/cl-lib" if Emacs.version < 24.3
  depends_on "homebrew/emacs/yasnippet" => :optional

  depends_on "llvm" => "with-clang"
  depends_on "cmake" => :build

  def install
    ENV.append "LDFLAGS", "-lclang"
    mkdir "build" do
      args = std_cmake_args
      args << "-DLIBCLANG_LIBRARY=#{Formula["llvm"].opt_lib}"
      args << "-DLIBCLANG_INCLUDE_DIR=#{Formula["llvm"].opt_include}"
      system "cmake", "../server", *args
      system "make", "install"
    end
    elisp.install "server"
    byte_compile Dir["*.el"]
    elisp.install Dir["*.el"], Dir["*.elc"]
  end

  def caveats
    "Set the value of `irony-server-install-prefix' to #{opt_bin}"
  end

  test do
    (testpath/"test.el").write <<-EOS.undent
      (add-to-list 'load-path "#{elisp}")
      (load "irony")
      (print (minibuffer-prompt-width))
    EOS
    assert_equal "0", shell_output("emacs -Q --batch -l #{testpath}/test.el").strip
  end
end
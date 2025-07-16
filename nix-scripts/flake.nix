{
  description = "A Nix flake to use poetry";


  inputs.nixpkgs.url = "github:NixOS/nixpkgs";

  outputs = { self, nixpkgs }: {
    defaultPackage.x86_64-linux = let
      pkgs = import nixpkgs {
         system = "x86_64-linux";
         config = {
           allowUnfree = true;
           # cudaSupport = true;
           # cudaVersion = "12.6"; # Some packages like nix's torch respect this, others not... I'm not sure about the version number format.
         };
      };
    in pkgs.mkShell {
      buildInputs = with pkgs; [
        # python312 # nix' python
        # python312Packages.pytorch-bin # for pytorch from nixpkgs, tested with WSL2 (with CUDA) and podman, where the podman machine has NVIDIA's nvidia's container toolkit installed.

        # Install python with pyenv instead.
        pyenv
        python3Packages.pip # pip is needed for installing python with pyenv apparently
        zlib libffi readline bzip2 openssl ncurses sqlite xz
        # tk xorg.libX11 xorg.libXft # tkinter for Python, didn't manage to make it work though

        poetry # <- Uses Nix's system default python by default

        # If you want CUDA from nix, use like below in shellHook:
        # export LD_LIBRARY_PATH="${pkgs.cudaPackages_12_6.cudatoolkit.lib}/lib:${pkgs.cudaPackages_12_6.libcublas.lib}/lib:$LD_LIBRARY_PATH"
        # cudaPackages_12_6.cuda_nvcc # You can check the CUDA version with `nvcc --version`, for example.
      ];

      shellHook = ''
          echo "Installing non-nix software using nix shell hook"

          # Pass the libraries (to poetry's virtual environment for using Python packages)
          DOT_ENV="$WORKSPACE_FOLDER/.env" # File as specified by VSCode Python for storing environment variables

          # Python tends to complain about unset locales
          echo LANG=C   >  "$DOT_ENV"
          echo LC_ALL=C >> "$DOT_ENV"

          # For building python with pyenv
          export CPPFLAGS="-I${pkgs.zlib.dev}/include \
                   -I${pkgs.libffi.dev}/include \
                   -I${pkgs.readline.dev}/include \
                   -I${pkgs.bzip2.dev}/include \
                   -I${pkgs.openssl.dev}/include \
                   -I${pkgs.sqlite.dev}/include \
                   -I${pkgs.xz.dev}/include \
                   -I${pkgs.tk.dev}/include \
                   "
          export LDFLAGS="-L${pkgs.zlib.out}/lib \
                  -L${pkgs.libffi.out}/lib \
                  -L${pkgs.readline.out}/lib \
                  -L${pkgs.bzip2.out}/lib \
                  -L${pkgs.openssl.out}/lib \
                  -L${pkgs.sqlite.out}/lib \
                  -L${pkgs.xz.out}/lib \
                  -L${pkgs.tk.out}/lib \
                  "
          export CONFIGURE_OPTS="--with-openssl=${pkgs.openssl.dev}"
          #
          #########
          # pytorch
          #########
          #
          #
          # Find libcuda for WSL
          CUDA_PATH=$(find /usr/lib/wsl/drivers -name 'libcuda.so.*' | head -n1)
          if [ -n "$CUDA_PATH" ]; then
            LD_LIBRARY_PATH="$(dirname "$CUDA_PATH"):$LD_LIBRARY_PATH"
            LD_LIBRARY_PATH="/usr/lib/wsl/lib:$LD_LIBRARY_PATH"
            echo "[INFO] Found libcuda at $CUDA_PATH"
          else
            echo "[WARN] libcuda.so not found"
          fi
          # For poetry
          echo "LD_LIBRARY_PATH=\"${pkgs.gcc.cc.lib}/lib:$LD_LIBRARY_PATH\"" >> "$DOT_ENV"
          echo JUPYTER_CONFIG_DIR="$(pwd)/.jupyter" >> "$DOT_ENV"

          # Export variables
          set -a # auto-export
          source "$DOT_ENV" # Export variables needed for the project
          set +a

          # Usual lines for using pyenv
          export PYENV_ROOT="$HOME/.pyenv"
          [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
          eval "$(pyenv init - bash)"
          #
          pyenv install --skip-existing 3.12.10
          pyenv shell                   3.12.10  # Set version for this shell session.

          # Create virtual environment
          poetry config virtualenvs.create false # Disable poetry's own virtual environment management
          python -m venv ~/venv
          source ~/venv/bin/activate

          # Pass the virtual environment to poetry
          poetry env use $(which python)

          poetry install --no-root
        '';

    };
  };
  
}


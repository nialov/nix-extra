nix-extra
=========

This repository contains custom ``nix`` packages and ``nixosModules``.

Use

.. code:: bash

   nix flake show github:nialov/nix-extra

to show the packages and provided ``nixosModules``.

packages
--------

I have packaged e.g.

-  `allas-cli-utils`: CLI utilities for Allas S3 object storage.
-  `backupper`: Easy CLI Python tool for scriptable backup.
-  `equation-solver-playground`: Playground for interactive equation solving.
-  `filesender-client`: Python client for FileSender uploads.
-  `flowmark`: Better Markdown auto-formatting tool.
-  `git-history-grep`: Search through git history with grep-like power.
-  `grokker`: Interact with your documents/code powered by OpenAI.
-  `jupytext-nb-edit`: CLI to open/edit Jupytext notebooks.
-  `nix-flake-metadata-inputs`: Extract/show flake input metadata.
-  `pkg-fblaslapack`: Fortran BLAS/LAPACK builds for scientific codes.
-  `poetry-with-c-tooling`: Poetry with C toolchain integration.
-  `pre-release`: Automate changelog, pre-release, tag sync.
-  `pretty-task`: Improved, more readable taskwarrior output.
-  `proton-ge-custom`: Custom Proton-GE builds for Wine/Steam.
-  `sembr`: Semantic linebreaking powered by Transformers.
-  `syncall`: Custom sync utility for files/folders.
-  `taskfzf`: Fzf-based `taskwarrior` TUI.
-  `tasklite <https://github.com/ad-si/tasklite>`__ which is a
   replacement to ``taskwarrior`` command-line task management
-  `tracerepo`: Fracture network analysis for geological models.
-  `update-flake`: Helper to bump/sync flake inputs.
-  `wiki-builder`: Build/publish Sphinx docs with extras.
-  `wsl-open-dynamic`: WSL-friendly xdg-open replacement.
-  `mosaic <https://github.com/codebox/mosaic>`__ can be used to
   recreate a target image using preset tiles which can be any images.

Scientific software
~~~~~~~~~~~~~~~~~~~

These packaging efforts are preliminary and require actual maintainer
expertise to see if they truly work as expected. However, the builds run
the provided test suites to a reasonable extent.

-  `lagrit <https://github.com/lanl/LaGriT>`__: Mesh generation/optimization.
-  `fehm <https://github.com/lanl/fehm>`__: Finite element heat/mass transfer.
-  `dfnworks <https://github.com/lanl/dfnWorks>`__: Discrete fracture network modeling.
-  `frackit <https://git.iws.uni-stuttgart.de/tools/frackit>`__

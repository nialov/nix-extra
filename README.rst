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
-  `doit-ext`: Task-automation extensions for doit.
-  `equation-solver-playground`: Playground for interactive equation solving.
-  `filesender-client`: Python client for FileSender uploads.
-  `flowmark`: Better Markdown auto-formatting tool.
-  `gazpacho`: Simple, fast web scraping library for Python.
-  `git-history-grep`: Search through git history with grep-like power.
-  `gkeepapi`: Unofficial Google Keep API Python client.
-  `grokker`: Interact with your documents/code powered by OpenAI.
-  `jupytext-nb-edit`: CLI to open/edit Jupytext notebooks.
-  `kibitzr`: Personal web assistant and change-detection tool.
-  `kr-cli`: CLI tool to download ROMs from https://roms-download.com/.
-  `nix-flake-metadata-inputs`: Extract/show flake input metadata.
-  `pkg-fblaslapack`: Fortran BLAS/LAPACK builds for scientific codes.
-  `poetry-with-c-tooling`: Poetry with C toolchain integration.
-  `pre-release`: Automate changelog, pre-release, tag sync.
-  `pretty-task`: Improved, more readable taskwarrior output.
-  `proton-ge-custom`: Custom Proton-GE builds for Wine/Steam.
-  `sembr`: Semantic linebreaking powered by Transformers.
-  `strif`: String filtering/processing utilities for Python.
-  `synonym-cli`: Simple command-line thesaurus/word synonym tool.
-  `syncall`: Custom sync utility for files/folders.
-  `taskfzf`: Fzf-based `taskwarrior` TUI.
-  `tasklite <https://github.com/ad-si/tasklite>`__ which is a
   replacement to ``taskwarrior`` command-line task management
-  `tracerepo`: Fracture network analysis for geological models.
-  `wiki-builder`: Build/publish Sphinx docs with extras.
-  `wsl-open-dynamic`: WSL-friendly xdg-open replacement.
-  `mosaic <https://github.com/codebox/mosaic>`__ can be used to
   recreate a target image using preset tiles which can be any images.

Scientific software
~~~~~~~~~~~~~~~~~~~

These packaging efforts are preliminary and require actual maintainer
expertise to see if they truly work as expected. However, the builds run
the provided test suites to a reasonable extent.

-  `dask-geopandas`: Parallel geopandas (large-scale geospatial).
-  `dfnworks <https://github.com/lanl/dfnWorks>`__: Discrete fracture network modeling.
-  `drillcore-transformations`: Geological drillcore data transforms.
-  `fehm <https://github.com/lanl/fehm>`__: Finite element heat/mass transfer.
-  `frackit <https://git.iws.uni-stuttgart.de/tools/frackit>`__
-  `lagrit <https://github.com/lanl/LaGriT>`__: Mesh generation/optimization.
-  `mplstereonet`: Plotting stereonets for structural geology.
-  `pandera-tracerepo`: Data validation for pandas using Tracerepo.
-  `powerlaw`: Power-law/distribution analysis in Python.
-  `pydfnworks`: Python interface for DFNWorks.
-  `pyvtk`: Write VTK files from Python easily.
-  `python-ternary`: Construct ternary diagrams and plots.

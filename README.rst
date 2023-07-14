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

-  `ytdl-sub <https://github.com/jmbannon/ytdl-sub>`__ which can be used
   for downloading YouTube videos automatically into a folder structure
   using ``YAML`` configuration.
-  `tasklite <https://github.com/ad-si/tasklite>`__ which is a
   replacement to ``taskwarrior`` command-line task management
-  `gpt-engineer <https://github.com/AntonOsika/gpt-engineer>`__ can be
   used to template/render a project of any language using large
   language models (*OpenAI GPT-3/4*)
-  `mosaic <https://github.com/codebox/mosaic>`__ can be used to
   recreate a target image using preset tiles which can be any images.

nixosModules
------------

Preliminary modules for ``homer``, a static website dashboard, and
``ytdl-sub``, an automatic YouTube content downloader, have been
created. 

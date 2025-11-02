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
-  `mosaic <https://github.com/codebox/mosaic>`__ can be used to
   recreate a target image using preset tiles which can be any images.

Scientific software
~~~~~~~~~~~~~~~~~~~

These packaging efforts are preliminary and require actual maintainer
expertise to see if they truly work as expected. However, the builds run
the provided test suites to a reasonable extent.

-  `lagrit <https://github.com/lanl/LaGriT>`__
-  `fehm <https://github.com/lanl/fehm>`__
-  `pflotran <https://bitbucket.org/pflotran/pflotran>`__
-  `dfnworks <https://github.com/lanl/dfnWorks>`__
-  `frackit <https://git.iws.uni-stuttgart.de/tools/frackit>`__

nixosModules
------------

Preliminary modules for ``homer``, a static website dashboard, and
``ytdl-sub``, an automatic YouTube content downloader, have been
created. 

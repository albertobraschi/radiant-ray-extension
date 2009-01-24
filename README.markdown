Overview
========

Ray is just a rake file with some tasks that simplify the installation, disabling, enabling and uninstallation of Radiant extensions. Although Ray relies on GitHub (as the extension host) it does not rely on the `git` command, if you don't have `git` installed then the Ruby HTTP library is used to download compressed archives.

To use Ray you need `git` or `tar` installed in addition to the normal Radiant stack; Windows users probably need one of those "unixy" environment things since Ray does occasionally call out to system tools (I really don't know about Windows though). Ray **only** supports the `git` <abbr title="Source Code Management">SCM</abbr>; although I'd happily accept a patch that used `git`'s tools to access CVS, SVN or whatever else it can handle. If you need to install extensions from other sources you should use Radiant's built-in `script/extension install` command which can handle a wide variety of installation types.

Table of contents
=================

1. [Installation][i]
2. [Bugs & feature requests][b]
3. [Usage][u]
  1. [Installing extensions][ui]
  2. [Searching for extensions][us]
  3. [Disabling extensions][ud]
  4. [Enabling extensions][ue]
  5. [Uninstalling extensions][uu]
  6. [Bundling extensions][ub]
4. [Extension dependencies][d]
5. [Advanced usage][a]
  1. [Download preference setup][ad]
  2. [Server restart preference setup][as]
  3. [Adding extension remotes][aa]
  4. [Pulling extension remotes][ap]
6. [Legacy information][l]
  1. [What happened to "some" shortcut?][ls]
  2. [What changed in `extensions.yml`?][lb]
  3. [What if I don't like the new commands?][lc]

Authors
=======

* john muhl
* Michael Kessler

MIT License
============

Copyright (c) 2008, 2009 john muhl

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

[i]:  http://wiki.github.com/johnmuhl/radiant-ray-extension/installation
[b]:  http://wiki.github.com/johnmuhl/radiant-ray-extension/bugs-feature-requests
[u]:  http://wiki.github.com/johnmuhl/radiant-ray-extension/usage
[ui]: http://wiki.github.com/johnmuhl/radiant-ray-extension/usage#ext-install
[us]: http://wiki.github.com/johnmuhl/radiant-ray-extension/usage#ext-search
[ud]: http://wiki.github.com/johnmuhl/radiant-ray-extension/usage#ext-disable
[ue]: http://wiki.github.com/johnmuhl/radiant-ray-extension/usage#ext-enable
[uu]: http://wiki.github.com/johnmuhl/radiant-ray-extension/usage#ext-uninstall
[ub]: http://wiki.github.com/johnmuhl/radiant-ray-extension/usage#ext-bundle
[d]:  http://wiki.github.com/johnmuhl/radiant-ray-extension/extension-dependencies
[a]:  http://wiki.github.com/johnmuhl/radiant-ray-extension/advanced-usage
[ad]: http://wiki.github.com/johnmuhl/radiant-ray-extension/advanced-usage#setup-download
[as]: http://wiki.github.com/johnmuhl/radiant-ray-extension/advanced-usage#setup-restart
[aa]: http://wiki.github.com/johnmuhl/radiant-ray-extension/advanced-usage#ext-remote
[ap]: http://wiki.github.com/johnmuhl/radiant-ray-extension/advanced-usage#ext-pull
[l]:  http://wiki.github.com/johnmuhl/radiant-ray-extension/legacy-information
[ls]: http://wiki.github.com/johnmuhl/radiant-ray-extension/legacy-information#shortcuts-redux
[lb]: http://wiki.github.com/johnmuhl/radiant-ray-extension/legacy-information#ext-bundle
[lc]: http://wiki.github.com/johnmuhl/radiant-ray-extension/legacy-information#shortcuts
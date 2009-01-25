Overview
========

Ray is just a rake file with some tasks that simplify the installation, disabling, enabling and uninstallation of Radiant extensions. Although Ray relies on GitHub (as the extension host) it does not rely on the `git` command, if you don't have `git` installed then the Ruby HTTP library is used to download compressed archives.

To use Ray you need `git` or `tar` installed in addition to the normal Radiant stack; Windows users probably need one of those "unixy" environment things since Ray does occasionally call out to system tools (I really don't know about Windows though). Ray **only** supports the `git` <abbr title="Source Code Management">SCM</abbr>; although I'd happily accept a patch that used `git`'s tools to access CVS, SVN or whatever else it can handle. If you need to install extensions from other sources you should use Radiant's built-in `script/extension install` command which can handle a wide variety of installation types.

Table of contents
=================

<ol>
  <li><a href="http://wiki.github.com/johnmuhl/radiant-ray-extension/installation">Installation</a></li>
  <li><a href="http://wiki.github.com/johnmuhl/radiant-ray-extension/bugs-feature-requests">Bugs &amp; feature requests</a></li>
  <li><a href="http://wiki.github.com/johnmuhl/radiant-ray-extension/usage">Usage</a>
    <ol>
      <li><a href="http://wiki.github.com/johnmuhl/radiant-ray-extension/usage#ext-install">Installing extensions</a></li>
      <li><a href="http://wiki.github.com/johnmuhl/radiant-ray-extension/usage#ext-search">Searching for extensions</a></li>
      <li><a href="http://wiki.github.com/johnmuhl/radiant-ray-extension/usage#ext-disable">Disabling extensions</a></li>
      <li><a href="http://wiki.github.com/johnmuhl/radiant-ray-extension/usage#ext-enable">Enabling extensions</a></li>
      <li><a href="http://wiki.github.com/johnmuhl/radiant-ray-extension/usage#ext-uninstall">Uninstalling extensions</a></li>
      <li><a href="http://wiki.github.com/johnmuhl/radiant-ray-extension/usage#ext-bundle">Bundling extensions</a></li>
    </ol>
  </li>
  <li><a href="http://wiki.github.com/johnmuhl/radiant-ray-extension/extension-dependencies">Extension dependencies</a></li>
  <li><a href="http://wiki.github.com/johnmuhl/radiant-ray-extension/advanced-usage">Advanced usage</a>
    <ol>
      <li><a href="http://wiki.github.com/johnmuhl/radiant-ray-extension/advanced-usage#setup-download">Download preference setup</a></li>
      <li><a href="http://wiki.github.com/johnmuhl/radiant-ray-extension/advanced-usage#setup-restart">Server restart preference setup</a></li>
      <li><a href="http://wiki.github.com/johnmuhl/radiant-ray-extension/advanced-usage#ext-remote">Adding extension remotes</a></li>
      <li><a href="http://wiki.github.com/johnmuhl/radiant-ray-extension/advanced-usage#ext-pull">Pulling extension remotes</a></li>
    </ol>
  </li>
  <li><a href="http://wiki.github.com/johnmuhl/radiant-ray-extension/legacy-information">Legacy information</a>
    <ol>
      <li><a href="http://wiki.github.com/johnmuhl/radiant-ray-extension/legacy-information#shortcuts-redux">What happened to &#8220;some&#8221; shortcut?</a></li>
      <li><a href="http://wiki.github.com/johnmuhl/radiant-ray-extension/legacy-information#ext-bundle">What changed in <code>extensions.yml</code>?</a></li>
      <li><a href="http://wiki.github.com/johnmuhl/radiant-ray-extension/legacy-information#shortcuts">What if I don&#8217;t like the new commands?</a></li>
    </ol>
  </li>
</ol>

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

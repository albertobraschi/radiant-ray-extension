Hello, my name is Ray.
---

Ray is not so much an "extension" to Radiant as it is a collection of `rake` tasks meant to simplify common tasks. Currently, Ray just handles installing and managing extensions.

Installing extensions
---

Under the hood Ray uses `git` to install download extensions from GitHub. This means you'll need to get familiar with the available variables.

####Installation variables

* `name` [extension_name -- required]
* `hub` [github user name -- optional]
* `fullname` [non-standard-extension_name -- requires `hub`]

####Install an extension from the official Radiant repository

The easiest sort of installation is of extensions in the [official Radiant repository][rr]. If you wanted to install the Link Roll extension you would simply run

	rake ray:extension:install name=link-roll

Ray isn't too uptight about how to refer to an extension, so you could also run

	rake ray:extension:install name=link_roll

[rr]: http://github.com/radiant

####Install a regularly named extension from any GitHub user

The next simplest installation is of extensions from authors who have named their extensions like `radiant-extension-name-extension`. If you wanted to install the [Help extension][he] from *saturnflyer* you would run

	rake ray:extension:install name=help hub=saturnflyer

[he]: http://github.com/saturnflyer/radiant-help-extension

####Install any extension from any GitHub user

Finally, you can supply the `name`, `fullname` and `hub` variables to get any extension from any user on GitHub. For example, you can install the [Copy/Move extension][cm] from *pilu* by running

	rake ray:extension:install name=copy-move fullname=radiant-copy-move hub=pilu

You still need to supply the `name` variable so Ray can install the extension into the proper directory.

[cm]: http://github.com/pilu/radiant-copy-move

####Special extensions

#####Page Attachments

Some extensions are downright special and deserve special attention. So far Ray only gives this special attention to the [Page Attachments extension][pa]. If you want to install Page Attachments then you would run

	rake ray:extension:page_attachments

By doing so Ray will grab the required `attachment_fu` plugin and install it to `vendor/plugins` before installing Page Attachments.

The `page_attachments` command comes with an extra variable used to additionally install an image processing library. Without an image processing library Page Attachments won't be able to automatically generate thumbnails when you upload an image. Before you ask Ray to install an image library for you check to see if you already have one installed; often `rmagick` or `mini_magick` will be installed as part of a normal Rails setup. To check which gems you have installed run

	gem list

To install Page Attachments and `mini_magick` run

	rake ray:extensions:page_attachments lib=mini_magick

To install Page Attachments with `rmagick` run

	rake ray:extension:page_attachments lib=rmagick

[pa]: http://github.com/radiant/radiant-page-attachments-extension

Disabling extensions
---

With Ray you can disabling any installed extension by running

	rake ray:extension:disable name=extension_name

Just like with installing, Ray doesn't mind if you prefer

	rake ray:extension:disable name=extension-name

Disabled extensions will be moved to `vendor/extensions_disabled`.

Enabling extensions
---

Enabling extensions is just as easy as disabling

	rake ray:extension:enable name=extension_name

Restarting your application server
---

After you install, enable or disable any extension you need to restart your application server. Currently Ray can only restart a Mongrel cluster or Passenger processes. To have your server restarted run your command as normal and add the `restart` variable

	rake ray:extension:install name=link-roll restart=mongrel_cluster

Or

	rake ray:extension:install name=link-roll restart=passenger


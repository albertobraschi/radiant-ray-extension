Hello, my name is Ray.
---

Ray is not so much an extension to Radiant as it is a collection of `rake` tasks meant to simplify common tasks (or at least reduce typing). Currently, Ray just handles installing and managing extensions.

Installing Ray
---

	pick one
	========
	./script/extension install ray
	git clone git://github.com/johnmuhl/radiant-ray-extension.git vendor/extensions/ray
	wget http://github.com/johnmuhl/radiant-ray-extension/tarball/master

Then restart your server.

Setup
---

###First time user

	rake ray:setup
	==============
	this command completely destroys any existing Ray preferences.
	**DO NOT** use it for upgrading between versions.

###Upgrading user

	rake ray:update

###Resetting your download preference

	rake ray:setup:download

###Resetting your server preference

	pick one
	========
	rake ray:setup:restart server=passenger
	rake ray:setup:restart server=mongrel

Installing extensions
---

Ray uses `git` or the Ruby HTTP library to install extensions from GitHub. You'll need `git` installed and in your `PATH` for Ray to use it. Additionally, if Ray notices that you're managing your Radiant application with `git` then he'll decide to pull extensions in as submodules instead of as clones.

###Installation variables

* `name` [extension_name -- required]
* `hub` [github user name -- optional]
* `fullname` [non-standard-extension_name -- requires `hub`]
* `remote` [add github repository as git remote -- requires `git` as installation method]

###Searching for extensions

If you're just curious what extensions are available you can easily search directly from Ray. Ray can only handle single term searches like,

	rake ray:search term=blog

This is will output the necessary information for installation and a short description of the extensions found. For instance the above search would output something including

	name: import-mephisto
	fullname: radiant-import-mephisto
	hub: martinbtt
	Radiant extension that aids in the process of migrating from the Mephisto...

So to install this extension you would use the command

	rake ray:ext name=import-mephisto fullname=radiant-import-mephisto hub=martinbtt

###Install an extension from the official Radiant repository

The easiest sort of installation is of extensions in the [official Radiant repository][rr]. If you wanted to install the Link Roll extension you would simply run

	rake ray:ext name=link-roll

Ray isn't too uptight about how to refer to an extension, so you could also run

	rake ray:ext name=link_roll

[rr]: http://github.com/radiant

###Install a regularly named extension from any GitHub user

The next simplest installation is of extensions from authors who have named their extensions like `radiant-extension-name-extension`. If you wanted to install the [Tags extension][te] from *jomz* you would run

	rake ray:ext name=tags hub=jomz

[te]: http://github.com/jomz/radiant-tags-extension

###Install any extension from any GitHub user

Finally, you can supply the `name`, `fullname` and `hub` variables to get any extension from any user on GitHub. For example, you can install the [Copy/Move extension][cm] from *pilu* by running

	rake ray:ext name=copy-move fullname=radiant-copy-move hub=pilu

You still need to supply the `name` variable so Ray can install the extension into the proper directory.

[cm]: http://github.com/pilu/radiant-copy-move

###Add github repository as git remote

If you use `git` as installation method and want to merge changes from another github repository, you can add the github repository as git remote to the submodule by supplying the `remote` variable. This enables you to use

    git pull `remotehub` master

from within the submodule directory to merge changes from the remote repository, whereas `remotehub` is the name of the github user where the repository is located at. The format of the `remote` variable must match `remotehub/repository`.

This option is considered to use for extension development and thus uses your clone url `git@github.com:username/repository.git` instead of `git://github.com/username/repository.git, so that you can push changes back to the repository.

###Bulk install extensions from a YAML file

You can create a simple YAML file called `extensions.yml` in your Radiant application's `config` directory and then use

	rake ray:bundle

to install all of those extensions at once. Here is what the `extensions.yml` file would look like to install the Aggregation, Help, Link Roll, Markdown and Page Attachments extensions.

	---
	- name: aggregation
	- name: link-roll
	- name: help`
	  hub: saturnflyer
	- name: markdown
	  hub: johnmuhl
	  lib: rdiscount
	  vendor: markdown_filter
	- name: page_attachments
	  plugin: attachment_fu
	  plugin_repository: technoweenie
	  lib: mini_magick
    - name: blog
      hub: netzpirat
      remote: saturnflyer/radiant-blog-extension

###Special extensions

Some extensions are downright special and deserve special attention.

####Paperclipped

If you want to install the [Paperclipped Asset Manager][pc] extension run

	rake ray:assets

Due to Ray's dumbness and some peculiar practices in the Paperclipped extension you **cannot** use Ray to install Paperclipped as you would other extensions. So you have to install it using this special method.

[pc]: http://github.com/kbingman/paperclipped/tree

####Page Attachments

If you want to install [Page Attachments][pa] then you would run

	rake ray:attachments

By doing so Ray will grab the required `attachment_fu` plugin and install it to `vendor/plugins` before installing Page Attachments.

The `page_attachments` command comes with an extra variable used to additionally install an image processing library. Without an image processing library Page Attachments won't be able to automatically generate thumbnails when you upload an image. Before you ask Ray to install an image library for you check to see if you already have one installed; often `rmagick` or `mini_magick` will be installed as part of a normal Rails setup. To check which gems you have installed run. **If you choose to install an image processing library you'll be asked to enter a system administrator password.**

	gem list

To install Page Attachments and `mini_magick` run

	rake ray:extensions:page_attachments lib=mini_magick

To install Page Attachments with `rmagick` run

	rake ray:extension:page_attachments lib=rmagick

[pa]: http://github.com/radiant/radiant-page-attachments-extension

####Markdown Filter (RDiscount version)

To install the RDiscount version of the Markdown filter run

	rake ray:markdown

This will install the RDiscount gem, then the new Markdown filter. If you have trouble getting the new Markdown filter to load in Radiant < 0.6.8 check [the installation section on this page][tp] (you should see "(RDiscount)" in the extension description)

[tp]: http://github.com/johnmuhl/radiant-markdown-extension/tree/master

####Help Extension

Every single extension should come with documentation ready to be absorbed by the [Help extension][hp]; Ray does. To install the Help extension simply run

	rake ray:help

[hp]: http://github.com/saturnflyer/radiant-help-extension/tree/master

Disabling extensions
---

With Ray you can disabling any installed extension by running

	rake ray:dis name=extension_name

Just like with installing, Ray doesn't mind if you prefer

	rake ray:dis name=extension-name

Disabled extensions will be moved to `vendor/ray/disabled_extensions`.

Enabling extensions
---

Enabling extensions is just as easy as disabling

	rake ray:en name=extension_name

Removing extensions
---

Removing an extension is a little different than disabling in that remove will try to revert any migrations the extension added. Removed extensions end up in `vendor/ray/removed_extensions`. To remove an extension run

	rake ray:rm name=extension-name

Restarting your application server
---

After you install, enable or disable any extension you need to restart your application server. Currently Ray can only restart a Mongrel cluster or Passenger processes. To have your server restarted run your command as normal and add the `restart` variable

	rake ray:ext name=link-roll restart=mongrel

Or

	rake ray:ext name=link-roll restart=passenger

Even better though is setting up a server preference file and letting Ray do the typing for you. To setup this file run the command the corresponds to your server:

	rake ray:setup:restart server=mongrel
	rake ray:setup:restart server=passenger

And now every time you install, remove, disable or enable an extension your server will be restarted automatically upon completion. Additionally you can use the restart task as a standalone command like,

	rake ray:restart
	===
	or (if you didn't set a preference)
	===
	rake ray:restart server=passenger

Installing the edge Radiant
---

Ray differs slightly from the bundled `rake radiant:freeze:edge` in a couple of ways, most notably

* Installs Edge Radiant as a Git submodule or clone (just like extensions)
* Can fallback on HTTP when Git is unavailable

To grab Edge Radiant with Ray you just run

	rake ray:edge

Ray will pull down the latest version or update your existing `vendor/radiant` to the latest. When using the HTTP method smart updates are not possible and Ray just grabs the latest version and replaces your current version (even if the two are the same).

If you decide Edge is not for you and want to revert back to your gem instance version run

	rake ray:instance

If your `vendor/radiant` was a Git submodule you'll need to commit the submodule changes manually after running the `ray:instance` command (Ray will do the `git rm --cached vendor/radiant` part but won't push commits into your git repo).

"Legacy" Information
---

Users of previous versions may notice that the commands have changed. While this appears to be the case it's not actually. All the same old commands are available, so if you got comfortable with `rake ray:extension:install name=mailer` and don't want to switch to `rake ray:ext name=mailer` you can keep right on using the long versions.
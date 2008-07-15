Totally alpha
===

I just started this and it's incredibly rough. You can install and disable/enable extensions from github as long as the extension is named like `radiant-extension-name-extension`.

It says some stuff about Capistrano and deploying Radiant, but that's all pie in the sky right now. I want installing extensions from github to be solid before I bother with deployment garbage.

Tasks you can use today
---

	# install page_attachments extension and the attachment_fu plugin
	rake ray:extension:page_attachments
	
	# install page_attachments extension, the attachment_fu plugin and mini_magick
	rake ray:extension:page_attachments lib=mini_magick
	
	# from the official Radiant repository
	rake ray:extension:install name=multi_site
	
	# from some other user's repository
	rake ray:extension:install name=markdown HUB=johnmuhl
	
	# from some completely arbritrary github repository
	rake ray:extension:install name=sweet-sauce HUB=bob fullname=sweet-sauce-for-radiant
	
	# restart your Mongrel cluster or Passenger processes after install an extension (or enabling/disabling)
	rake ray:extension:install name=mailer restart=mongrel_cluster
	
	# disable an installed extension
	rake ray:extension:disable name=multi-site
	
	# enable a disabled extension
	rake ray:extension:enable name=multi_site

**Ray** doesn't particularly care if you use `name=multi_site` or `name=multi-site`. The `HUB=github_user_name ` needs to be the exact user name.

The `extension:disable` command just moves extensions to `vendor/extensions_disabled` until there is a real way to disable extensions.
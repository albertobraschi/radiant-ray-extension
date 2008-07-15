Totally alpha
===

I just started this and it's incredibly rough. You can install and disable/enable extensions from github as long as the extension is named like `radiant-extension-name-extension`.

It says some stuff about Capistrano and deploying Radiant, but that's all pie in the sky right now. I want installing extensions from github to be solid before I bother with deployment garbage.

Also, I'll probably downcase all the variable names later on so don't get too comfy with those `ALLCAP=` things.

Tasks you can use today
---

	# from the official Radiant repository
	rake ray:install NAME=multi_site
	
	# from some other user's repository
	rake ray:install NAME=markdown HUB=johnmuhl
	
	# disable an installed extension
	rake ray:disable NAME=multi-site
	
	# enable a disabled extension
	rake ray:enable NAME=multi_site

**Ray** doesn't particularly care if you use `NAME=multi_site` or `NAME=multi-site`. The `HUB=github_user_name ` needs to be the exact user name.

The `:disable` command just moves extensions to `vendor/extensions_disabled` until there is a real way to disable extensions.
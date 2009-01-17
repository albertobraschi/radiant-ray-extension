For complete documentation refer to [Ray's GitHub page](http://johnmuhl.github.com/radiant-ray-extension)

---

Usage
---

        # install an extension
    rake ray:ext name=extension_name
    
    # search for an extension
    rake ray:search term=search
    
    # disable an extension
    rake ray:dis name=extension_name
    
    # enable an extension
    rake ray:en name=extension_name
    
    # uninstall an extension
    rake ray:rm name=extension_name
    
    # setup server auto-restart for a mongrel_cluster
    rake ray:setup:restart server=mongrel
    
    # setup server auto-restart for passenger
    rake ray:setup:restart server=passenger
    
    # update your download preference
    rake ray:setup:download
    
    # setup a remote tracking branch
    rake ray:extension:remote name=extension_name remote=other_user
    
    # update an extension's remote branches
    rake ray:extension:pull name=extension_name
    
    # update all extension's remote branches
    rake ray:extension:pull
    
    # view all available extensions
    rake ray:extension:all

Bugs & feature requests
---

Bug reports and feature requests can be created at [Ray's Lighthouse page][lh]. When filing bugs please include your Radiant and Ray versions, and if appropriate the GitHub URL of the extension you're having trouble with. *Don't forget to add yourself to the watchers list on tickets you file in case I need to follow up*.

[lh]: http://jmm.lighthouseapp.com/projects/23552/home

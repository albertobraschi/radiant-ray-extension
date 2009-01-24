# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application'

class RayExtension < Radiant::Extension
  version "2.0b4"
  description "In Flux."
  url "http://wiki.github.com/johnmuhl/radiant-ray-extension"
  
  # define_routes do |map|
  #   map.connect 'admin/ray/:action', :controller => 'admin/ray'
  # end
  
  def activate
    # admin.tabs.add "Ray", "/admin/ray", :after => "Layouts", :visibility => [:admin]
  end
  
  def deactivate
    # admin.tabs.remove "Ray"
  end
  
end
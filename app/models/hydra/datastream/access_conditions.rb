require 'active_fedora'

# Datastream that uses a Generic MODS Terminology;  essentially an exemplar.
# this class will be renamed to Hydra::Datastream::ModsBasic in Hydra 5.0
module Hydra
  module Datastream
    class AccessConditions < ActiveFedora::NokogiriDatastream
	
	  set_terminology do |t|
	    t.root(:path=>"schema")
		t.object(:path=>"object") {
		  t.digitalFormats(:path=>"digitalFormats",:attributes=>{:type=>"tif"}) {
		    t.rule(:path=>"rule") {
		    }
		  }    
		}		    
	  end
    end
  end
end